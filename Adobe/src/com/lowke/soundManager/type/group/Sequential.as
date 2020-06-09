package com.lowke.soundManager.type.group
{

    public class Sequential extends Group
	{

		public function Sequential(jsonObject:Object)
		{
			super(jsonObject);
		}

		override public function play(functionComplete:Function = null):void
		{
			playGroup(_index, functionComplete);

			// increment index and loop back to beginning if at end
			_index++;
			if (_index == _rgSoundIds.length)
			{
				_index = 0;
			}
		}
	}
}
