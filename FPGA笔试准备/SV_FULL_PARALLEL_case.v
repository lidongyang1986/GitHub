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
The x-assignment will also be treated as a don'tcare for synthesis, 
which may allow the synthesis tool to further optimize the synthesized design. 
       
It's the potentially causing a mismatch to occur between simulation and synthesis. 
To insure that the pre-synthesis and post-synthesis simulations match, 
the case default could assign the y-output to either a predetermined constant value, 
or to one of the other multiplexer input values
      
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
  
  
  
  
///////////////////////////////////////////////////////////////
  
Another thing to note is that, some values do not match. For example there is no match for 3'b010. 
In such case the previous value is preserved.  
  
casez  (sel)
3'bl0l : A  =  l'bl ;
3'bl??:  A  =  l'bO;
3'bOOO:  A  =  l'bl;
endcase 
  
  
  
FULL
SystemVerilog use priority modified case statement to solve the full case problem:
e.g.
priority case (...)
...
endcase
  
a priority case will cause simulators to add run-time checks that will report a warning for the following condition:
1. If the case expression does not match any of the case item expressions, and there is no default case 

  
  

||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
//http://referencedesigner.com/tutorials/verilog/verilog_21.php
From synthesis point of view, a parallel case statement infers a multiplexing routing network.
A non-parallel case statement usually infers a priority routing network.   
  
PARALLEL
The unique keyword shall cause the simulator to report a run-time error if a case expression is ever found to match more than one of the case items. In essence, the unique
case statement is a "safe" parallel_case case statement.

unique case (...)
...
default: ...
endcase
  
  
unique case causes a simulator to add run-time checks that will report a warning if any of the following conditions are true:
1. More than one case item matches the case expression 
2. No case item matches the case expression, and there is no default case   
Back to the example, because of the unique keyword, synthesis will remove the priority logic.  
  
  /****************************************************/
  https://www.verilogpro.com/systemverilog-unique-priority/
  One of the easiest ways to avoid these unwanted latches is by making a default assignment to the outputs before the case statement.
  
