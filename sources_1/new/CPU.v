`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/20 20:25:35
// Design Name: 
// Module Name: CPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module ALU(
	input [31:0]ALUa,
	input [31:0]ALUb,
	input [2:0]ALUOp,
	output reg zero,
	output reg [31:0]ALUresult
    );
	reg fc;
	reg [31:0]data;
	parameter add = 3'd0, sub = 3'd1, yu = 3'd2, huo = 3'd3, yihuo = 3'd4, huofei = 3'd5, slt = 3'd6, bne = 3'd7;
	always@(*)
	begin
		if(ALUOp == add)  //加
		begin
			ALUresult = ALUa + ALUb;
			if(ALUresult==0&&fc==0) zero = 1;
			else zero=0;
		end
		else if(ALUOp == sub) //减
		begin
			{fc, ALUresult} = ALUa - ALUb;
			if(ALUresult==0&&fc==0) zero = 1;
			else zero=0;
		end
		else if(ALUOp == yu)  //与
		begin
			ALUresult = ALUa & ALUb;
			if(ALUresult==0) zero=1;
			else zero=0;
		end
		else if(ALUOp == huo) //或
		begin
			ALUresult = ALUa | ALUb;
			if(ALUresult==0) zero=1;
			else zero=0;
		end
		else if (ALUOp == yihuo)  //异或
		begin
			ALUresult = ALUa ^ ALUb;
			if(ALUresult==0) zero=1;
			else zero=0;
		end
		else if(ALUOp == huofei) 
		begin
			ALUresult = ~(ALUa | ALUb);
			if(ALUresult==0) zero=1;
			else zero=0;
		end
		else if(ALUOp == slt)
		begin
			data = ALUa - ALUb;
			if(data[31] == 1) ALUresult = 32'd1;
			else ALUresult = 32'd0;
		end
		else if(ALUOp == bne)
		begin
			{fc, ALUresult} = ALUa - ALUb;
			if(ALUresult==0&&fc==0) zero = 0;
			else zero = 1;
		end
	end
endmodule
module register_file #(parameter m=4,am=31,n=31)(
	input clk,
	input reset,
	input we,
	input [m:0]Write_register,
	input [m:0]Read_register1,
	input [m:0]Read_register2,
	input [m:0]addr,
	input [n:0]Write_data,
	output [n:0]Read_data1,
	output [n:0]Read_data2,
	output [n:0]reg_data
    );
	reg [n:0] reg_file [am:0];
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			reg_file[0]=0;
			reg_file[25] = 0;
		end
		else if(we)
		begin
			reg_file[Write_register]=Write_data;
		end
	end
	assign Read_data1=reg_file[Read_register1];
	assign Read_data2=reg_file[Read_register2];
	assign reg_data=reg_file[addr];
endmodule
module CPU(
	input clk_5M,
	input reset,
	input [7:0]addr,
	input [11:0]data_in,
	input cont,
	input load_in,
	output [31:0]mem_data,
	output [31:0]reg_data,
	output [7:0]out_pc
	);
	parameter add = 3'd0, sub = 3'd1, yu = 3'd2, huo = 3'd3, yihuo = 3'd4, huofei = 3'd5, slt = 3'd6, bne = 3'd7;
	wire clk,clk_mem;
	assign clk = (cont==1)? clk_5M:0;
	assign clk_mem = (cont==1)? clk:load_in;
	
	//EX control
	wire ALUSrc,RegDst;
	wire [2:0]ALUOp,ALUOp_Branch;
	//M control
	wire Branch_B,Branch_J;
	wire MemRead,MemWrite;
	//WB control
	wire RegWrite,MemtoReg;
	wire RegWrite_2,MemRead_1;
	control c1 (.clk(clk),
	.Op(IR[31:26]),
	.func(IR[5:0]),
	.control_stall(control_stall),
	.control_stall_branch(control_stall_branch),
	.ALUSrc_out(ALUSrc),
	.RegDst_out(RegDst),
	.ALUOp_out(ALUOp),
	.BranchB_out(Branch_B),
	.BranchJ_out(Branch_J),
	.MemRead_out(MemRead),
	.MemWrite_out(MemWrite),
	.RegWrite_out(RegWrite),
	.MemtoReg_out(MemtoReg),
	.RegWrite_out_2(RegWrite_2),
	.MemRead_out_1(MemRead_1));
	
	wire [1:0]ForwardA,ForwardB;
	Forwarding_unit f1 (.RegWrite_2(RegWrite_2),
	.RegWrite_3(RegWrite),
	.rs(rs),
	.rt(rt),
	.reg_WB_2(reg_WB_2),
	.reg_WB_3(reg_WB_3),
	.ForwardA(ForwardA),
	.ForwardB(ForwardB));
	
	wire control_stall,IRWrite,PCWrite;
	Hazard_detection_unit h1 (
	.MemRead(MemRead_1),
	.rt_1(rt),
	.rs_0(IR[25:21]),
	.rt_0(IR[20:16]),
	.control_stall(control_stall),
	.IRWrite(IRWrite),
	.PCWrite(PCWrite));
	
	wire IRFlush, control_stall_branch;
	Branch_flush_unit b1 (.Branch_J(Branch_J),.PCSrc(PCSrc),.IRFlush(IRFlush),.control_stall(control_stall_branch));
	//PC
	reg [31:0]PC;
	assign out_pc=PC[9:2];
	wire PCSrc;
	reg [31:0]mux_pc;
	assign PCSrc = Branch_B&zero;
	wire [31:0] Add_pc;
	ALU alu1 (.ALUa(PC),.ALUb(32'd4),.ALUOp(add),.zero(),.ALUresult(Add_pc));
	always@(Add_pc or Addresult or j_addr or PCSrc or Branch_J)
	begin
		if(PCSrc) mux_pc = Addresult;
		else if(Branch_J) mux_pc = j_addr;
		else mux_pc = Add_pc;
	end
	reg [31:0]NPC_0,IR;
	always@(negedge clk or posedge reset)
	begin
		if(reset) PC<=32'd0;
		else
		begin
			if(PCWrite) PC <= mux_pc;
			if(IRWrite)
			begin
				if(IRFlush) IR <= 32'd0;
				else IR <= ins;
				NPC_0 <= Add_pc;
			end
		end
	end
	wire [31:0]ins;
	Instruction_Memory m1 (.a(PC[9:2]),.spo(ins));
	
	//registers
	wire [31:0]Read_data1,Read_data2;
	register_file reg_files (clk,reset,RegWrite,reg_WB_3,IR[25:21],IR[20:16],5'd25,Write_data_reg,Read_data1,Read_data2,reg_data);
	reg [31:0]A,B,Imm,NPC_1;
	reg [4:0]rs,rt,rd;
	wire [31:0]sign_extend,j_addr;
	assign sign_extend = (IR[15]==1)? {16'b1111111111111111,IR[15:0]} : {16'b0000000000000000,IR[15:0]};
	assign j_addr = {NPC_0[31:28],IR[25:0],2'b00};
	always@(negedge clk)
	begin
		NPC_1 <= NPC_0;
		A <= Read_data1;
		B <= Read_data2;
		Imm <= sign_extend;
		rs <= IR[25:21];
		rt <= IR[20:16];
		rd <= IR[15:11];
	end
	
	//ALU
	wire [31:0]Imm_shift2,Addresult;
	assign Imm_shift2 = {Imm[29:0],2'b00};
	ALU alu2 (.ALUa(NPC_1),.ALUb(Imm_shift2),.ALUOp(add),.zero(),.ALUresult(Addresult));
	
	wire [31:0]ALUresult,real_ALUb,zero;
	wire [4:0]rt_rd_mux;
	reg [31:0]ALUOut_2,Write_data,ALUa,ALUb;
	reg [4:0]reg_WB_2;
	
	always@(ForwardA or A or ALUOut_2 or Write_data_reg)
	begin
		if(ForwardA == 2'b00) ALUa = A;
		else if(ForwardA == 2'b01) ALUa = Write_data_reg;
		else if(ForwardA == 2'b10) ALUa = ALUOut_2;
	end
	
	always@(ForwardB or B or ALUOut_2 or Write_data_reg)
	begin
		if(ForwardB == 2'b00) ALUb = B;
		else if(ForwardB == 2'b01) ALUb = Write_data_reg;
		else if(ForwardB == 2'b10) ALUb = ALUOut_2;
	end
	
	assign real_ALUb = (ALUSrc == 1)? Imm:ALUb;
	ALU alu3 (.ALUa(ALUa),.ALUb(real_ALUb),.ALUOp(ALUOp),.zero(zero),.ALUresult(ALUresult));
	assign rt_rd_mux = (RegDst == 1)? rd:rt;
	always@(negedge clk)
	begin
		ALUOut_2 <= ALUresult;
		Write_data <= B;
		reg_WB_2 <= rt_rd_mux;
	end
	
	//Mem
	wire [31:0]Read_data;
	wire [7:0]real_Addr;
	wire [31:0]real_writedata;
	wire real_we;
	assign real_Addr = (cont==1)? ALUOut_2[9:2]:addr;
	assign real_writedata = (cont==1)?  Write_data:{20'd0,data_in};
	assign real_we = (cont==1)? MemWrite:1;
    Data_Memory m2 (.a(real_Addr),.d(real_writedata),.dpra(addr),.clk(~clk_mem),.we(real_we),.spo(Read_data),.dpo(mem_data));
	reg [31:0]MDR,ALUOut_3;
	reg [4:0]reg_WB_3;
	always@(negedge clk)
	begin
		MDR <= Read_data;
		ALUOut_3 <= ALUOut_2;
		reg_WB_3 <= reg_WB_2;
	end

	wire [31:0]Write_data_reg;
	assign Write_data_reg = (MemtoReg == 1)? MDR:ALUOut_3;
endmodule