//
//  Rectangle
//

#include <iostream>
#include <iomanip>
using namespace std;

static const float VALUE_MAX = 20.0;

class Rectangle
{
    
public:
    Rectangle()
    {
        cout << "Rectangle created " << this << endl;
    }
    
    ~Rectangle()
    {
        cout << "Rectangle destroyed " << this << endl;
    }
    
    float getWidth()
    {
        return mWidth;
    }
    
    float getLength()
    {
        return mLength;
    }
    
    float getPerimeter()
    {
        return 2*mWidth + 2*mLength;
    }
    
    float getArea()
    {
        return mWidth*mLength;
    }
    
    void setWidth(float value)
    {
        if (isValueLegal(value))
        {
            mWidth = value;
        }
        else
        {
            cout << "Rectangle width must be > 0 and <= " << VALUE_MAX << endl;
        }
    }
    
    void setLength(float value)
    {
        if (isValueLegal(value))
        {
            mLength = value;
        }
        else
        {
            cout << "Rectangle length must be > 0 and <= " << VALUE_MAX << endl;
        }
    }
    
    void print()
    {
        cout << "Rectangle: " << this << endl;
        cout << " { width:" << mWidth << ", length: " << mLength << ", ";
        cout << "perimeter: " << getPerimeter() << ", area: " << getArea() << " }" << endl;
    }
    
private:
    
    bool isValueLegal(float value)
    {
        if (value > 0.0 && value <= VALUE_MAX)
        {
            return true;
        }

        return false;
    }
    
    float mWidth = 1;
    float mLength = 1;
};

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

