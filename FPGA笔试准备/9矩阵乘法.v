`timescale 1ns / 1ps  
 // Fixed point 4x4 Matrix Multiplication  
 // fpga4student.com FPGA projects, Verilog projects, VHDL projects
 // Verilog project: Verilog code for fixed point Matrix multiplication 
 module matrix_multiplication(  
           input clk,reset,  
      output [15:0] data_out  
   );  // fpga4student.com FPGA projects, Verilog projects, VHDL projects 
       // Input and output format for fixed point  
      //     |1|<- N-Q-1 bits ->|<--- Q bits -->|  
      // |S|IIIIIIIIIIIIIIII|FFFFFFFFFFFFFFF|  
 wire [15:0] mat_A;  
 wire [15:0] mat_B;  
 wire overflow1,overflow2,overflow3,overflow4;  
 reg wen;  
 reg [15:0]data_in;  
 reg [3:0] addr;  
 reg [4:0] address;  
 reg [15:0] matrixA[3:0][3:0],matrixB[3:0][3:0];  
 //wire [15:0] matrix_output[3:0][3:0];  
 wire [15:0] tmp1[3:0][3:0],tmp2[3:0][3:0],tmp3[3:0][3:0],tmp4[3:0][3:0],tmp5[3:0][3:0],tmp6[3:0][3:0],tmp7[3:0][3:0];  
 reg matrix_transfer_done;
  
      // BRAM matrix A  
      //Matrix_A matrix_A_u (.clka(clk),.addra (addr),.douta(mat_A) );  
      ROM matrix_A_u (.clk(clk),.raddr (addr),.dout(mat_A) );      
      // BRAM matrix B  
      ROM matrix_B_u(.clk(clk), .raddr (addr),.dout(mat_B) );  
      always @(posedge clk or posedge reset)  
      begin  
           if(reset) begin  
                addr <= 0; 
                matrix_transfer_done<=0; 
           end  
           else  
           begin  
                if(addr<15)begin   
                    addr <= addr + 1; 
                    matrix_transfer_done<=0; 
                end
                else  begin
                    addr <= addr; 
                    matrix_transfer_done<=1;                  
                end
                
                matrixA[addr/4][addr-(addr/4)*4] <= mat_A ;  
                matrixB[addr/4][addr-(addr/4)*4] <= mat_B ; 
 

           end  
      end  
      // fpga4student.com FPGA projects, Verilog projects, VHDL projects 
      genvar i,j,k;  
      generate  
      for(i=0;i<4;i=i+1) begin:gen1  
      for(j=0;j<4;j=j+1) begin:gen2 
           // fixed point multiplication  
           qmult #(8,16) mult_u1(.i_multiplicand(matrixA[i][0]),.i_multiplier(matrixB[0][j]),.o_result(tmp1[i][j]),.ovr(overflow1));  
           qmult #(8,16) mult_u2(.i_multiplicand(matrixA[i][1]),.i_multiplier(matrixB[1][j]),.o_result(tmp2[i][j]),.ovr(overflow2));  
           qmult #(8,16) mult_u3(.i_multiplicand(matrixA[i][2]),.i_multiplier(matrixB[2][j]),.o_result(tmp3[i][j]),.ovr(overflow3));  
           qmult #(8,16) mult_u4(.i_multiplicand(matrixA[i][3]),.i_multiplier(matrixB[3][j]),.o_result(tmp4[i][j]),.ovr(overflow4));  
           // fixed point addition  
           qadd #(8,16) Add_u1(.a(tmp1[i][j]),.b(tmp2[i][j]),.c(tmp5[i][j]));  
           qadd #(8,16) Add_u2(.a(tmp3[i][j]),.b(tmp4[i][j]),.c(tmp6[i][j]));  
           qadd #(8,16) Add_u3(.a(tmp5[i][j]),.b(tmp6[i][j]),.c(tmp7[i][j]));  
           //assign matrix_output[i][j]= tmp7[i][j]; 
      end  
      end  
      endgenerate  
      
      
      
      // fpga4student.com FPGA projects, Verilog projects, VHDL projects 
      always @(posedge clk or posedge reset)  
      begin  
           if(reset) begin  
                address <= 0;  
                wen <= 0;
                data_in <=0;  
                end  
           else begin  
                address <= address + 1;  
                if(address<16) begin  
                     wen <= 1;  
                     data_in <= tmp7[address/4][address-(address/4)*4];  
                end  
                else  
                begin  
                     wen <= 0;            
                end  
           end  
      end  
      RAM matrix_out_u(.clk(clk),.addr (address[3:0]),.dout(data_out),.wen(wen),.din(data_in) );  
 endmodule  