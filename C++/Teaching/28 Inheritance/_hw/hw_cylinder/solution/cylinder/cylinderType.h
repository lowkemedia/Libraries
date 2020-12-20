
#ifndef cylinderType_H
#define cylinderType_H

#include "circleType.h"

class cylinderType: public circleType
{
public:
    void print();
    void setHeight(double);
    double getHeight();
    double volume();
    double area();
      //returns surface area
    cylinderType(double = 0, double = 0);

private:
    double height;
};

#endif
