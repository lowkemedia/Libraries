//
// Sprite.cpp: implementation for the Sprite class.
//
//
//      AUTHOR: Russell Lowke
//
//        Date: Jan 20th 2005
//

#include "Sprite.h"
#include "Animator.h"

using namespace std;

Sprite::Sprite() {}                                     // default parameters
Sprite::Sprite(const Sprite& s) { *this = s; }          // copy constructor
void Sprite::initialize(Animator* a, size_t n) {
    m_animator  = a;
    m_number    = n;
    m_zero      = fMatrix(0.0, 0.0, 0.0);

    // dangerous to init display rect.
    m_displayRect       = fMatrix(0.0, 0.0, 0.0, 0.0);

    clear();
}

void Sprite::clear() {
    
    m_active         = false;
    m_image          = NULL;
    m_angle          = 0;
    m_location       = NULL;
    m_velocity       = NULL;
    m_radius         = 0;
    m_max_velocity   = 0;
    m_height         = 0;
    m_width          = 0;
    m_cycleSize      = 0;
    m_cycleCell      = 0;
    m_cycleDirection = 0;
    m_cycleTPerFrame = 0;
    m_cycleType      = C_NONE;
    m_wallType       = W_NONE;
    m_updateTime     = 0;
    m_cycleLast      = 0;
    m_label          = NONE;
    m_collisionList  = CList();

}

void Sprite::setActive(bool val) {
    m_active = val;
    if (! m_active)
        // g_asteroids->deactivated(m_number);  // tell the game sprite deactivated
}

void Sprite::setImage(Image* images, size_t n) {

    m_cycleSize      = (int) n;
    m_cycleCell      = 0;
    m_image          = images;
    m_height         = images[0].getHeight();
    m_width          = images[0].getWidth();
    m_cycleDirection = +1;      // default direction
    m_cycleType      = C_WRAP;  // default type
}

void Sprite::setCollision(size_t val, Collision c) {
    pair<size_t, Collision> value;
    value.first  = val;
    value.second = c;
    m_collisionList.push_back(value);
}

void Sprite::update(long double updateTime, float time_passed) {

    m_updateTime = updateTime;
    
    if (m_max_velocity)                                 // limit velocity to m_max_velocity
        if (m_velocity.distance(m_zero) > m_max_velocity)
            m_velocity = getVelocity_Vel(m_velocity.y(), m_velocity.x(), m_max_velocity);
    m_location += m_velocity * time_passed;             // add velocity
    // check if at destination
    doCycles();                                         // handle cycling frames
    doWalls();                                          // check display limit
    doCollisions();                                     // handle collisions
    doDraw();                                           // draw the sprite
}

void Sprite::capCycles() {
    // ensure cycle place does not exceed cycle end or start
    if (m_cycleCell < 0)
        m_cycleCell = 0;
    else if (m_cycleCell >= m_cycleSize)
        m_cycleCell = m_cycleSize - 1;
}
void Sprite::doCycles() {

    // special case for C_NONE
    if (m_cycleType == C_NONE)
        return;
    // special case for C_FACING
    else if (m_cycleType == C_FACING || m_cycleType == C_SMOOTHFACING) {
        m_angle = findAngle(m_velocity.y(), m_velocity.x());
        int target = angleToCell(m_angle, m_cycleSize);

        if (m_cycleType == C_SMOOTHFACING) {
            m_cycleCell += incOrDec(m_cycleCell, target, m_cycleSize);
            if (m_cycleCell < 0)
                m_cycleCell = m_cycleSize-1;
            else if (m_cycleCell >= m_cycleSize)
                m_cycleCell = 0;
        } else
            m_cycleCell = target;
    }
    // time to changes cells?
    else if (m_cycleDirection && m_updateTime > m_cycleLast + m_cycleTPerFrame) {

        // get the next cell
        m_cycleCell += m_cycleDirection;
        m_cycleLast = m_updateTime;

        if (m_cycleCell >= m_cycleSize || m_cycleCell < 0) {
            
            switch (m_cycleType) {
                case C_WRAP:
                    if (m_cycleCell >= m_cycleSize)
                        m_cycleCell -= m_cycleSize;
                    else if (m_cycleCell < 0)
                        m_cycleCell += m_cycleSize;
                    capCycles();            // cap after, not before
                    break;
                case C_REVERSE:
                    capCycles();
                    m_cycleDirection = 0 - m_cycleDirection;
                    m_cycleLast = 0;        // ensure an update;
                    doCycles();             // call again
                    break;
                case C_DEACTIVATE:
                    capCycles();
                    setActive(false);
                    break;
            }
        }
    }
}

