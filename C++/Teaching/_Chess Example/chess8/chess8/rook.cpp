//
//  piece.cpp
//

#include "rook.hpp"
#include "piece.hpp"
#include <iostream>
#include <iomanip>

using namespace std;

Rook::Rook(int row, int column, char type) : Piece(row, column, type)
{
    cout << "Rook object being created. " << this << endl;
}

char Rook::getSymbolAt(int indexRow, int indexColumn)
{
    if (indexColumn == mColumn && indexRow == mRow)
    {
        return mType;
    }
    else if (indexRow == mRow || indexColumn == mColumn)
    {
        return 'X';
    }
    else
    {
        return ' ';
    }
}
