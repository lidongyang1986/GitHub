
// simple priority arbiter

always @ (*)

begin

	shift_grant[3:0] = 4'b0;

	if (shift_req[0])	shift_grant[0] = 1'b1;

	else if (shift_req[1])	shift_grant[1] = 1'b1;

	else if (shift_req[2])	shift_grant[2] = 1'b1;

	else if (shift_req[3])	shift_grant[3] = 1'b1;

end






// Referencedesigner.com 
// Priority Encoder Example - Usage of casez
// Verilog Tutorial 
 
module  priory_encoder_casez
(
input wire  [4:1] A,
output reg  [2:0]  pcode 
);
always  @ *
 
casez  (A)
4'b1zzz :
pcode  = 3'b100;
4'b01zz :
pcode  =  3'b011 ;
4'b001z :
pcode  =  3'b010;
4'b0001 :
pcode =  3'b001;
4'b0000  : 
pcode = 3'b000;
endcase
 
endmodule
