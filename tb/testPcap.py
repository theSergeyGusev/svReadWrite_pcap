#!/usr/bin/python
from scapy.all import *
from random import randint
import random
import string
import sys
import os

def datafield( len_datafield ):
    l = 0
    data_field = ''
    while l < len_datafield:
        data_field = data_field + random.choice(string.ascii_letters)
        l=l+1
    return data_field

ipv4 = []
count_packets = 10

mac_src = '11:22:33:44:55:66'
mac_dst = '77:88:99:AA:BB:CC'

i = 0
while i < count_packets:
    src_ip_v4   = "192.168."+str(i/256)   +"."+str(i%256)
    dst_ip_v4   = "192.168."+str(10+i/256)+"."+str(i%256)
    src_port    = i%256
    dst_port    = 256+i%256
    data_f_ip   = datafield(64)

    ipv4.append(Ether(src = mac_src,dst = mac_dst)/
                IP(src=src_ip_v4,dst=dst_ip_v4)/
                UDP(sport=src_port,dport=dst_port)/
                data_f_ip
    )
    
    i=i+1
                
wrpcap("ipv4.pcap",ipv4)
