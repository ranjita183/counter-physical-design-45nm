# ####################################################################

#  Created by Genus(TM) Synthesis Solution 20.11-s111_1 on Wed Jul 22 18:37:23 IST 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design up_dn

create_clock -name "clk" -period 10.0 -waveform {0.0 5.0} [get_ports clk]
set_false_path -from [get_ports rst]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks clk] -add_delay 2.0 [get_ports mode]
set_output_delay -clock [get_clocks clk] -add_delay 2.0 [get_ports {cout[3]}]
set_output_delay -clock [get_clocks clk] -add_delay 2.0 [get_ports {cout[2]}]
set_output_delay -clock [get_clocks clk] -add_delay 2.0 [get_ports {cout[1]}]
set_output_delay -clock [get_clocks clk] -add_delay 2.0 [get_ports {cout[0]}]
set_wire_load_mode "enclosed"
set_clock_uncertainty -setup 0.1 [get_clocks clk]
set_clock_uncertainty -hold 0.1 [get_clocks clk]
