`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:10:58 08/15/2016
// Design Name:   cache_top
// Module Name:   D:/DAPU/DAPU_cache_module/cache/src/cache_top_tb.v
// Project Name:  cache
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: cache_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module cache_top_tb;

	// Inputs
	reg clk_2x;
	reg rst_n_2x;
	reg [31:0] in_LBA;
	reg in_update_cache_2x;

	// Outputs


	// Instantiate the Unit Under Test (UUT)
	cache_top uut (
		.clk_2x(clk_2x), 
		.rst_n_2x(rst_n_2x), 
		.in_LBA(in_LBA), 
		.in_update_cache_2x(in_update_cache_2x)

	);

	initial begin
		// Initialize Inputs
		rst_n_2x = 0;
		clk_2x =0;
		in_update_cache_2x<=0;
		in_LBA<=0;
		// Wait 400 ns for global reset to finish
		#100;    
		// Add stimulus here
		rst_n_2x = 1;
		
		#200; 		
		in_update_cache_2x<=1;
		in_LBA<=32'h19860001;
		#10;
		in_update_cache_2x<=0;
		
		#400;
		in_update_cache_2x<=1;
		in_LBA<=32'h07180001;		
		#10;
		in_update_cache_2x<=0;			
	end
	
  // Clock generation  
  
always
    #5 clk_2x = ~clk_2x;  	
		
      
endmodule

