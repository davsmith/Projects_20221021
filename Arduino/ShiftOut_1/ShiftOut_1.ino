//**************************************************************//
//  Name    : shiftOutCode, Hello World                                
//  Author  : Carlyn Maw,Tom Igoe, David A. Mellis 
//  Date    : 25 Oct, 2006    
//  Modified: 23 Mar 2010                                 
//  Version : 2.0                                             
//  Notes   : Code for using a 74HC595 Shift Register           //
//          : to count from 0 to 255                           
//****************************************************************

//Pin connected to ST_CP (RCLK - IC pin 12) of 74HC595
int latchPin = 8;

//Pin connected to SH_CP (SRCLK - IC pin 11) of 74HC595
int clockPin = 12;

////Pin connected to DS (SER - IC pin 14) of 74HC595
int dataPin = 11;

int swButton1 = 13;
const int BUTTON_CHANGED = 4;

enum MODE
{
  NONE=1,
  COUNTER,
  ALL_ON
};

void setup() {
  //set pins to output so you can control the shift register
  pinMode(latchPin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataPin, OUTPUT);

  pinMode(swButton1, INPUT);
  
  Serial.begin(9600);
}

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
