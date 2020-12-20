#ifndef UTILS_H
#define UTILS_H

#include "Matrix.h"
#include <iostream>
#include <ctime>
#define PI 3.14159265

// typedef Matrix<float>  fMatrix;                    // all Matrix in Astroids are of type float
typedef Point4D  fMatrix;

using namespace std;

void    wait (float seconds);                     // pause for seconds
bool    isPowerOfTwo(long num);                   // check if n is PowerOfTwo
void    randomizer();                             // random seed according to time
int     randomInt(int min, int max);              // random int generator between min and max
float   getGradient(float rise, float run);       // given a rise [y] and an run [x] return a gradient [m]
fMatrix getVelocity_Vel(float rise,               // return velocity vector given a gradient and a desired velocity
                        float run, 
                        float velocity);
int     incOrDec(int n, int dest, int max);       // if at n which direction (+ or -) is quickest to get to dest
int     angleToCell(float angle, int nCells);     // convert angle (degrees) to an animation cell number
float   FPS_to_Ticks(float fps);                  // convert frames per second to ticks per frame
float   findAngle(float rise, float run);         // get "z" angle given "y" rise and "x" run
float   radiansToDegrees(float rad);
float   degreesToRadians(float deg);
float   gradientOfLine(float x1, float y1, float x2, float y2);
float   getYOnALine(float x, float x1, float y1, float m); // find y, given x through the point x1, y1 with gradient m
float   getXOnALine(float y, float x1, float y1, float m); // find x, given y through the point x1,y1 with gradient m
                 


#endif // UTILS_H