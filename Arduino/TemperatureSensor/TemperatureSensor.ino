/*
  Love-O-Meter.ino
  
  Uses TMP sensor to determine body temperature of user.
 
  History:
  8/31/2014: Created for experimentation.
 */
 
// Constants
const int ledDiagnostic = 13;      // Assign a constant to the onboard LED (pin 13)
const int tmp1 = A0;
const int led1 = 2;
const int led2 = 3;
const int led3 = 4;

// Global variables
int gnCycleNumber = 0;


void SetLEDs(bool bOn = false)
{
  if (bOn == true)
  {
    digitalWrite(led1, HIGH);
    digitalWrite(led2, HIGH);
    digitalWrite(led3, HIGH); 
  }
  else
  {
    digitalWrite(led1, LOW);
    digitalWrite(led2, LOW);
    digitalWrite(led3, LOW); 
  }
}

// Add initialization code to be run once.
void setup()
{                
  
  for (int n=2; n<5; n++)
  {
    pinMode(n, OUTPUT);
    digitalWrite(n, LOW);
  }
  
  Serial.begin(9600);                      // initialize the serial connection to the PC for debug messages.
}

// Add code to be run over and over (the game loop)
void loop()
{
  int nSensorVal=0;
  static int nAmbient=0;
    
  gnCycleNumber++;
 
  SetLEDs(false);
  
  nSensorVal = analogRead(tmp1); 

  if (nAmbient==0)
  {
    nAmbient = nSensorVal;
    Serial.print("Setting ambient value to ");
    Serial.println(nAmbient);
  }
 
  if ((nSensorVal - nAmbient) >= 2)
  {
    digitalWrite(led1, HIGH);
    digitalWrite(led2, LOW);
    digitalWrite(led3, LOW);    
    Serial.println("Lighting up LED 1");
  }

  if ((nSensorVal - nAmbient) >= 4)
  {
    digitalWrite(led1, HIGH);
    digitalWrite(led2, HIGH);
    digitalWrite(led3, LOW);    
    Serial.println("Lighting up LED 2");
  }

  if ((nSensorVal - nAmbient) >= 6)
  {
    digitalWrite(led3, HIGH);
    digitalWrite(led3, HIGH);
    digitalWrite(led3, HIGH);
    Serial.println("Lighting up LED 3");
  }

  Serial.print("A0 = ");
  Serial.println(tmp1);
  Serial.print("Current temp: ");
  Serial.println(nSensorVal);
  
  delay(1000);
}
