/**@#-*/
#if (_MSC_VER > 1000) || defined(__MWERKS__)
#pragma once
#endif
#ifndef _IGMERSENNETWISTERRANDOMNUMBER_H_F073F5E7_
#define _IGMERSENNETWISTERRANDOMNUMBER_H_F073F5E7_
/**@#+*/

/************************************************************************
**                                                                      
**         Copyright (C) 1999-2006, Vicarious Visions, Inc.            
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


/**@#-*/
#include <igGap.h>
#include <igUtils/igUtils.h>
#include <igCore/igMetaObject.h>
#include <igCore/igObject.h>
#include <igUtils/igRandomNumber.h>
#include <igGapAllProm.h>
namespace Gap {
	namespace Core {
		class igMetaEnum;
		class igIntMetaField;
		class igUnsignedIntArrayMetaField;
	}
	using Core::igMetaEnum;
	using Core::igIntMetaField;
	using Core::igUnsignedIntArrayMetaField;
}
/**@#+*/

namespace Gap {
namespace Utils {

/**
 * An implement of the igRandomNumber interface using Mersenne Twister.
 *
 * Mersenne Twister is a pseudorandom number generator with a large period
 * (2^19937 - 1) and good distribution (623-dimensional equidistribution).
 *
 * More detailed information on the Mersenne Twister can be found at
 * http://www.math.keio.ac.jp/~matumoto/emt.html
 *
 * This implementation is heavily based off of the code freely available
 * under the Artistic License at
 * http://www.math.keio.ac.jp/~matumoto/eartistic.htm
 */
class LIBIGUTILS igMersenneTwisterRandomNumber : public igRandomNumber
{
	IG_OBJECT_DEFINE(igMersenneTwisterRandomNumber);
private:
	enum constants
	{
		N = 624,
		M = 397
	};
	/**@#-*/
	static Gap::igMetaEnum* getconstantsMetaEnum();
	private:
	static Gap::igMetaEnum* constants_Meta;
	/**@#+*/
	
private:
	IG_DEFINE_FIELD(igMersenneTwisterRandomNumber, igInt, igIntMetaField, _mti, k_mti, __noAttrs__);
	IG_DEFINE_ARRAY_FIELD(igMersenneTwisterRandomNumber, igUnsignedInt, igUnsignedIntArrayMetaField, _mt, k_mt, N, __noAttrs__);

protected:
	#line 44 "igMersenneTwisterRandomNumber.igo"
	virtual  void userResetFields(igBool persistant);

public:
	/**
	 *Seed the pseudorandom number generator.
	 *
	 *@param theSeed A number between 0 and IG_UNSIGNED_INT_MAX to seed the
	 *generator with.
	 */
	#line 55 "igMersenneTwisterRandomNumber.igo"
	virtual  void seed(igUnsignedInt theSeed);

public:
	/**
	 *Get a pseudorandom number.
	 *
	 *@returns  A pseudorandom number between 0 and IG_UNSIGNED_INT_MAX,
	 *inclusive.
	 */
	#line 66 "igMersenneTwisterRandomNumber.igo"
	inline virtual  igUnsignedInt getNumber()
	{ return getNumberNonVirtual(); }

public:
	/**
	 *Get a pseudorandom number without incurring a virtual function call.
	 *
	 *This method is provided in case you need to get a large number of random
	 *numbers in a time critical section of code.  Note, however, that you must
	 *specifically cast to an igMersenneTwisterRandomNumber in order to call
	 *this method.
	 *
	 *@returns A pseudorandom number between 0 and IG_UNSIGNED_INT_MAX,
	 *inclusive.
	 */
	#line 82 "igMersenneTwisterRandomNumber.igo"
	 igUnsignedInt getNumberNonVirtual();
	#line 119 "igMersenneTwisterRandomNumber.h"
};

/**
 * A smart pointer to an object of type igMersenneTwisterRandomNumber.
 *
 * Smart pointers perform automatic reference-counting of the objects they point to.
 * See "Object Reference Counting" under "Intrinsic Alchemy Core" in the <i>User's Guide</i>.
 */
typedef Gap::igSmartPointer<igMersenneTwisterRandomNumber> igMersenneTwisterRandomNumberRef;

/**
 * A smart pointer to a constant (read-only) object of type igMersenneTwisterRandomNumber.
 *
 * Smart pointers perform automatic reference-counting of the objects they point to.
 * See "Object Reference Counting" under "Intrinsic Alchemy Core" in the <i>User's Guide</i>.
 */
typedef Gap::igSmartPointer<const igMersenneTwisterRandomNumber> igConstMersenneTwisterRandomNumberRef;

}
}


#endif
