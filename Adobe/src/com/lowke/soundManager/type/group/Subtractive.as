package com.lowke.soundManager.type.group
{

	import com.lowke.util.Util;

	public class Subtractive extends Group
	{
		private var indices:Vector.<int>;

		public function Subtractive(jsonObject:Object)
		{
			super(jsonObject);
		}

		private function getIndex():int
		{
			if (! indices || ! indices.length)
			{
				indices = new Vector.<int>();
				for (var i:int = 0; i < _rgSoundIds.length; ++i)
				{
					indices.push(i);
				}
			}

			var random:int = Util.randomInt(0, indices.length - 1);
			var index:int = indices.splice(random, 1)[0];
			return index;
		}

		override public function play(functionComplete:Function = null):void
		{
			playGroup(getIndex(), functionComplete);
		}
	}
}
