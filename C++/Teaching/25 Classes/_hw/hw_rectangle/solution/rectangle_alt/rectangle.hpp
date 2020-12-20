//
//  rectangle.hpp
//

#ifndef rectangle_hpp
#define rectangle_hpp

static const float VALUE_MAX = 20.0;

class Rectangle
{
    
public:
    Rectangle();
    ~Rectangle();
    
    float getWidth();
    float getLength();
    float getPerimeter();
    float getArea();
    
    void setWidth(float value);
    void setLength(float value);

    void print();
    
private:
    
    bool isValueLegal(float value);
    
    float mWidth = 1;
    float mLength = 1;
};

#endif
