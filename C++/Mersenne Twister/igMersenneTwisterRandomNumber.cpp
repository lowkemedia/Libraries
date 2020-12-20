/************************************************************************
** $Id: //newgap/tot/utils/common/igMersenneTwisterRandomNumber.cpp#6 $
**                                                                      
**         Copyright (C) 1999-2003, Vicarious Visions, Inc.            
**                        All Rights Reserved.                          
**                                                                      
** UNPUBLISHED -- Rights  reserved  under  the  copyright  laws  of the 
** United States.  Use  of a copyright notice is precautionary only and 
** does not imply publication or disclosure.                            
**                                                                      
** THIS DOCUMENTATION CONTAINS CONFIDENTIAL AND PROPRIETARY INFORMATION 
** OF   VICARIOUS   VISIONS,  INC.    ANY   DUPLICATION,  MODIFICATION, 
** DISTRIBUTION, OR DISCLOSURE IS STRICTLY PROHIBITED WITHOUT THE PRIOR 
** EXPRESS WRITTEN PERMISSION OF VICARIOUS VISIONS, INC.               
************************************************************************/

#include <igUtils/igMersenneTwisterRandomNumber.h>

namespace Gap {
  namespace Utils {

void igMersenneTwisterRandomNumber::seed(igUnsignedInt mySeed)
{
  for (int i = 0; i < N; i++) {
    _mt[i] = mySeed & 0xffff0000;
    mySeed = 69069 * mySeed + 1;
    _mt[i] |= (mySeed & 0xffff0000) >> 16;
    mySeed = 69069 * mySeed + 1;
  }
  _mti = N;
}


void igMersenneTwisterRandomNumber::userResetFields(igBool persistant)
{
  igRandomNumber::userResetFields(persistant);
  seed(5150);
}


igUnsignedInt igMersenneTwisterRandomNumber::getNumberNonVirtual()
{
  const igUnsignedInt lowerMask = 0x7fffffff;
  const igUnsignedInt upperMask = 0x80000000;
  const igUnsignedInt temperingMaskB = 0x9d2c5680;
  const igUnsignedInt temperingMaskC = 0xefc60000;
  static const igUnsignedInt mag01[2] = {0, 0x9908b0df};

  igUnsignedInt ret;

  if (_mti >= N) { // generate N words at one time
    int i;

    for (i=0; i < N-M; i++) {
      ret = (_mt[i] & upperMask) | (_mt[i+1] & lowerMask);
      _mt[i] = _mt[i+M] ^ (ret >> 1) ^ mag01[ret & 0x1];
    }
    for (; i < N-1; i++) {
      ret = (_mt[i] & upperMask) | (_mt[i+1] & lowerMask);
      _mt[i] = _mt[i+(M-N)] ^ (ret >> 1) ^ mag01[ret & 0x1];
    }
    ret = (_mt[N-1] & upperMask) | (_mt[0] & lowerMask);
    _mt[N-1] = _mt[M-1] ^ (ret >> 1) ^ mag01[ret & 0x1];
    
    _mti = 0;
  }

  ret = _mt[_mti++];
  ret ^= ret >> 11;
  ret ^= (ret << 7) & temperingMaskB;
  ret ^= (ret << 15) & temperingMaskC;
  ret ^= ret >> 18;

  return ret;
}


  }
}
