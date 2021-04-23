///
//  Matrix.h v 1.0 for C++
//  Russell Lowke, Jan 20th 2005
//
//  Copyright (c) 2005 Russell Lowke
//  see http://www.lowkemedia.com for more information
//
//  Permission is hereby granted, free of charge, to any person obtaining a 
//  copy of this software and associated documentation files (the "Software"), 
//  to deal in the Software without restriction, including without limitation 
//  the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//  and/or sell copies of the Software, and to permit persons to whom the 
//  Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in 
//  all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
//  IN THE SOFTWARE. 
//
//

//
//  Useful C++ template for dealing with matrices
//


#ifndef MATRIX_H
#define MATRIX_H

#include <iostream>
#include <cmath>
using namespace std;

// Forward declare class template and function template
template <class T> class Matrix;
template <class T> ostream& operator<<(ostream& os, Matrix<T>& v);

template <class T>
class Matrix {

    friend ostream& operator<< (ostream& os, const Matrix<T>& m);

    public:
        
        Matrix<T>(size_t w = 0, size_t h = 0);                  // default constructor
        Matrix<T>(const Matrix<T>& m);                          // copy constructor
        Matrix<T>(T x, T y);                                    // 2d point matrix
        Matrix<T>(T x, T y, T z);                               // 3d point matrix
        Matrix<T>(T x, T y, T z, T w);                          // 4d/rect  matrix
        Matrix<T>(size_t w, size_t h, T data[]);                // matrix of width and height with data
        virtual ~Matrix<T>();                                   // destructor

        // comparisons and assignment
        bool       equal      (const Matrix<T>& other) const;
        Matrix<T>& operator=  (const Matrix<T>& other);
        bool       operator== (const Matrix<T>& other) const;

        // Matrix operations
        Matrix<T>& add        (const Matrix<T>& other);
        Matrix<T>& subtract   (const Matrix<T>& other);
        Matrix<T>  mMultiply  (const Matrix<T>& other) const;
        Matrix<T>& multiply   (const Matrix<T>& other);
        Matrix<T>& divide     (const Matrix<T>& other);
        Matrix<T>& operator+= (const Matrix<T>& other);
        Matrix<T>  operator+  (const Matrix<T>& other) const;
        Matrix<T>& operator-= (const Matrix<T>& other);
        Matrix<T>  operator-  (const Matrix<T>& other) const;
        Matrix<T>& operator*= (const Matrix<T>& other);
        Matrix<T>  operator*  (const Matrix<T>& other) const;
        Matrix<T>& operator/= (const Matrix<T>& other);
        Matrix<T>  operator/  (const Matrix<T>& other) const;

        // by value operations
        Matrix<T>& add        (T value);
        Matrix<T>& subtract   (T value);
        Matrix<T>& multiply   (T value);
        Matrix<T>& divide     (T value);
        Matrix<T>& operator+= (T value);
        Matrix<T>  operator+  (T value) const;
        Matrix<T>& operator-= (T value);
        Matrix<T>  operator-  (T value) const;
        Matrix<T>& operator*= (T value);
        Matrix<T>  operator*  (T value) const;
        Matrix<T>& operator/= (T value);
        Matrix<T>  operator/  (T value) const;

        inline T distance(const Matrix<T>& other) const {
            return sqrt(pow(other.x() - *m_x, 2) + pow(other.y() - *m_y, 2) + pow(other.z() - *m_z, 2));
        }

        //  accessors
        inline T  operator()(size_t x, size_t y) const      { return  m_data[x][y]; }
        inline T  getAt(size_t x, size_t y) const           { return  m_data[x][y]; }
        inline size_t getWidth() const                      { return  m_width; }
        inline size_t getHeight() const                     { return  m_height; }
        inline T** getData() const                          { return  m_data; }
        inline T  x() const                                 { return *m_x; }
        inline T  y() const                                 { return *m_y; }
        inline T  z() const                                 { return *m_z; }
        inline T  w() const                                 { return *m_w; }

        // mutators
        inline void   setAt(size_t x, size_t y, T val)      { m_data[x][y] = val; }
        inline void   x(const T n)                          { *m_x = n; }
        inline void   y(const T n)                          { *m_y = n; }
        inline void   z(const T n)                          { *m_z = n; }
        inline void   w(const T n)                          { *m_w = n; }

    protected:

        void initialize(size_t w, size_t h, T* data);
        void initialize(size_t w, size_t h, T** data);

        T** m_data;

    private:
    
        void initialize(size_t w, size_t h);
        virtual void labels();
        inline bool congruent(const Matrix<T>& other) const { 
            return (m_width == other.m_width && m_height == other.m_height); 
        }

        size_t  m_width, m_height;

