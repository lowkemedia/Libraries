//
//  Rectangle
//

#include "rectangle.hpp"
#include <iostream>

using namespace std;

int main()
{
    Rectangle rect = Rectangle();
    
    float width;
    cout << "Rectangle width: ";
    cin >> width;
    rect.setWidth(width);
    
    float length;
    cout << "Rectangle length: ";
    cin >> length;
    rect.setLength(length);
    
    rect.print();
    
    return 0;
}
