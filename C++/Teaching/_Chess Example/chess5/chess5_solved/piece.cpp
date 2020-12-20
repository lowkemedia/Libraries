//
//  piece.cpp
//

#include "piece.hpp"
#include <iostream>
#include <iomanip>

using namespace std;

Piece::Piece(int row, int column, char type)     // constructor
{
    cout << "Piece object being created. " << this << endl;
    mRow = row;
    mColumn = column;
    mType = type;
    this->print();
}

Piece::~Piece()    // destructor
{
    cout << "Piece object being deleted. " << this << endl;
}


void Piece::print()
{
    cout << "Piece " << this << endl;
    cout << " { mPieceType:" << mType;
    cout << " mPieceRow:" << mRow;
    cout << " mPieceColumn:" << mColumn << " }";
}

int Piece::getRow()
{
    return mRow;
}

int Piece::getColumn()
{
    return mColumn;
}

char Piece::getType()
{
    return mType;
}
