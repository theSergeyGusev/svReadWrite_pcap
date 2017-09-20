task automatic read_pcap_task
    (
     string        file_name,
     ref reg       clk,
     ref reg       o_packet_en,
     ref reg [7:0] o_packet[]
     );

    localparam CLK_PAUSE = 4;

    struct         {
        bit [31:00] magic         ;
        bit [15:00] version_major ;
        bit [15:00] version_minor ;
        bit [31:00] thiszone      ;
        bit [31:00] sigfigs       ;
        bit [31:00] snaplen       ;
        bit [31:00] linktype      ;
    }pcap_file_hdr;

    struct          {
        bit [31:00] tv_sec  ;
        bit [31:00] tv_usec ;
        bit [31:00] caplen  ;
        bit [31:00] len     ;
    }pcap_pkt_hdr;

    automatic integer count_clk = 0;
    automatic reg [07:00] data_in_8b = 0;
    automatic reg [31:00] packet_lenght = 0;
    automatic integer p = 0;
    automatic integer buf_w = 0;

    automatic integer fd = $fopen(file_name,"r");

    o_packet = new[0];

    @(negedge clk);
    $fread( pcap_file_hdr,fd );
    while(!$feof(fd)) begin
        @(negedge clk);
        o_packet_en = 0;
        if (count_clk==CLK_PAUSE) begin
            count_clk = 0;
            $fread( pcap_pkt_hdr,fd );
            packet_lenght = {pcap_pkt_hdr.caplen[07:00],pcap_pkt_hdr.caplen[15:08],
                             pcap_pkt_hdr.caplen[23:16],pcap_pkt_hdr.caplen[31:24]};

            if (packet_lenght>0)  begin
                buf_w=packet_lenght;
                o_packet = new[buf_w];
                while(p<packet_lenght) begin
                    $fread( data_in_8b,fd ); o_packet[p]=data_in_8b; p=p+1;
                end
                o_packet_en = 1;
            end
            p=0;
        end
        else begin
            count_clk = count_clk + 1;
        end
    end
    @(negedge clk);
    o_packet_en = 0;

endtask
