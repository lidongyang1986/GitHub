https://www.edaplayground.com/x/3Hfm


module tb;
  bit [1:0] 	abc;
  
  initial begin
    abc = 1;
    
    // First match is executed
    priority case (abc)
      0 : $display ("Found to be 0");
      0 : $display ("Again found to be 0");
      2 : $display ("Found to be 2");
    endcase
  end
endmodule





/////////////////////////////////
https://asic-interview.blogspot.com/2010/04/systemverilog-interview-question-5.html


e.g. Full case, sel=2'b11 will be covered by default statement.
     The x-assignment will also be treated as a don'tcare for synthesis, which may allow the synthesis tool to further optimize the synthesized design. It's the potentially causing a mismatch to occur between simulation and synthesis. To insure that the pre-synthesis and post-synthesis simulations match, the case default could assign the y-output to either a
predetermined constant value, or to one of the other multiplexer input values

module mux3c
(output reg y,
input [1:0] sel,
input a, b, c);
always @*
case (sel)
2'b00: y = a;
2'b01: y = b;
2'b10: y = c;
default: y = 1'bx;
endcase
endmodule

FULL
SystemVerilog use priority modified case statement to solve the full case problem:
e.g.
priority case (...)
...
endcase


  
  
  
  
  
  
  
  

||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
PARALLEL
The unique keyword shall cause the simulator to report a run-time error if a case expression is ever found to match more than one of the case items. In essence, the unique
case statement is a "safe" parallel_case case statement.

unique case (...)
...
default: ...
endcase
