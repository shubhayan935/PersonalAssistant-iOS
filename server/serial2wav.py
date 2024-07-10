# (c)  Teddy Warner, Jackson Oswalt, Shubhayan Srivastava - 2024
#
# This work is licensed under CC BY-NC-SA 4.0 and may be reproduced,
# modified, distributed, performed, and displayed for any non-commercial
# purpose, but must acknowledge Jackson Oswalt, Teddy Warner, and Shubhayan Srivastava.
# Copyright is retained and must be preserved. The work is
# provided as is; no warranty is provided, and users accept all liability.

import serial
import wave

serial_port = 'COM7'
baud_rate = 256000

output_wav_file = 'output.wav'
channels = 1
sample_rate = 16000  # This should match the ESP32's I2S sample rate
sample_width = 2  # 16-bit samples

try:
    ser = serial.Serial(serial_port, baud_rate, timeout=1)
except serial.SerialException as e:
    print(f"Error opening serial port {serial_port}: {e}")
    exit(1)

with wave.open(output_wav_file, 'wb') as wav_file:
    wav_file.setnchannels(channels)
    wav_file.setsampwidth(sample_width)
    wav_file.setframerate(sample_rate)

    print("Recording started. Press Ctrl+C to stop.")
    try:
        while True:
            data = ser.read(4096)  # Read in larger chunks to match real-time audio flow better
            if data:
                wav_file.writeframes(data)
    except KeyboardInterrupt:
        print("Stopped recording by user.")
    finally:
        ser.close()
        print("Serial port closed.")
        duration = wav_file.getnframes() / sample_rate
        print(f"Recorded {duration:.2f} seconds of audio.")