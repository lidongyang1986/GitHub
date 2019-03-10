module elevator_fsm (//input
        clk,nrst,lamp,
        //output
        state,
        dbg_tflr
);
//input 
input clk;
input nrst;
input [4:0] lamp;
output wire [4:0] state;
output wire [4:0] dbg_tflr;
reg [4:0] cstate,nstate;
reg [4:0] tflr;
parameter FL1 = 5'b00001,
          FL2 = 5'b00010,
          FL3 = 5'b00100,
          FL4 = 5'b01000,
          FL5 = 5'b10000;
assign state = cstate;
assign dbg_tflr = tflr;
//lamp is the request from different floors.
always @(*)
  if (lamp >= FL5) tflr = FL5;
  else if (lamp >= FL4) tflr = FL4;
  else if (lamp >= FL3) tflr = FL3;
  else if (lamp >= FL2) tflr = FL2;
  else if (lamp >= FL1) tflr = FL1;
  else tflr = FL1; 

always @(posedge clk or negedge nrst)
if (~nrst)
    cstate <= FL1;
else
    cstate <= nstate;
//
always @(*)
  case (cstate)
       FL1: begin
             if (tflr != 1) nstate = tflr;
             else nstate = FL1;
       end
       FL2: begin
             if (tflr != 2) nstate = tflr;
             else nstate = FL2;
       end
       FL3: begin
             if (tflr != 3) nstate = tflr;
             else nstate = FL3;
           end
       FL4: begin
             if (tflr != 4) nstate = tflr;
             else  nstate = FL4;
           end
       FL5: begin
             if (tflr != 5) nstate = tflr;
             else nstate = FL5;
       end
       default: nstate = FL1;
  endcase
endmodule


==============================================================================
testbench:
`timescale 1ns/1ps
`define depth  16
`define width  8

module top;
integer  seed = 6;
reg clk,nrst,nrst_d;
reg [4:0] button;
wire [4:0] state;
wire [4:0] dbg_tflr;
always #20 clk =~clk;
initial 
begin
   clk =0;
   nrst=1;
   nrst_d =1;
   #41 nrst =0;
   #85 nrst =1;
   #2000 $finish;
end
always @(posedge clk or negedge nrst)
if (~nrst) button <= #1 1;
else button <= $random;

elevator_fsm fsm_inst(//input
             .clk(clk),
             .nrst(nrst),
             .lamp(button),
            //output
             .state(state),
             .dbg_tflr(dbg_tflr)
);

initial
 begin  

       $dumpfile("dump.vcd");
    	$dumpvars(1); 
 end 
endmodule 


















