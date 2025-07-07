from flask import Flask, Response
import cv2

app = Flask(__name__)

def generate():
    cap = cv2.VideoCapture("test.mp4")  # or use sample video with cv2.VideoCapture("video.mp4")
    while True:
        success, frame = cap.read()
        if not success:
            break
        _, buffer = cv2.imencode('.jpg', frame)
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + buffer.tobytes() + b'\r\n')

@app.route('/video_feed')
def video_feed():
    return Response(generate(),mimetype='multipart/x-mixed-replace; boundary=frame')


from multiprocessing import Pool
from multiprocessing import cpu_count
import time
import os

def f(x):
    set_time = 0.5
    timeout = time.time() + 60*float(set_time)  # X minutes from now
    while True:
        if time.time() > timeout:
            break
        x

# if __name__ == '__main__':
    # processes = 2
    # print ('utilizing %d cores\n' % processes)
    # pool = Pool(processes)
    # pool.map(f, range(processes))


@app.route('/stress_cpu')
def stress_cpu():
    processes = 2
    print ('utilizing %d cores\n' % processes)
    pool = Pool(processes)
    pool.map(f, range(processes))
    return "Completed!"

app.run(host='0.0.0.0', port=8883, debug=True)
