package com.lowke.soundManager.type.sound
{
	import com.lowke.Delayer;
	import com.lowke.JsonVerifier;
	import com.lowke.assetManager.AssetManager;
	import com.lowke.logger.Logger;
	import com.lowke.soundManager.SoundManager;
	import com.lowke.soundManager.soundFx.LoadSoundFx;
	import com.lowke.soundManager.soundFx.SoundFx;
	import com.lowke.soundManager.type.Type;
	
	public class Sound extends Type
	{
        protected var _assetManager:AssetManager;

        protected var _url:String;
		private var _volume:Number;
		private var _delay:uint;
		private var _loop:Boolean;
		protected var _sound:SoundFx;
		private var _delayer:Delayer;

		public function Sound(jsonObject:Object)
		{
			super(jsonObject);

			_assetManager = SoundManager.assetManager;

			_url = JsonVerifier.getString(jsonObject, "url", true);
			_volume = JsonVerifier.getNumber(jsonObject, "volume");
			_loop = JsonVerifier.getBoolean(jsonObject, "loop");
			_delay = JsonVerifier.getUint(jsonObject, "delay");

            loadSound();
		}

        protected function loadSound():void
        {
            var loadSoundFx:LoadSoundFx = new LoadSoundFx(_url);
            _assetManager.loadUsing(loadSoundFx, soundLoaded);
        }


        protected function soundLoaded(sound:SoundFx):void
		{
			_sound = sound;

			if (! _sound)
			{
				return;
			}

			_sound.id = _id;
			_sound.defaultVolume = _volume;
			_sound.loopByDefault = _loop;
		}

		override public function play(callBackFunct:Function = null):void
		{
			if (_delay)
			{
				_delayer = Delayer.delay(_delay, function ():void
				{
					internalPlay(callBackFunct);
				});
			}
			else
			{
				internalPlay(callBackFunct);
			}
		}

		private function internalPlay(callBackFunct:Function = null):void
		{
            if (! _sound)
            {
				Logger.warning("Sound \"" + _id + "\" can't be played yet as it hasn't loaded.", SoundManager.WARNING_SOUND_NOT_LOADED_YET);
                return;
            }

			_sound.playSound(callBackFunct);
		}

		override public function stop():void
		{
			if (_delayer)
			{
				_delayer.close();
				_delayer = null;
			}

            if (_sound)
            {
                _sound.stop();
            }
		}
	}
}
