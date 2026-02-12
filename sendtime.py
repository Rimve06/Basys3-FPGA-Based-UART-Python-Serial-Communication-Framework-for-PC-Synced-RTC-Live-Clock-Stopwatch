import serial
import time
from datetime import datetime

# Open serial port
ser = serial.Serial('COM10', 9600, timeout=1)
time.sleep(2)  # Wait for serial connection to establish

print("=== FPGA Clock/Date System ===")
print("Waiting for button press from FPGA...")
print("Button 0 (Center): Request Time")
print("Button 1 (Up): Request Date")
print("Press Ctrl+C to exit\n")

try:
    while True:
        # Check if data is available from FPGA
        if ser.in_waiting > 0:
            # Read the button option sent by FPGA
            data = ser.read(1)
            opt = data[0]
            print(data)
            # Get current time and date
            now = datetime.now()
            hour = now.hour
            minute = now.minute
            second = now.second
            date = now.day
            month = now.month
            year = now.year % 100
            
            if opt == 0:
                # Send time data as binary bytes
                print(f"[Time Request] Sending: {hour:02d}:{minute:02d}:{second:02d}")
                
                ser.write(bytes([hour]))
                time.sleep(0.05)
                
                ser.write(bytes([minute]))
                time.sleep(0.05)
                
                ser.write(bytes([second]))
                time.sleep(0.05)
                
            elif opt == 1:
                # Send date data as binary bytes
                print(f"[Date Request] Sending: {date:02d}/{month:02d}/{year:02d}")
                
                ser.write(bytes([date]))
                time.sleep(0.05)
                
                ser.write(bytes([month]))
                time.sleep(0.05)
                
                ser.write(bytes([year]))
                time.sleep(0.05)
                
            else:
                print(f"[Warning] Unknown option received: {opt}")
        
        # Small delay to prevent CPU overuse
        time.sleep(0.1)

except KeyboardInterrupt:
    print("\n\nClosing serial port...")
    ser.close()
    print("Done.")
except Exception as e:
    print(f"\nError: {e}")
    ser.close()