/*
  Template.ino
  
  Turns on an LED on for one second, then off for one second, repeatedly.
 
  History:
  8/31/2014: Created for use as a template.
 */
 
// Constants
int ledDiagnostic = 13;      // Assign a constant to the onboard LED (pin 13)

// Global variables
int gnCycleNumber = 0;


// Add initialization code to be run once.
void setup()
{                
  pinMode(ledDiagnostic, OUTPUT);          // initialize the digital pin as an output.     
  Serial.begin(9600);                      // initialize the serial connection to the PC for debug messages.
}

// Add code to be run over and over (the game loop)
void loop()
{
    gnCycleNumber++;
  
  digitalWrite(ledDiagnostic, HIGH);       // turn the LED on (HIGH is the voltage level)
  delay(1000);                             // wait for a second
  digitalWrite(ledDiagnostic, LOW);        // turn the LED off by making the voltage LOW
  delay(1000);                             // wait for a second
  
  Serial.print("Cycle #");
  Serial.println(gnCycleNumber);
}
