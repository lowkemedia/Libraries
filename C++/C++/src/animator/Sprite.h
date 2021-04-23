//
// Sprite.h: header for the Sprite class.
//
//      AUTHOR: Russell Lowke
//
//        Date: Jan 20th 2005
//

#ifndef Sprite_H
#define Sprite_H

#include "utils.h"
#include "Matrix.h"
#include "Image.h"
#include <iostream>
#include <ctime>
#include <vector>
#include <string>
#include <GL/glut.h>
#include <GL/gl.h>
#include <GL/glu.h>
#define PI 3.14159265

class  Animator;

enum Label      { NONE, NORMAL, EXPLODE, LARGE, MEDIUM, SMALL };
enum Collision  { STAR_V_SHIP, STAR_V_BULLET, STAR_V_MINE, ASTEROID_V_SHIP, ASTEROID_V_BULLET, MINE_V_SHIP, MINE_V_BULLET, MINE_V_MINE };
enum Sound      { START, SHOOT, KILL_ASTEROID, SHIP_DEAD, GET_GOODIE, SHOT_GOODIE, ENEMY_FIRE, KILL_ENEMY, GET_STAR, SHOOT_MINE, LEVEL, EXTRA_SHIP, GAME_OVER };

enum Walls      { W_NONE, W_REFLECT, W_WRAP, W_DEACTIVATE, W_BLOCK };
enum Cycle      { C_NONE, C_WRAP, C_REVERSE, C_FACING, C_SMOOTHFACING, C_REVERSE_END, C_END, C_DEACTIVATE };

typedef vector< pair<size_t, Collision> > CList;
typedef CList::const_iterator CListItr;

using namespace std;

class Sprite {

    public:
        Sprite();
        Sprite(const Sprite& n);                            // copy constructor
        void update(long double updateTime, float time_passed);
        void initialize(Animator* a, size_t n);
        void clear();
        Sprite& operator=(const Sprite& other);

        // accessors
        inline bool    getActive() const                    { return m_active; }
        inline float   getAngle() const                     { return m_angle; }
        inline fMatrix getLocation() const                  { return m_location; }
        inline fMatrix getVelocity() const                  { return m_velocity; }
        inline float   getRadius() const                    { return m_radius; }
        inline fMatrix getDisplayRect() const               { return m_displayRect; }
        inline Label   getLabel() const                     { return m_label; }
        inline Cycle   getCycleType() const                 { return m_cycleType; }
        
        // mutators
        void setImage(Image* val, size_t nI);
        void setActive(bool val);
        void setCollision(size_t val, Collision c);
        inline void    clearCollisions()                    { m_collisionList = CList(); }
        inline void    setLocation(fMatrix& val)            { m_location = val; }
        inline void    setVelocity(fMatrix& val)            { m_velocity = val; }
        inline void    setRadius(float val)                 { m_radius = val; }
        inline void    setMaxVelocity(float val)            { m_max_velocity = val; }
        inline void    setDisplayRect(fMatrix& val)         { m_displayRect = val; }
        inline void    setWallType(Walls val)               { m_wallType = val; }
        inline void    setLabel(Label val)                  { m_label = val; }
        inline void    setCycleCell(int val)                { m_cycleCell = val; }
        inline void    setCycleType(Cycle val)              { m_cycleType = val; }
        inline void    setCycleDirection(int val)           { m_cycleDirection = val; }
        inline void    setCycleFPS(float val)               { m_cycleTPerFrame = FPS_to_Ticks(val); }

    private:

        void doWalls();                         // handle sprite hitting limit of display rect
        void doCycles();                        // handle cycling of sprite image cells
        void doCollisions();                    // handle collisions with other sprites
        void doDraw();                          // handle drawing the sprite on screen
        void capCycles();                       // ensure cycle does not exceed cycle bounds

        Animator* m_animator;                   // ancestor

        bool    m_active;                       // active or not?
        size_t  m_number;                       // sprite number
        float   m_angle;                        // facing angle in degrees
        fMatrix m_location;                     // location of sprite x, y, z
        fMatrix m_velocity;                     // velocity of sprite x, y, z
        fMatrix m_zero;                         // a useful zeroed Matrix
        float   m_radius;                       // radius used for collision detection
        float   m_max_velocity;                 // use to cap movement
        Image*  m_image;                        // image object for this sprite
        size_t  m_height;                       // height(y) of sprite
        size_t  m_width;                        // width(x) of sprite
        Walls   m_wallType;                     // how sprite handles walls
        fMatrix m_displayRect;                  // display area for this sprite
        int     m_cycleSize;                    // number of images in cycle
        int     m_cycleCell;                    // image currently displayed
        int     m_cycleDirection;               // Direction to cycle through cycle list (-1 back, 0 pause, +1 forward)
        long double m_updateTime;               // time of last update
        long double m_cycleLast;                // time of last cycle update
        float   m_cycleTPerFrame;               // time between frame changes
        Cycle   m_cycleType;                    // What to do at the end of a cycle
        Label   m_label;                        // misc. label usually used in conjunction with collisions
        CList   m_collisionList;                // list of collisions to check for
};

#endif // Sprite_H