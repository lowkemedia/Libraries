//
//  queen.hpp
//  

#ifndef queen_hpp
#define queen_hpp

#include "piece.hpp"

class Queen : public Piece
{
public:
    Queen(int row, int column, char type);       // constructor
    char getSymbolAt(int row, int column);      // override
};

#endif
