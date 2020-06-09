package com.lowke.soundManager.type
{
	import com.lowke.JsonVerifier;
	import com.lowke.soundManager.SoundManager;
	import com.lowke.soundManager.type.group.Random;
	import com.lowke.soundManager.type.group.Sequential;
	import com.lowke.soundManager.type.group.Subtractive;
	import com.lowke.soundManager.type.sound.Lazy;
	import com.lowke.soundManager.type.sound.Sound;

	public class Type
	{
		private static const DEFINITIONS:Vector.<String> = new <String>[SOUND,
												LAZY, SEQUENTIAL,
												RANDOM, SUBTRACTIVE];
		public static const SOUND:String = "sound";
		public static const LAZY:String = "lazy";
		public static const SEQUENTIAL:String = "sequential";
		public static const RANDOM:String = "random";
		public static const SUBTRACTIVE:String = "subtractive";

        protected var _soundManager:SoundManager = SoundManager.instance;
		protected var _id:String;

		public static function mk(jsonObject:Object):Type
		{
			var type:String = JsonVerifier.getString(jsonObject, "type", true, SOUND, true, DEFINITIONS);

			// special case, check for "lazy" sound.
			if (type == SOUND)
			{
				var lazy:Boolean = JsonVerifier.getBoolean(jsonObject, "lazy");
				if (lazy)
				{
					type = LAZY;
				}
			}

			switch(type)
			{
				case SOUND:
					return new Sound(jsonObject);
				case LAZY:
					return new Lazy(jsonObject);
				case SEQUENTIAL:
					return new Sequential(jsonObject);
				case RANDOM:
					return new Random(jsonObject);
				case SUBTRACTIVE:
					return new Subtractive(jsonObject);
			}

			return null;
		}

		public function Type(jsonObject:Object)
		{
			_id = JsonVerifier.getString(jsonObject, "id", true);
		}

		public function get id():String
		{
			return _id;
		}

		// abstract method to be extended
		public function play(functionComplete:Function = null):void
		{
			throw new Error("Method play() must be overidden by extending class.");
		}

		// abstract method to be extended
		public function stop():void
		{
			throw new Error("Method stop() must be overidden by extending class.");
		}
	}
}
