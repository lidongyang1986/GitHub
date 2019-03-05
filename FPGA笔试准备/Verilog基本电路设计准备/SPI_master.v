`timescale 1ns/1ns
module SPI_master(
	//PL IOs
	input clk,					//系统时钟，用于状态更新，需远快于SPI时钟
	input reset,				//复位
	input SPI_clk,				//SPI时钟
	input start,				//开始
	input wr,					//读写，1写，0读
	input [7:0]address,			//操作寄存器地址
	input [7:0]data_in,			//写入时写入的数据
	output reg [7:0]data_out,	//所读数据
	output reg done,			//完成
	output reg busy,			//繁忙
	//moudle IOs
	output CS,
	output SCLK,
	output SDO,
	input SDI
);
	//指令参数
	parameter Tx_Command = 8'h0a;
	parameter Rx_Command = 8'h0b;
	
	//状态定义
	localparam	Idle	=	8'b1000_0001,//空闲
				Send	=	8'b0000_0011,//准备发送
				Read	=	8'b0000_0111,//准备接收
				Sending =	8'b0000_1111,//发送中
				Reading =	8'b0001_1111,//接收中
				S_Done	=	8'b0011_1111,//发送完毕
				R_Done	=	8'b0111_1111,//接收完毕
				WaitEnd	=	8'b0111_1110;//等待结束
				
	reg en_scl;						//允许时钟输出
	reg en_r;						//允许读数据，移位寄存器使能
	reg sda;						//就是SDO，单纯为了方便，不影响
	reg cs_n;						//就是CS，单纯为了方便，不影响
	reg [23:0]data;					//待传输数据存储器
	reg [7:0]Control_SM,Control_SM_n;//状态寄存器
	reg [7:0]data_mover;			//移位寄存器
	reg Tx_start;					//发送开始
	reg Rx_start;					//读取开始
	reg Tx_done;					//发送完成	
	reg Rx_done;					//读取完成
	
	wire lock;						//将所有输入数据保存，防止发送过程中被更改
	assign CS = cs_n;
	assign SDO = sda;
	assign SCLK = en_scl?SPI_clk:1'b0;//不使能时钟时，将时钟拉低，否则输出spi时钟
	assign lock = Tx_start || Rx_start;//当传输开始时，生成lock信号，保存数据
	
	//锁存数据
	always @ (posedge lock)
		if(wr)
			data <= {Tx_Command,address,data_in};
		else
			data <= {Rx_Command,address,data_in};
	
	//移位寄存器，当读取使能时，每个SPIclk上升沿移位一次，将输入数据保存
	always @ (posedge SPI_clk)
		if(en_r)
			data_mover <= {data_mover[6:0],SDI};																//！！！！！！！！！！！！！！！！！！注意主要的读取过程
		else
			data_mover <= data_mover;
		
	//读取结束时，把移位寄存器数据保存到输出寄存器，保证数据正确
	always @ (posedge Rx_done)
		data_out <= data_mover;
	
	//控制器状态机，第一段，状态刷新模块
	always @ (posedge clk or posedge reset)
	begin
		if(reset)
			Control_SM <= Idle;
		else
			Control_SM <= Control_SM_n;
	end
	
	//控制状态机第二段，逻辑块
	always @ (*)
	begin
		case(Control_SM)
		Idle:begin//空闲时等待start，根据wr决定下一状态
			busy = 0;
			done = 0;
			Tx_start = 0;
			Rx_start = 0;
			if(start) begin
				if(wr)
					Control_SM_n = Send;
				else
					Control_SM_n = Read;
			end
			else
				Control_SM_n = Idle;
		end
		Send:begin//准备发送，产生Tx_start高电平
			busy = 1;
			done = 0;
			Tx_start = 1;
			Rx_start = 0;
			Control_SM_n = Sending;
		end
		Read:begin//准备发送，产生Rx_start高电平
			busy = 1;
			done = 0;
			Tx_start = 0;
			Rx_start = 1;
			Control_SM_n = Reading;
		end
		Sending:begin//发送中，等待Tx_Done
			busy = 1;
			done = 0;
			Tx_start = 1;
			Rx_start = 0;
			if(Tx_done)
				Control_SM_n = S_Done;
			else
				Control_SM_n = Sending;
		end
		Reading:begin//发送中，等待Rx_Done
			busy = 1;
			done = 0;
			Tx_start = 0;
			Rx_start = 1;
			if(Rx_done)
				Control_SM_n = R_Done;
			else
				Control_SM_n = Reading;
		end
		S_Done:begin//发送完成，等慢速状态机归0后再继续
			busy = 0;
			done = 0;
			Tx_start = 0;
			Rx_start = 0;
			if(SMC == 8'd0)
				Control_SM_n = WaitEnd;
			else
				Control_SM_n = S_Done;
		end
		R_Done:begin//接收完成，等慢速状态机归0后再继续
			busy = 0;
			done = 0;
			Tx_start = 0;
			Rx_start = 0;
			if(SMC == 8'd0)
				Control_SM_n = WaitEnd;
			else
				Control_SM_n = R_Done;
		end
		WaitEnd:begin//等待start结束，防止重复传输，同时保持done信号，供上位机使用
			busy = 0;
			done = 1;
			Tx_start = 0;
			Rx_start = 0;
			if(start)
				Control_SM_n = WaitEnd;
			else
				Control_SM_n = Idle;
		end
		default:begin
			busy = 0;
			done = 0;
			Tx_start = 0;
			Rx_start = 0;
			Control_SM_n = Idle;
		end
		endcase
	end
	
	//发送时序状态机寄存器
	reg [7:0]SMC,SMC_n;
	
	//下降沿触发（spi时序，下降沿改变数据），发送状态机第一段
	always @ (negedge SPI_clk)
	begin
		if(Control_SM[7])//只有控制状态机为Idle时此位为高
			SMC <= 8'd0;
		else
			SMC <= SMC_n;
	end
	
	//发送状态机第二段
	always @ (*)
	begin
		//默认值设定
		Tx_done = 1'b0;
		Rx_done = 1'b0;
		SMC_n = SMC + 1'b1;
		case(SMC)
		8'd0:begin//空闲，，等待Tx_start或者Rx_start,并准入不同的发送时序中
			en_scl = 1'b0;en_r = 1'b0;sda = 1'bz;cs_n = 1'b1;
			if(Tx_start) SMC_n = 8'd1;
			else if(Rx_start) SMC_n = 8'd100;//读时序从100开始
			else SMC_n = 8'd0;
		end
		8'd1:begin//spi时序开始，使能时钟，cs拉低，写状态不允许读，数据为待发送的最高位
			en_scl = 1'b1;en_r = 1'b0;sda = data[23];cs_n = 1'b0;
		end
		8'd2:begin//依次发送
			en_scl = 1'b1;en_r = 1'b0;sda = data[22];cs_n = 1'b0;
		end
		8'd3:begin//依次发送
			en_scl = 1'b1;en_r = 1'b0;sda = data[21];cs_n = 1'b0;
		end
		8'd4:begin//依次发送
			en_scl = 1'b1;en_r = 1'b0;sda = data[20];cs_n = 1'b0;
		end
		8'd5:begin//依次发送
			en_scl = 1'b1;en_r = 1'b0;sda = data[19];cs_n = 1'b0;
		end
		8'd6:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[18];cs_n = 1'b0;
		end
		8'd7:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[17];cs_n = 1'b0;
		end
		8'd8:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[16];cs_n = 1'b0;
		end
		8'd9:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[15];cs_n = 1'b0;
		end
		8'd10:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[14];cs_n = 1'b0;
		end
		8'd11:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[13];cs_n = 1'b0;
		end
		8'd12:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[12];cs_n = 1'b0;
		end
		8'd13:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[11];cs_n = 1'b0;
		end
		8'd14:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[10];cs_n = 1'b0;
		end
		8'd15:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[9];cs_n = 1'b0;
		end
		8'd16:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[8];cs_n = 1'b0;
		end
		8'd17:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[7];cs_n = 1'b0;
		end
		8'd18:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[6];cs_n = 1'b0;
		end
		8'd19:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[5];cs_n = 1'b0;
		end
		8'd20:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[4];cs_n = 1'b0;
		end
		8'd21:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[3];cs_n = 1'b0;
		end
		8'd22:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[2];cs_n = 1'b0;
		end
		8'd23:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[1];cs_n = 1'b0;
		end
		8'd24:begin//依次发送
			en_scl = 1'b1;en_r = 1'b0;sda = data[0];cs_n = 1'b0;
		end
		8'd25:begin//关闭时钟使能，取消片选CS
			en_scl = 1'b0;en_r = 1'b0;sda = 1'bz;cs_n = 1'b1;
		end
		8'd26:begin//产生Tx_done高电平，并回归初始状态
			en_scl = 1'b0;en_r = 1'b0;sda = 1'bz;cs_n = 1'b1;Tx_done = 1;SMC_n = 8'd0;
		end
		8'd100:begin//读取开始，先发送高16位，cmd和addr
			en_scl = 1'b1;en_r = 1'b0;sda = data[23];cs_n = 1'b0;
		end
		8'd101:begin//依次发送
			en_scl = 1'b1;en_r = 1'b0;sda = data[22];cs_n = 1'b0;
		end
		8'd102:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[21];cs_n = 1'b0;
		end
		8'd103:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[20];cs_n = 1'b0;
		end
		8'd104:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[19];cs_n = 1'b0;
		end
		8'd105:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[18];cs_n = 1'b0;
		end
		8'd106:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[17];cs_n = 1'b0;
		end
		8'd107:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[16];cs_n = 1'b0;
		end
		8'd108:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[15];cs_n = 1'b0;
		end
		8'd109:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[14];cs_n = 1'b0;
		end
		8'd110:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[13];cs_n = 1'b0;
		end
		8'd111:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[12];cs_n = 1'b0;
		end
		8'd112:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[11];cs_n = 1'b0;
		end
		8'd113:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[10];cs_n = 1'b0;
		end
		8'd114:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[9];cs_n = 1'b0;
		end
		8'd115:begin
			en_scl = 1'b1;en_r = 1'b0;sda = data[8];cs_n = 1'b0;
		end
		8'd116:begin//高16位发送完成，开始读取，使能读取信号
			en_scl = 1'b1;en_r = 1'b1;sda = 1'b0;cs_n = 1'b0;
		end
		8'd117:begin//移位寄存中
			en_scl = 1'b1;en_r = 1'b1;sda = 1'b1;cs_n = 1'b0;
		end
		8'd118:begin
			en_scl = 1'b1;en_r = 1'b1;sda = 1'b0;cs_n = 1'b0;
		end
		8'd119:begin
			en_scl = 1'b1;en_r = 1'b1;sda = 1'b1;cs_n = 1'b0;
		end
		8'd120:begin
			en_scl = 1'b1;en_r = 1'b1;sda = 1'b0;cs_n = 1'b0;
		end
		8'd121:begin
			en_scl = 1'b1;en_r = 1'b1;sda = 1'b1;cs_n = 1'b0;
		end
		8'd122:begin
			en_scl = 1'b1;en_r = 1'b1;sda = 1'b0;cs_n = 1'b0;
		end
		8'd123:begin//读取完毕
			en_scl = 1'b1;en_r = 1'b1;sda = 1'b1;cs_n = 1'b0;
		end
		8'd124:begin//读时序结束
			en_scl = 1'b0;en_r = 1'b0;sda = 1'bz;cs_n = 1'b1;
		end
		8'd125:begin//产生Rx_done高电平，回归初始状态
			en_scl = 1'b0;en_r = 1'b0;sda = 1'bz;cs_n = 1'b1;Rx_done = 1;SMC_n = 8'd0;
		end
		default:begin
			en_scl = 1'b0;en_r = 1'b0;sda = 1'bz;cs_n = 1'b1;SMC_n = 8'd0;
		end
		endcase
	end

endmodule