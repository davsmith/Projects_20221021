''' Example code from https://www.youtube.com/watch?v=ot94H3-d5d8 '''

' Minimal PyQt6 window with no icon or title, using classes '
from  PyQt6.QtWidgets import QApplication, QWidget
import sys

class Window(QWidget):
    def __init_(self):
        super().__init__()

app = QApplication([])
window = Window()
window.show()
sys.exit(app.exec())

