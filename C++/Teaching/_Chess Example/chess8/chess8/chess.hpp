//
//  chess.hpp
//  

#ifndef chess_hpp
#define chess_hpp

#include "rook.hpp"
static const int BOARD_SIZE = 8;

// pieces
const char ROOK = 'R';
const char KNIGHT = 'N';
const char BISHOP = 'B';
const char QUEEN = 'Q';
const char KING = 'K';

class Chess
{
public:
    Chess();
    ~Chess();
    
    void play();
    void makeChessPiece();
    void drawBoard();
    
private:
    Rook* mPtrPiece;
    
    int askInt(int min, int max);
    char askType();
    bool isValidType(char pieceType);
};

#endif
