//
//  bishop.hpp
//  

#ifndef bishop_hpp
#define bishop_hpp

#include "piece.hpp"

class Bishop : public Piece
{
public:
    Bishop(int row, int column, char type);     // constructor
    char getSymbolAt(int row, int column);      // override
};

#endif
