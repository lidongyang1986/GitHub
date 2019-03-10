https://www.cnblogs.com/lueguo/p/3283594.html

module srl_test(
    input clk,
    input rst,
    input din,
    output dout
    );
reg din_d;


always@(posedge clk) begin
if(rst)
    din_d<=1'b0;
else
    din_d<=din;
end


reg [18:0] d_sh;

always@(posedge clk) begin
    d_sh<={d_sh[17:0],din_d};
end

assign dout=d_sh[18];

endmodule
