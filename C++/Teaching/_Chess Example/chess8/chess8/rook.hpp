//
//  piece.hpp
//  

#ifndef rook_hpp
#define rook_hpp

#include "piece.hpp"

class Rook : public Piece
{
public:
    Rook(int row, int column, char type);       // constructor
    char getSymbolAt(int row, int column);      // override
};

#endif
