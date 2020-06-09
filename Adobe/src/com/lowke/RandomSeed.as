package com.lowke
{
	// Generates random numbers in a predictable way.
	// Allows us to synchronize with random numbers on the server.
	public class RandomSeed
	{
		private var _seed:int = 246353424;
		private var _count:int; // Number of calls since seeded

		public function RandomSeed(seed:int)
		{
			setSeed(seed);
		}

		public function clone():RandomSeed
		{
			return new RandomSeed(_seed);
		}

		public function setSeed(seed:int):void
		{
			_seed = seed;
			_count = 0;
		}

		private function generateInt():int
		{
			_seed = _seed^(_seed<<13);
			_seed = _seed^(_seed>>17);
			_seed = _seed^(_seed<<5);
			return _seed;
		}

		public function getCallsSinceSeeded():int
		{
			return _count;
		}

		public function nextInt():int
		{
			_count++;
			return generateInt();
		}

		/* Return [0,n) */
		public function nextIntRange(n:int):int
		{
			if (n <= 0)
			{
				throw new Error("n must be positive");
			}

			var bits:int;
			var val:int;
			do
			{
				bits = nextInt();
				bits = bits < 0 ? -bits : bits ;
				val = bits % n;
			} while (bits - val + (n - 1) < 0);

			return val;
		}
	}
}