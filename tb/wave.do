add wave -divider #bus#
add wave {sim:/test/clk  } 
add wave {sim:/test/bus_data  } 
add wave {sim:/test/bus_state } 
add wave {sim:/test/bus_stop  } 

add wave -divider ##
add wave {sim:/test/buf_packet_en_out  } 

#add wave -divider #packet_buffer#
#add wave {sim:/test/buf_packet}

run -all
