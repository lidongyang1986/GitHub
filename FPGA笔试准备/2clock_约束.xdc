==========================================================
时钟约束：
create_clock -name <clock_name> -period <period> [get_ports <clock port>]		//
create_clock -period <period> -waveform {<rise_time> <fall_time>} [get_ports <input_port>]


create_generated_clock -name <generated_clock_name> \
                       -source <master_clock_source_pin_or_port> \
                       -multiply_by <mult_factor> \
                       -divide_by <div_factor> \
                       <pin_or_port>

set_clock_groups -asynchronous -group <clock_name_1> -group <clock_name_2>		//# Set two clocks as asynchronous
set_clock_groups -physically_exclusive -group <clock_name_1> -group <clock_name_2>	//物理不相关


set_clock_uncertainty -setup \							//# Add uncertainty on timing paths from clock0 to clock1 for setup analysis only
                      -from [get_clocks <clock0_name>] \
                      -to [get_clocks <clock1_name>] \
                      <uncertainty_value>


==========================================================
输入约束1：
# The delay value is the delay external to the FPGA
# UCF Example: OFFSET = IN 4ns VALID 1.5ns BEFORE clk, assume period is 10ns
# The XDC max delay is 6 and min delay is 2.5

set_input_delay <max delay> -max -clock [get_clocks <clock>] [get_ports <ports>]
set_input_delay <min delay> -min -clock [get_clocks <clock>] [get_ports <ports>]



输入约束2：
# The delay value is the delay external to the FPGA
# UCF Example: OFFSET = IN 6ns BEFORE clock; assume period is 10ns
# The XDC delay is 10 - 6 = 4ns

set_input_delay <delay> -clock [get_clocks <clock>] [get_ports <ports>]


输入约束3：双沿：
set input_clock         <clock_name>;      # Name of input clock
set input_clock_period  <period_value>;    # Period of input clock (full-period)
set dv_bre              0.000;             # Data valid before the rising clock edge
set dv_are              0.000;             # Data valid after the rising clock edge
set dv_bfe              0.000;             # Data valid before the falling clock edge
set dv_afe              0.000;             # Data valid after the falling clock edge
set input_ports         <input_ports>;     # List of input ports

# Input Delay Constraint
set_input_delay -clock $input_clock -max [expr $input_clock_period/2 - $dv_bfe] [get_ports $input_ports];
set_input_delay -clock $input_clock -min $dv_are                                [get_ports $input_ports];
set_input_delay -clock $input_clock -max [expr $input_clock_period/2 - $dv_bre] [get_ports $input_ports] -clock_fall -add_delay;
set_input_delay -clock $input_clock -min $dv_afe                                [get_ports $input_ports] -clock_fall -add_delay;








==========================================================
输出约束：
set_output_delay -clock [get_clocks DA_WRT_0] -rise -min -add_delay -1.500 [get_ports {DA_DATA_0[*]}]
set_output_delay -clock [get_clocks DA_WRT_0] -rise -max -add_delay 2.000 [get_ports {DA_DATA_0[*]}]




# Rising Edge System Synchronous Outputs 
#
# A System Synchronous design interface is a clocking technique in which the same 
# active-edge of a system clock is used for both the source and destination device. 
#
# dest                    __________                         __________
# clk   	 ____|                   |__________|
#         	                                                         |
#                  (trce_dly_max+tsu) <---------|
#                                (trce_dly_min-thd) <-|
#                                                         	 __    __
# data   XXXXXXXXXXXXXXXX__DATA__XXXXXXXXXXXXX
#

set destination_clock <clock_name>;     # Name of destination clock
set tsu               0.000;            # Destination device setup time requirement
set thd               0.000;            # Destination device hold time requirement
set trce_dly_max      0.000;            # Maximum board trace delay
set trce_dly_min      0.000;            # Minimum board trace delay
set output_ports      <output_ports>;   # List of output ports

# Output Delay Constraint
set_output_delay -clock $destination_clock -max [expr $trce_dly_max + $tsu] [get_ports $output_ports];
set_output_delay -clock $destination_clock -min [expr $trce_dly_min - $thd] [get_ports $output_ports];



==========================================================
多周期路径和假路径：
set_false_path -from <startpoints> -to <endpoints>
set_multicycle_path <num cycles> -from <startpoints> -to <endpoints>
set_multicycle_path -hold <num cycles> -from <startpoints> -to <endpoints>


set_max_delay <delay> -from <startpoints> -to <endpoints>








==========================================================
SAMSUNG AI题目2:
always@(posedge clk)begin
clk1<=~clk1;
clk1_reg<=clk1;
end

always@(posedge clk1)
clk2<=~clk2;

always@(posedge clk)begin
clk_1syn <= clk1_reg;
clk_2syn <= clk2;
end


==========================================================
SAMSUNG AI题目3:
3.Module A is based on a 1MHz (clk1)
Module B is based on a 333 KHz (clk2)
There is a signal sent from module A to module B.
Provide the timing constraint definitions.

create_clock -period 1000ns -name clk1 -waveform {0.000 500.000}
create_clock -period 3333ns -name clk2 -waveform {0.000 1666.000}
set_clock_groups -asynchronous -groups clk1 -gourps clk2
