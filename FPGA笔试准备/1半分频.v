//http://referencedesigner.com/tutorials/verilogexamples/verilog_ex_08.php


module clk_divn (clk,reset, clk_out);
 
input clk;
input reset;
output clk_out;
 
reg [8:0]  count;  
reg  ps_count1,ps_count5,ps_count6 ; 
 
/* Counter reset value : 9�b000000001 */
/* count is a  ring counter */
 
always @( posedge clk or negedge reset)
if (!reset)
count[8:0] <= 9'b000000001;
else
begin
count <= count << 1;
count[0] <= count[8];
end
always @(negedge clk or negedge reset)
if (!reset)
begin
ps_count1 <= 1'b0;
ps_count5 <= 1'b0;
ps_count6 <= 1'b0;
end
else
begin
ps_count1 <= count[0];
ps_count5 <= count[4];
ps_count6 <= count[5];
end
 
// Use this Math to generate an this odd clock divider.
 
assign clk_out = (ps_count5 | ps_count6| count[5])|
(count[0] | count[1] | ps_count1);
 
 
endmodule
