//
//  queen.cpp
//

#include "queen.hpp"
#include "piece.hpp"
#include <iostream>
#include <iomanip>

using namespace std;

Queen::Queen(int row, int column, char type) : Piece(row, column, type)
{
    cout << "Queen object being created. " << this << endl;
}

char Queen::getSymbolAt(int indexRow, int indexColumn)
{
    if (indexColumn == mColumn && indexRow == mRow)
    {
        return mType;
    }
    
    int rowDiff = mRow - indexRow;
    int columnDiff = mColumn - indexColumn;
    
    if (columnDiff == 0 || rowDiff == 0)
    {
        return 'X';
    }
    else if (columnDiff + rowDiff == 0 ||
             columnDiff == rowDiff)
    {
        return 'X';
    }
    else
    {
        return ' ';
    }
}
