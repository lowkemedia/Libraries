//
// Animator.cpp: implementation for the Animator class.
//
//
//      AUTHOR: Russell Lowke
//
//        Date: Jan 20th 2005
//

#include "Animator.h"

using namespace std;

Animator::Animator(size_t sprites) : m_updateTime(0.0), m_updatePrev(0.0) {

    // CLK_TCK defines the relation betwen a clock tick and 
    // a second (number of clock ticks per second)
    // Define an Animator tick as 1/60th of a second
    m_tick = CLK_TCK / 60.0;

    // create sprites array
    m_nSprites = sprites;
    m_sprites  = new Sprite[m_nSprites];
    
    for(size_t i = 0; i < m_nSprites; ++i)
        m_sprites[i].initialize(this, i);
}

//  destructor
Animator::~Animator() {
    delete[] m_sprites;
}

void Animator::clear() {
    // reset all sprites in the Animator
    for(size_t i = 0; i < m_nSprites; ++i)
        m_sprites[i].clear();
}

void Animator::update() {

    m_updateTime = clock() / m_tick;  // an update tick = 1/60th of a second

    // execute only once we have a previous time
    if (m_updatePrev > 0) {

        float time_passed = m_updateTime - m_updatePrev;
        if (time_passed > TIMECAP)
            time_passed = TIMECAP;

        // animate each sprite
        for (size_t i = 0; i < m_nSprites; ++i)
            if (m_sprites[i].getActive())
                m_sprites[i].update(m_updateTime, time_passed);
    }

    m_updatePrev = m_updateTime;
}