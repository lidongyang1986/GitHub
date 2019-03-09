
module check_par(clk, parity, data);
input clk, parity;
input [31:0] data;

property p_check_par;
  @(posedge clk)  (^(data^parity)) == 1'b0;
endproperty
a_check_par: assert property(p_check_par);
endmodule
  

/*
module dffChecker (clk, rst_, d, q);
parameter WIDTH = 8;
input clk, rst_;
input [WIDTH-1:0] d, q;
property d_q_property_0;
@(posedge clk) !rst_ |->##1 (q == 8'h0);
endproperty
endmodule
*/


module dffChecker (clk, rst_, d, q);
parameter WIDTH = 8;
input clk, rst_;
  
input [WIDTH-1:0] d, q;
  
logic [3:0] delay,a,b;

property assert_check;
  @(posedge clk) disable iff(rst_)
  $rose(a) |-> ##(delay) b == 1;
endproperty : assert_check
  
  
  
endmodule


