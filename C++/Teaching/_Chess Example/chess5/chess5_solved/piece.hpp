//
//  piece.hpp
//  

#ifndef piece_hpp
#define piece_hpp

class Piece
{
    
public:
    Piece(int row, int column, char type);
    ~Piece();
    
    void print();
    
    int getRow();
    int getColumn();
    char getType();
    
private:
    int mRow;
    int mColumn;
    char mType;
};

#endif
