//
//  Abstract Class example
//

#include <iostream>

using namespace std;

const float PI = 3.14159265;


// Base class
class Shape
{
public:
    Shape(int x, int y)
    {
        _x = x;
        _y = y;
    }
    
    virtual ~Shape() = default;
    
    int getX() {
        return _x;
    }
    
    int getY() {
        return _y;
    }
    
    // Note: getArea() in Shape is pure virtual
    virtual float getArea() = 0;
    
private:
    int _x;
    int _y;
};



// Derived class
class Rectangle: public Shape
{
public:
    Rectangle(int x, int y,
              int width, int height) : Shape(x, y)
    {
        _width = width;
        _height = height;
    }
    
    float getArea()
    {
        cout << "Rectangle getArea():";
        return _width*_height;
    }
    
private:
    int _width;
    int _height;
};


// Derived class
class Circle: public Shape
{
public:
    Circle(int x, int y,
           int radius) : Shape(x, y)
    {
        _radius = radius;
    }
    
    float getArea()
    {
        cout << "Circle getArea():";
        return PI*_radius*_radius;
    }
    
private:
    int _radius;
};

int main()
{
    // Shape is an abstract class and we cannot
    //  dircetly create instances of it.
    // Shape *spot = new Shape(6, 6);
    
    Shape *rect = new Rectangle(5, 7, 8, 8);
    Shape *circ = new Circle(2, 3, 4);
    
    cout << "rect- ("
    << rect->getX() << ","
    << rect->getY() << ") "
    << rect->getArea() << endl;
    
    cout << "circ- ("
    << circ->getX() << ","
    << circ->getY() << ") "
    << circ->getArea() << endl;
    
    delete rect;
    delete circ;
    
    return 0;
}
