//
//  student
//

#include <iostream>

using namespace std;


struct StudentType
{
    string      name;
    char        letterGrade;
    float       testAverage;
    int         testScores[10];
    bool        ownsComputer;
};


int main()
{
    StudentType studentA;
    studentA.name = "Brandy Alexander";
    studentA.letterGrade = 'B';
    studentA.testAverage = 7.3;
    cout << "name: " << studentA.name << endl;
    cout << "letterGrade: " << studentA.letterGrade << endl;
    cout << "testAverage: " << studentA.testAverage << endl;
    
    StudentType studentB = {"Andrew Beatnik", 'A', 9.1};
    cout << "name: " << studentB.name << endl;
    cout << "letterGrade: " << studentB.letterGrade << endl;
    cout << "testAverage: " << studentB.testAverage << endl;
    
    return 0;
}
