//
//  Box class
//

#include <iostream>
using namespace std;

class Box
{
    public:
    Box(double length,      // constructor
        double breadth,
        double height)
    {
        cout << "Box object being created." << endl;
        _length = length;
        _breadth = breadth;
        _height = height;
    }
    
    ~Box()                  // destructor
    {
        cout << "Box object being deleted." << endl;
    }
    
    double getVolume()
    {
        return _length*_breadth*_height;
    }
    
    /* compare() method by value
    bool compare(Box box)
    {
        return (this->getVolume() > box.getVolume());
    }
    */
    
    // compare() method by reference
    bool compare(Box *box)
    {
        return (this->getVolume() > box->getVolume());
    }
    
    private:
    double _length;   // Length of a box
    double _breadth;  // Breadth of a box
    double _height;   // Height of a box
};



int main( )
{
    Box box1(5.0, 6.0, 7.0);        // Declare Box1 of type Box
    Box box2(10.0, 12.0, 13.0);     // Declare Box2 of type Box
    double volume;
    
    // volume of box 1
    volume = box1.getVolume();
    cout << "Volume of Box1 : " << volume <<endl;
    
    // volume of box 2
    volume = box2.getVolume();
    cout << "Volume of Box2 : " << volume <<endl;
    
    if (box1.compare(&box2))
    {
        cout << "box2 is smaller than box1" << endl;
    }
    else
    {
        cout << "box2 is equal to or larger than box1" << endl;
    }
    
    return 0;
}
