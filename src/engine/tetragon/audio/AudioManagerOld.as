/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * tetragon : Engine for Flash-based web and desktop games.
 * Licensed under the MIT License.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package tetragon.audio
{
	import tetragon.Main;
	import tetragon.core.exception.Exception;
	import tetragon.data.Settings;
	import tetragon.file.resource.ResourceIndex;

	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;
	
	
	/**
	 * An audio manager that can play sound effects and music.
	 */
	public class AudioManagerOld
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Constant value for the max. possible number of loops.
		 */
		public static const MAX_LOOPS:int = int.MAX_VALUE;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _resourceIndex:ResourceIndex;
		/** @private */
		private var _musics:Object;
		/** @private */
		private var _channels:Dictionary;
		/** @private */
		private var _globalVolume:Number;
		/** @private */
		private var _musicVolume:Number;
		/** @private */
		private var _musicVolumeDefault:Number;
		/** @private */
		private var _effectsVolume:Number;
		/** @private */
		private var _currentMusicID:String;
		/** @private */
		private var _paused:Boolean;
		/** @private */
		private var _muted:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function AudioManagerOld(pass:Object)
		{
			if (!(pass is Main))
			{
				throw new Exception("Tried to instanciate AudioManager directly."
					+ " Use main.audioManager instead!");
				return;
			}
			
			_resourceIndex = Main.instance.resourceManager.resourceIndex;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function init():void
		{
			dispose();
			
			/* Retrieve volume values. All other volumes are offset from the global volume. */
			var settings:Settings = Main.instance.registry.settings;
			_globalVolume = settings.getNumber("globalVolume");
			_musicVolume = settings.getNumber("musicVolume");
			_effectsVolume = settings.getNumber("effectsVolume");
			
			calculateVolumes();
			
			_musics = {};
			_channels = new Dictionary();
		}
		
		
		/**
		 * Plays an effect sound.
		 * 
		 * @param sound Can be a Sound object, Sound class or a sound resource ID string.
		 * @param loops Number of times the sound should be played, 0 = once.
		 * @param volume Sound volume, 0.0 to 1.0.
		 * @param solo If true all other currently playing sound effects are stopped.
		 * @return The SoundChannel object of the sound.
		 */
		public function playSound(sound:*, loops:int = 0, volume:Number = NaN,
			solo:Boolean = false):SoundChannel
		{
			if (_muted || !sound) return null;
			if (solo) stopSounds();
			
			var s:Sound;
			var obj:*;
			
			/* Create or obtain the sound object. */
			if (sound is String)
			{
				obj = _resourceIndex.getResourceContent(sound);
				if (!(obj is Sound)) return null;
				s = obj;
			}
			else if (sound is Class)
			{
				obj = new sound();
				if (!(obj is Sound)) return null;
				s = obj;
			}
			else if (sound is Sound)
			{
				s = sound;
			}
			
			/* Limit volume and loops. */
			var vol:Number = isNaN(volume) ? _effectsVolume : volume;
			if (vol < 0.0) vol = 0.0;
			else if (vol > 1.0) vol = 1.0;
			if (loops < 0) loops = 0;
			else if (loops > MAX_LOOPS) loops = MAX_LOOPS;
			
			var st:SoundTransform = new SoundTransform(vol);
			//var sc:Class = getSoundClass(s);
			
			/* Stop the same sound if it's already playing. */
			if (_channels[s])
			{
				(_channels[s] as SoundChannel).stop();
			}
			
			/* Play the sound and get it's channel. */
			var ch:SoundChannel = s.play(0, loops, st);
			
			_channels[s] = ch;
			return ch;
		}
		
		
		/**
		 * Stops a specific sound. The sound object is identified by it's class.
		 * 
		 * @param soundClass The class of the sound.
		 * @return true if the sound was stopped, false if the sound was not playing.
		 */
		public function stopSound(sound:Sound):Boolean
		{
			var channel:SoundChannel = _channels[sound];
			if (!channel) return false;
			channel.stop();
			delete _channels[channel];
			return true;
		}
		
		
		/**
		 * Stops all currently playing sounds that were started with playSound().
		 */
		public function stopSounds():void
		{
			for each (var channel:SoundChannel in _channels)
			{
				channel.stop();
				delete _channels[channel];
			}
		}
		
		
		/**
		 * Creates a music.
		 * 
		 * @param id ID of the music.
		 * @param loops Array of audio loops.
		 * @param sequence Array of sequence numbers.
		 * @return A Music object.
		 */
		public function createMusic(id:String, loops:Array, sequence:Array):Music
		{
			if (_musics[id]) return _musics[id];
			var music:Music = new Music();
			for (var i:uint = 0; i < loops.length; i++)
			{
				music.addLoop(loops[i]);
			}
			music.sequence = sequence;
			_musics[id] = music;
			return music;
		}
		
		
		/**
		 * Starts playing a specific music.
		 * 
		 * @param id
		 */
		public function startMusic(id:String):void
		{
			if (_muted) return;
			if (id == _currentMusicID) return;
			var music:Music = _musics[id];
			if (!music) return;
			if (music.isPlaying) return;
			_currentMusicID = id;
			music.volume = _musicVolume;
			music.play();
		}
		
		
		/**
		 * Stops currently played music.
		 */
		public function stopMusic():void
		{
			if (_currentMusicID == null) return;
			var music:Music = _musics[_currentMusicID];
			if (!music) return;
			music.stop();
			_currentMusicID = null;
		}
		
		
		public function toggleVolume():void
		{
			toggleMusicVolume();
			
		}
		
		
		public function toggleMusicVolume():void
		{
			if (_musicVolume > 0) _musicVolume = 0;
			else _musicVolume = _musicVolumeDefault;
			
			var currentMusic:Music = _musics[_currentMusicID];
			if (currentMusic)
			{
				currentMusic.volume = _musicVolume;
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			stopSounds();
			for each (var m:Music in _musics)
			{
				m.dispose();
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The global volume that is used as a base for all other volumes.
		 */
		public function get globalVolume():Number
		{
			return _globalVolume;
		}
		public function set globalVolume(v:Number):void
		{
			_globalVolume = v;
			calculateVolumes();
		}
		
		
		/**
		 * The general audio volume for music.
		 */
		public function get musicVolume():Number
		{
			return _musicVolume;
		}
		public function set musicVolume(v:Number):void
		{
			_musicVolume = v;
			calculateVolumes();
		}
		
		
		/**
		 * The general audio volume for sound effects.
		 */
		public function get effectsVolume():Number
		{
			return _effectsVolume;
		}
		public function set effectsVolume(v:Number):void
		{
			_effectsVolume = v;
			calculateVolumes();
		}
		
		
		/**
		 * Pauses/unpauses the current music.
		 */
		public function get paused():Boolean
		{
			return _paused;
		}
		public function set paused(v:Boolean):void
		{
			_paused = v;
			var music:Music = _musics[_currentMusicID];
			if (!music) return;
			music.paused = v;
		}
		
		
		/**
		 * Determines whether all sounds and music is currently muted or not.
		 */
		public function get muted():Boolean
		{
			return _muted;
		}
		public function set muted(v:Boolean):void
		{
			_muted = v;
			if (_muted)
			{
				_musicVolume = 0;
				var transform:SoundTransform;
			}
			else
			{
				_musicVolume = _musicVolumeDefault;
			}
			for each (var m:Music in _musics)
			{
				m.volume = _musicVolume;
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Calculates the volumes by keeping their offset to the global volume in mind.
		 * @private
		 */
		private function calculateVolumes():void
		{
			_globalVolume = isNaN(_globalVolume) ? 1.0 : _globalVolume;
			if (_globalVolume < 0.0) _globalVolume = 0.0;
			else if (_globalVolume > 1.0) _globalVolume = 1.0;
			
			_musicVolume = calculateVolumeOffset(isNaN(_musicVolume) ? 1.0 : _musicVolume);
			if (_musicVolume < 0.0) _musicVolume = 0.0;
			else if (_musicVolume > 1.0) _musicVolume = 1.0;
			_musicVolumeDefault = _musicVolume;
			
			_effectsVolume = calculateVolumeOffset(isNaN(_effectsVolume) ? 1.0 : _effectsVolume);
			if (_effectsVolume < 0.0) _effectsVolume = 0.0;
			else if (_effectsVolume > 1.0) _effectsVolume = 1.0;
		}
		
		
		/**
		 * Calculates the volume in respect to the global volume.
		 * @private
		 */
		private function calculateVolumeOffset(volume:Number):Number
		{
			var percent:Number = (volume / _globalVolume) * 100;
			var value:Number = (percent * _globalVolume) / 100;
			return value;
		}
		
		
		/**
		 * @private
		 */
//		private function getSoundClass(sound:Sound):Class
//		{
//			if (!sound) return null;
//			return sound['constructor'] as Class;
//		}
	}
}
