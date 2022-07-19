/*
  Pointer.ino
  
  Simple loop that demonstrates pointers (to an array) work with Arduino.
 
  History:
  10/22/2014 Removed LED flashing code since it's not relvant
 */
 
// Constants
int ledDiagnostic = 13;      // Assign a constant to the onboard LED (pin 13)

// Global variables
int gnCycleNumber = 0;
byte ar[8] = {1,2,3,4,5,6,7,8};
byte val = 0;
byte pVal = NULL;

// Add initialization code to be run once.
void setup()
{                
  pinMode(ledDiagnostic, OUTPUT);          // initialize the digital pin as an output.     
  Serial.begin(9600);                      // initialize the serial connection to the PC for debug messages.
  Serial.flush();
}

// Add code to be run over and over (the game loop)
void loop()
{
  delay(2000);                             // wait for a second
  
  val = ar[0];
  pVal = ar[4];
  
  Serial.print("Cycle #");
  Serial.println(pVal);
}
