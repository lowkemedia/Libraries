//
//  king.hpp
//  

#ifndef king_hpp
#define king_hpp

#include "piece.hpp"

class King : public Piece
{
public:
    King(int row, int column, char type);       // constructor
    char getSymbolAt(int row, int column);      // override
};

#endif
