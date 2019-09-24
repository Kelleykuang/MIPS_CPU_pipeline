`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/27 14:47:19
// Design Name: 
// Module Name: Branch_flush_unit
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


module Branch_flush_unit(
	input Branch_J,
	input PCSrc,
	output IRFlush,
	output control_stall
    );
	assign IRFlush = (Branch_J==1 || PCSrc==1)? 1:0;
	assign control_stall = (PCSrc==1)? 1:0;
endmodule
