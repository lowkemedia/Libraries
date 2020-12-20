//
//  Abstract Factory example
//

#include <iostream>

using namespace std;

class Computer
{
public:
    virtual void run() = 0;
    virtual void stop() = 0;
    virtual void print() = 0;
    
    // without this, you do not call Laptop or Desktop destructor in this example!
    virtual ~Computer() {};
};

class Laptop: public Computer
{
public:
    void run() override   { mHibernating = false; };
    void stop() override  { mHibernating = true; };
    void print() override { cout << "Laptop hibernating: " << mHibernating << endl; };
    
    // because we have virtual functions, we need virtual destructor!
    virtual ~Laptop() {};
private:
    bool mHibernating; // Whether or not the machine is hibernating
};

class Desktop: public Computer
{
public:
    void run() override   { mOn = true; };
    void stop() override  { mOn = false; };
    void print() override { cout << "Desktop on: " << mOn << endl; };
    virtual ~Desktop() {};
private:
    bool mOn; // Whether or not the machine has been turned on
};
    
class ComputerFactory
{
public:
    static Computer* makeNewComputer(char type)
    {
        switch (type)
        {
            case 'l':
                return new Laptop();
            case 'd':
                return new Desktop();
        }
        return NULL;
    }
};

int main()
{
    Computer *ptrLaptop = ComputerFactory::makeNewComputer('l');
    Computer *ptrDesktop = ComputerFactory::makeNewComputer('d');
    
    ptrLaptop->print();
    ptrDesktop->print();
    
    delete ptrLaptop;
    delete ptrDesktop;
    
    return 0;
}
