//
//  king.cpp
//

#include "king.hpp"
#include "piece.hpp"
#include <iostream>
#include <iomanip>

using namespace std;

King::King(int row, int column, char type) : Piece(row, column, type)
{
    cout << "King object being created. " << this << endl;
}

char King::getSymbolAt(int indexRow, int indexColumn)
{
    if (indexColumn == mColumn && indexRow == mRow)
    {
        return mType;
    }
    else if (indexColumn >= mColumn - 1 &&
             indexColumn <= mColumn + 1 &&
             indexRow >= mRow - 1 &&
             indexRow <= mRow + 1)
    {
        return 'X';
    }
    else
    {
        return ' ';
    }
}
