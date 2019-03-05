`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: URI
// Engineer: CLARK YAO
// 
// Create Date: 07/14/2017 10:57:47 PM
// Design Name: 
// Module Name: spi_tx_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module spi_tx_module(

        input clk,
        input rst_n,
        input en_config,
        input [12:0]Config_reg_A,
        input [7:0]Config_reg_data,
        output cs_n,
        output sclk,
        output sdio,
        output busy

    );
    
    reg cs_n_reg;
    assign cs_n = cs_n_reg;
    reg sclk_reg;
    assign sclk = sclk_reg;
    reg sdio_reg;
    assign sdio = sdio_reg;
    reg busy_reg;
    assign busy = busy_reg;
    
    parameter Read = 1'b1;
    parameter Write_N = 1'b0;
    parameter single_data = 2'b00; //W[1],W[0] = 2'b00;
    
    reg [7:0]clk_count;
    reg [23:0]data_out_temp;
    reg [11:0]data_count_temp;
    
    reg [1:0]next_state;
    parameter IDLE = 2'd0;
    parameter CS_N = 2'd1;
    parameter DATA = 2'd2;
    parameter END = 2'd3;

//State machine
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		// reset
		current_state <= IDLE;
	end
	else begin
		current_state <= next_state;
	end
end

always @(current_state) begin
	next_state = current_state;
	case(current_state)
	IDLE : begin
		next_state <= en_config ? CS_N : IDLE;
	end

	CS_N : begin
		next_state <= DATA;
	end

	DATA : begin
		next_state <= (clk_count >= 8'd49) ? END : DATA;
	end

	END : begin
	    next_state <= IDLE;
	end

	default : begin
		next_state = IDLE;
	end
	endcase
end
always @ (posedge clk or negedge rst_n) begin
    case (next_state)
    IDLE : begin   
        cs_n_reg <= 1'b1;
        sclk_reg <= 1'b0;
        sdio_reg <= 1'b0;
        busy_reg <= 1'b0;
        clk_count <= 8'd0;
        data_count_temp <= 12'd0;
    end
    CS_N : begin
        clk_count <= 8'd1;
        busy_reg <= 1'b1;
        data_out_temp <=  {Write_N,single_data,Config_reg_A,Config_reg_data};//23'b0_00_000000_10101010_10101010 
        sclk_reg <= 1'b1;//~sclk_reg;
        cs_n_reg <= 1'b1;
        sdio_reg <= 1'b0;
        data_count_temp <= 12'd0;
    end
    DATA : begin
        clk_count <= (clk_count >= 8'd49) ? 8'd0: clk_count + 8'd1;
        sclk_reg <= ~sclk_reg;
        cs_n_reg <=  (clk_count >= 8'd49) ? 1'b1 : 1'b0;
        sdio_reg <=  (clk_count >= 8'd49) ? 1'b0 : data_out_temp[(8'd23 - data_count_temp)];					//！！！！！！！！！！！！！发送环节
        data_count_temp <= clk_count >> 1;
    end
    END : begin
        clk_count <= 8'd0;
        data_out_temp <= 24'd0;
        cs_n_reg <= 1'b1;
        sclk_reg <= 1'b0;
        sdio_reg <= 1'b0;  
        data_count_temp <= 12'd0;
    end
    default : begin
        next_state <= IDLE;
        cs_n_reg <= 1'b1;
        sclk_reg <= 1'b0;
        sdio_reg <= 1'b0;
        busy_reg <= 1'b1;
        clk_count <= 8'd0;
    end
    endcase
end
endmodule
