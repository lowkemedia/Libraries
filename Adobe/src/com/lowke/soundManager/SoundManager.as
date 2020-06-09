//
//  SoundManager v 2.0 - soundManager package
//  Russell Lowke, September 19th 2016
//
//  Copyright (c) 2008-2016 Lowke Media
//  see http://www.lowkemedia.com for more information
//  see http://code.google.com/p/lowke/ for code repository
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//
//

//
//
//  When possible encode audio at 44.1KHz Stereo.
//  This is because it is the target playback sampling rate of the Flash Player,
//  so if it’s not encoded at that then the player will have to to re-sample and
//  filter your audio which takes away precious CPU cycles.
//  Audio data is always exposed as 44100 Hz Stereo.


package com.lowke.soundManager
{
	import com.lowke.JsonVerifier;
	import com.lowke.assetManager.AssetManager;
	import com.lowke.assetManager.cache.Cache;
	import com.lowke.logger.Logger;
	import com.lowke.soundManager.soundFx.SoundFx;
	import com.lowke.soundManager.type.Type;
	
	public class SoundManager
	{
		//
		// error, warning and ifo IDs
		public static const LOG_PREFIX:String                           = "SND";
		public static const WARNING_CANT_FIND_SOUND:String = "SND00";
		public static const WARNING_SOUND_NOT_LOADED_YET:String = "SND01";

		private static var _instance:SoundManager = new SoundManager();
		private static var _assetManager:AssetManager;
        private static var _cache:Cache;

		private var _url:String;
		private var _jsonObject:Object;

		public function SoundManager()
		{
            _cache = new Cache();
			_assetManager = new AssetManager(_cache);
		}

		public function loadJson(url:String):void
		{
			_url = url;
			_assetManager.loadFile(_url, parseJson);
		}

		public function parseJson(jsonObject:Object):void
		{
			_jsonObject = jsonObject;

			var sounds:Array = JsonVerifier.getArray(_jsonObject, "sounds");
			for each (var json:Object in sounds)
			{
				var type:Type = Type.mk(json);
				addSound(type, type.id);
			}
		}

        private function addSound(soundType:Type,
                                  id:String,
                                  url:String = null):void
        {
            _cache.cacheAsset(soundType, id, false, url, null, true, false);
        }

		public function play(id:String, functionComplete:Function = null):void
		{
			
			var type:Type = _cache.retrieve(id, false);
			
			if (!type)
			{
				Logger.warning("Could not find sound \"" + id + "\" to play it.", WARNING_CANT_FIND_SOUND);
				return;
			}
			
			type.play(functionComplete);
		}

		public function stop(id:String):void
		{
            var type:Type = _cache.retrieve(id);
			type.stop();
		}

        public function removeSound(id:String, giveWarning:Boolean = true):void
        {
            _cache.forget(id, giveWarning);
        }

		public static function get assetManager():AssetManager
		{
			return _assetManager;
		}

		public static function get instance():SoundManager
		{
			return _instance;
		}

		public static function set masterVolume(value:Number):void
		{
			SoundFx.masterVolume = value;
		}

		public static function get masterVolume():Number
		{
			return SoundFx.masterVolume;
		}
	}
}