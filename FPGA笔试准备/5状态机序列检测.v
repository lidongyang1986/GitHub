////////////////////////////////////////////////////////////////////////
verilog FSM 

module test
   (
    input      clk,
    input      rst_,
    input      in,
    output reg int
   );

parameter ST_IDLE  = 3'h0, ST_DET_1 = 3'h1, ST_DET_2 = 3'h2, 
          ST_DET_3 = 3'h3, ST_DET_4 = 3'h4, ST_DEFAULT = 3'hx;
reg [2:0] st_cur, st_nxt;

always @(posedge clk or negedge rst_)
   if (~rst_)
      st_cur <= ST_IDLE;
   else
      st_cur <= st_nxt;

always @(*)            
   case (st_cur)
      ST_IDLE : st_nxt = in? ST_DET_1 : ST_IDLE;    // 1
     ST_DET_1 : st_nxt = in? ST_DET_2 : ST_IDLE;    // 1
     ST_DET_2 : st_nxt = in? ST_DET_3 : ST_IDLE;    // 1  
     ST_DET_3 : st_nxt = in? ST_DET_3 : ST_DET_4;   // 0
     ST_DET_4 : st_nxt = in? ST_DET_1 : ST_IDLE;    // 1  
      default : st_nxt = ST_DEFAULT;                
   endcase                
                   
always @(posedge clk or negedge rst_)            
   if (~rst_)
      int <= 1'b0;
   else   
      case (st_cur)
         ST_IDLE : int <= 1'b0;                     // 1
        ST_DET_1 : int <= 1'b0;                     // 1
        ST_DET_2 : int <= 1'b0;                     // 1  
        ST_DET_3 : int <= 1'b0;                     // 0
        ST_DET_4 : int <= in;                       // 1  
         default : int <= 1'bx;                
      endcase                           

endmodule



////////////////////////////////////////////////////////////////////////
systemverilog FSM : https://www.edaplayground.com/x/d5P

module example_FSM(input logic clk,
                   input logic reset,
                   input logic X,
                   output logic Y);
  
  typedef enum logic[2:0] {A, B, C, D, E} State;
  
  State CurState, NextState;
  
  always_ff@(posedge clk)
    if(reset) 	CurState <= A;
    else		CurState <= NextState;
  
  always_comb begin
    case (CurState)
      A: 	if(X)NextState<=B;
      		else NextState<=C;
      
      B: 	if(X)NextState<=D;
      		else NextState<=B; 
      
      C: 	if(X)NextState<=C;
      		else NextState<=E;
      
      D: 	if(X)NextState<=C;
      		else NextState<=E; 
      
      E: 	if(X)NextState<=D;
      		else NextState<=B; 
      
      default: NextState<=A;
    endcase
            
  end
  
  assign Y = (CurState==D |CurState==E );
  
  
endmodule
