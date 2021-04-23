////////
//
//  Russell's Utils.cc package   7/18/2002
//
//

#include <iostream>
#include <iomanip>
#include <cstdlib>
#include <ctime>


//
//  random seed according to time
//
void randomizer()
{
    time_t      timeval;
    
    time(&timeval);
    srand(timeval);
}


//
//  random generator
//
int randomInt(int min, int max)
{
    static bool seed = false;
        
    if (! seed) {
        randomizer();
        seed = true;
    }
    
    int range = (max + 1) - min;
    return (int) (( rand() / (double) RAND_MAX ) * range + min);
}


//
//  Get a string [str] of length maxLength
//
void getString(char * query, char * str, int maxLength)
{
    cout << query;                          // ask query
    
    cin >> ws;                              // remove all the white spaces
    cin.getline(str, maxLength);            // read characters until \n MAXSTR
}
    

//
//  reads an integer from the keyboard,
//  uses error checking to ensure value is between minValue and maxValue
//
int getInt(char askStr[], int minValue, int maxValue)
{
    int mVar;
    bool inputOK = false;
    
    while (! inputOK) { 
        
        cout << askStr;                     // ask query
        cin >> mVar;                        // get input
        
        if ( (mVar >= minValue && mVar <= maxValue) )
            inputOK = true;                 // input OK, exit loop
        else {
            cout << "Bad input: please enter a value between "
                 << minValue << " and " << maxValue << endl;
            cin.clear();                    // clear error [see  cin.fail();]
            cin.ignore(80, '\n');           // empty buffer
        }
    }
    
    return mVar;
}


//
//  reads a list of integers from the keyboard,
//
int getIntList(char askStr[], int * intList, int endSig, int maxList)
{
    int  v = 0, n = 0;
    char c = '\0';
    
    // seed first value as 0
    *intList = 0;
    intList++;
    
    cout << askStr;
    
    do {
        cin >> v;
        c = cin.get();
        
        if ( cin.fail() ) {
            cout << "BAD input." << endl;
            cin.clear();                    // clear error
            cin.ignore(80, '\n');           // empty buffer
            return -1;
        } else {
            *intList = v;
            intList++;
            n++;
        }
    } while ( c != '\n' && n < MAXENTERIES);
    
    return n;
}


//
//  convert base
//
void writeBase(int n, int base)
{
    if (n >= base) {
        writeBase( (n / base) , base );
    }
    
    switch(n % base)
    {
        case 0:  cout << '0'; break;
        case 1:  cout << '1'; break;
        case 2:  cout << '2'; break;
        case 3:  cout << '3'; break;
        case 4:  cout << '4'; break;
        case 5:  cout << '5'; break;
        case 6:  cout << '6'; break;
        case 7:  cout << '7'; break;
        case 8:  cout << '8'; break;
        case 9:  cout << '9'; break;
        case 10: cout << 'A'; break;
        case 11: cout << 'B'; break;
        case 12: cout << 'C'; break;
        case 13: cout << 'D'; break;
        case 14: cout << 'D'; break;
        case 15: cout << 'F'; break;
    }
    // ...or cout << char( n + '0' ) for val between 0-9
}


//
//  print the date/time
//
void myTime()
{
    time_t      timeval;
    
    time(&timeval);
    cout << ctime(&timeval) << endl;
    cout << timeval << endl;
}


//
// convert Farenheit to Kelvin
//
double farenheitToKelvin(int farenheit)
{
    double kelvin;

    // calc to temp in Kelvin
    kelvin = ( (double) farenheit - 32) * 5 / 9 + 273.16;

    return kelvin;
}


//
//  set cout to display up to [percision] decimal places
//
void setDecPlace(int percision)
{
    // "formula" for precision notation
    cout.setf(ios::fixed);
    cout.setf(ios::showpoint);
    cout.precision(percision);
}


//
// prints the array
//
void printArray(int * array, int n)
{
    cout << "{ ";
    for (int i = 0; i < n; i++) {
        cout << array[i] << " ";
    }
    cout << "}" << endl;
}


