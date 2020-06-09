package com.lowke.soundManager.type.group
{
    import com.lowke.util.Util;

	public class Random extends Group
	{

		public function Random(jsonObject:Object)
		{
			super(jsonObject);
		}

		override public function play(functionComplete:Function = null):void
		{
			/// select a new random sound to play
			var index:int = Util.randomInt(0, _rgSoundIds.length - 1);
			playGroup(index, functionComplete);
		}
	}
}