        T*  m_x;
        T*  m_y;
        T*  m_z;
        T*  m_w;
};

// default constructor
template <class T>
Matrix<T>::Matrix(size_t w /* = 0 */, size_t h /* = 0 */) {
    initialize(w, h);
}

// copy constructor
template <class T>
Matrix<T>::Matrix(const Matrix<T>& m) {             
    *this = m;
}

// general constructors
template <class T>
Matrix<T>::Matrix(T x, T y) {       
    T data[] = { x, y };
    initialize( 1, 2, data);
}
template <class T>
Matrix<T>::Matrix(T x, T y, T z) {      
    T data[] = { x, y, z };
    initialize( 1, 3, data);
}
template <class T>
Matrix<T>::Matrix(T x, T y, T z, T w) {     
    T data[] = { x, y, z, w };
    initialize( 1, 4, data);
}
template <class T>
Matrix<T>::Matrix(size_t w, size_t h, T data[]) {
    initialize(w, h, data);
}

// destructor
template <class T>
Matrix<T>::~Matrix() {
    // delete two dimensional array
    for (size_t i = 0; i < m_width; ++i)
        delete[] m_data[i];
    delete[] m_data;
}

//
// initialize Matrix with data
//
template <class T>
void Matrix<T>::initialize(size_t w, size_t h) {
    m_width  = w;
    m_height = h;

    // c style two dimensional array (quick)
    m_data = new T* [m_width];
    for (size_t i = 0; i < m_width; ++i)
        m_data[i] = new T[m_height];

    // x, y, z, w  references
    // Note: I'd like to remove these and have their 
    //       functionality only in the inherited classes
    m_x = &m_data[0][0]; 
    m_y = &m_data[0][1];
    m_z = &m_data[0][2]; 
    m_w = &m_data[0][3];

    labels();
}
template <class T>
void Matrix<T>::initialize(size_t w, size_t h, T* data) {
    initialize(w, h);
    for (size_t x = 0; x < m_width; ++x)
        for (size_t y = 0; y < m_height; ++y)
            m_data[x][y] = data[ m_width * y + x ];
}
template <class T>
void Matrix<T>::initialize(size_t w, size_t h, T** data) {
    initialize(w, h);
    for (size_t x = 0; x < m_width; ++x)
        for (size_t y = 0; y < m_height; ++y )
            m_data[x][y] = data[x][y];
}

template <class T>
void Matrix<T>::labels() {} // no labels
//
// comparison & assignment operators
//
template <class T>
bool Matrix<T>::equal(const Matrix<T>& other) const {
    if (! congruent(other)) return false;
    for (size_t x = 0; x < m_width; ++x)                // test data
        for (size_t y = 0; y < m_height; ++y)
            if (m_data[x][y] != other.m_data[x][y])
                return false;
    return true;                                        // ok.
}
template <class T>
Matrix<T>& Matrix<T>::operator=(const Matrix<T>& other) {
    if (this == &other) return *this;
    initialize(other.m_width, other.m_height, other.m_data);
    return *this;
}
template <class T>
bool Matrix<T>::operator==(const Matrix<T>& other) const {
    return equal(other);
}

