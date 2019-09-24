`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/25 21:12:09
// Design Name: 
// Module Name: Forwarding_unit
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

module Forwarding_unit(
	input RegWrite_2,
	input RegWrite_3,
	input [4:0]rs,
	input [4:0]rt,
	input [4:0]reg_WB_2,
	input [4:0]reg_WB_3,
	output reg [1:0]ForwardA,
	output reg [1:0]ForwardB
    );
	wire c1_A,c1_B,c2_A,c2_B;
	assign c1_A = (RegWrite_2==1 && reg_WB_2==rs)? 1:0;
	assign c1_B = (RegWrite_2==1 && reg_WB_2==rt)? 1:0;
	assign c2_A = (RegWrite_3==1 && reg_WB_3==rs && reg_WB_2!=rs)? 1:0;
	assign c2_B = (RegWrite_3==1 && reg_WB_3==rt && reg_WB_2!=rt)? 1:0;
	
	always@(c1_A or c2_A)
	begin
		if(c1_A == 1) ForwardA = 2'b10;
		else if(c2_A == 1) ForwardA = 2'b01;
		else ForwardA = 2'b00;
	end
	
	always@(c1_B or c2_B)
	begin
		if(c1_B == 1) ForwardB = 2'b10;
		else if(c2_B == 1) ForwardB = 2'b01;
		else ForwardB = 2'b00;
	end
	
endmodule
