#!/usr/bin/python3

import sys

while True:
    data = sys.stdin.buffer.read(1)
    while (data != b'\xd3'):
        data = sys.stdin.buffer.read(1)

    length_data = sys.stdin.buffer.read(2)
    length = (length_data[0] << 8) + length_data[1]
    packet_data = sys.stdin.buffer.read(length)
    crc24_data = sys.stdin.buffer.read(3)

    message_number = (packet_data[0] << 8) + packet_data[1]
    message_number >>= 4

    sys.stdout.buffer.write(b'\xd3')
    sys.stdout.buffer.write(length_data)
    sys.stdout.buffer.write(packet_data)
    sys.stdout.buffer.write(crc24_data)
    sys.stdout.flush()

    if message_number == 1005:
        # blank 1008 message for Trimble
        sys.stdout.buffer.write(bytes([0xd3,0x00,0x06,0x3f,0x00,0x00,0x00,0x00,0x00,0x99,0x25,0xca]))

        sys.stdout.flush()
