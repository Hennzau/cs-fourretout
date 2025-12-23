import imutils
import time
import cv2
import json
import random
import zenoh
import io

from dataclasses import dataclass

from servo import *

from pycdr2 import IdlStruct
from pycdr2.types import int8, int32, uint32, float64

@dataclass
class Vector3(IdlStruct, typename="Vector3"):
    x: float64
    y: float64
    z: float64

@dataclass
class Twist(IdlStruct, typename="Twist"):
    linear: Vector3
    angular: Vector3

DEVICENAME                  = '/dev/ttyACM0'
PROTOCOL_VERSION            = 2.0
BAUDRATE                    = 115200
MOTOR_ID                    = 200

def listener(sample):
    global cmd
    
    cmd_json = json.loads (sample.payload.decode ("utf-8"))
    cmd_str = cmd_json[0]
    cmd_value = float(cmd_json[1])
    
    if cmd_str == "Rotate":
        cmd.angular.z = cmd_value     
    elif cmd_str == "Forward":
        cmd.linear.x = cmd_value
    else:
        print("not recnognizable")

from picamera2 import Picamera2

jpeg_opts = [int(cv2.IMWRITE_JPEG_QUALITY), 95]

print('[INFO] Open zenoh session...')

zenoh.init_logger()
conf = zenoh.Config.from_file ("config_turtle.json")
z = zenoh.open(conf)

print('[INFO] Start video stream - Cam #{}'.format(0))

picam2 = Picamera2()
picam2.configure (picam2.create_still_configuration({'format': 'BGR888'}))
picam2.start ()

cmd = Twist(Vector3(0.0, 0.0, 0.0), Vector3(0.0, 0.0, 0.0))
count = 0

print('[INFO] Connect to motor...')
servo = Servo(DEVICENAME, PROTOCOL_VERSION, BAUDRATE, MOTOR_ID)

if servo is None:
    print('[WARN] Unable to connect to motor.')
else:
    servo.write1ByteTxRx(IMU_RE_CALIBRATION, 1)
    sub = z.declare_subscriber('turtle/cmd_vel', listener)

time.sleep(3.0)

while True:
    raw = picam2.capture_array ()
    frame = imutils.resize(raw, width=400)

    _, jpeg = cv2.imencode('.jpg', frame, jpeg_opts)

    z.put('turtle/camera', jpeg.tobytes())
    
    if servo is not None:
        servo.write1ByteTxRx(HEARTBEAT, count)
        servo.write4ByteTxRx(CMD_VELOCITY_LINEAR_X, int(cmd.linear.x))
        servo.write4ByteTxRx(CMD_VELOCITY_LINEAR_Y, int(cmd.linear.y))
        servo.write4ByteTxRx(CMD_VELOCITY_LINEAR_Z, int(cmd.linear.z))
        servo.write4ByteTxRx(CMD_VELOCITY_ANGULAR_X, int(cmd.angular.x))
        servo.write4ByteTxRx(CMD_VELOCITY_ANGULAR_Y, int(cmd.angular.y))
        servo.write4ByteTxRx(CMD_VELOCITY_ANGULAR_Z, int(cmd.angular.z))
        
        count += 1
        
        if count > 255:
            count = 0
	
vs.stop()
z.close()
