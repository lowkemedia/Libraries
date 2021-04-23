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
    
    bool compare(Box *box)
    {
        return (this->getVolume() > box->getVolume());
    }
    
    private:
    double _length;   // Length of a box
    double _breadth;  // Breadth of a box
    double _height;   // Height of a box
};



int main()
{
    // memory allocated with new
    Box *ptrBox1 = new Box(5.0, 6.0, 7.0);
    Box *ptrBox2 = new Box(10.0, 12.0, 13.0);
    double volume;
    
    // volume of box 1
    volume = ptrBox1->getVolume();
    cout << "Volume of Box1 : " << volume << endl;
    
    // volume of box 2
    volume = ptrBox2->getVolume();
    cout << "Volume of Box2 : " << volume << endl;
    
    
    if (ptrBox1->compare(ptrBox2))
    {
        cout << "box2 is smaller than box1" << endl;
    }
    else
    {
        cout << "box2 is equal to or larger than box1" << endl;
    }
    
    // Note: if delete not called a memory leak occurs!
    delete ptrBox1;
    delete ptrBox2;
    
    return 0;
}