//
//  matrix operations
//
template <class T>
Matrix<T>& Matrix<T>::add( const Matrix<T>& other) {
    if (congruent(other))
        for (size_t x = 0; x < m_width; ++x)
            for (size_t y = 0; y < m_height; ++y )
                m_data[x][y] += other.m_data[x][y];
    return *this;
}
template <class T>
Matrix<T>& Matrix<T>::subtract(const Matrix<T>& other) {
    if (congruent(other))
        for (size_t x = 0; x < m_width; ++x)
            for (size_t y = 0; y < m_height; ++y )
                m_data[x][y] -= other.m_data[x][y];
    return *this;
}
//
// for matrix multiplication the number of columns
// in this Matrix must equal the number of rows in other
template <class T>
Matrix<T> Matrix<T>::mMultiply(const Matrix<T>& other) const {
    size_t height = m_height;
    size_t width  = other.m_width;  
    Matrix<T> result(width, height);
    T n = 0;
    for (size_t x = 0; x < width; ++x)
        for (size_t y = 0; y < height; result.m_data[x][y] = n, ++y, n = 0 )
            for (size_t i = 0; i < other.m_height && i < m_width; ++i )
                n += (m_data[i][y] * other.m_data[x][i]);
    return result;
}
template <class T>
Matrix<T>& Matrix<T>::multiply(const Matrix<T>& other) {
    if (congruent(other))
        for (size_t x = 0; x < m_width; ++x)
            for (size_t y = 0; y < m_height; ++y )
                m_data[x][y] *= other.m_data[x][y];
    return *this;
}
template <class T>
Matrix<T>& Matrix<T>::divide( const Matrix<T>& other) {
    if (congruent(other))
        for (size_t x = 0; x < m_width; ++x)
            for (size_t y = 0; y < m_height; ++y )
                m_data[x][y] /= other.m_data[x][y];
    return *this;
}
template <class T>
Matrix<T>& Matrix<T>::operator+= (const Matrix<T>& other) {
    return add(other);
}
template <class T>
Matrix<T> Matrix<T>::operator+ (const Matrix<T>& other) const {
    Matrix<T> temp = *this;
    temp += other;
    return temp;
}
template <class T>
Matrix<T>& Matrix<T>::operator-= (const Matrix<T>& other) {
    return subtract(other);
}
template <class T>
Matrix<T> Matrix<T>::operator- (const Matrix<T>& other) const {
    Matrix<T> temp = *this;
    temp -= other;
    return temp;
}
template <class T>
Matrix<T>& Matrix<T>::operator*= (const Matrix<T>& other) {
    if (m_width == other.m_height) {
        *this = mMultiply(other);
        return *this;
    } else
        return multiply(other);
}
template <class T>
Matrix<T> Matrix<T>::operator* (const Matrix<T>& other) const {
    if (m_width == other.m_height)
        return mMultiply(other);
    else {
        Matrix<T> temp = *this;
        temp *= other;
        return temp;
    }
}
template <class T>
Matrix<T>& Matrix<T>::operator/= (const Matrix<T>& other) {
    return divide(other);
}
template <class T>
Matrix<T> Matrix<T>::operator/ (const Matrix<T>& other) const {
    Matrix<T> temp = *this;
    temp /= other;
    return temp;
}

//
// by value operations
//
template <class T>
Matrix<T>& Matrix<T>::add(T value) {
    for (size_t x = 0; x < m_width; ++x)
        for (size_t y = 0; y < m_height; ++y )
            m_data[x][y] += value;
    return *this;
}
template <class T>
Matrix<T>& Matrix<T>::subtract(T value) {
    for (size_t x = 0; x < m_width; ++x)
        for (size_t y = 0; y < m_height; ++y )
            m_data[x][y] -= value;
    return *this;
}
template <class T>
Matrix<T>& Matrix<T>::multiply(T value) {
    for (size_t x = 0; x < m_width; ++x)
        for (size_t y = 0; y < m_height; ++y )
            m_data[x][y] *= value;
    return *this;
}
template <class T>
Matrix<T>& Matrix<T>::divide(T value) {
    for (size_t x = 0; x < m_width; ++x)
        for (size_t y = 0; y < m_height; ++y )
            m_data[x][y] /= value;
    return *this;
}
template <class T>
Matrix<T>& Matrix<T>::operator+= (T value) {
    return add(value);
}
template <class T>
Matrix<T>  Matrix<T>::operator+ (T value) const {
    Matrix<T> temp = *this;
    temp += value;
    return temp;
}
template <class T>
Matrix<T>& Matrix<T>::operator-= (T value) {
    return subtract(value);
}
template <class T>
Matrix<T>  Matrix<T>::operator- (T value) const {
    Matrix<T> temp = *this;
    temp -= value;
    return temp;
}
template <class T>
Matrix<T>& Matrix<T>::operator*= (T value) {
    return multiply(value);
}
template <class T>
Matrix<T>  Matrix<T>::operator* (T value) const {
    Matrix<T> temp = *this;
    temp *= value;
    return temp;
}
template <class T>
Matrix<T>& Matrix<T>::operator/= (T value) {
    return divide(value);
}
template <class T>
Matrix<T>  Matrix<T>::operator/ (T value) const {
    Matrix<T> temp = *this;
    temp /= value;
    return temp;
}

//
//  print Matrix
//
template <class T>
ostream& operator<< (ostream& os, const Matrix<T>& m) {
    for (size_t y = 0; y < m.m_height; ++y) {
        os << "[ ";
        for (size_t x = 0; x < m.m_width; ++x)
            os << m.m_data[x][y] << " ";
        os << "]" << endl;
    }
    return os;
}


class Point2D : public Matrix<float> {

    public:
        Point2D(float x = 0, float y = 0) {
            float data[] = { x, y };
            initialize(1, 2, data);
        }
        Point2D(const Matrix<float>& m) { initialize(m.getWidth(), m.getHeight(), m.getData()); }

        inline float distance(const Point2D& other) const {
            return sqrt(pow(other.x() - *m_x, 2) + pow(other.y() - *m_y, 2));
        }

