package com.lowke.util
{
	public class BinaryUtil
	{
		/**
		*	bitNum	the position of the bit.  left most bit is bit zero
		*	bitVal	the 0 or 1 value of a given bit
		*	num		the number to have it's bit altered
		*
		* note: assign the modified var to the output of the set/clr function
		* myNum = BinaryUtil.setBit(myNum, 1, 6);	// <<== sets the 6th bit to 1
		*
		*	 test usage producess
		*	 this output
		*	 
		*	 bit #0:	1	true
		*	bit #1:	0	false
		*	bit #2:	1	true
		*	bit #3:	0	false
		*	bit #4:	1	true
		*	bit #5:	0	false
		*	bit #6:	1	true
		*	bit #7:	1	true
		*	myNum  	213	11010101
		*	Copy   	213	11010101
		*	Inverse	213	101010
		*
		*		public function TestBinary() {
		*			var myNum:uint=213;
		*			var myNumCopy:int=0;
		*			var myNumInverse:int=0;
		*			for(var iB:uint=0; iB<8; ++iB) {
		*				var tf:Boolean = getBitAsBoolean(myNum,iB);						// convert specific bit to true/false
		*				myNumCopy = setBit(myNumCopy, getBit(myNum,iB), iB);			// produce the same bit as in myNum
		*				myNumInverse = setBit(myNumInverse, 1-getBit(myNum,iB), iB);	// produce inverse of myNum's bit
		*				trace("bit #" + iB + ":\t" + getBit(myNum,iB) + "\t" + tf );
		*			}
		*			trace("myNum  \t" + myNum		+ "\t" + showUintAsBinary(myNum) );
		*			trace("Copy   \t" + myNumCopy	+ "\t" + showUintAsBinary(myNumCopy) );
		*			trace("Inverse\t" + myNumCopy	+ "\t" + showUintAsBinary(myNumInverse) );
		*		}
		*/
		
		/**
		 * maxBit
		 * defaults to 31.  
		 */
		public static var maxBit:uint = 31;
		

		/**
		 * getBit (num:uint, bitNum:uint ):uint
		 * 
		 * getBit(myNum, 3);
		 */
		public static function getBit(num:uint, bitNum:uint ):uint
		{
			return num>>bitNum &1;
		}

		/**
		 * setBit (num:uint, bitVal:uint, bitNum:uint):uint
		 * 
		 * myNum = setBit (myNum, 0, 4);	// clear bit #4 ** the 5th bit ** in myNum
		 */
		public static function setBit(num:uint, bitVal:uint, bitNum:uint):uint
		{
			return num | bitVal<<bitNum;
		}

		/**
		 * setBitInUint (bitNum:uint, num:uint):uint
		 * 
		 * myNum = setBitInUint (myNum, 3);		// make bit #3 ** the 4th bit** be a 1
		 */
		public static function setBitInUint(bitNum:uint, num:uint):uint
		{
			if (bitNum > maxBit)
			{
				return num;
			}
			return num | flag(bitNum);
		}
		
		/**
		 * clearBitInUint (bitNum:uint, num:uint):uint
		 * 
		 * myNum = clrBitInUint (myNum, 3);		// make bit #3 ** the 4th bit** be a 0
		 */
		public static function clearBitInUint(bitNum:uint, num:uint):uint
		{
			if (bitNum>maxBit)
			{
				return num;
			}
			return num & ~flag(bitNum);
		}
		
		/**
		 * getBitAsBoolean (num:uint, bitNum:uint):Boolean
		 */
		public static function getBitAsBoolean(num:uint, bitNum:uint):Boolean
		{
			return Boolean(getBit(num,bitNum) == 1);
		}

		/**
		 * setBooleanAsBit (num:uint, tf:Boolean, bitNum:uint ):uint
		 * 
		 * myNum = setBooleanAsBit (myNum, true, 5 );	// set myNum's 6th bit be a "1"
		 */
		public static function setBooleanAsBit (num:uint, tf:Boolean, bitNum:uint ):uint
		{
			return setBit(num, tf?1:0, bitNum);
		}

		/**
		 * flag	(bitNum:uint):uint
		 * 
		 * trace( flag(6) ) ;		// produces 64
		 */
		public static function flag(bitNum:uint):uint
		{
			return 1<<bitNum;
		}
		

		/**
		 * showUintAsBinary	(num:uint):String
		 * 
		 * trace( showUintAsBinary(213) )	// produces 11010101
		 */
		public static function showUintAsBinary(num:uint):String
        {
			var s:String="";
			var bit:uint=0;
			while((num>>bit) > 0)
			{
				++bit;
			}
			for(var iB:int=bit-1; iB>=0; --iB)
			{
				s+= ((!!(num&(1<<iB))) ? "1":"0");
			}
			return s;
		}
	}
}