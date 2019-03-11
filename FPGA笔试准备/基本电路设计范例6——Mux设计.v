module Mux2_1(out,cntrl,in1,in2);
input cntrl,in1,in2;
output out;
assign out = cntrl ? in1 : in2;
endmodule



module mux_4to1_assign ( input [3:0] a,                 // 4-bit input called a
                         input [3:0] b,                 // 4-bit input called b
                         input [3:0] c,                 // 4-bit input called c
                         input [3:0] d,                 // 4-bit input called d
                         input [1:0] sel,               // input sel used to select between a,b,c,d
                         output [3:0] out);             // 4-bit output based on input sel
 
   // When sel[1] is 0, (sel[0]? b:a) is selected and when sel[1] is 1, (sel[0] ? d:c) is taken
   // When sel[0] is 0, a is sent to output, else b and when sel[0] is 0, c is sent to output, else d
   assign out = sel[1] ? (sel[0] ? d : c) : (sel[0] ? b : a); 
 
endmodule


module mux_4to1_case ( input [3:0] a,                 // 4-bit input called a
                       input [3:0] b,                 // 4-bit input called b
                       input [3:0] c,                 // 4-bit input called c
                       input [3:0] d,                 // 4-bit input called d
                       input [1:0] sel,               // input sel used to select between a,b,c,d
                       output reg [3:0] out);         // 4-bit output based on input sel
 
   // This always block gets executed whenever a/b/c/d/sel changes value
   // When that happens, based on value in sel, output is assigned to either a/b/c/d
   always @ (a or b or c or d or sel) begin
      case (sel)
         2'b00 : out <= a;
         2'b01 : out <= b;
         2'b10 : out <= c;
         2'b11 : out <= d;
      endcase
   end
endmodule
