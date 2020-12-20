//
//  knight.cpp
//

#include "knight.hpp"
#include "piece.hpp"
#include <iostream>
#include <iomanip>

using namespace std;

Knight::Knight(int row, int column, char type) : Piece(row, column, type)
{
    cout << "Knight object being created. " << this << endl;
}

char Knight::getSymbolAt(int indexRow, int indexColumn)
{
    if (indexColumn == mColumn && indexRow == mRow)
    {
        return mType;
    }
    
    int rowDiff = mRow - indexRow;
    int columnDiff = mColumn - indexColumn;
    
    if ((columnDiff*columnDiff + rowDiff*rowDiff == 5)
        || (columnDiff == 0 && rowDiff == 0))
    {
        return 'X';
    }
    else
    {
        return ' ';
    }
}
