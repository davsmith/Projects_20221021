''' Example code from https://www.youtube.com/watch?v=ot94H3-d5d8 '''

' Minimal PyQt6 window with no icon or title '
from  PyQt6.QtWidgets import QApplication, QWidget

import sys


app = QApplication(sys.argv)

window = QWidget()
window.show()

sys.exit(app.exec())

