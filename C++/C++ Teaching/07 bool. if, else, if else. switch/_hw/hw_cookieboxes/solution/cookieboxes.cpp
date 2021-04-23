
#include <iostream>
#include <iomanip>

using namespace std;

const int NUMBER_OF_COOKIES_IN_BOX = 24;
const int CONTAINER_CAPACITY = 75;

int main()
{
    int numberOfCookies;
    cout << "Enter the total number of cookies: ";
    cin >> numberOfCookies;
    cout << endl;
    
    int numberOfBoxes = numberOfCookies/NUMBER_OF_COOKIES_IN_BOX;
    int leftoverCookies = numberOfCookies%NUMBER_OF_COOKIES_IN_BOX;
    cout << "The number of cookie boxes needed to hold the cookies: "
         << numberOfBoxes << endl;
    
    if (leftoverCookies > 0)
    {
        cout << "Leftover cookies: " << leftoverCookies << endl;
    }
    
    
    int numberOfContainers = numberOfBoxes/CONTAINER_CAPACITY;
    int leftoverBoxes = numberOfBoxes%CONTAINER_CAPACITY;
    cout << "The number of containers needed to store the cookie boxes: "
         << numberOfContainers << endl;
    
    if (leftoverBoxes > 0)
    {
        cout << "Leftover boxes: " << leftoverBoxes << endl;
    }
    
    return 0;
}
