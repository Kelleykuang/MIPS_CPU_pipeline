`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/26 14:35:54
// Design Name: 
// Module Name: Hazard_detection_unit
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


module Hazard_detection_unit(
	input MemRead,
	input [4:0]rt_1,
	input [4:0]rs_0,
	input [4:0]rt_0,
	output reg control_stall,
	output reg IRWrite,
	output reg PCWrite
    );
	always@(*)
	begin
		if(MemRead==1 && ((rt_1 == rs_0)||(rt_1 == rt_0)))
		begin
			control_stall = 1;
			IRWrite = 0;
			PCWrite = 0;
		end
		else 
		begin
			control_stall = 0;
			IRWrite = 1;
			PCWrite = 1;
		end
	end
endmodule
