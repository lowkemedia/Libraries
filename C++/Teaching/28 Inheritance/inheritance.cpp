//
//  Inheritance example
//

#include <iostream>

using namespace std;

const float PI = 3.14159265;

//
// Base class
//
class Shape
{
    public:
        Shape(int x, int y)
        {
            _x = x;
            _y = y;
        }
    
        int getX() {
            return _x;
        }
    
        int getY() {
            return _y;
        }
    
        virtual float getArea()
        {
            cout << "getArea():";
            return 0;
        }
    
    private:
        int _x;
        int _y;
};


//
// Derived class
//
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


//
// Derived class
//
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


int main(void)
{
    Shape spot(6, 6);
    Rectangle rect(5, 7, 8, 8);
    Circle circ(2, 3, 4);
    
    cout << "spot- ("
         << spot.getX() << ","
         << spot.getY() << ") "
         << spot.getArea() << endl;
    
    cout << "rect- ("
         << rect.getX() << ","
         << rect.getY() << ") "
         << rect.getArea() << endl;
    
    cout << "circ- ("
         << circ.getX() << ","
         << circ.getY() << ") "
         << circ.getArea() << endl;
    
    return 0;
}

/*
int main()
{
    Shape *pShape;
    Rectangle rect(5, 7, 10, 7);
    Circle circ(2, 3, 4);
    
    // store the address of rect and print
    pShape = &rect;
    cout << pShape->getArea() << endl;
    
    // store the address of circ and print
    pShape = &circ;
    cout << pShape->getArea() << endl;
    
    return 0;
}
 */
