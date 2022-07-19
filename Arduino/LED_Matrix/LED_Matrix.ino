//**************************************************************//
//  Name    : LED_Matrix                                
//  Author  : Dave Smith 
//  Date    : 29 Sep, 2014    
//  Modified:                                 
//  Version : 1.0                                             
//  Notes   : Code for using a 74HC595 Shift Register         
//          : to control an 8x8, single color LED matrix.
//
//***************************************************************

//
// Info for the 74HC595 shift register
//
int latchPin = 8;   // Arduino pin connected to pin 12 (ST_CP or RCLK) of 74HC595
int clockPin = 12;  // Arduino pin connected to pin 11 (SH_CP or SRCLK) of 74HC595
int dataPin = 11;   // Arduino pin connected to pin 14 (DS or SER) of 74HC595


//
// Info for the push button
//
int swButton1 = 13;
const int BUTTON_CHANGED = 4;


//
// Program constants, globals and enumerated types
//
enum MODE
{
  NONE=1,
  COUNTER,
  ALL_ON
};



//
// Main program setup
//
void setup() {
  //set pins to output so you can control the shift register
  pinMode(latchPin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataPin, OUTPUT);

  pinMode(swButton1, INPUT);
  
  Serial.begin(9600);
}


//
// Main processing loop
//
void loop()
{
  static int nCounter=0;
  static int nMode=ALL_ON;
  int nButtonStatus; 
  
  nButtonStatus = CheckButtonStatus();
  
  if (nButtonStatus == (BUTTON_CHANGED | HIGH))
  {
     Serial.println("Button transition UP.");
  }
  else if (nButtonStatus == (BUTTON_CHANGED | LOW))
  {
    nMode++;
    if (nMode > ALL_ON)
    {
      nMode = NONE;
    }
    
    if (nMode == COUNTER)
    {
      nCounter = 0;
    }
    
    Serial.print("Mode: ");
    Serial.println(nMode);
  }
    
  switch (nMode)
  {
    case NONE:
      digitalWrite(latchPin, LOW);
      shiftOut( dataPin, clockPin, MSBFIRST, 0 );
      digitalWrite(latchPin, HIGH);
      Serial.println("Mode: NONE");
      break;
    
    case COUNTER:
      digitalWrite(latchPin, LOW);
      shiftOut( dataPin, clockPin, MSBFIRST, nCounter );
      digitalWrite(latchPin, HIGH);
      Serial.println("Mode: COUNTER");
      break;
    
    case ALL_ON:
      digitalWrite(latchPin, LOW);
      shiftOut( dataPin, clockPin, MSBFIRST, 255 );
      digitalWrite(latchPin, HIGH);
      Serial.println("Mode: ALL_ON");
      break;
  }
  
  nCounter++;
  delay(500);
}

int CheckButtonStatus()
{
  int nStatus = LOW;
  long lElapsed = 0;
  static long lBenchmark = 0; 
  static int nPrevious = LOW;
  int nRetVal = 0;
  
  nStatus = digitalRead(swButton1);
  nRetVal = nStatus;
  
  if (nStatus != nPrevious)
  {
    lElapsed = millis() - lBenchmark;
    Serial.print("Button status changed.  From: ");
    Serial.print(nPrevious);
    Serial.print(" to: ");
    Serial.print(nStatus);
    Serial.print("  Time elapsed: ");
    Serial.println(lElapsed);
    if (lElapsed < 50)
    {
      Serial.println("Discarding switch bounce");
      nStatus = !nStatus; 
    }

    nRetVal |= BUTTON_CHANGED;
    
    nPrevious = nStatus;
    lBenchmark = millis();
  }
  
  return nRetVal;
}
