/*
  Shift_Cascade.ino
  
  Shifts a number (< 4 bytes) into a set of shift registers.
  
  So far this code has been tested with 2 cascaded shift registers.
 
  History:
  10/04/2014 -- Created from an example, and wrote shiftCascade function
 */
 
// Constants
const int latchPin = 8;
const int clockPin = 12;
const int dataPin = 11;

// Global variables
unsigned int numberToDisplay = 0;

void setup() 
{
  pinMode(latchPin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataPin, OUTPUT);
  
  Serial.begin(9600);
}

void loop() 
{
  digitalWrite(latchPin, LOW);
  // shift out the bits:
//  shiftOut(dataPin, clockPin, MSBFIRST, numberToDisplay >> 8);
//  shiftOut(dataPin, clockPin, MSBFIRST, numberToDisplay);  //take the latch pin high so the LEDs will light up:
  shiftCascade(dataPin, clockPin, numberToDisplay, 2);
  digitalWrite(latchPin, HIGH);
  // pause before next value:
  delay(50);
//  numberToDisplay = (numberToDisplay + 1);
}


void shiftCascade(int dataPin, int clockPin, unsigned long data, int numCascades)
{
  Serial.print("Shifting ");
  Serial.println(data);
  for (int i=numCascades; i>0; i--)
  {
    Serial.print("  Shift #");
    Serial.println(i);
    shiftOut(dataPin, clockPin, MSBFIRST, data >> 8*(i-1));
  }
}
