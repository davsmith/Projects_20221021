/*
  ledMatrixExample.ino
  
  Sample code for using the ledMatrix library.
 
  History:
  10/18/2014 -- Created from Shift_Cascade_Matrix.ino.
*/

#include "ledMatrix.h"

ledMatrix led;

void setup() 
{
  // Initialize the serial connection
  Serial.begin(9600);

  led.setMatrix(ledMatrix::_matrixX);

  led.setPixel(3, 3, led.off);
  led.setPixel(3, 4, led.off);
  led.setPixel(4, 3, led.off);
  led.setPixel(4, 4, led.off);

  led.setPixel(0, 3, led.on);
  led.setPixel(0, 4, led.on);
  led.setPixel(3, 7, led.on);
  led.setPixel(4, 7, led.on);
  led.setPixel(3, 0, led.on);
  led.setPixel(4, 0, led.on);
  led.setPixel(7, 3, led.on);
  led.setPixel(7, 4, led.on);

  //led.setMatrix(ledMatrix::_matrixBox);
}


void loop() 
{
  static unsigned long time = 0;
  static unsigned long toggleInterval = 100;
  
  if (time == 0)
  {
    time = millis();
  }
  else if ((millis() - time) > toggleInterval)
  {
    time = 0;
    led.invertMatrix();
  }
  
  // led.setMatrix(led._matrixNone);
  led.drawMatrix(false);  // The bounce and speed parameters can be used to slow down the display.
} 

