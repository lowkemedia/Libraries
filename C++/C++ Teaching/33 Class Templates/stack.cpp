//
//  Function Templates
//

#include <iostream>
using namespace std;

static const int MAX_SIZE = 100;

class Stack
{
public:
    
    // return top element of the stack
    int top()
    {
        if (isEmpty())
        {
            // stack is empty
            return -1;
        }
        
        return mStack[mSize - 1];
    }
    
    // push an element onto the stack
    void push(int value)
    {
        mStack[mSize++] = value;
    }
    
    // pop an element off the stack
    int pop()
    {
        if (isEmpty())
        {
            // stack is empty
            return -1;
        }
        
        int pop = top();
        
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
    Stack* myStack = new Stack();
    
    cout << "stack size:" << myStack->getSize() << endl;
    
    cout << "adding items" << endl;
    myStack->push(11);
    myStack->push(13);
    myStack->push(18);
    cout << "stack size:" << myStack->getSize() << endl;
    
    cout << "pop:" << myStack->pop() << endl;
    cout << "stack size:" << myStack->getSize() << endl;
    
    delete myStack;
    
    return 0;
}

