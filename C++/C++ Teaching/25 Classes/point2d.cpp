
#include <iostream>

using namespace std;

class Point2d
{
public:
    Point2d(int x, int y)
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
    
    int differeceInX(Point2d pt)
    {
        return this->getX() - pt.getX();
    }
    
    int differeceInX(Point2d *pt)
    {
        return this->getX() - pt->getX();
    }
    
    
private:
    int _x, _y;
};



int main()
{
    
    Point2d ptA(3, 4);
    Point2d ptB(7, 5);
    
    cout << ptB.differeceInX(ptA) << endl;
    
    return 0;
}