//
//  returns true if [int y] is a leap year
//
bool leapYear(int y)
{ 
    return ((( y % 4 ==0) && (y % 100 ) != 0)
               ||  ((y % 400 ) == 0 ))  ;
}


//
//  printTree
//  Note: tree array starts at 1
void printTree(int * array, int n)
{
    int    width = 80, shift = width / 2;
    int    lineCount = 0;
    double breakAt   = 0;
    bool   nwLine    = true;
    
    for (int i = 1; i <= n ; i++) {
    
        if (nwLine) {
            cout << setw(shift) << array[i];
            nwLine = false;
        } else {
            cout << setw(width) << array[i];
        }
        
        if ( i == breakAt + 1) {
        
            lineCount++;
            width = shift;
            shift = shift / 2;
            if (shift < 3) {
                shift = 3;
            }
            breakAt += pow(2, lineCount);
            
            cout << endl;
            nwLine = true;
        }
    }
    cout << endl;
}


//
// swap - swap the values of two variables.
// Used by several of the sorting algorithms below.
//
template <class elt>
void swap(elt& a, elt& b)
{
    elt temp;
    temp = a;
    a = b;
    b = temp;
}


//
// recursive sift function
//
void sift(int array[], int start, int end)
{
    int item, leftPos, rightPos, childPos;
    
    leftPos    = ( start * 2     > end ? -1 : start * 2 );
    rightPos   = ( start * 2 + 1 > end ? -1 : start * 2 + 1);
    
    // default to left child
    childPos   = leftPos;
    
    // if left child empty use right child
    if (leftPos == -1) {
        childPos = rightPos;
    }
    
    // If right larger than left, use right
    if ( (leftPos > -1 && rightPos > -1) && array[rightPos] > array[leftPos] ) {
        childPos = rightPos;
    }

    // check if at end of tree, or sorted
    if (childPos == -1 || array[start] > array[childPos]) {
        // finished;
    } else {

        // assuming tree was previously sorted
        swap(array[start], array[childPos]);        // swap
        sift(array, childPos, end);                 // sift down
    }
}


//
// makeHeap - Construct a heap from the unsorted array.
//
template <class elt>
void makeHeap(elt arr[], int num_objects)
{
    // Construct a heap from the unsorted array.
    for (int left = num_objects/2; left >= 1; left--) {
        sift(arr, left, num_objects);
    }
}


//
// HeapSort - perform heap sort on the specified array.
//
template <class elt>
void HeapSort(elt arr[], int num_objects)
{
    // Construct a heap from the unsorted array.
    for (int left = num_objects/2; left >= 1; left--) {
        sift(arr, left, num_objects);
    }

    // Repeatedly put elements in their correct positions.
    for (int right = num_objects; right >= 2; right--) {
        swap(arr[1], arr[right]);  // Put the top element in position
        sift(arr, 1, right - 1);  // Rebuild heap
    }

}


/////


void setBit(int& bits, int val)
{
    bits |= (1 << val);
}


void clearBit(int& bits, int val)
{
    bits &= ((1 << val) ^ 255);
}


bool getBit(int bits, int val)
{
    return (bits & (1 << val) );
}

////
//
// Init all values in array to '\0'
//
void initArray(char mArray[], int arraySize)
{
    int i;
    for (i = 0;  i <= arraySize-1 ; i++)
            mArray[i] = '\0';
}

//
// Trim leading and trailing whitespace (including '\n')
//
void trimWhiteSpace(char source[])
{    
    int  i;
    char target[BUFLEN];
    
    // strip trailing whitespace
    for (i = strlen(source)-1; isspace((int)source[i]) && i >= 0 ; i-- ) {
            source[i] = '\0';
    }

    // count leading whitespace
    for (i = 0; isspace((int)source[i]) ; i++) {
    }

    // copy into target
    strcpy(target, &source[i]);

    // copy back to source
    strcpy(source, target);
}