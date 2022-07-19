/*
  lettersClass.ino
  
  A set of constants for displaying letters and numbers on an 8x8 matrix array.
  
  History:
  10/23/2014 -- Created
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
class letters
{
  private:
    static const int _numRows = 8;
    
  public:
    // Shapes
    static const byte A[_numRows];
    static const byte B[_numRows];
    static const byte C[_numRows];
    static const byte D[_numRows];
    static const byte E[_numRows];
    static const byte F[_numRows];
    static const byte G[_numRows];
    static const byte H[_numRows];
    static const byte I[_numRows];
    static const byte J[_numRows];
    static const byte K[_numRows];
    static const byte L[_numRows];
    static const byte M[_numRows];
    static const byte N[_numRows];
    static const byte O[_numRows];
    static const byte P[_numRows];
    static const byte Q[_numRows];
    static const byte R[_numRows];
    static const byte S[_numRows];
    static const byte T[_numRows];
    static const byte U[_numRows];
    static const byte V[_numRows];
    static const byte W[_numRows];
    static const byte X[_numRows];
    static const byte Y[_numRows];
    static const byte Z[_numRows];
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
  const byte letters::A[_numRows] = {126,255,231,231,255,255,231,231};
  const byte letters::B[_numRows] = {127,255,231,127,127,231,255,127};
  const byte letters::C[_numRows] = {126,255,231,7,7,231,255,126};
  const byte letters::D[_numRows] = {127,255,231,231,231,231,255,127};
  const byte letters::E[_numRows] = {255,255,7,63,63,7,255,255};
  const byte letters::F[_numRows] = {255,255,7,63,63,7,7,7};
  const byte letters::G[_numRows] = {126,255,231,7,247,231,255,126};
  const byte letters::H[_numRows] = {231,231,231,255,255,231,231,231};
  const byte letters::I[_numRows] = {28,28,28,28,28,28,28,28};
  const byte letters::J[_numRows] = {224,224,224,224,224,224,252,124};
  const byte letters::K[_numRows] = {199,231,119,63,63,119,231,199};
  const byte letters::L[_numRows] = {7,7,7,7,7,7,255,255};
  const byte letters::M[_numRows] = {195,231,255,255,219,195,195,195};
  const byte letters::N[_numRows] = {231,239,239,255,255,255,247,231};
  const byte letters::O[_numRows] = {126,255,231,231,231,231,255,126};
  const byte letters::P[_numRows] = {127,255,231,255,127,7,7,7};
  const byte letters::Q[_numRows] = {126,255,231,231,199,183,111,222};
  const byte letters::R[_numRows] = {127,255,231,255,127,231,231,231};
  const byte letters::S[_numRows] = {126,255,7,127,254,224,255,126};
  const byte letters::T[_numRows] = {127,127,28,28,28,28,28,28};
  const byte letters::U[_numRows] = {231,231,231,231,231,231,255,126};
  const byte letters::V[_numRows] = {231,231,231,231,231,231,126,60};
  const byte letters::W[_numRows] = {195,195,219,219,219,255,126,52};
  const byte letters::X[_numRows] = {231,231,126,60,60,126,231,231};
  const byte letters::Y[_numRows] = {231,231,231,126,60,24,24,24};
  const byte letters::Z[_numRows] = {255,255,120,60,30,15,255,255};

