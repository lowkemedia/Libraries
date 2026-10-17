//
//  animal.hpp
//

#ifndef animal_hpp
#define animal_hpp

#include <stdio.h>
#include <iostream>

using namespace std;

class Animal
{
private:
    int mPosition = 0;
    
public:
    int getPosition();
    void setPosition(int pos);
    
protected:
    void changePosition(int newPos);
    
};

#endif /* animal_hpp */
