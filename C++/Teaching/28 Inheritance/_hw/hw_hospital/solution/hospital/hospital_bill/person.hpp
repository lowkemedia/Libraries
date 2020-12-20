//
//  person.hpp
//

#ifndef person_hpp
#define person_hpp

#include <stdio.h>
#include <iostream>
#include <string>
#include <iomanip>

using namespace std;

class Person
{
protected:
    string mFirstName = "John";
    string mLastName = "Doe";
    
public:
    Person(string first, string last);
    ~Person();
    string getFirst() const;
    string getLast() const;
    void setFirst(string first);
    void setLast(string last);
    void setName(string first, string last);
    void print();
};

#endif /* person_hpp */
