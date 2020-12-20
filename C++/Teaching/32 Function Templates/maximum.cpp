//
//  Function Templates
//

#include <iostream>
using namespace std;

template <typename T> // or  template <class T>
T maximum(T valuel, T value2, T value3)
{
    T maximumValue = valuel;		// assume valuel is maximum
    
    // determine whether value2 is greater than maximumValue
    if (value2 > maximumValue)
    {
        maximumValue = value2;
    }
    
    // determine whether value3 is greater than maximumValue
    if (value3 > maximumValue)
    {
        maximumValue = value3;
    }
    
    return maximumValue;
}


int main()
{
    // demonstrate maximum() int values
    cout << "Input three integer values: ";
    
    int int1, int2, int3;
    cin >> int1 >>  int2 >> int3;
    
    // invoke int version of maximum
    cout << "The maximum integer value is: " << maximum(int1, int2, int3) << endl;
    cout << endl;
    
    // demonstrate maximum() double values
    cout << "Input three double values: ";
    
    double double1, double2, double3;
    cin >> double1 >>  double2 >> double3;
    
    // invoke int version of maximum
    cout << "The maximum double value is: " << maximum(double1, double2, double3) << endl;
    cout << endl;
    
    // demonstrate maximum() char values
    cout << "Input three characters: ";
    
    char char1, char2, char3;
    cin >> char1 >>  char2 >> char3;
    
    // invoke char version of maximum
    cout << "The maximum char value is: " << maximum(char1, char2, char3) << endl;
    cout << endl;
    
    return 0;
}

