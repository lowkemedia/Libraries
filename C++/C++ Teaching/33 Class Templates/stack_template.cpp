//
//  Function Templates
//

#include <iostream>
using namespace std;

static const int MAX_SIZE = 100;

template<typename T>
class Stack
{
public:
    
    // return top element of the stack
    T top()
    {
        if (isEmpty())
        {
            // stack is empty
            return -1;
        }
        
        return mStack[mSize - 1];
    }
    
    // push an element onto the stack
    void push(T value)
    {
        mStack[mSize++] = value;
    }
    
    // pop an element off the stack
    T pop()
    {
        if (isEmpty())
        {
            // stack is empty
            return NULL;
        }
        
        T pop = top();
        
        // clear the top value
        mStack[mSize--] = 0;
        
        return pop;
    }
    
    // determine if stack is empty
    bool isEmpty() const
    {
        return (mSize == 0);
    }
    
    // return size of stack
    int getSize()
    {
        return mSize;
    }
    
private:
    int mSize = 0;
    int mStack[MAX_SIZE] = {};
};

int main()
{
    // demonstrate Stack of ints
    Stack<int>* intStack = new Stack<int>();
    
    cout << "stack size:" << intStack->getSize() << endl;
    
    cout << "adding items" << endl;
    intStack->push(11);
    intStack->push(13);
    intStack->push(18);
    cout << "stack size:" << intStack->getSize() << endl;
    
    cout << "pop:" << intStack->pop() << endl;
    cout << "stack size:" << intStack->getSize() << endl;
    cout << endl;
    
    
    // demonstrate Stack of chars
    Stack<char>* charStack = new Stack<char>();
    
    cout << "stack size:" << charStack->getSize() << endl;
    
    cout << "adding items" << endl;
    charStack->push('a');
    charStack->push('b');
    charStack->push('c');
    charStack->push('d');
    cout << "stack size:" << charStack->getSize() << endl;
    
    cout << "pop:" << charStack->pop() << endl;
    cout << "stack size:" << charStack->getSize() << endl;
    
    delete intStack;
    delete charStack;
    
    return 0;
}

