package com.lowke.soundManager.type.sound
{
	import com.lowke.soundManager.soundFx.LoadSoundFx;
	import com.lowke.soundManager.soundFx.SoundFx;

	public class Lazy extends Sound
	{

		public function Lazy(jsonObject:Object)
		{
			super(jsonObject);
		}

		override protected function loadSound():void
		{
			// lazy sounds don't load until played
		}

		override public function play(functionComplete:Function = null):void
		{
			if (_sound)
			{
				super.play(functionComplete);
				return;
			}

			var loadSoundFx:LoadSoundFx = new LoadSoundFx(_url);
			_assetManager.loadUsing(loadSoundFx, function(sound:SoundFx):void
				{
					lazySoundLoaded(sound, functionComplete);
				});
		}

		private function lazySoundLoaded(sound:SoundFx, functionComplete:Function):void
		{
			super.soundLoaded(sound);
			super.play(functionComplete);
		}
	}
}
