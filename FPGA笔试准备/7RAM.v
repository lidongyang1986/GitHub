`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/22/2016 11:46:33 AM
// Design Name: 
// Module Name: asc_encoding_RAM
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


module RAM(
     //input:
     clk,
	 
     wen,
     din,
     addr,
     dout
     );

     parameter   DWIDTH = 16; //数据宽度，请根据实际情况修改
     parameter   AWIDTH = 4;  //地址宽度，请根据实际情况修改

     input  clk;
     input  wen;
     input  [DWIDTH   -1:0] din;      
     input  [AWIDTH   -1:0] addr;      
     output [DWIDTH   -1:0] dout;       

     reg [DWIDTH-1:0] RAM [AWIDTH ** 2 - 1:0];
 
     integer RAM_index;
     initial begin
        for(RAM_index=0; RAM_index<16; RAM_index=RAM_index+1)begin
            RAM[RAM_index] <= RAM_index + 1;
        end
     end
	 
	 
	 always@(posedge clk)begin
		if(wen)RAM[addr]<=din;
	 end
     
     assign dout = RAM[addr];

 endmodule
