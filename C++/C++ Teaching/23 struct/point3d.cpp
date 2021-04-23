//
//  point3d
//

#include <iostream>

using namespace std;

struct Point3d
{
    int x, y, z;
};

void printPoint(Point3d pt)
{
    cout << "x:" << pt.x << " y:" << pt.y << " z:" << pt.z << endl;
}


/* without "arrow syntax"
 void printPointByRef(Point3d *pt)
 {
 cout << "x:" << (*pt).x << " y:" << (*pt).y << " z:" << (*pt).z << endl;
 }
 */


// with "arrow syntax"
void printPointByRef(Point3d* pt)
{
    cout << "x:" << pt->x << " y:" << pt->y << " z:" << pt->z << endl;
}


int main()
{
    Point3d ptA = {3, 2, 7};
    Point3d ptB = {7, 4, 5};
    
    printPointByRef(&ptA);
    printPointByRef(&ptB);
    
    return 0;
}
