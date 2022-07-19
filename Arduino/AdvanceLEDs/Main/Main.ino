/*
  AdvanceLEDs
  Cycles between 3 LEDs 1 second at a time, before returning to the first.
 
  In initial implementation the first 2 LEDs are red, and the third is Green.
  
  NOTE:  No arrays are used in this example.
  
  Timeline:
  8/31/14:  Created
 */
 
int ledDiagnostic = 13;      // Diagnostic onboard LED
int ledRed1 = 4;             // First LED in the sequence
int ledRed2 = 3;             // Second LED in the sequence
int ledGreen = 2;            // Third LED in the sequence

// the setup routine runs once when you press reset:
void setup() {                
  // initialize the digital pin as an output.
  pinMode(ledDiagnostic, OUTPUT);     
  pinMode(ledRed1, OUTPUT);     
  pinMode(ledRed2, OUTPUT);     
  pinMode(ledGreen, OUTPUT);     

  Serial.begin(9600);
}

// the loop routine runs over and over again forever:
void loop() {
  AdvanceLED();
  delay(1000);               // wait for a second
}


void AdvanceLED()
{
  static int nState=0; 
  
  if (nState>2)
  {
    nState = 0;
  }
  
  digitalWrite(ledRed1, LOW);
  digitalWrite(ledRed2, LOW);
  digitalWrite(ledGreen, LOW);
  
  switch (nState)
  {
    case 0:
      digitalWrite(ledRed1, HIGH);
      Serial.println("Case 0");
      break;
    case 1:
      digitalWrite(ledRed2, HIGH);
      Serial.println("Case 1");
      break;
    case 2:
      digitalWrite(ledGreen, HIGH);
      Serial.println("Case 2");
      break;
    default: 
      digitalWrite(ledRed1, HIGH);
      digitalWrite(ledRed2, HIGH);
      Serial.println("Default");
  }

  nState++;
}
