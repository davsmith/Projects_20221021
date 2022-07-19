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