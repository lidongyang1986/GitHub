`timescale 1ns/1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 	Nanjing Tech University
// Engineer: 	Xu Zhenyu
// 
// Create Date: 2017/09/08 15:52:41
// Design Name: I2C_master
// Module Name: I2C_master
// Project Name: I2C_master
// Target Devices: Artix-7,Zynq-7000
// Tool Versions: Vivado 2017.2
// Description: I2C_master  
//	wr	:high for write
// 	start:posedge for start one transmition
//	done :One Transmition finished,but it cannot mark the transmition succeed.It can be used as data_valid_signal checked
//		together with error
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// !!!clk should be faster than I2C_clk,better 10 times faster!!!
//////////////////////////////////////////////////////////////////////////////////
module I2C_master(
	input clk,
	//input I2C_clk,
	input reset,
	input [23:0]data_in,
	input start,
	input wr,
	output scl,
	inout sda,
	output reg busy,
	output reg done,
	output reg error,
	output reg[7:0]data_out
);
	parameter clkFreq = 100000000;
	parameter I2CFreq = 100000;

	localparam DIV_Val = clkFreq/I2CFreq;
	localparam	Idle	=	8'b1000_0001,
				Send	=	8'b0000_0011,
				Read	=	8'b0000_0111,
				Sending =	8'b0000_1111,
				Reading =	8'b0001_1111,
				S_Done	=	8'b0011_1111,
				R_Done	=	8'b0111_1111,
				WaitEnd	=	8'b0111_1110;
	
	reg [10:0] CLK_DIV;
	reg I2C_clk;
	always @ (posedge clk or posedge reset)
	begin
		if(reset) begin
			CLK_DIV <= 0;
			I2C_clk <= 0;
		end
		else if(CLK_DIV >= DIV_Val)begin
			CLK_DIV <= 0;
			I2C_clk <= ~I2C_clk;
		end
		else begin
			CLK_DIV <= CLK_DIV + 1;
			I2C_clk <= I2C_clk;
		end
	end

	reg [7:0]	Control_SM;
	reg [7:0]	Control_SM_n;
	reg Send_start;
	reg Read_start;
	reg Send_done;
	reg Read_done;
	reg en_r;
	reg _scl;
	reg en_c;
	reg _sda;
	assign scl = en_c?I2C_clk:_scl;
	assign sda = en_r?1'bz:_sda;
	reg [7:0] Count_s;
	reg [7:0] Count_s_n;
	reg [23:0] data;
	reg [2:0] ack_reg;
	reg en_ack;
	wire lock;
	reg [7:0] data_mover;
	reg en_read;
	
	//Control State Machine
	always @ (posedge clk)
	begin
		if(reset)
			Control_SM <= Idle;
		else
			Control_SM <= Control_SM_n;
	end
	
	always @ (*)
	begin
		error = 1'b0;
		case(Control_SM)
		Idle:begin
			busy = 0;
			done = 0;
			Send_start = 0;
			Read_start = 0;
			if(start) begin
				if(wr)
					Control_SM_n = Send;
				else
					Control_SM_n = Read;
			end
			else
				Control_SM_n = Idle;
		end
		Send:begin
			busy = 1;
			done = 0;
			Send_start = 1;
			Read_start = 0;
			Control_SM_n = Sending;
		end
		Read:begin
			busy = 1;
			done = 0;
			Send_start = 0;
			Read_start = 1;
			Control_SM_n = Reading;
		end
		Sending:begin
			busy = 1;
			done = 0;
			Send_start = 1;
			Read_start = 0;
			if(Send_done)
				Control_SM_n = S_Done;
			else
				Control_SM_n = Sending;
		end
		Reading:begin
			busy = 1;
			done = 0;
			Send_start = 0;
			Read_start = 1;
			if(Read_done)
				Control_SM_n = R_Done;
			else
				Control_SM_n = Reading;
		end
		S_Done:begin
			busy = 0;
			done = 0;
			Send_start = 0;
			Read_start = 0;
			Control_SM_n = WaitEnd;
		end
		R_Done:begin
			busy = 0;
			done = 0;
			Send_start = 0;
			Read_start = 0;
			Control_SM_n = WaitEnd;
		end
		WaitEnd:begin
			busy = 0;
			if(ack_reg == 3'b000)
				done = 1;
			else begin
				done = 0;
				error = 1;
			end
			Send_start = 0;
			Read_start = 0;
			if(start)
				Control_SM_n = WaitEnd;
			else
				Control_SM_n = Idle;
		end
		default:begin
			busy = 0;
			done = 0;
			Send_start = 0;
			Read_start = 0;
			Control_SM_n = Idle;
		end
		endcase
	end
	//Control State Machine end
	
	//Save the data in case data_in changes  
	assign lock = Send_start || Read_start;
	always @ (posedge lock)
		data <= data_in;
	
	//Check Acknowledge Signals
	always @ (posedge I2C_clk)
	begin
		if(en_ack)
			ack_reg <= {ack_reg[1:0],sda};
		else
			ack_reg <= ack_reg;
	end
	
	//Save data for output 
	always @ (posedge Read_done)
	begin
		data_out <= data_mover;
	end
	
	//Serial to Parellel
	always @ (posedge I2C_clk)
		if(en_read)
			data_mover <= {data_mover[6:0],sda};
		else
			data_mover <= data_mover;
			
	//Send&Read State Machine
	always @ (negedge I2C_clk)
	begin
		if(Control_SM[7])
			Count_s <= 8'd0;
		else
			Count_s <= Count_s_n;
	end
	
	always @ (*)
	begin
		Count_s_n = Count_s + 1;
		Read_done = 1'b0;
		Send_done = 1'b0;
		en_read = 1'b0;
		case(Count_s)
		8'd0:begin //Idle state
			en_r = 1'b0;_sda = 1'bz;en_c = 1'b0;_scl = 1'b1;en_ack = 1'b0;
			if(Send_start) Count_s_n = 8'd1;
			else if(Read_start) Count_s_n = 8'd101;
			else Count_s_n = 8'd0;
		end
		//Send State
		8'd1:begin
			en_r = 1'b0;_sda = 1'b1;en_c = 1'b0;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd2:begin
			en_r = 1'b0;_sda = 1'b0;en_c = 1'b0;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd3:begin
			en_r = 1'b0;_sda = 1'b0;en_c = 1'b0;_scl = 1'b0;en_ack = 1'b0;
		end
		8'd4:begin
			en_r = 1'b0;_sda = data[23];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd5:begin
			en_r = 1'b0;_sda = data[22];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd6:begin
			en_r = 1'b0;_sda = data[21];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd7:begin
			en_r = 1'b0;_sda = data[20];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd8:begin
			en_r = 1'b0;_sda = data[19];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd9:begin
			en_r = 1'b0;_sda = data[18];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd10:begin
			en_r = 1'b0;_sda = data[17];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd11:begin
			en_r = 1'b0;_sda = data[16];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd12:begin
			en_r = 1'b1;_sda = 1'b1;en_c = 1'b1;_scl = 1'b1;en_ack = 1'b1;
		end
		8'd13:begin
			en_r = 1'b0;_sda = data[15];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd14:begin
			en_r = 1'b0;_sda = data[14];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd15:begin
			en_r = 1'b0;_sda = data[13];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd16:begin
			en_r = 1'b0;_sda = data[12];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd17:begin
			en_r = 1'b0;_sda = data[11];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd18:begin
			en_r = 1'b0;_sda = data[10];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd19:begin
			en_r = 1'b0;_sda = data[9];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd20:begin
			en_r = 1'b0;_sda = data[8];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd21:begin
			en_r = 1'b1;_sda = 1'b1;en_c = 1'b1;_scl = 1'b1;en_ack = 1'b1;
		end
		8'd22:begin
			en_r = 1'b0;_sda = data[7];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd23:begin
			en_r = 1'b0;_sda = data[6];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd24:begin
			en_r = 1'b0;_sda = data[5];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd25:begin
			en_r = 1'b0;_sda = data[4];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd26:begin
			en_r = 1'b0;_sda = data[3];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd27:begin
			en_r = 1'b0;_sda = data[2];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd28:begin
			en_r = 1'b0;_sda = data[1];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd29:begin
			en_r = 1'b0;_sda = data[0];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd30:begin
			en_r = 1'b1;_sda = 1'b1;en_c = 1'b1;_scl = 1'b1;en_ack = 1'b1;
		end
		8'd31:begin
			en_r = 1'b0;_sda = 1'b0;en_c = 1'b0;_scl = 1'b0;en_ack = 1'b0;
		end
		8'd32:begin
			en_r = 1'b0;_sda = 1'b0;en_c = 1'b0;_scl = 1'b0;en_ack = 1'b0;
		end
		8'd33:begin
			en_r = 1'b0;_sda = 1'b0;en_c = 1'b0;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd34:begin
			en_r = 1'b0;_sda = 1;en_c = 1'b0;_scl = 1'b1;en_ack = 1'b0;Send_done = 1'b1;
			Count_s_n = 8'd0;
		end		
		//Read State
		8'd101:begin
			en_r = 1'b0;_sda = 1'b1;en_c = 1'b0;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd102:begin
			en_r = 1'b0;_sda = 1'b0;en_c = 1'b0;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd103:begin
			en_r = 1'b0;_sda = 1'b0;en_c = 1'b0;_scl = 1'b0;en_ack = 1'b0;
		end
		8'd104:begin//DeviceID
			en_r = 1'b0;_sda = data[23];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd105:begin
			en_r = 1'b0;_sda = data[22];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd106:begin
			en_r = 1'b0;_sda = data[21];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd107:begin
			en_r = 1'b0;_sda = data[20];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd108:begin
			en_r = 1'b0;_sda = data[19];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd109:begin
			en_r = 1'b0;_sda = data[18];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd110:begin
			en_r = 1'b0;_sda = data[17];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd111:begin
			en_r = 1'b0;_sda = data[16];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd112:begin
			en_r = 1'b1;_sda = 1'b1;en_c = 1'b1;_scl = 1'b1;en_ack = 1'b1;
		end
		8'd113:begin//Reg ID
			en_r = 1'b0;_sda = data[15];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd114:begin
			en_r = 1'b0;_sda = data[14];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd115:begin
			en_r = 1'b0;_sda = data[13];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd116:begin
			en_r = 1'b0;_sda = data[12];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd117:begin
			en_r = 1'b0;_sda = data[11];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd118:begin
			en_r = 1'b0;_sda = data[10];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd119:begin
			en_r = 1'b0;_sda = data[9];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd120:begin
			en_r = 1'b0;_sda = data[8];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd121:begin
			en_r = 1'b1;_sda = 1'b1;en_c = 1'b1;_scl = 1'b1;en_ack = 1'b1;
		end
		8'd122:begin
			en_r = 1'b0;_sda = 1'b0;en_c = 1'b0;_scl = 1'b0;en_ack = 1'b0;
		end
		8'd123:begin
			en_r = 1'b0;_sda = 1'b1;en_c = 1'b0;_scl = 1'b0;en_ack = 1'b0;
		end
		8'd124:begin
			en_r = 1'b0;_sda = 1'b1;en_c = 1'b0;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd125:begin
			en_r = 1'b0;_sda = 1'b1;en_c = 1'b0;_scl = 1'b1;en_ack = 1'b0;
		end	
		8'd126:begin
			en_r = 1'b0;_sda = 1'b1;en_c = 1'b0;_scl = 1'b1;en_ack = 1'b0;
		end	
		8'd127:begin
			en_r = 1'b0;_sda = 1'b1;en_c = 1'b0;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd128:begin
			en_r = 1'b0;_sda = 1'b0;en_c = 1'b0;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd129:begin
			en_r = 1'b0;_sda = 1'b0;en_c = 1'b0;_scl = 1'b0;en_ack = 1'b0;
		end
		8'd130:begin
			en_r = 1'b0;_sda = data[23];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd131:begin
			en_r = 1'b0;_sda = data[22];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd132:begin
			en_r = 1'b0;_sda = data[21];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd133:begin
			en_r = 1'b0;_sda = data[20];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd134:begin
			en_r = 1'b0;_sda = data[19];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd135:begin
			en_r = 1'b0;_sda = data[18];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd136:begin
			en_r = 1'b0;_sda = data[17];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd137:begin
			en_r = 1'b0;_sda = data[16];en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd138:begin
			en_r = 1'b1;_sda = 1;en_c = 1'b1;_scl = 1'b1;en_ack = 1'b1;Send_done = 1'b0;
		end
		8'd139:begin
			en_r = 1'b1;_sda = 1'b1;en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;en_read  = 1'b1;
		end
		8'd140:begin
			en_r = 1'b1;_sda = 1'b1;en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;en_read  = 1'b1;
		end
		8'd141:begin
			en_r = 1'b1;_sda = 1'b1;en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;en_read  = 1'b1;
		end
		8'd142:begin
			en_r = 1'b1;_sda = 1'b1;en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;en_read  = 1'b1;
		end
		8'd143:begin
			en_r = 1'b1;_sda = 1'b1;en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;en_read  = 1'b1;
		end
		8'd144:begin
			en_r = 1'b1;_sda = 1'b1;en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;en_read  = 1'b1;
		end
		8'd145:begin
			en_r = 1'b1;_sda = 1'b1;en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;en_read  = 1'b1;
		end
		8'd146:begin
			en_r = 1'b1;_sda = 1'b1;en_c = 1'b1;_scl = 1'b1;en_ack = 1'b0;en_read  = 1'b1;
		end
		8'd147:begin
			en_r = 1'b1;_sda = 1'b0;en_c = 1'b1;_scl = 1'b0;en_ack = 1'b0;
		end
		8'd148:begin
			en_r = 1'b0;_sda = 1'b0;en_c = 1'b0;_scl = 1'b0;en_ack = 1'b0;
		end
		8'd149:begin
			en_r = 1'b0;_sda = 1'b0;en_c = 1'b0;_scl = 1'b0;en_ack = 1'b0;
		end
		8'd150:begin
			en_r = 1'b0;_sda = 1'b0;en_c = 1'b0;_scl = 1'b1;en_ack = 1'b0;
		end
		8'd151:begin
			en_r = 1'b0;_sda = 1'b1;en_c = 1'b0;_scl = 1'b1;en_ack = 1'b0;Read_done = 1'b1;
			Count_s_n = 8'd0;
		end
		default:begin
			en_r = 1'b0;_sda = 1'bz;en_c = 1'b0;_scl = 1'b1;en_ack = 1'b0;
		end
		endcase
	end
	

	
			

endmodule