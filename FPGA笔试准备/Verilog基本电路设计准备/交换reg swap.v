
//with temporary register
 
always @(posedge clk)
begin
temp = b;
b = a;
temp = a;
end
 
//without temporary register
 
always @(posedge clk)
begin
a<=b;b<=a;
end
