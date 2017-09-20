`timescale 1 ns/1 ps

`include "../write_pcap_task.sv"
`include "../read_pcap_task.sv"

`define CLK_PERIOD 10 // 10ns

module test;

    //generate clk
    reg clk=0;
    always #(`CLK_PERIOD/2) clk <= ~clk;
       
    struct                            {
        bit [31:00]                   magic         = 32'ha1b23c4d;
        bit [15:00]                   version_major = 16'd2;
        bit [15:00]                   version_minor = 16'd4;
        bit [31:00]                   thiszone      = 32'd0;
        bit [31:00]                   sigfigs       = 32'd0;
        bit [31:00]                   snaplen       = 32'd65535;
        bit [31:00]                   linktype      = 32'd1;
    }pcap_file_hdr;

    struct                            {
        bit [31:00]                   tv_sec  = 32'd0;
        bit [31:00]                   tv_usec = 32'd0;
        bit [31:00]                   caplen  = 32'd0;
        bit [31:00]                   len     = 32'd0;
    }pcap_pkt_hdr;

    //integer                           fd = $fopen("./2307753.pcap","r");
    //initial begin
    //    $fread( pcap_file_hdr,fd );
    //    $fread( pcap_pkt_hdr,fd );
    //end

    reg [79:0] pack1 [3:0] = '{
                               80'h39_38_37_36_35_34_33_32_31_30,
                               80'h29_28_27_26_25_24_23_22_21_20,
                               80'h19_18_17_16_15_14_13_12_11_10,
                               80'h09_08_07_06_05_04_03_02_01_00
                               };

    reg [79:0] pack2 [3:0] = '{
                               80'h79_78_77_76_75_74_73_72_71_70,
                               80'h69_68_67_66_65_64_63_62_61_60,
                               80'h59_58_57_56_55_54_53_52_51_50,
                               80'h49_48_47_46_45_44_43_42_41_40
                               };

    //generate packet bus
    reg [79:0] bus_data  = 0;
    reg        bus_state = 0;
    reg        bus_stop  = 0;   
    integer    num=0;
    initial begin
        @(posedge clk);
        while(1) begin
            bus_state <= 1; bus_data <= pack1[0];
            @(posedge clk);
            bus_data <= pack1[1];
            @(posedge clk);
            bus_data <= pack1[2];
            @(posedge clk);
            bus_stop <= 1; bus_data <= pack1[3];
            @(posedge clk);
            bus_state <= 0; bus_stop <= 0;            
            
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);

            bus_state <= 1; bus_data <= pack2[0];
            @(posedge clk);
            bus_data <= pack2[1];
            @(posedge clk);
            bus_data <= pack2[2];
            @(posedge clk);
            bus_stop <= 1; bus_data <= pack2[3];
            @(posedge clk);
            bus_state <= 0; bus_stop <= 0;            
             
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            
            num = num + 1;
            if (num==20) begin
                $finish();
            end
        end
    end

    reg [7:0] buf_packet[];
    reg       buf_packet_en = 0;
    integer   p=0;
    
    initial begin
        @(posedge clk);
        while(1) begin
            @(negedge clk);
            if (buf_packet_en==1) begin
                buf_packet_en = 0;                
                buf_packet = new[0];
                p=0;
            end
            if (bus_state==1) begin
                buf_packet = new[(buf_packet.size()+10)](buf_packet);
                buf_packet[p] = bus_data[08:00];p=p+1;
                buf_packet[p] = bus_data[15:08];p=p+1;
                buf_packet[p] = bus_data[23:16];p=p+1;
                buf_packet[p] = bus_data[31:24];p=p+1;
                buf_packet[p] = bus_data[39:32];p=p+1;
                buf_packet[p] = bus_data[47:40];p=p+1;
                buf_packet[p] = bus_data[55:48];p=p+1;
                buf_packet[p] = bus_data[63:56];p=p+1;
                buf_packet[p] = bus_data[71:64];p=p+1;
                buf_packet[p] = bus_data[79:72];p=p+1;
            end
            if (bus_stop==1) begin
                buf_packet_en = 1;
            end
        end
    end
    
    reg [7:0] buf_packet_out[];
    reg       buf_packet_en_out;
    initial begin
        read_pcap_task ("./ipv4.pcap", clk, buf_packet_en_out, buf_packet_out);
    end
    initial begin
        write_pcap_task ("packet_out.pcap", clk, buf_packet_en_out, buf_packet_out);
    end
    
endmodule

