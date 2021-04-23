//
// utils.cpp: utility functions for use with Animator
//
//
//      AUTHOR: Russell Lowke
//
//        Date: Jan 20th 2005
//

#include "utils.h"

// pause for seconds
void wait(float seconds) {
    clock_t endwait = clock() + (clock_t) (seconds * CLK_TCK);
    while (clock() < endwait) {}
}


// check if n isPowerOfTwo
bool isPowerOfTwo(long n) {
    while (n > 1) {
        if (n % 2) break;
        n >>= 1;
    }
    return(n == 1);
}

//  random seed according to time
void randomizer() {
    time_t  timeval;
    time(&timeval);
    srand( (unsigned int) timeval);
}


//  random int generator between min and max
int randomInt(int min, int max) {
    static bool seed = false;
                
    if (! seed) {
        randomizer();
        seed = true;
    }
            
    int range = (max + 1) - min;
    return (int) (( rand() / (double) RAND_MAX ) * range + min);
}

// given a rise [y] and an run [x] return a gradient [m]
float getGradient(float rise, float run) {
    if (rise == 0)
        return 0;
    else if (run == 0)
        return rise;            // infinity
    return rise / run;          // m = (rise / run)
}

// return velocity vector given a gradient and a desired velocity
fMatrix getVelocity_Vel(float rise, float run, float velocity) {
    float m     = getGradient(rise, run);
    float angle = atan(m);

    float nX = 0;
    float nY = 0;

    if (run > 0 && rise < 0) {
        nX = cos(angle) * velocity;
        nY = sin(angle) * velocity;
    } else if (run < 0 && rise < 0 || run < 0 && rise > 0) {
        nX = 0 - cos(angle) * velocity;
        nY = 0 - sin(angle) * velocity;
    } else if (run > 0 && rise > 0) {
        nX = cos(angle) * velocity;
        nY = sin(angle) * velocity;
    }

    return fMatrix(nX, nY, 0.0);
}

// given a looping sequence in both directions with a range of max
// if at n which direction (+ or -) is quickest to get to dest
int incOrDec(int n, int dest, int max) {

    if (n == dest) { return 0; }

    for (int i = n, j = n; true ; --i, ++j ) {
        if ( i == -1   ) { i = max-1; }
        if ( j == max  ) { j = 0; }
        if ( i == dest ) { return -1; }
        if ( j == dest ) { return +1; }
    }
}

// convert angle (degrees) to an animation cell number
// with 0 degrees [north] being 0
int angleToCell(float angle, int nCells) {
    float increments    = (float) 361.0 / nCells;
    float adjustedAngle = (angle + (increments / 2));
    if (adjustedAngle > 360) { adjustedAngle -= 360; }
    float f = adjustedAngle / increments;
    return (int) f;
}

// convert frames per second to ticks per frame
float FPS_to_Ticks(float fps) {
    if (fps == 0) {
        return 0;   // avoid divide by zero
    } else {
        return (float) (60.0 / abs(fps));
    }
}

// get "z" angle given "y" rise and "x" run
float findAngle(float rise, float run) {
    float angle = 0;

    if (rise == 0) {
        if (run == 0) {
            angle = 0;      // stationary
        } else if (run > 0) {
            angle = 270;
        } else if (run < 0) {
            angle = 90;
        }
    } else if (run == 0) {
        if (rise > 0) {
            angle = 0;
        } else if (rise < 0) {
            angle = 180;
        }
    } else {

        float radians = abs(atan(rise / run));
        float degrees = radiansToDegrees(radians);

        if (run < 0 && rise > 0)      { angle = 90 - degrees; }  // +y -x
        else if (run < 0 && rise < 0) { angle = 90 + degrees; }  // -y -x
        else if (run > 0 && rise < 0) { angle = 270 - degrees; } // -y +x
        else if (run > 0 && rise > 0) { angle = 270 + degrees; } // +y +x
    }

    return angle;
}
float radiansToDegrees(float rad) {
    return ((rad * 360) / (float) (2 * PI) );
}
float degreesToRadians(float deg) {
    return (float) ((2 * PI * deg) / 360);
}
float gradientOfLine(float x1, float y1, float x2, float y2) {
  float rise = y2 - y1;
  float run  = x2 - x1;
  return getGradient(rise, run);
}

// find y, given x through the point x1, y1 with gradient m
float getYOnALine(float x, float x1, float y1, float m) {
    return m * (x - x1) + y1;
}

// find x, given y through the point x1,y1 with gradient m
float getXOnALine(float y, float x1, float y1, float m) {
    if (m == 0)
        return 0;               // avoid divide by zero
    else
        return x1 + (y - y1) / m;       
}