//
//  bishop.cpp
//

#include "bishop.hpp"
#include "piece.hpp"
#include <iostream>
#include <iomanip>

using namespace std;

Bishop::Bishop(int row, int column, char type) : Piece(row, column, type)
{
    cout << "Bishop object being created. " << this << endl;
}

char Bishop::getSymbolAt(int indexRow, int indexColumn)
{
    if (indexColumn == mColumn && indexRow == mRow)
    {
        return mType;
    }
    
    int rowDiff = mRow - indexRow;
    int columnDiff = mColumn - indexColumn;
    
    if (columnDiff + rowDiff == 0 ||
        columnDiff == rowDiff)
    {
        return 'X';
    }
    else
    {
        return ' ';
    }
}
