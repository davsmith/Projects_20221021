/*
  SpaceShip.ino
  Shows a green LED until a button switch is pressed, at which point
  two red LEDs are flashed alternately, until the switch is released.
 
  NOTE:  No arrays are used in this example.
  
  Timeline:
  8/31/14:  Created
 */
 
int ledDiagnostic = 13;      // Diagnostic onboard LED
int ledRed1 = 4;             // First LED in the sequence
int ledRed2 = 3;             // Second LED in the sequence
int ledGreen = 2;            // Third LED in the sequence
int sw1 = 13;

// the setup routine runs once when you press reset:
void setup() {                
  // initialize the digital pin as an output.
  pinMode(ledDiagnostic, OUTPUT);     
  pinMode(ledRed1, OUTPUT);     
  pinMode(ledRed2, OUTPUT);     
  pinMode(ledGreen, OUTPUT);     
  pinMode(sw1, INPUT);

  Serial.begin(9600);
}

// the loop routine runs over and over again forever:
void loop()
{
  int swVal1;
  
  swVal1 = digitalRead(sw1);
  Serial.print("Switch value: ");
  Serial.println(swVal1);
  if (swVal1 == HIGH)
  {
    CycleRedLEDs();
  }
  else
  {
    ShowGreenLED();
  }
}


void SetAllLEDs(bool bOn=true)
{
  if (bOn == true)
  {
    digitalWrite(ledRed1, HIGH);
    digitalWrite(ledRed2, HIGH);
    digitalWrite(ledGreen, HIGH);
  }
  else
  {
    digitalWrite(ledRed1, LOW);
    digitalWrite(ledRed2, LOW);
    digitalWrite(ledGreen, LOW);
  }
}

void CycleRedLEDs()
{
  static int nStartTime = 0;
  int ledRed1Status;
  
  // SetAllLEDs(false);
  if (nStartTime == 0)
  {
    nStartTime = millis();
    digitalWrite(ledGreen, LOW);    
  }
  else
  {
    if ((millis() - nStartTime) > 200)
    {
      nStartTime = 0;
      ledRed1Status = digitalRead(ledRed1);
      digitalWrite(ledRed2, ledRed1Status);
      digitalWrite(ledRed1, !ledRed1Status);
    }
  }
}
  

void ShowGreenLED()
{
  SetAllLEDs(false);
  digitalWrite(ledGreen, HIGH);
}
