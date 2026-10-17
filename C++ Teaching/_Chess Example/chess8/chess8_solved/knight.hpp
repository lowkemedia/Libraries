//
//  knight.hpp
//  

#ifndef knight_hpp
#define knight_hpp

#include "piece.hpp"

class Knight : public Piece
{
public:
    Knight(int row, int column, char type);       // constructor
    char getSymbolAt(int row, int column);      // override
};

#endif
