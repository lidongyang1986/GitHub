http://referencedesigner.com/tutorials/verilog/verilog_34.php

// referencedesigner.com 
// 4 bit ring counter example 
module four_bit_ring_counter (
      input clock,
      input reset,
  output [3:0] q
    );
 
  reg[3:0] a;
 
    always @(posedge clock)
      if (reset)
        a = 4'b0001;
 
      else
        begin
        a <=  a<<1; // Notice the blocking assignment
        a[0]<=a[3];
        end
 
    assign q = a;
 
  endmodule
