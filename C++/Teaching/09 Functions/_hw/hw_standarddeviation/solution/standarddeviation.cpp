
#include <iostream>
#include <math.h>

using namespace std;


double mean(double x1, double x2, double x3,
            double x4, double x5)
{
    return (x1 + x2 + x3 + x4 + x5)/5;
}

double standardDeviation(double x1, double x2, double x3,
                         double x4, double x5)
{
    double sd, mn;
    mn = mean(x1, x2, x3, x4, x5);
    sd = (pow((x1 - mn), 2) + pow((x2 - mn), 2) + pow((x3 - mn), 2) +
          pow((x4 - mn), 2) + pow((x5 - mn), 2))/5.0;
    sd = sqrt(sd);
    
    return sd;
}

int main()
{
    // declare variables
    double x1, x2, x3, x4, x5;
    
    cout << "Enter value of x1 = ";
    cin >> x1;
    
    cout << "Enter value of x2 = ";
    cin >> x2;
    
    cout << "Enter value of x3 = ";
    cin >> x3;
    
    cout << "Enter value of x4 = ";
    cin >> x4;
    
    cout << "Enter value of x5 = ";
    cin >> x5;
    
    cout << "The mean value is: " << mean(x1, x2, x3, x4, x5) << endl;
    cout << "The standard deviation is: " << standardDeviation(x1, x2, x3, x4, x5) << endl;
    
}
