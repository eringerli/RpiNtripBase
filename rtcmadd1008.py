#!/usr/bin/python3

import sys

while True:
    data = sys.stdin.buffer.read(1)
    while (data != b'\xd3'):        # Find Preamble byte 0b11010011
        data = sys.stdin.buffer.read(1)

    # 2 first bytes: 6 bits Reserved and 10 bits Message Length (0 - 1023 bytes)
    length_data = sys.stdin.buffer.read(2)
    # Masking away the first 6 Reserved  bits
    length = ((length_data[0] & 0b00000011) << 8) + length_data[1]
    packet_data = sys.stdin.buffer.read(length)
    crc24_data = sys.stdin.buffer.read(3)

    # Message Number (0 - 4095) is 12 first bits of the packet_data.
    if length >= 2:
        message_number = (packet_data[0] << 8) + packet_data[1]
        message_number >>= 4

    sys.stdout.buffer.write(b'\xd3')
    sys.stdout.buffer.write(length_data)
    sys.stdout.buffer.write(packet_data)
    sys.stdout.buffer.write(crc24_data)
    sys.stdout.flush()

    if message_number == 1005:
        # 1008 message: ADVNULLANTENNA (station id =0)
        sys.stdout.buffer.write(bytes([0xd3,0x00,0x14,0x3f,0x00,0x00,0x0e,0x41,0x44,0x56,0x4e,0x55,0x4c,0x4c,0x41,0x4e,0x54,0x45,0x4e,0x4e,0x41,0x00,0x00,0x79,0x06,0x89]))
        # blank 1008 message for Trimble
        # sys.stdout.buffer.write(bytes([0xd3,0x00,0x06,0x3f,0x00,0x00,0x00,0x00,0x00,0x99,0x25,0xca]))

        sys.stdout.flush()
