//https://blog.csdn.net/Hision_fpgaer/article/details/50831002
//�̶����ȼ��ٲ�����FPGAʵ������ѯ�ٲ������ƣ�Ψһ��ͬ������ѯ�ٲ���ÿ����Ӧ��request�������ȼ����и��£����̶����ȼ�����Ҫ�˲��衣

//���ݵ�ǰ�ٲ��������ȼ�����Ӧ��Ӧ������source request������source�������������������ԴΪ2��Ϊ��
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
		
//�����ٲ��������ȼ���		
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
//��ͨ�����ȼ��ٲ�
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

