#set_property PACKAGE_PIN T11 [get_ports rst_n]
#set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
#set_property PACKAGE_PIN U18 [get_ports clk]
#set_property IOSTANDARD LVCMOS33 [get_ports clk]

create_clock -period 20.000 -name clk -waveform {0.000 10.000} [get_ports clk]
# create_clock -period 5.000 -name clk -waveform {0.000 2.500} [get_ports clk]
