//
//  Magic Square
//

#include <iostream>
using namespace std;

static const int SQUARE_SIZE = 3;

void askMagicSquareInput(int arr2d[][SQUARE_SIZE])
{
    cout << "Enter numbers for your " << SQUARE_SIZE << " x "
         << SQUARE_SIZE << " magic square" << endl;
    
    for (int y = 0; y < SQUARE_SIZE; ++y)
    {
        for (int x = 0; x < SQUARE_SIZE; ++x)
        {
            cin >> arr2d[x][y];
        }
    }
}

void printMagicSquare(int arr2d[][SQUARE_SIZE])
{
    cout << "Your square looks like this:" << endl;
    for (int y = 0; y < SQUARE_SIZE; ++y)
    {
        for (int x = 0; x < SQUARE_SIZE; ++x)
        {
            cout << " " << arr2d[x][y];
        }
        cout << endl;
    }
}

int sumRow(int row, int arr2d[][SQUARE_SIZE])
{
    int sum = 0;
    for (int x = 0; x < SQUARE_SIZE; ++x)
    {
        sum += arr2d[x][row];
    }
    return sum;
}

int sumColumn(int column, int arr2d[][SQUARE_SIZE])
{
    int sum = 0;
    for (int y = 0; y < SQUARE_SIZE; ++y)
    {
        sum += arr2d[column][y];
    }
    return sum;
}

int sumDiagonal(bool inverse, int arr2d[][SQUARE_SIZE])
{
    int sum = 0;
    for (int i = 0; i < SQUARE_SIZE; ++i)
    {
        if (inverse)
        {
            sum += arr2d[SQUARE_SIZE - i - 1][SQUARE_SIZE - i - 1];
        }
        else
        {
            sum += arr2d[i][i];
            
        }
    }
    return sum;
}

bool checkMagicSquare(int magicNumber, int arr2d[][SQUARE_SIZE])
{
    // check rows and columns
    for (int i = 0; i < SQUARE_SIZE; ++i)
    {
        if (sumRow(i, arr2d) != magicNumber ||
            sumColumn(i, arr2d) != magicNumber)
        {
            return false;
        };
    }
    
    // check diagonals
    if (sumDiagonal(false, arr2d) != magicNumber ||
        sumDiagonal(true, arr2d) != magicNumber)
    {
        return false;
    };
    
    // OK, is magic square
    return true;
}

int main()
{
    int magicSquare[SQUARE_SIZE][SQUARE_SIZE]; // = {{8, 3, 4}, {1, 5, 9}, {6, 7, 2}};
    
    askMagicSquareInput(magicSquare);
    printMagicSquare(magicSquare);
    
    // magic number is sum of any row, column, or diagonal
    int magicNumber = sumRow(0, magicSquare);
    
    bool isMagicSquare = checkMagicSquare(magicNumber, magicSquare);
    if (isMagicSquare)
    {
        cout << "Your sqaure IS a magic square with value " << magicNumber
             << " in every direction." << endl;
    }
    else
    {
        cout << "Your sqaure is NOT a magic square." << endl;
    }
    
    return 0;
}
