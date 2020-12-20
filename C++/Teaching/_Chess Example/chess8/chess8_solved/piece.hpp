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
    virtual char getSymbolAt(int row, int column);
    
protected:
    int mRow;
    int mColumn;
    char mType;
    
private:
    
};

#endif
