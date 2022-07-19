/*
  Template.ino
  
  Turns on an LED on for one second, then off for one second, repeatedly.
 
  History:
  8/31/2014: Created for use as a template.
 */
 
// Constants
int ledDiagnostic = 3;      // Assign a constant to the onboard LED (pin 13)
int swPushButton1 = 2;

// Global variables
int gnCycleNumber = 0;


// Add initialization code to be run once.
void setup()
{                
  pinMode(ledDiagnostic, OUTPUT);          // initialize the digital pin as an output.     
  pinMode(swPushButton1, INPUT);           // Pushbutton switch
  Serial.begin(9600);                      // initialize the serial connection to the PC for debug messages.
}

// Add code to be run over and over (the game loop)
void loop()
{

  Serial.println(digitalRead(swPushButton1));
  if (swPushButton1 == HIGH)
  {
     digitalWrite(ledDiagnostic, HIGH);
     Serial.print("Setting pin ");
     Serial.print(ledDiagnostic);
     Serial.println(" HIGH");  
  }
  else
  {
     digitalWrite(ledDiagnostic, HIGH);
     Serial.print("Setting pin ");
     Serial.print(ledDiagnostic);
     Serial.println(" LOW");  
  }
  
  Serial.print("Cycle #");
  Serial.println(gnCycleNumber);
  delay(500);
}
