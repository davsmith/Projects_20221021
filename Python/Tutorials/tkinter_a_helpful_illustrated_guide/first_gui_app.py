# import tkinter as tk

# window = tk.Tk()
# window.title("My first GUI")
# window.geometry('300x200')

# label_name = tk.Label(text='Some text')
# label_name.grid(column=10,row=10)

# window.mainloop()


import tkinter as tk
def doorbell(event):
    print(" You rang the Doorbell !")
window = tk.Tk()
window.title(" Doorbell App")
window.geometry("300x200")
mybutton = tk.Button(window, text = "Doorbell")
mybutton.grid(column=1,row=0)
mybutton.bind("<Button-1>",doorbell)
window.mainloop()