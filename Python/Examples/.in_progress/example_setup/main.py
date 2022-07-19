""" Example code for VS Code Python Setup video from Traversy media

https://www.youtube.com/watch?v=W--_EOzdTHk
VS Code Setup (OneNote) https://bit.ly/37UPfIi

Examples of:
      Code extensions:
            - AREPL
            - Kite
      Virtual Environment (VENV)
      Random User REST API
"""
import json

items = json.loads('[{"id":1, "text": "Item 1"}, {"id":2, "text": "Item 2"}]')

for item in items:
      print(item['text'])
