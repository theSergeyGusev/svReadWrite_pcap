`timescale 1 ns/1 ps

`include "../write_pcap_task.sv"
`include "../read_pcap_task.sv"

`define CLK_PERIOD 10 // 10ns

module test;
    //generate clk
    reg clk=0;
    always #(`CLK_PERIOD/2) clk <= ~clk;

    reg [7:0] buf_packet_out[];
    reg       buf_packet_en_out;
    reg       end_read;
    initial begin
        read_pcap_task ("./ipv4.pcap", clk, buf_packet_en_out, buf_packet_out, end_read);
    end
    initial begin
        write_pcap_task ("packet_out.pcap", clk, buf_packet_en_out, buf_packet_out);
    end

    always@(posedge clk) begin
        if (end_read==1) begin
            $finish();
        end
    end

endmodule
