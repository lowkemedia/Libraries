//
// Asteroids.h: header for the Asteroids class.
//
//      AUTHOR: Russell Lowke
//
//        Date: Jan 20th 2005
//

#ifndef Animator_H
#define Animator_H

#include "utils.h"
#include "Sprite.h"
#include "Matrix.h"
#include <iostream>
#include <ctime>
#include <vector>
#include <string>
#include <GL/glut.h>
#include <GL/gl.h>
#include <GL/glu.h>

using namespace std;

class Animator {

    public:
        Animator(size_t sprites);                       // constructor
       ~Animator();                                     // destructor
        void clear();                                   // clear all sprites
        void update();                                  // update all sprites

        // accessors
        inline bool    getActive(size_t n) const                     { return m_sprites[n].getActive(); }
        inline fMatrix getLocation(size_t n) const                   { return m_sprites[n].getLocation(); }
        inline fMatrix getVelocity(size_t n) const                   { return m_sprites[n].getVelocity(); }
        inline float   getRadius(size_t n) const                     { return m_sprites[n].getRadius(); }
        inline Label   getLabel(size_t n) const                      { return m_sprites[n].getLabel(); }

        // mutators
        inline void  clear(size_t n)                                 { m_sprites[n].clear(); }
        inline void  clearCollisions(size_t n)                       { m_sprites[n].clearCollisions(); }
        inline void  setActive(size_t n, bool val)                   { m_sprites[n].setActive(val); }
        inline void  setLocation(size_t n, fMatrix& val)             { m_sprites[n].setLocation(val); }
        inline void  setVelocity(size_t n, fMatrix& val)             { m_sprites[n].setVelocity(val); }
        inline void  setRadius(size_t n, float val)                  { m_sprites[n].setRadius(val); }
        inline void  setMaxVelocity(size_t n, float val)             { m_sprites[n].setMaxVelocity(val); }
        inline void  setDisplayRect(size_t n, fMatrix& val)          { m_sprites[n].setDisplayRect(val); }
        inline void  setWallType(size_t n, Walls val)                { m_sprites[n].setWallType(val); }
        inline void  setLabel(size_t n, Label val)                   { m_sprites[n].setLabel(val); }
        inline void  setImage(size_t n, Image* val, size_t nI)       { m_sprites[n].setImage(val, nI); }
        inline void  setCycleCell(size_t n, int val)                 { m_sprites[n].setCycleCell(val); }
        inline void  setCycleType(size_t n, Cycle val)               { m_sprites[n].setCycleType(val); }
        inline void  setCycleDirection(size_t n, int val)            { m_sprites[n].setCycleDirection(val); }
        inline void  setCycleFPS(size_t n, float val)                { m_sprites[n].setCycleFPS(val); }
        inline void  setCollision(size_t n, size_t val, Collision c) { m_sprites[n].setCollision(val, c); }

    private:

        float        m_tick; // = CLK_TCK / 60.0;       // duration of an Animator's "tick", 1/60th of a second
        const static clock_t TIMECAP = 15;              // maximum time passed allowed [1/4 of a second]
        long double  m_updateTime;                      // time when updateAnimate was called
        long double  m_updatePrev;                      // previous time of updateAnimate
        size_t       m_nSprites;                        // number of sprites
        Sprite*      m_sprites;                         // list of sprite objects

};

#endif // Animator_H