void Sprite::doWalls() {

    float x1 = m_displayRect.x();   // x1
    float y1 = m_displayRect.y();   // y1
    float x2 = m_displayRect.z();   // x2
    float y2 = m_displayRect.w();   // y2

    switch (m_wallType) {

        case W_NONE:
            break;
        case W_REFLECT:
            if (m_location.x() > x2) {
                m_location.x(x2);
                m_velocity.x(0 - m_velocity.x());
            } else if (m_location.x() < x1) {
                m_location.x(x1);
                m_velocity.x(0 - m_velocity.x());
            }
            if (m_location.y() > y2) {
                m_location.y(y2);
                m_velocity.y(0 - m_velocity.y());
            } else if (m_location.y() < y1) {
                m_location.y(y1);
                m_velocity.y(0 - m_velocity.y());
            }
            break;
        case W_WRAP:

            if (m_location.x() > x2)
                m_location.x(x1);
            else if (m_location.x() < x1)
                m_location.x(x2);

            if (m_location.y() > y2)
                m_location.y(y1);
            else if (m_location.y() < y1)
                m_location.y(y2);

            break;
        case W_DEACTIVATE:
            if (m_location.x() < x1 ||
                m_location.x() > x2 ||
                m_location.y() < y1 ||
                m_location.y() > y2) {
                setActive(false);
            }
            break;
        case W_BLOCK:
            break;

        default:
            break;
    }
}

void Sprite::doCollisions() {
    // NOTE: m_collisionList can change size during loop!
    pair<size_t, Collision> c;
    for (size_t i = 0; i < m_collisionList.size(); ++i) {
        c = m_collisionList[i];
        size_t n = c.first;
        if (m_animator->getActive(n) &&
            m_location.distance(m_animator->getLocation(n)) <
            m_radius + m_animator->getRadius(n)) {
            // g_asteroids->collision(m_number, n, c.second);
        }
    }
}

void Sprite::doDraw() {

    // check if still active, 
    // sprite could have been switched off 
    // due to a collision or similar
    if (m_active) {
        int xLoc = m_location.x() - m_image[m_cycleCell].getWidth()/2;
        int yLoc = m_location.y() - m_image[m_cycleCell].getHeight()/2;
        m_image[m_cycleCell].drawAt(xLoc, yLoc);
    }
}


Sprite& Sprite::operator=(const Sprite& other) {
    if (this == &other) { return *this; }   // trying to copy itself

    // make a copy of the sprite. copy all values
    // except for m_animator, m_number and m_zero
    // which are only ever set during initialization

    m_active         = other.m_active;
    m_angle          = other.m_angle;
    m_location       = other.m_location;
    m_velocity       = other.m_velocity;
    m_zero           = other.m_zero;
    m_radius         = other.m_radius;
    m_max_velocity   = other.m_max_velocity;
    m_image          = other.m_image;       // Note: only ptrs to images
    m_height         = other.m_height;
    m_width          = other.m_width;
    m_wallType       = other.m_wallType;
    m_displayRect    = other.m_displayRect;
    m_cycleSize      = other.m_cycleSize;
    m_cycleCell      = other.m_cycleCell;
    m_cycleDirection = other.m_cycleDirection;
    m_updateTime     = other.m_updateTime;
    m_cycleLast      = other.m_cycleLast;
    m_cycleTPerFrame = other.m_cycleTPerFrame;
    m_cycleType      = other.m_cycleType;
    m_label          = other.m_label;
    m_collisionList  = other.m_collisionList;

    return *this;
}