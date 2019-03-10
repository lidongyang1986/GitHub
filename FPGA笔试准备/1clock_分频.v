http://referencedesigner.com/tutorials/verilogexamples/verilog_ex_03.php
===============================================================================================
偶数倍2分频：
module frequency_divider_by2 ( clk ,rst,out_clk );
output reg out_clk;
input clk ;
input rst;
always @(posedge clk)
begin
if (~rst)
     out_clk <= 1'b0;
else
     out_clk <= ~out_clk;	
end
endmodule

=============================================================================================
偶数倍4分频：
module clk_div (clk,reset, clk_out);
 
input clk;
input reset;
output clk_out;
 
reg [1:0] r_reg;
wire [1:0] r_nxt;
reg clk_track;
 
always @(posedge clk or posedge reset)
begin
  if (reset)
     begin
        r_reg <= 3'b0;
	clk_track <= 1'b0;
     end
  else if (r_nxt == 2'b10)			//4/2=2
 	   begin
	     r_reg <= 0;
	     clk_track <= ~clk_track;
	   end
  else 
      r_reg <= r_nxt;
end
 
 assign r_nxt = r_reg+1;   	      
 assign clk_out = clk_track;
endmodul


===============================================================================================
Clock Divide by even number 2N 

module clk_div 
#( 
parameter WIDTH = 3, // Width of the register required
parameter N = 6// We will divide by 12 for example in this case
)
(clk,reset, clk_out);
 
input clk;
input reset;
output clk_out;
 
reg [WIDTH-1:0] r_reg;
wire [WIDTH-1:0] r_nxt;
reg clk_track;
 
always @(posedge clk or posedge reset)
 
begin
  if (reset)
     begin
        r_reg <= 0;
	clk_track <= 1'b0;
     end
 
  else if (r_nxt == N)
 	   begin
	     r_reg <= 0;
	     clk_track <= ~clk_track;
	   end
 
  else 
      r_reg <= r_nxt;
end
 
 assign r_nxt = r_reg+1;   	      
 assign clk_out = clk_track;
endmodule



===============================================================================================
3分频
module clk_div3(clk,reset, clk_out);
 
input clk;
input reset;
output clk_out;
 
reg [1:0] pos_count, neg_count;
wire [1:0] r_nxt;
 
always @(posedge clk)
if (reset)
pos_count <=0;
else if (pos_count ==2) pos_count <= 0;
else pos_count<= pos_count +1;
 
always @(negedge clk)
if (reset)
neg_count <=0;
else  if (neg_count ==2) neg_count <= 0;
else neg_count<= neg_count +1;
 
assign clk_out = ((pos_count == 2) | (neg_count == 2));
endmodule




===============================================================================================
奇数倍分频（5分）
module clk_divn #(
parameter WIDTH = 3,
parameter N = 5)
 
(clk,reset, clk_out);
 
input clk;
input reset;
output clk_out;
 
reg [WIDTH-1:0] pos_count, neg_count;
wire [WIDTH-1:0] r_nxt;
 
 always @(posedge clk)
 if (reset)
 pos_count <=0;
 else if (pos_count ==N-1) pos_count <= 0;
 else pos_count<= pos_count +1;
 
 always @(negedge clk)
 if (reset)
 neg_count <=0;
 else  if (neg_count ==N-1) neg_count <= 0;
 else neg_count<= neg_count +1; 
 
assign clk_out = ((pos_count > (N>>1)) | (neg_count > (N>>1))); 
endmodule




===============================================================================================
半分频（3.5分）
module time_adv_half #(
	parameter M = 2,
		WIDTH = 7		//3.5*2
)(
    input clk,
    input rst,
    output reg clk_out
    );

wire clk_cnt;
assign clk_cnt = (clk_vld) ? !clk : clk;

reg [WIDTH : 0]counter;
always @(posedge clk_cnt or posedge rst) begin
	if (rst) begin
		// reset
		counter <= 0;
	end
	else if (counter == M) begin
		counter <= 0;
	end
	else begin
		counter <= counter + 1;
	end
end

reg clk_vld;
always @(posedge clk_out or posedge rst) begin
	if (rst) begin
		// reset
		clk_vld <= 0;
	end
	else begin
		clk_vld <= !clk_vld;
	end
end

always @(posedge clk_cnt or posedge rst) begin
	if (rst) begin
		// reset
		clk_out <= 0;
	end
	else if (counter == M-1) begin
		clk_out <= !clk_out;
	end
	else if (counter == M) begin
		clk_out <= !clk_out;
	end
end

endmodule
--------------------- 
作者：moon9999 
来源：CSDN 
原文：https://blog.csdn.net/moon9999/article/details/75020355/ 
版权声明：本文为博主原创文章，转载请附上博文链接！


