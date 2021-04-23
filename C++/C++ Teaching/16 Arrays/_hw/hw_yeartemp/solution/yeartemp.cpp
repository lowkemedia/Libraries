
#include <iostream>

using namespace std;

const int MONTHS = 12;

/*
void getData(int twoDim[][2], int rows)
{
    cout << "Enter high temperature for each month" << endl;
    for (int i = 0; i < rows; ++i)
    {
        cin >> twoDim[i][0];
    }
    
    cout << "Enter low temperature for each month" << endl;
    for (int i = 0; i < rows; ++i)
    {
        cin >> twoDim[i][1];
    }
}
*/

float averageHigh(int twoDim[][2], int rows)
{
    float sum = 0;
    
    for (int i = 0; i < rows; ++i)
    {
        sum = sum + twoDim[i][0];
    }
    
    if (rows > 0)
    {
        return sum/rows;
    }
    else
    {
        return 0;
    }
}

float averageLow(int twoDim[][2], int rows)
{
    float sum = 0;
    
    for (int i = 0; i < rows; i++)
    {
        sum = sum + twoDim[i][1];
    }
    
    if (rows > 0)
    {
        return sum/rows;
    }
    else
    {
        return 0;
    }
}

int indexHighTemp(int twoDim[][2], int rows)
{
    int highIndex = 0;
    
    for (int i = 1; i < rows; i++)
    {
        if (twoDim[highIndex][0] < twoDim[i][0])
        {
            highIndex = i;
        }
    }
    return highIndex;
}

int indexLowTemp(int twoDim[][2], int rows)
{
    int lowIndex = 0;
    
    for (int i = 1; i < rows; i++)
    {
        if (twoDim[lowIndex][1] > twoDim[i][1])
        {
            lowIndex = i;
        }
    }
    return lowIndex;
}

int main()
{
    int hiLowArray[MONTHS][2];
    
    int indexHigh;
    int indexLow;
    
    // getData(hiLowArray, MONTHS);
    
    cout << "Enter high temperature for each month" << endl;
    for (int i = 0; i < MONTHS; ++i)
    {
        cin >> hiLowArray[i][0];
    }
    
    cout << "Enter low temperature for each month" << endl;
    for (int i = 0; i < MONTHS; ++i)
    {
        cin >> hiLowArray[i][1];
    }
    
    cout << "Average high temperature: "
         << averageHigh(hiLowArray, MONTHS) << endl;
    
    cout << "Average low temperature: "
         << averageLow(hiLowArray, MONTHS) << endl;
    
    indexHigh = indexHighTemp(hiLowArray, MONTHS);
    cout << "Highest temperature: " << hiLowArray[indexHigh][0] << endl;
    
    indexLow = indexLowTemp(hiLowArray, MONTHS);
    cout << "Lowest temperature: " << hiLowArray[indexLow][1] << endl;
    
    return 0;
}
