module seg_display(
	input [3:0]x,
	output reg [6:0]seg
	);
	always@(*) begin
		case (x)
			0: seg <= 7'b1000000;        
			1: seg <= 7'b1111001;  
           	2: seg <= 7'b0100100;        
           	3: seg <= 7'b0110000;  
           	4: seg <= 7'b0011001;        
           	5: seg <= 7'b0010010;  
           	6: seg <= 7'b0000010;        
           	7: seg <= 7'b1111000;  
           	8: seg <= 7'b0000000;        
           	9: seg <= 7'b0010000;  
          	10: seg <= 7'b0001000;       
          	11: seg <= 7'b0000011;  
          	12: seg <= 7'b1000110;       
          	13: seg <= 7'b0100001;  
          	14: seg <= 7'b0000110;       
          	15: seg <= 7'b0001110;  
		endcase
	end
endmodule
 
module DDU(
	input clk_100M,
	input reset,
	input cont,
	//input step,
	input [11:0]data,
	input load_in,
	//input mem,
	input inc,
	input dec,
	output [15:0]LED,
	output [6:0]seg,     
	output reg [7:0]AN,
	output complete
    );
	wire clk_5M;
	wire [31:0]mem_data,reg_data;
	clk_wiz_0 u (.clk_in1(clk_100M),.clk_out1(clk_5M));
	reg [7:0]addr;
	CPU u1 (.clk_5M(clk_5M),.reset(reset),.out_pc(LED[7:0]),.mem_data(mem_data),.reg_data(reg_data),.addr(addr),.cont(cont),.data_in(data),.load_in(load_in));
	assign LED[15:8] = addr;
	
	parameter s0=3'd0,s1=3'd1,s2=3'd2,s3=3'd3,s4=3'd4;
	reg [2:0]state,nextstate;
	always@(posedge clk_5M or posedge reset)
	begin
		if(reset) state <= s0;
		else state <= nextstate;
	end
	
	always@(state or inc or dec)
	begin
		if(state == s0)
		begin
			if(inc) nextstate = s1;
			else if(dec) nextstate = s3;
			else nextstate = s0;
		end
		else if (state == s1) nextstate = s2;
		else if(state == s2)
		begin
			if(inc) nextstate = s2;
			else nextstate = s0;
		end
		else if(state == s3) nextstate = s4;
		else if(state == s4)
		begin
			if(dec) nextstate = s4;
			else nextstate = s0;
		end
	end
	
	always@(posedge clk_5M or posedge reset)
	begin
		if(reset) addr <= 8'd0;
		else if(state == s1) addr <= addr + 8'd1;
		else if(state == s3) addr <= addr - 8'd1;
	end
	
	reg [3:0]x;
	wire [31:0]display_data;
	//assign display_data = (mem == 1)? mem_data : reg_data;
	assign display_data = mem_data;
	assign complete = (reg_data==0)? 0 : 1;
	seg_display s (.x(x),.seg(seg));
	reg [15:0]cnt2;
	always@(posedge clk_5M)				
	begin
		if(cnt2>=16'd39999) cnt2=16'd0;
		else cnt2=cnt2+16'd1;
	end 
	always@(cnt2)
	begin
		if(cnt2<=16'd5000)
		begin
			AN=8'b11111110;
			x=display_data[3:0];
		end
		else if(cnt2<=16'd10000)
		begin
			AN=8'b11111101;
			x=display_data[7:4];
		end
		else if(cnt2<=16'd15000)
		begin
			AN=8'b11111011;
			x=display_data[11:8];
		end
		else if(cnt2<=16'd20000)
		begin
			AN=8'b11110111;
			x=display_data[15:12];
		end
		else if(cnt2<=16'd25000)
		begin
			AN=8'b11101111;
			x=display_data[19:16];
		end
		else if(cnt2<=16'd30000)
		begin
			AN=8'b11011111;
			x=display_data[23:20];
		end
		else if(cnt2<=16'd35000)
		begin
			AN=8'b10111111;
			x=display_data[27:24];
		end
		else if(cnt2<=16'd40000)
		begin
			AN=8'b01111111;
			x=display_data[31:28];
		end
	end
endmodule