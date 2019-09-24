module control(
	input clk,
	input reset,
	input [5:0]Op,
	input [5:0]func,
	input control_stall,
	input control_stall_branch,
	output ALUSrc_out,
	output RegDst_out,
	output [2:0]ALUOp_out,
	output BranchJ_out,
	output BranchB_out,
	output MemRead_out,
	output MemWrite_out,
	output RegWrite_out,
	output MemtoReg_out,
	output RegWrite_out_2,
	output MemRead_out_1
	);
	parameter add = 3'd0, sub = 3'd1, yu = 3'd2, huo = 3'd3, yihuo = 3'd4, huofei = 3'd5, slt = 3'd6, bne = 3'd7;
	parameter LW = 6'b100011, SW = 6'b101011, R = 6'b000000, Iadd = 6'b001000, Iand = 6'b001100, Ior = 6'b001101, Ixor = 6'b001110, Islt = 6'b001010, BEQ = 6'b000100, BNE = 6'b000101, J = 6'b000010;
	//EX control
	wire ALUSrc,RegDst;
	reg [2:0]ALUOp;
	//M control
	wire BranchJ;
	wire BranchB;
	wire MemRead,MemWrite;
	//WB control
	wire RegWrite,MemtoReg;
	
	assign RegDst = (Op == R)? 1 : 0;
	always@(Op or func)
	begin
		if(Op == R)
		begin
			if(func == 6'b100000) ALUOp = add;
			else if(func == 6'b100010) ALUOp = sub;
			else if(func == 6'b100100) ALUOp = yu;
			else if(func == 6'b100101) ALUOp = huo;
			else if(func == 6'b100110) ALUOp = yihuo;
			else if(func == 6'b100111) ALUOp = huofei;
			else if(func == 6'b101010) ALUOp = slt;
		end
		else if(Op == LW || Op == SW) ALUOp = add;
		else if(Op == BEQ) ALUOp = sub;
		else if(Op == BNE) ALUOp = bne;
		else if(Op == J) ALUOp = add;
		else if(Op == Iadd) ALUOp = add;
		else if(Op == Iand) ALUOp = yu;
		else if(Op == Ior) ALUOp = huo;
		else if(Op == Ixor) ALUOp = yihuo;
		else if(Op == Islt) ALUOp = slt;
	end
	assign ALUSrc = (Op == R || Op == BEQ || Op == BNE)? 0 : 1;
	assign BranchB = (Op == BEQ || Op == BNE)? 1:0;
	assign BranchJ = (Op == J)? 1:0;
	assign MemRead = (Op == LW)? 1:0;
	assign MemWrite = (Op == SW)? 1:0;
	assign RegWrite = (Op == SW || Op == BEQ || Op == J || Op == BNE)? 0:1;
	assign MemtoReg = (Op == LW)? 1:0;
	
	reg ALUSrc_1,RegDst_1;
	reg [2:0]ALUOp_1;
	reg BranchB_1;
	reg MemRead_1,MemWrite_1;
	reg RegWrite_1,MemtoReg_1;
	
	reg MemRead_2,MemWrite_2;
	reg RegWrite_2,MemtoReg_2;
	
	reg RegWrite_3,MemtoReg_3;
	
	always@(negedge clk or posedge reset)
	begin
		if(reset)
		begin
			ALUSrc_1 <= 0;
			RegDst_1 <= 0;
			ALUOp_1 <= 2'd0;
			BranchB_1 <= 0;
			MemRead_1 <= 0;
			MemWrite_1 <= 0;
			RegWrite_1 <= 0;
			MemtoReg_1 <= 0;
			
			MemRead_2 <= 0;
			MemWrite_2 <= 0;
			RegWrite_2 <= 0;
			MemtoReg_2 <= 0;
			
			RegWrite_3 <= 0;
			MemtoReg_3 <= 0;
		end
		else
		begin
			if(control_stall || control_stall_branch)
			begin
				ALUSrc_1 <= 0;
				RegDst_1 <= 0;
				ALUOp_1 <= 2'd0;
				BranchB_1 <= 0;
				MemRead_1 <= 0;
				MemWrite_1 <= 0;
				RegWrite_1 <= 0;
				MemtoReg_1 <= 0;
			end
			else 
			begin
				ALUSrc_1 <= ALUSrc;
				RegDst_1 <= RegDst;
				ALUOp_1 <= ALUOp;
				BranchB_1 <= BranchB;
				MemRead_1 <= MemRead;
				MemWrite_1 <= MemWrite;
				RegWrite_1 <= RegWrite;
				MemtoReg_1 <= MemtoReg;
			end
			
			MemRead_2 <= MemRead_1;
			MemWrite_2 <= MemWrite_1;
			RegWrite_2 <= RegWrite_1;
			MemtoReg_2 <= MemtoReg_1;
			
			RegWrite_3 <= RegWrite_2;
			MemtoReg_3 <= MemtoReg_2;
		end
	end
	
	assign ALUSrc_out = ALUSrc_1;
	assign RegDst_out = RegDst_1;
	assign ALUOp_out = ALUOp_1;
	assign BranchJ_out = BranchJ;
	assign BranchB_out = BranchB_1;
	assign MemRead_out = MemRead_2;
	assign MemWrite_out = MemWrite_2;
	assign RegWrite_out = RegWrite_3;
	assign MemtoReg_out = MemtoReg_3;
	assign RegWrite_out_2 = RegWrite_2;
	assign MemRead_out_1 = MemRead_1;
endmodule