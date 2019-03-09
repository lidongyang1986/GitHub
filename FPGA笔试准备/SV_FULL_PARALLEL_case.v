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
