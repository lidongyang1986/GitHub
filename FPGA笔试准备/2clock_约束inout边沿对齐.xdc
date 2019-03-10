
# Rising Edge System Synchronous Inputs

set input_clock     <clock_name>;   # Name of input clock
set tco_max         0.000;          # Maximum clock to out delay (external device)
set tco_min         0.000;          # Minimum clock to out delay (external device)
set trce_dly_max    0.000;          # Maximum board trace delay
set trce_dly_min    0.000;          # Minimum board trace delay
set input_ports     <input_ports>;  # List of input ports

# Input Delay Constraint
set_input_delay -clock $input_clock -max [expr $tco_max + $trce_dly_max] [get_ports $input_ports];
set_input_delay -clock $input_clock -min [expr $tco_min + $trce_dly_min] [get_ports $input_ports];


///////////////////////////////////////////////////////////////////////////////////////////////////
# Center-Aligned Rising Edge Source Synchronous Inputs 

set input_clock         <clock_name>;      # Name of input clock
set input_clock_period  <period_value>;    # Period of input clock
set dv_bre              0.000;             # Data valid before the rising clock edge
set dv_are              0.000;             # Data valid after the rising clock edge
set input_ports         <input_ports>;     # List of input ports

# Input Delay Constraint
set_input_delay -clock $input_clock -max [expr $input_clock_period - $dv_bre] 	[get_ports $input_ports];
set_input_delay -clock $input_clock -min $dv_are                              		[get_ports $input_ports];



///////////////////////////////////////////////////////////////////////////////////////////////////
# Edge-Aligned Rising Edge Source Synchronous Inputs 
# (Using a direct FF connection)
#

set input_clock         <clock_name>;      # Name of input clock
set input_clock_period  <period_value>;    # Period of input clock
set skew_bre            0.000;             # Data invalid before the rising clock edge
set skew_are            0.000;             # Data invalid after the rising clock edge
set input_ports         <input_ports>;     # List of input ports


# Input Delay Constraint
set_input_delay -clock $input_clock -max [expr $input_clock_period + $skew_are] [get_ports $input_ports];
set_input_delay -clock $input_clock -min [expr $input_clock_period - $skew_bre] [get_ports $input_ports];



















///////////////////////////////////////////////////////////////////////////////////////////////////
# Rising Edge System Synchronous Outputs 


set destination_clock <clock_name>;     # Name of destination clock
set tsu               0.000;            # Destination device setup time requirement
set thd               0.000;            # Destination device hold time requirement
set trce_dly_max      0.000;            # Maximum board trace delay
set trce_dly_min      0.000;            # Minimum board trace delay
set output_ports      <output_ports>;   # List of output ports

# Output Delay Constraint
set_output_delay -clock $destination_clock -max [expr $trce_dly_max + $tsu] [get_ports $output_ports];
set_output_delay -clock $destination_clock -min [expr $trce_dly_min - $thd] [get_ports $output_ports];




///////////////////////////////////////////////////////////////////////////////////////////////////
#  Rising Edge Source Synchronous Outputs 

# Example of creating generated clock at clock output port
# create_generated_clock -name <gen_clock_name> -multiply_by 1 -source [get_pins <source_pin>] [get_ports <output_clock_port>]
# gen_clock_name is the name of forwarded clock here. It should be used below for defining "fwclk".	

set fwclk       	<clock_name>;	# forwarded clock name (generated using create_generated_clock at output clock port)
set fwclk_period 	<period_value>;	# forwarded clock period
set bre_skew 		0.000;			# skew requirement before rising edge
set are_skew 		0.000;			# skew requirement after rising edge
set output_ports 	<output_ports>;	# list of output ports

# Output Delay Constraints
set_output_delay -clock $fwclk -max [expr $fwclk_period - $are_skew] [get_ports $output_ports];
set_output_delay -clock $fwclk -min $bre_skew                        [get_ports $output_ports];



///////////////////////////////////////////////////////////////////////////////////////////////////
#  Rising Edge Source Synchronous Outputs 
#
#  Source synchronous output interfaces can be constrained either by the max data skew
#  relative to the generated clock or by the destination device setup/hold requirements.
#
#  Setup/Hold Case:
#  Setup and hold requirements for the destination device and board trace delays are known.
#  
# forwarded         ____                                                    ___________________ 
# clock                            |_________ ___________|                                             |____________ 
#                                                                                         |
#                                                                               tsu    |    thd
#                                                                    <---------->|<--------->
#                                                              ____________|___________
# data @ destination    XXXXXXXXX________________________XXXXX
#
# Example of creating generated clock at clock output port
# create_generated_clock -name <gen_clock_name> -multiply_by 1 -source [get_pins <source_pin>] [get_ports <output_clock_port>]
# gen_clock_name is the name of forwarded clock here. It should be used below for defining "fwclk".	

set fwclk        <clock-name>;     # forwarded clock name (generated using create_generated_clock at output clock port)        
set tsu          0.000;            # destination device setup time requirement
set thd          0.000;            # destination device hold time requirement
set trce_dly_max 0.000;            # maximum board trace delay
set trce_dly_min 0.000;            # minimum board trace delay
set output_ports <output_ports>;   # list of output ports

# Output Delay Constraints
set_output_delay -clock $fwclk -max [expr $trce_dly_max + $tsu] [get_ports $output_ports];
set_output_delay -clock $fwclk -min [expr $trce_dly_min - $thd] [get_ports $output_ports];

# Report Timing Template
# report_timing -to [get_ports $output_ports] -max_paths 20 -nworst 1 -delay_type min_max -name src_sync_pos_out -file src_sync_pos_out.txt;
		
     














