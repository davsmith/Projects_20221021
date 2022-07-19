/*
  ledMatrixClass.ino
  
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



// 
// Global constants
//

//
// Global variables
//


//
// Class definitions
//
class ledMatrix
{
  private:
    // Other member variables
    static const int _numRows = 8;                         // Number of rows in the matrix
    static const int _numCols = 8;                         // Number of columns in the matrix

    int _matrix[_numRows];                                 // The memory map of the LED matrix
    
    // Pins
    static const int _dataPin    = 11;                     // The data to be parallelized (up to 4 bytes)
    static const int _clockPin   = 12;                     // Pulsed high to transfer one bit of data to an internal register
    static const int _latchPin   = 8;                      // Pulsed high to transfer the internal register to Q0-Q7.


    // Methods
    void shiftCascade(int dataPin, int clockPin, unsigned long data, int numCascades);

  public:
    // Shapes
    static const byte _matrixChex[_numRows];
    static const byte _matrixAll[_numRows];
    static const byte _matrixBox[_numRows];
    static const byte _matrixNone[_numRows];
    static const byte _matrixX[_numRows];

    enum enmStatus {off, on, toggle};                      // Enumerated type to set pixels on or off.
    
    ledMatrix();                
    void setPixel(int row, int col, enmStatus value);      // Turns an individual pixel on or off in the LED map (0-7)
    byte getPixel(int row, int col);                       // Returns the current value of an individual pixel (0-7)
    void setRow(int row, byte value);                      // Turns on or off LEDs a row at a time.
    byte getRow(int row);                                  // Returns the current status of the 8 LEDs in a row.
    void setMatrix(const byte matrix[_numRows]);           // Sets all 8 bytes of a an LED matrix
    
    void invertMatrix();                                   // Toggles the values of each pixel in the LED matrix
    
    void drawText();                                       // Dumps the current LED map out as text to the serial monitor
    void drawMatrix(boolean bounce, int speed);            // Copies the current LED map to cascaded shift registers
};


//
// These are the initializers for a set of array constants defining shapes to display
// on the LED matrix.
//
// Since C++ doesn't allow constants to be initialized in the class definition, they
// are declared in the definition, and initialized here.
//
// More sample code for constant arrays in C++ is here: https://www.gidforums.com/t-2981.html
//
const byte ledMatrix::_matrixChex[8] = {170, 85, 170, 85, 170, 85, 170, 85};         // Alternate on/off in a checkerboard pattern
const byte ledMatrix::_matrixAll[8]  = {255, 255, 255, 255, 255, 255, 255, 255};     // All LEDs on
const byte ledMatrix::_matrixNone[8] = {0,0,0,0,0,0,0,0};                            // All LEDs off
const byte ledMatrix::_matrixBox[8]  = {255, 129, 129, 129, 129, 129, 129, 255};     // Draw a square across outside border
const byte ledMatrix::_matrixX[8]    = {129, 66, 36, 24, 24, 36, 66, 129};           // Draw an X


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
  pinMode(_latchPin, OUTPUT);
  pinMode(_clockPin, OUTPUT);
  pinMode(_dataPin, OUTPUT);
  
  setMatrix(_matrixNone);
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
//  Serial.println("In shiftCascade");
  
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
//      Serial.println(String("Mask value: "+String(mask))); 
      break;  
    case on:
      mask = 1 << col;
      _matrix[row] = _matrix[row] | mask;
//      Serial.println(String("Mask value: "+String(mask)));
      break;
    default:
      Serial.println(String("Invalid status parameter: "+String(value)));
      break;
  }
}


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


void ledMatrix::setRow(int row, byte value)
{
  _matrix[row] = value;
  return;
}


byte ledMatrix::getRow(int row)
{
  return _matrix[row];
}


void ledMatrix::setMatrix(const byte matrix[_numRows])
{
  for (int i=0; i<_numRows; i++)
  {
    _matrix[i] = matrix[i];
  }
  
  return;
}


void ledMatrix::invertMatrix()
{
  for (int i=0; i<_numRows; i++)
  {
    _matrix[i] = ~_matrix[i]; 
  }
}


void ledMatrix::drawText()
{
  for (int i=0; i<_numRows; i++)
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
void ledMatrix::drawMatrix(boolean bounce, int speed=0)
{
  unsigned int dataRow;
  byte rowByte=254;            // All rows should be HIGH except one.
  byte colByte;                // The 8 bits of data to display.
  int sleep=speed;                 // Setting this to something higher than 0 makes an animation.
  
  // Shift data out one row at a time.
  // If sleep is set to something other than zero, 
  // the shifting will appear to animate.
  for (int i=0; i<_numRows; i++)
  {
    colByte = _matrix[i];
    dataRow = word(rowByte, colByte);
    digitalWrite(_latchPin, LOW);
    shiftCascade(_dataPin, _clockPin, dataRow, 2);
    digitalWrite(_latchPin, HIGH);
    rowByte = (rowByte << 1) + 1;
    delay(sleep);
  }
  
  // If bounce was specified, repeat outputting the data
  // in the other direction.
  if (bounce)
  {
    rowByte = 191;                            // Set the active row to the penultimate row (all HIGH except 2^6)
    for (int i=_numRows-1; i>0; i--)          // Work backward to the second row
    {
      colByte = _matrix[i];
      dataRow = word(rowByte, colByte);
      digitalWrite(_latchPin, LOW);
      shiftCascade(_dataPin, _clockPin, dataRow, 2);
      digitalWrite(_latchPin, HIGH);
      rowByte = (rowByte >> 1) + 128;
      delay(sleep);
    }
  }
}


ledMatrix led;
letters l;

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
  
//  led.setMatrix(led._matrixNone);
  led.drawMatrix(false);  // The bounce and speed parameters can be used to slow down the display.
} 

