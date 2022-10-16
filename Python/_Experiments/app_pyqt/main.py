''' Code from How to Build Your First Desktop App in Python (https://tinyurl.com/y3zdk646) '''
import sys
import os
import threading
from time import strftime, gmtime, sleep

from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtQuick import QQuickWindow
from PyQt6.QtCore import QObject, pyqtSignal

curr_time = strftime("%H:%M:%S", gmtime())

class Backend(QObject):
    def __init__(self):
        QObject.__init__(self)

    def bootUp(self):
        t_thread = threading.Thread(target=self._bootUp)
        t_thread.daemon = True
        t_thread.start()
        
    def _bootUp(self):
        while True:
            curr_time = strftime("%H:%M:%S", gmtime())
            print(curr_time)
            sleep(1)

QQuickWindow.setSceneGraphBackend('software')
app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()
engine.quit.connect(app.quit)
engine.load('./UI/main.qml')
back_end = Backend()
engine.rootObjects()[0].setProperty('backend', back_end)
engine.rootObjects()[0].setProperty('currTime', curr_time)
sys.exit(app.exec())
