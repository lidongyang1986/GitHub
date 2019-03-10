https://www.edaplayground.com/x/3Mie

module traffic_light(rst_n,
                            clk,
                            trigger, //触发信号，使得状态机进入循环
                            light1,
                            light2
                                 );
input rst_n;
input clk;
input trigger;

output [3:0] light1;   //4bit分别对应绿、黄、左、红灯
output [3:0] light2;

//灯亮时间
parameter G1_T = 7'd40;  //方向1的亮灯时间
parameter Y1_T = 7'd5;
parameter L1_T = 7'd15;

parameter G2_T = 7'd30;    //方向2的亮灯时间
parameter Y2_T = 7'd5;
parameter L2_T = 7'd15;

//状态编码
parameter IDLE = 4'd0;    //此处为了方便采用简单的binary编码，可用one-hot或gray提高性能
parameter G1 = 4'd1;
parameter Y1_1 = 4'd2;
parameter L1 = 4'd3;
parameter Y1_2 = 4'd4;

parameter G2 = 4'd5;
parameter Y2_1 = 4'd6;
parameter L2 = 4'd7;
parameter Y2_2 = 4'd8;

reg [3:0] cur_state;
reg [3:0] nxt_state;

reg [3:0] light1;
reg [3:0] light2;

reg [3:0] light1_tmp;
reg [3:0] light2_tmp;

reg [6:0] light_t_tmp;
reg [6:0] light_t;

reg change;
reg start;

//状态寄存，时序逻辑
always@(posedge clk)
    if(!rst_n)
        cur_state <= IDLE;
    else
        cur_state <= nxt_state;

//状态转换，组合逻辑        
always@(*)
    if(!rst_n)
        begin
            //start <= 1'b0;
            nxt_state = IDLE;
        end
    else  
        begin
            case(cur_state)
                IDLE : //if(change) 
                        if(trigger)  //状态机通过trigger进入状态循环
                            begin
                                //start <= 1'b1;  //start与计数值light_t_tmp是同步的，因此一同写在输出控制中 
                                nxt_state = G1;  //状态变换由组合逻辑实现，采用阻塞赋值即=，而非<=
                            end
                G1   : if(trigger)  
                            begin
                                //start <= 1'b1;
                                nxt_state = G1;
                            end
                        else if(change)  
                                begin
                                    //start <= 1'b1;
                                    change <= 1'b0;
                                    nxt_state = Y1_1;
                                end
                Y1_1 : if(trigger)  
                            begin
                                //start <= 1'b1;
                                nxt_state = G1;
                            end
                        else if(change)  
                            begin
                                //start <= 1'b1;
                                change <= 1'b0;
                                nxt_state = L1;
                            end
                L1   : if(trigger)  
                            begin
                                //start <= 1'b1;
                                nxt_state = G1;
                            end
                        else if(change)  
                            begin
                                //start <= 1'b1;
                                change <= 1'b0;
                                nxt_state = Y1_2;
                            end
                Y1_2 : if(trigger)  
                            begin
                                //start <= 1'b1;
                                nxt_state = G1;
                            end
                        else if(change)  
                            begin
                                //start <= 1'b1;
                                change <= 1'b0;
                                nxt_state = G2;
                            end
                G2   : if(trigger)  
                            begin
                                //start <= 1'b1;
                                nxt_state = G1;
                            end
                        else if(change)  
                            begin
                                //start <= 1'b1;
                                change <= 1'b0;
                                nxt_state = Y2_1;
                            end
                Y2_1 : if(trigger)  
                            begin
                                //start <= 1'b1;
                                nxt_state = G1;
                            end
                        else if(change)  
                            begin
                                //start <= 1'b1;
                                change <= 1'b0;
                                nxt_state= L2;
                            end
                L2   : if(trigger)  
                            begin
                                //start <= 1'b1;
                                nxt_state = G1;
                            end
                        else if(change)  
                            begin
                                //start <= 1'b1;
                                change <= 1'b0;
                                nxt_state = Y2_2;
                            end
                Y2_2 : if(trigger)  
                            begin
                                //start <= 1'b1;
                                nxt_state = G1;
                            end
                        else if(change)  
                            begin
                                //start <= 1'b1;
                                change <= 1'b0;
                                nxt_state = G1;
                            end
                default : nxt_state = IDLE;
            endcase
        end        
        
