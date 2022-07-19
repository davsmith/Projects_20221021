/*
  Class_Morse.ino
  
  Experimenting with organizing code into classes.
 
  History:
  10/12/2014: Created from template.
 */
 
// Constants
int ledDiagnostic = 13;      // Assign a constant to the onboard LED (pin 13)

// Global variables
int gnCycleNumber = 0;


class Morse
{
  public:
    Morse(int pin);
    void dot();
    void dash();
  private:
    int _pin;
};


Morse::Morse(int pin)
{
  pinMode(pin, OUTPUT);
  _pin = pin;
}

void Morse::dot()
{
  digitalWrite(_pin, HIGH);
  delay(250);
  digitalWrite(_pin, LOW);
  delay(250);  
}

void Morse::dash()
{
  digitalWrite(_pin, HIGH);
  delay(1000);
  digitalWrite(_pin, LOW);
  delay(250);
}

// Add initialization code to be run once.
Morse morse(13);

void setup()
{                
  pinMode(ledDiagnostic, OUTPUT);          // initialize the digital pin as an output.     
  Serial.begin(9600);                      // initialize the serial connection to the PC for debug messages.
}

// Add code to be run over and over (the game loop)
void loop()
{
  morse.dot(); morse.dot(); morse.dot();
  morse.dash(); morse.dash(); morse.dash();
  morse.dot(); morse.dot(); morse.dot();
  delay(3000);
}
