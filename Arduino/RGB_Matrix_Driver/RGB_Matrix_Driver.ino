/*
  RGB_Matrix_Driver.ino
  
  Based on Shift_Cascade_Matrix.ino which uses 2 74HC595 chips to 
  control an 8x8 Red LED array.
  
  This sketch controls an 8x8 RGB array using 4 74HC595 chips, creating
  an 8 byte memory map array for Red, Green, and Blue.
  
  One chip controls each R, G, and B, with one chip controlling which is
  the active row.
  
  History:
  10/04/2014 -- Created from an example, and wrote shiftCascade function.
  10/17/2014 -- Added comments, and cleaned up code.
  10/31/2014 -- Modified to work with 4 595 chips and 3 memory maps.
  
 */
 
// Constants
const int dataPin   = 11;    // The data to be parallelized (up to 4 bytes)
const int clockPin  = 12;    // Pulsed high to transfer one bit of data to an internal register
const int latchPin  = 8;     // Pulsed high to transfer the internal register to Q0-Q7.

const int numRows   = 8;     // The number of output rows on the LED matrix
const int numCols   = 8;     // The number of output columns on the LED matrix

// Global variables
byte matrixX[numRows] = {170, 85, 170, 85, 170, 85, 170, 85};            // Values to display an X on the LED matrix
byte matrixALL[numRows] = {255, 255, 255, 255, 255, 255, 255, 255};      // Values to light all LEDs in the matrix
byte matrixRed[numRows] = {170, 85, 170, 85, 170, 85, 170, 85};             // 8x8 (1 byte = 8 bits) internal array representing the LED matrix
byte matrixGreen[numRows] = {170, 85, 170, 85, 170, 85, 170, 85};             // 8x8 (1 byte = 8 bits) internal array representing the LED matrix
byte matrixBlue[numRows] = {170, 85, 170, 85, 170, 85, 170, 85};             // 8x8 (1 byte = 8 bits) internal array representing the LED matrix



void setup() 
{
  // Initialize the serial connection
  Serial.begin(9600);

  // Set pin modes
  pinMode(latchPin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataPin, OUTPUT);
  
  // Load an X into the internal matrix
  matrix[0] = B10000001;
  matrix[1] = B01000010;
  matrix[2] = B00100100;
  matrix[3] = B00011000;
  matrix[4] = B00011000;
  matrix[5] = B00100100;
  matrix[6] = B01000010;
  matrix[7] = B10000001;
}


//
// The shiftCascade function outputs n bytes of data on cascaded shift registers.
// The data is output 1 byte per 74xx595 chip.
//
// dataPin     - The Arduino pin connected to data pin (14) on the shift register.
// clockPin    - The Arduino pin connected to clock pin (11) on the shift register.
// data        - Up to 4 bytes of data to shift into registers.
// numCascades - The number of bytes of data to shift in (one byte per 74xx595 chip)
//
void shiftCascade(int dataPin, int clockPin, unsigned long data, int numCascades)
{
  for (int i=numCascades; i>0; i--)
  {
    shiftOut(dataPin, clockPin, MSBFIRST, data >> 8*(i-1));
  }
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
void drawMatrix(boolean bounce, int speed=100)
{
  unsigned int dataRow;
  byte rowByte=254;            // All rows should be HIGH except the active row.
  byte colByte;                // The 8 bits of data to display.
  int sleep=0;                 // Setting this to something higher than 0 makes an animation.
  
  if (bounce)
  {
    sleep = speed;
  }
  
  // Shift data out one row at a time.
  // If sleep is set to something other than zero, 
  // the shifting will appear to animate.
  for (int i=0; i<numRows; i++)
  {
    colByte = matrix[i];                            // Retrieve the next row from the global array
    dataRow = word(rowByte, colByte);               // Make a 2 byte value with the row byte the high order.
    digitalWrite(latchPin, LOW);                    // Make sure the latch pin is low until we shift out the data.
    shiftCascade(dataPin, clockPin, dataRow, 2);    // Shift out two bytes of data.
    digitalWrite(latchPin, HIGH);                   // Set the latch pin to high to transfer the data to the outputs on the 74595
    rowByte = (rowByte << 1) + 1;                   // Disable the current row on the LED, and enable the next one.
    delay(sleep);                                   
  }
  
  // If bounce was specified, repeat outputting the data
  // in the other direction.
  if (bounce)
  {
    rowByte = 191;                           // Set the active row to the penultimate row (all HIGH except 2^6)
    for (int i=numRows-1; i>0; i--)          // Work backward to the second row
    {
      colByte = matrix[i];
      dataRow = word(rowByte, colByte);
      digitalWrite(latchPin, LOW);
      shiftCascade(dataPin, clockPin, dataRow, 2);
      digitalWrite(latchPin, HIGH);
      rowByte = (rowByte >> 1) + 128;        // 128 is added because the >> shifts in a zero, and we need a one.
      delay(sleep);
    }
  }
}


void loop() 
{
  drawMatrix(true);  // The bounce and speed parameters can be used to slow down the display.
} 

