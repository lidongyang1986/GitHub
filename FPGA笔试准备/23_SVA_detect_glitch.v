import uvm_pkg::*; `include "uvm_macros.svh" 
module top; 
	timeunit 1ns; timeprecision 100ps; 
	bit clk, a, b, signal;  
	default clocking @(posedge clk); endclocking
	initial forever #10 clk=!clk;
	realtime duration=45.0ns; 
 
  property glitch_p;
    realtime first_change;
    // realtime duration = 10;
   @(signal)  // pos and neg edge 
      // detecting every 2 changes duration
     (1, first_change = $realtime) |=> (($realtime - first_change) >= duration); // [*1:$];
  endproperty
  ap_glitch_p: assert property(glitch_p);  
 
  always_ff  @(posedge clk)  begin 
 end 
 
 initial begin 
     repeat(200) begin 
       @(posedge clk);   
       if (!randomize(signal)  with 
           { signal dist {1'b1:=1, 1'b0:=3};
             b dist {1'b1:=1, 1'b0:=2};
 
           }) `uvm_error("MYERR", "This is a randomize error")
       end 
       $stop; 
    end 
endmodule  
