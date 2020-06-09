package com.lowke.soundManager.type.group
{

	import com.lowke.JsonVerifier;
    import com.lowke.soundManager.type.Type;

    public class Group extends Type
	{
		protected var _rgSoundIds:Vector.<String>;
		protected var _index:int;                // index of last sound played

		public function Group(jsonObject:Object)
		{
			super(jsonObject);

			_rgSoundIds = new Vector.<String>;
			var array:Array = JsonVerifier.getArray(jsonObject, "sounds", true);
			for each (var sound:String in array)
			{
				_rgSoundIds.push(sound);
			}
		}

		public function playGroup(index:int, functionComplete:Function = null):void
		{
			_index = index;
			_soundManager.play(getSoundId(_index), functionComplete);
		}

		private function getSoundId(index:int):String
		{
			return _rgSoundIds[index];
		}

		override public function stop():void
		{
			_soundManager.stop(getSoundId(_index));
		}
	}
}