        inline float  x() const             { return *m_x; }
        inline float  y() const             { return *m_y; }
        inline void   x(const float n)      { *m_x = n; }
        inline void   y(const float n)      { *m_y = n; }
        
    private:
        void labels() {
            m_x = &m_data[0][0]; 
            m_y = &m_data[0][1];
        }
        float* m_x;
        float* m_y;
        
};

class Point3D : public Matrix<float> {

    public:
        Point3D(float x = 0, float y = 0, float z = 0) {
            float data[] = { x, y, z };
            initialize(1, 3, data);
        }
        Point3D(const Matrix<float>& m) { initialize(m.getWidth(), m.getHeight(), m.getData()); }

        inline float distance(const Point3D& other) const {
            return sqrt(pow(other.x() - *m_x, 2) + pow(other.y() - *m_y, 2) + pow(other.z() - *m_z, 2));
        }

        inline float  x() const             { return *m_x; }
        inline float  y() const             { return *m_y; }
        inline float  z() const             { return *m_z; }
        inline void   x(const float n)      { *m_x = n; }
        inline void   y(const float n)      { *m_y = n; }
        inline void   z(const float n)      { *m_z = n; }
        
    private:

        void labels() {
            m_x = &m_data[0][0]; 
            m_y = &m_data[0][1];
            m_z = &m_data[0][2];
        }

        float* m_x;
        float* m_y;
        float* m_z;
};
class Point4D : public Matrix<float> {

    public:
        Point4D(float x = 0, float y = 0, float z = 0, float w = 0) {
            float data[] = { x, y, z, w };
            initialize(1, 4, data);
        }
        Point4D(const Matrix<float>& m) { initialize(m.getWidth(), m.getHeight(), m.getData()); }

        inline float distance(const Point4D& other) const {
            return sqrt(pow(other.x() - *m_x, 2) + pow(other.y() - *m_y, 2) + pow(other.z() - *m_z, 2));
        }

        inline float  x() const             { return *m_x; }
        inline float  y() const             { return *m_y; }
        inline float  z() const             { return *m_z; }
        inline float  w() const             { return *m_w; }
        inline void   x(const float n)      { *m_x = n; }
        inline void   y(const float n)      { *m_y = n; }
        inline void   z(const float n)      { *m_z = n; }
        inline void   w(const float n)      { *m_w = n; }
        
    private:

        void labels() {
            m_x = &m_data[0][0]; 
            m_y = &m_data[0][1];
            m_z = &m_data[0][2];
            m_w = &m_data[0][3];
        }

        float* m_x;
        float* m_y;
        float* m_z;
        float* m_w;
};
class Rect : public Matrix<float> {

    public:
        Rect(float x1 = 0, float y1 = 0, float x2 = 0, float y2 = 0) {
            float data[] = { x1, y1, x2, y2 };
            initialize(1, 4, data);
        }
        Rect(const Matrix<float>& m) { initialize(m.getWidth(), m.getHeight(), m.getData()); }

        inline Point2D loc() const { 
            return Point2D(*m_x1 + (*m_x2-*m_x1)/2, *m_y1 + (*m_y2-*m_y1)/2); 
        }
        inline bool inside(const Point2D& pt) const {
            return (inside(pt.x(), pt.y()));
        }
        inline bool inside(const float& x, const float& y) const {
            return (x >= ((*m_x1 < *m_x2) ? *m_x1 : *m_x2) && 
                    x <= ((*m_x1 > *m_x2) ? *m_x1 : *m_x2) && 
                    y >= ((*m_y1 < *m_y2) ? *m_y1 : *m_y2) && 
                    y <= ((*m_y1 > *m_y2) ? *m_y1 : *m_y2));
        }
        inline bool intersect(const Rect& other) const {
            return (other.inside(*m_x1, *m_y1) || 
                    other.inside(*m_x1, *m_y2) ||
                    other.inside(*m_x2, *m_y1) ||
                    other.inside(*m_x2, *m_y2));
        }

        inline float  x1() const            { return *m_x1; }
        inline float  y1() const            { return *m_y1; }
        inline float  x2() const            { return *m_x2; }
        inline float  y2() const            { return *m_y2; }
        inline void   x1(const float n)     { *m_x1 = n; }
        inline void   y1(const float n)     { *m_y1 = n; }
        inline void   x2(const float n)     { *m_x2 = n; }
        inline void   y2(const float n)     { *m_y2 = n; }
        
    private:

        void labels() {
            m_x1 = &m_data[0][0]; 
            m_y1 = &m_data[0][1];
            m_x2 = &m_data[0][2];
            m_y2 = &m_data[0][3];
        }

        float* m_x1;
        float* m_y1;
        float* m_x2;
        float* m_y2;
};

#endif /* MATRIX_H */