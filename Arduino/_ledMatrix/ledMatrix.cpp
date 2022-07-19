/*
  ledMatrix.cpp
  
  Based on the code from Shift_Cascade_Matrix, but created as a class, with
  methods and member variables rather than a set global variables and functions.
  
  Shifts up to a 4 byte piece of data to a set of shift registers,
  one shift register per byte.
  
  To verify the output (and make it more fun) the outputs are connected
  to an 8x8 LED matrix.  
  
  So far this code has been tested with 2 cascaded shift registers,
  taking a 2 byte piece of data as input.
 
  History:
  10/18/2014 -- Created from Shift_Cascade_Matrix.ino.
*/

#include "Arduino.h"
#include "ledMatrix.h"


//
// Class implementations
//

//
// ledMatrix sets the pin mode (input or output) for the relevant pins on the Arduino
// as well as resets the LED memory map.
//
ledMatrix::ledMatrix()
{
  // Set pin modes
  pinMode(_latchPin, OUTPUT);       // Pulsed high to transfer 8 bits to Q0-Q7 outputs
  pinMode(_clockPin, OUTPUT);       // Pulsed high to transfer the data pin to an internal register
  pinMode(_dataPin, OUTPUT);        // The input pin to the shift register defining each bit.
}


//
// The shiftCascade function outputs n bytes of data on cascaded shift registers.
// The data is output 1 byte per 74xx595 chip.
//
// dataPin     - The Arduino pin connected to data pin (14) on the shift register.
// clockPin    - The Arduino pin connected to clock pin (11) on the shift register.
// data        - Up to 4 bytes of data to shift into registers.
// numCascades - The number of bytes of data to shift in (one per xx595 chip)
//
void ledMatrix::shiftCascade(int dataPin, int clockPin, unsigned long data, int numCascades)
{
  for (int i=numCascades; i>0; i--)
  {
    shiftOut(dataPin, clockPin, MSBFIRST, data >> 8*(i-1));
  }
}


//
// Turns an individual pixel on or off in the LED memory map
// The row and column are zero based (i.e. 0-7)
//
void ledMatrix::setPixel(int row, int col, enmStatus value)
{
  byte mask;
  byte currentStatus = off;
  
  // If specified, flip the current state of the pixel.
  if (value == toggle)
  {
    currentStatus = getPixel(row, col);
    if (currentStatus == on)
    {
      value = off;
    }
    else
    {
      value = on;
    }
  }
 
  switch (value) {
    case off:
      mask = 1 << col;                              // Shift a 1 to the specified column (BUGBUG: could this be done by just shifting a 0 to col?)
      mask = ~mask;                                 // Toggle all 1s to 0s so we know the specified column is 0
      _matrix[row] = _matrix[row] & mask;
      break;  
    case on:
      mask = 1 << col;
      _matrix[row] = _matrix[row] | mask;
      break;
    default:
      Serial.println(String("Invalid status parameter: "+String(value)));
      break;
  }
}


//
// Returns on or off based on the present value
// of the specified pixel from the memory map.
//
// bugbug: Should this be enmStatus?
//
byte ledMatrix::getPixel(int row, int col)
{
  byte rowData = _matrix[row];
  byte mask = 1 << col;
  byte stat = rowData & mask;
  enmStatus retVal = off;
  
  if (stat > 0)
  {
    retVal = on;
  }
  
  return retVal;
}


//
// Sets the value of an entire row (8 bits)
//
void ledMatrix::setRow(int row, byte value)
{
  _matrix[row] = value;
  return;
}


//
// Returns the value of an entire row (8 bits)
//
byte ledMatrix::getRow(int row)
{
  return _matrix[row];
}


//
// Populates the full memory map (8x8) from
// an array.
//
void ledMatrix::setMatrix(const byte matrix[numRows])
{
  for (int i=0; i<numRows; i++)
  {
    _matrix[i] = matrix[i];
  }
  
  return;
}


//
// Toggles each value in the memory map
//
void ledMatrix::invertMatrix()
{
  for (int i=0; i<numRows; i++)
  {
    _matrix[i] = ~_matrix[i]; 
  }
}


//
// Outputs the value of the memory map
// to serial for debugging.
//
void ledMatrix::drawText()
{
  for (int i=0; i<numRows; i++)
  {
    String textRow = String(_matrix[i], BIN);
    for (int pad=8-textRow.length(); pad>0; pad--)
    {
      textRow = "0" + textRow;
    }
    Serial.println(textRow); 
  }
  return;
}


//
// Reads data from an internal array (matrix), and
// shifts it out to a set of cascaded shift registers
//
// Data is shifted one row at a time from the matrix
//
// Inputs:
//   bounce is a boolean indicating whether the routine
//     shifts data back out from row n to 1, after
//     shifting from 1 - n, making the display appear
//     to bounce.
//   speed is a number indicating how quickly to display
//     each row in sequence.  speed = 0 appears to display
//     the whole matrix at once.
//
// Assumptions:
//    matrix[] contains the data to be displayed, one byte per row.
//    numRows is the number of rows to be shifted.  This is typically 8.
//    dataPin, clockPin, and latchPin are defined.
//
void ledMatrix::drawMatrix(boolean bounce, int speed)
{
  unsigned int dataRow;
  byte rowEnable  = 254;            // All rows should be HIGH except one.
  byte data;                        // The 8 bits of data to display.
  int sleep     = speed;            // Setting this to something higher than 0 makes an animation.
  
  // Shift data out one row at a time.
  for (int i=0; i<numRows; i++)
  {
    data = _matrix[i];                  // The LEDs to turn on/off in the current row (1 bit per pixel)
    dataRow = word(rowEnable, data);            // Combine the data byte and the byte specifying which row is enabled 
    digitalWrite(_latchPin, LOW);           // Make sure the latch pin is reset.
    shiftCascade(_dataPin, _clockPin, dataRow, 2);  // Shift the current row to the cascaded shift registers.
    digitalWrite(_latchPin, HIGH);          // Toggle the latch pin to transfer data to the output pins on the shift registers.
    rowEnable = (rowEnable << 1) + 1;           // Disable the current row, and enable the next.
    delay(sleep);
  }
  
  // If bounce was specified, repeat outputting the data
  // in the other direction.
  // BUGBUG: This feels ham fisted.  Seems like there is a more clever way to do this.
  if (bounce)
  {
    rowEnable = 191;                                // Set the active row to the penultimate row (all HIGH except 2^6)
    for (int i=numRows-1; i>0; i--)                 // Work backward to the second row
    {
      data = _matrix[i];
      dataRow = word(data, rowEnable);
      digitalWrite(_latchPin, LOW);
      shiftCascade(_dataPin, _clockPin, dataRow, 2);
      digitalWrite(_latchPin, HIGH);
      rowEnable = (rowEnable >> 1) + 128;
      delay(sleep);
    }
  }
}