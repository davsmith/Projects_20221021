/*
  ledMatrix.h
  
  Based on the code from Shift_Cascade_Matrix, but created as a class, with
  methods and member variables rather than a set of global functions and variables.
  
  Shifts up to a 4 byte piece of data to a set of shift registers,
  one shift register per byte.
  
  To verify the output (and make it more fun) the outputs are connected
  to an 8x8 LED matrix.  
  
  So far this code has been tested with 2 cascaded shift registers,
  taking a 2 byte piece of data as input.
 
  History:
  10/18/2014 -- Created from Shift_Cascade_Matrix.ino.
*/

#ifndef ledMatrix_h
#define ledMatrix_h

#include "Arduino.h"

//
// Class definitions
//

class ledMatrix
{
  public:
    static const int numRows = 8;                          // Number of rows in the matrix

    enum enmStatus {off, on, toggle};                      // Enumerated type to set pixels on or off.
    
    ledMatrix();                
    void setPixel(int row, int col, enmStatus value);      // Turns an individual pixel on or off in the LED map (0-7)
    byte getPixel(int row, int col);                       // Returns the current value of an individual pixel (0-7)
    void setRow(int row, byte value);                      // Turns on or off LEDs a row at a time.
    byte getRow(int row);                                  // Returns the current status of the 8 LEDs in a row.
    void setMatrix(const byte matrix[numRows]);            // Sets all 8 bytes of a an LED matrix
    void setMatrix(int test);           
    
    void invertMatrix();                                   // Toggles the values of each pixel in the LED matrix
    
    void drawText();                                       // Dumps the current LED map out as text to the serial monitor
    void drawMatrix(boolean bounce, int speed=0);          // Copies the current LED map to cascaded shift registers

  private:
    // Member variables
    static const int _numCols = 8;                         // Number of columns in the matrix

    byte _matrix[numRows];                                 // The memory map of the LED matrix.  Use different type if more than 8 columns
    
    // Pins
    static const int _dataPin    = 11;                     // The data to be parallelized (up to 4 bytes)
    static const int _clockPin   = 12;                     // Pulsed high to transfer one bit of data to an internal register
    static const int _latchPin   = 8;                      // Pulsed high to transfer the internal register to Q0-Q7.

    // Methods
    void shiftCascade(int dataPin, int clockPin, unsigned long data, int numCascades);
};

#endif