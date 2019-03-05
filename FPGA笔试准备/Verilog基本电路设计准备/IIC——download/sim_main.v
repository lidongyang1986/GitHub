`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: Mario Blunk - electronics & IT engineering
// Engineer: Mario Blunk
//
// Create Date:   10:39:20 09/08/2011
// Design Name:   main
// Module Name:   /home/luno/ise-projects/transceiver/sim_main.v
// Project Name:  transceiver
// Target Device: XC2C384 (Coolrunner 2) 
// Tool versions: Xilinx ISE 10.1.03 (Linux)
// Description: 
//
// Verilog Test Fixture created by ISE for module: main
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module sim_main;

	// Inputs
	reg reset;	// this signal serves as marker in the waveform diagram - no further meaning
	reg scl;

	// Bidirs
	tri1 sda;	// sda is pulled up in real world
	
	// Outputs
	wire [7:0] parallel_data_output_by_slave;	 

	integer serial_data_red_from_slave; // 8 bit number received via I2C bus from slave





	// Instantiate the Unit Under Test (UUT) -> the I2C slave in this case
	I2CslaveWith8bitsIO is1(
		.SDA(sda),
		.SCL(scl),
		.IOout(parallel_data_output_by_slave)
		);






	initial begin
		// Initialize Inputs
		scl = 1;
		release sda;		
		reset = 1;

		// Wait 100 ns for global reset to finish
		#100;
		// Add stimulus here
		
		
		reset = 0; // indicate start of write access in waveform diagram
		#10;
		reset = 1;


		// WRITE ACCESS TO SLAVE
		start;
		#50;
      tx_slave_address_wr(7'h27); // slave address is hard coded in line 19 of UUT
      tx_slave_data(8'h8D); // tx 8Dh to slave
		// slave parallel output should be 8Dh now
		$display("parallel hex data output by slave: %h" , parallel_data_output_by_slave);
		stop;
				
				
		reset = 0; // indicate start of read access in waveform diagram
		#10;
		reset = 1;
		
		
		// READ ACCESS TO SLAVE
		start;
		#50;
		tx_slave_address_rd(7'h27); // slave address is hard coded in line 19 of UUT
      rx_slave_data(serial_data_red_from_slave); // NOTE: data red is equal to data written previously.
																 // data is red from UUT internal register "mem" , not from parallel IO port !
																 // modify line 80 (reg [7:0] mem = 8'h7E;) to change initial data	
		$display("serial hex data red from slave memory register: %h" , serial_data_red_from_slave);
		stop;
		#50;

		reset = 0; // indicate end of simulation
		#10;
		reset = 1;

	end
      
		
		
		
	// tasks
		
		
	task start;
		begin
			//scl and sda are assumed already high;
			#50 force sda = 0;
			#50 scl = 0;
		end
	endtask

	task stop;
		begin
			//scl assumed already low;			
			#50 force sda = 0;
			#50 scl = 1;
			#50 release sda;
			#50;
		end
	endtask

		
	task tx_slave_address_wr;
		//scl and sda are assumed already low;			
		input integer slave_address;
		integer clock_ct;
		integer bit_ptr=7; // first bit to send is MSB of a total of 7 address bits !
		begin // do 7 clock cycles
			for (clock_ct = 0 ; clock_ct < 7 ; clock_ct = clock_ct + 1)
				begin
					#50 force sda = slave_address[bit_ptr]; //NOTE: forcing sda H is no elegant way since sda is of type "tri1"
					bit_ptr = bit_ptr - 1; // be ready for next address bit
					#50 scl = 1;
					#50 scl = 0;
				end
		#50 force sda = 0; //WRITE access requested
		#50 scl = 1;	//do 8th clock cycle 
		#50 scl = 0;

		ackn_cycle;
		end
	endtask


	task tx_slave_address_rd;
		//scl and sda are assumed already low;			
		input integer slave_address;
		integer clock_ct;
		integer bit_ptr=7; // first bit to send is MSB of a total of 7 address bits !
		begin // do 7 clock cycles
			for (clock_ct = 0 ; clock_ct < 7 ; clock_ct = clock_ct + 1)
				begin
					#50 force sda = slave_address[bit_ptr]; //NOTE: forcing sda H is no elegant way since sda is of type "tri1"
					bit_ptr = bit_ptr - 1; // be ready for next address bit
					#50 scl = 1;
					#50 scl = 0;
				end
		#50 force sda = 1; //READ access requested
		#50 scl = 1;	//do 8th clock cycle 
		#50 scl = 0;

		ackn_cycle;
		end
	endtask


	task tx_slave_data;
		//scl and sda are assumed already low;			
		input integer slave_data;
		integer clock_ct;
		integer bit_ptr=8; // first bit to send is MSB of a total of 8 data bits !
		begin // do 8 clock cycles
			for (clock_ct = 0 ; clock_ct < 8 ; clock_ct = clock_ct + 1)
				begin
					#50 force sda = slave_data[bit_ptr]; //NOTE: forcing sda H is no elegant way since sda is of type "tri1"
					bit_ptr = bit_ptr - 1; // be ready for next data bit
					#50 scl = 1;
					#50 scl = 0;
				end

		ackn_cycle;
		end
	endtask
	

	task rx_slave_data;
		//scl assumed already low;			
		//sda assumed already released (H) by previous ackn_cycle
		output [7:0] slave_data;
		integer clock_ct;
		integer bit_ptr=7; // first bit to receive is MSB of a total of 8 data bits !
		begin // do 8 clock cycles
			for (clock_ct = 0 ; clock_ct < 8 ; clock_ct = clock_ct + 1)
				begin
					#50 scl = 1;
					slave_data[bit_ptr] = sda;
					bit_ptr = bit_ptr - 1; // be ready for next data bit
					#50 scl = 0;
				end

		no_ackn_cycle;
		end
	endtask


	task ackn_cycle;
		begin
			#50 release sda;	//ackn from slave expected -> slave drives L on ACK
			#50 scl = 1;	//do 9th clock cycle 
			#50 scl = 0;
			//slave releases sda line now
		end
	endtask

	task no_ackn_cycle;
		begin
			//tx a notackn to slave -> sda remains released (H)
			#50 scl = 1;	//do 9th clock cycle 
			#50 scl = 0;
		end
	endtask

		
endmodule