//输出控制，组合逻辑
//start与计数值light_t_tmp是同步的，因此一同写在输出控制中 
//always@(posedge clk)   //输出为组合逻辑，因此不在clk下动作
always@(*)
    if(!rst_n)
        begin
            start = 1'b0;
            light_t_tmp = 7'd0;
            light1_tmp = 4'b0000;
            light2_tmp = 4'b0000;
        end
    else case(cur_state)
            G1   : begin
                        start = 1'b1;
                        light_t_tmp = G1_T;
                        light1_tmp = 4'b1000;
                        light2_tmp = 4'b0001;                    
                     end
            Y1_1 : begin
                        start = 1'b1;
                        light_t_tmp = Y1_T;
                        light1_tmp = 4'b0100;
                        light2_tmp = 4'b0001;                
                     end
            L1   : begin
                        start = 1'b1;
                        light_t_tmp = L1_T;
                        light1_tmp = 4'b0010;
                        light2_tmp = 4'b0001;                
                     end
            Y1_2 : begin
                        start = 1'b1;
                        light_t_tmp = Y1_T;
                        light1_tmp = 4'b0100;
                        light2_tmp = 4'b0001;                
                     end
            G2   : begin
                        start = 1'b1;
                        light_t_tmp = G2_T;
                        light1_tmp = 4'b0001;
                        light2_tmp = 4'b1000;                
                     end
            Y2_1 : begin
                        start = 1'b1;
                        light_t_tmp = Y2_T;
                        light1_tmp = 4'b0001;
                        light2_tmp = 4'b0100;                
                     end
            L2   : begin
                        start = 1'b1;
                        light_t_tmp = L2_T;
                        light1_tmp = 4'b0001;
                        light2_tmp = 4'b0010;                
                     end
            Y2_2 : begin
                        start = 1'b1;
                        light_t_tmp = Y2_T;
                        light1_tmp = 4'b0001;
                        light2_tmp = 4'b0100;                
                     end
        endcase

//灯亮时间倒计时
//时序逻辑，要在clk时钟下动作
always@(posedge clk)
    if(!rst_n)
        begin
            light_t <= 7'd0;
        end
    else if(start)
                begin
                    start <= 1'b0;
                    light_t <= light_t_tmp;
                end
         else
            begin
                light_t <= light_t - 1'b1;
            end
            
//在light_t减到2时，置为change信号
//用组合逻辑
always@(*)
    if(!rst_n)
        change <= 1'b0;  
    else if(light_t == 4'd2)
        change <= 1'b1;
        
//输出寄存    
always@(posedge clk)
    if(!rst_n)
        begin
            light1 <= 4'd0;
            light2 <= 4'd0;
        end
    else
        begin
            light1 <= light1_tmp;
            light2 <= light2_tmp;
        end
        
//下面是调试过程中对change以及start的控制    
//因为使用了时序逻辑，导致各种错误
/*
always@(posedge clk)
    if(!rst_n)
        begin
            light_t <= 7'd0;
            //change <= 1'b0;  //复位，开始状态转换
        end
    else if(start)
                begin
                    start <= 1'b0;
                    //change <= 1'b0;
                    //change_r <= 1'b0;
                    light_t <= light_t_tmp;
                end
            //else if(light_t == 4'd1)
            //        change <= 1'b1;
                 else
                    begin
                        light_t <= light_t - 1'b1;
                        //change <= 1'b0;
                    end
*/
            
/*            
always@(*)
    if(!rst_n)
        change = 1'b0;  //复位，开始状态转换
    else if(start)
            change = 1'b0;
        else if(light_t == 4'd1)
        else if(light_t == 4'd2)
            change = 1'b1;        
*/    

endmodule
