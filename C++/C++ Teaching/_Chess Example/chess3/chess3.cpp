//
//  Chess Game - Part 3
//

#include <iomanip>
#include <iostream>
using namespace std;

const int BOARD_SIZE = 8;

// pieces
const char ROOK = 'R';
const char KNIGHT = 'N';
const char BISHOP = 'B';
const char QUEEN = 'Q';
const char KING = 'K';

int askInt(int min, int max)
{
    int value = 0;
    while (true)
    {
        cout << "Enter a number from " << min << " to " << max << ": ";
        cin >> value;
        if (value >= min && value <= max)
        {
            return value;
        }
        cout << "Invalid value. Try again. " << endl;

    };
}


bool isValidType(char type)
{
    switch (type)
    {
        case ROOK:
        case KNIGHT:
        case BISHOP:
        case QUEEN:
        case KING:
            return true;
            
        default:
            return false;
    }
}


char askType()
{
    char type;
    while (! isValidType(type))
    {
        cout << "Enter a letter for the piece type: ";
        cin >> type;
        type = toupper(type);
        
        if (! isValidType(type))
        {
            cout << "Invalid type. Try again. " << endl;
        }
    }
    
    return type;
}


int main()
{
    //
    // ask row
    cout << "Type the row where your chess piece is located." << endl;
    int row = askInt(1, BOARD_SIZE);
    cout << endl;
    
    //
    // ask column
    cout << "Type the column where your chess piece is located." << endl;
    int column = askInt(1, BOARD_SIZE);
    cout << endl;
    
    //
    // ask type
    cout << "Type " << ROOK << " for a Rook attack, " << endl;
    cout << KNIGHT << " for a Knight, " << endl;
    cout << BISHOP << " for a Bishop, " << endl;
    cout << QUEEN << "  for a Queen, " << endl;
    cout << "and " << KING << " for King." << endl;
    char type = askType();
    
    
    //
    // draw board
    cout << "\n   1 2 3 4 5 6 7 8\n";
    
    int indexRow, indexColumn, rowDiff, columnDiff;
    
    for (indexRow = 1; indexRow <= BOARD_SIZE; ++indexRow)
    {
        // print two spaces and then the row number
        cout << setw(2) << indexRow;
        
        rowDiff = row - indexRow;
        for (indexColumn = 1; indexColumn <= BOARD_SIZE; ++indexColumn)
        {
            
            columnDiff = column - indexColumn;
            bool isSpot = false;
            
            switch (type)
            {
                case ROOK:
                    break;
                    
                case BISHOP:
                    if (columnDiff + rowDiff == 0 ||
                        columnDiff == rowDiff)
                    {
                        isSpot = true;
                    }
                    break;
                    
                case QUEEN:
                    break;
                    
                case KING:
                    if (indexColumn >= column - 1 &&
                        indexColumn <= column + 1 &&
                        indexRow >= row - 1 &&
                        indexRow <= row + 1)
                    {
                        isSpot = true;
                    }
                    
                    /* Another solution for KING might be,
                    if ((columnDiff >= -1 &&
                         columnDiff <=  1 &&
                         rowDiff >= -1 &&
                         rowDiff <=  1))
                    {
                        isSpot = true;
                    }
                    */
                    break;
                    
                case KNIGHT:
                    if ((columnDiff*columnDiff + rowDiff*rowDiff == 5) ||
                        (columnDiff == 0 && rowDiff == 0))
                    {
                        isSpot = true;
                    }
                    break;
            }
            
            if (isSpot == true)
            {
                // capture square
                cout << " X";
            }
            else if ((indexColumn + indexRow)%2 == 0)
            {
                // black square
                cout << " -";
            }
            else
            {
                // white square
                cout << " .";
            }
        }
        
        cout << endl;
    }
    cout << endl;
    
    return 0;
}
