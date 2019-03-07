//https://blog.csdn.net/Hision_fpgaer/article/details/50831002
//固定优先级仲裁器在FPGA实现与轮询仲裁器类似，唯一不同的是轮询仲裁在每次响应完request后会对优先级进行更新，而固定优先级则不需要此步骤。

//根据当前仲裁器的优先级来响应相应的输入source request，并将source数据输出，代码以输入源为2个为例
always@(posedge clk or posedge rst)
    if (rst)
        sready <= 2'b00;
    else if (cur_state == TIME)
        casex({enabel,svalid,prio})
            4'b1x10 : sready <= 2'b01;
            4'b1100 : sready <= 2'b10;
            4'b11x1 : sready <= 2'b10;
            4'b1011 : sready <= 2'b01;
            default : sready <= 2'b00;
        endcase
		
//更新仲裁器的优先级。		
always @(psoedge clk or posedge rst)
    if (rst)
        prio <= 1'b0;
    else if (cur_state == TIME)
        casex(enable,svalid,prio)
            4'b1x10 : prio <= 1'b1;
            4'b11x1 : prio <= 1'b0;
            default : prio <= prio;
        endcase
		
	
		
//////////////////////////////////
//普通的优先级仲裁
//////////////////////////////////
// simple priority arbiter

always @ (*)
begin
	shift_grant[3:0] = 4'b0;
	if (shift_req[0])	shift_grant[0] = 1'b1;
	else if (shift_req[1])	shift_grant[1] = 1'b1;
	else if (shift_req[2])	shift_grant[2] = 1'b1;
	else if (shift_req[3])	shift_grant[3] = 1'b1;
end

