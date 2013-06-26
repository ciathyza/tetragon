/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * Tetragon : Game Engine for multi-platform ActionScript projects.
 * http://www.tetragonengine.com/
 * Copyright (c) The respective Copyright Holder (see LICENSE).
 * 
 * Permission is hereby granted, to any person obtaining a copy of this software
 * and associated documentation files (the "Software") under the rules defined in
 * the license found at http://www.tetragonengine.com/license/ or the LICENSE
 * file included within this distribution.
 * 
 * The above copyright notice and this permission notice must be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND. THE COPYRIGHT
 * HOLDER AND ITS LICENSORS DISCLAIM ALL WARRANTIES AND CONDITIONS, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO ANY IMPLIED WARRANTIES AND CONDITIONS OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT, AND ANY
 * WARRANTIES AND CONDITIONS ARISING OUT OF COURSE OF DEALING OR USAGE OF TRADE.
 * NO ADVICE OR INFORMATION, WHETHER ORAL OR WRITTEN, OBTAINED FROM THE COPYRIGHT
 * HOLDER OR ELSEWHERE WILL CREATE ANY WARRANTY OR CONDITION NOT EXPRESSLY STATED
 * IN THIS AGREEMENT.
 */
package tetragon.audio
{
	import tetragon.Main;
	import tetragon.core.exception.Exception;
	import tetragon.data.Settings;
	import tetragon.debug.Log;
	import tetragon.file.resource.ResourceIndex;

	import flash.media.Sound;
	import flash.utils.Dictionary;
	
	
	/**
	 * AudioManager class
	 *
	 * @author Hexagon
	 */
	public class AudioManager
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Constant value for the max. possible number of loops that a sound can be played.
		 */
		public static const MAX_LOOPS:int = int.MAX_VALUE;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _resourceIndex:ResourceIndex;
		/** @private */
		private var _sounds:Dictionary;
		/** @private */
		private var _musics:Dictionary;
		
		/** @private */
		private var _globalVolume:Number;
		/** @private */
		private var _effectsVolume:Number;
		/** @private */
		private var _effectsVolumeDefault:Number;
		/** @private */
		private var _musicVolume:Number;
		/** @private */
		private var _musicVolumeDefault:Number;
		
		private var _soundIDCounter:uint;
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
		 * @private
		 */
		public function AudioManager(pass:Object)
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
		 * Initializes the audio manager.
		 * A call to this method removes all mapped music objects.
		 */
		public function init():void
		{
			dispose();
			calculateVolumes();
			_musics = new Dictionary();
		}
		
		
		/**
		 * Plays a sound.
		 * 
		 * @param sound Can be a Sound object, Sound class, a sound resource ID string or a
		 *        BasicSound or PitchableSound object.
		 * @param loops Number of times the sound should be played, 0 = once, -1 = infinitely.
		 * @param volume Sound volume, 0.0 to 1.0.
		 * @param pan Sound panning, -1.0 to 1.0.
		 * 
		 * @return the sound's ID.
		 */
		public function playSound(sound:*, loops:int = 0, volume:Number = NaN,
			pan:Number = NaN, pitchRate:Number = NaN):String
		{
			if (_muted || !sound) return null;
			
			var snd:BasicSound;
			
			/* Re-use sound if already mapped. */
			if (sound is String)
			{
				snd = _sounds[sound as String];
			}
			if (!snd)
			{
				snd = createSound(sound, loops, volume, pan, pitchRate);
				_sounds[snd.id] = snd;
			}
			
			if (!snd) return null;
			snd.play();
			
			return snd.id;
		}
		
		
		/**
		 * Stops a sound that is playing.
		 * 
		 * @param id ID of the sound.
		 * @return true if the sound was stopped, false otherwise.
		 */
		public function stopSound(id:String):Boolean
		{
			var snd:BasicSound = _sounds[id];
			if (!snd) return false;
			snd.stop();
			return true;
		}
		
		
		/**
		 * Stops all sounds that are currently playing.
		 */
		public function stopAllSounds():void
		{
			for each (var s:BasicSound in _sounds)
			{
				stopSound(s.id);
			}
		}
		
		
		/**
		 * Creates and maps a music object.
		 * 
		 * @param id ID of the music.
		 * @param loops Array of audio loops.
		 * @param sequence Array of sequence numbers. If null, a seq with [0] is used.
		 * @return A Music object.
		 */
		public function createMusic(id:String, loops:Array, sequence:Array = null):Music
		{
			if (_musics[id]) return _musics[id];
			
			var music:Music = new Music(id);
			for (var i:uint = 0; i < loops.length; i++)
			{
				var bsd:BasicSound = createSound(loops[i], 0, 1.0, 0.0, NaN);
				if (bsd) music.addLoop(bsd);
			}
			
			music.sequence = sequence || [0];
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
			if (_currentMusicID == null || !_musics) return;
			var music:Music = _musics[_currentMusicID];
			if (!music) return;
			music.stop();
			_currentMusicID = null;
		}
		
		
		/**
		 * Disposes all sounds. This resets the internal map in that all sounds
		 * are stored. Created music objects are not disposed! The audiomanager
		 * can be reused afterwards.
		 */
		public function dispose():void
		{
			stopAllSounds();
			stopMusic();
			for each (var s:BasicSound in _sounds)
			{
				s.dispose();
			}
			for each (var m:Music in _musics)
			{
				m.dispose();
			}
			_soundIDCounter = 0;
			_sounds = new Dictionary();
		}
		
		
		/**
		 * @param id
		 * @return BasicSound
		 */
		public function getSound(id:String):BasicSound
		{
			return _sounds[id];
		}
		
		
		/**
		 * @param id
		 * @return Music
		 */
		public function getMusic(id:String):Music
		{
			return _musics[id];
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "AudioManager";
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
		 * Pauses/unpauses currently played sounds and music.
		 */
		public function get paused():Boolean
		{
			return _paused;
		}
		public function set paused(v:Boolean):void
		{
			_paused = v;
			var music:Music = _musics[_currentMusicID];
			if (music) music.paused = v;
			for each (var s:BasicSound in _sounds)
			{
				s.paused = _paused;
			}
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
				_musicVolume = _effectsVolume = 0;
			}
			else
			{
				_musicVolume = _musicVolumeDefault;
				_effectsVolume = _effectsVolumeDefault;
			}
			for each (var m:Music in _musics)
			{
				m.volume = _musicVolume;
			}
			for each (var s:BasicSound in _sounds)
			{
				s.volume = _effectsVolume;
			}
		}
		
		
		/**
		 * @private
		 */
		public function get sounds():Dictionary
		{
			return _sounds;
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
			/* Retrieve volume values. All other volumes are offset from the global volume. */
			var settings:Settings = Main.instance.registry.settings;
			_globalVolume = settings.getNumber("globalVolume");
			_musicVolume = settings.getNumber("musicVolume");
			_effectsVolume = settings.getNumber("effectsVolume");
			
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
			_effectsVolumeDefault = _effectsVolume;
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
		 * Creates the basic sound object.
		 * @private
		 */
		private function createSound(sound:*, loops:int, volume:Number, pan:Number,
			pitchRate:Number):BasicSound
		{
			var snd:*;
			var id:String;
			
			if (sound is String)
			{
				snd = _resourceIndex.getResourceContent(sound);
				id = sound;
			}
			else if (sound is Class)
			{
				snd = new sound();
				id = getUniqueSoundID();
			}
			else if (sound is Sound)
			{
				snd = sound;
				id = getUniqueSoundID();
			}
			else if (sound is BasicSound || sound is PitchableSound)
			{
				var bsd:BasicSound = sound;
				bsd.volume = volume;
				bsd.pan = pan;
				bsd.loops = loops;
				return bsd;
			}
			
			if (!(snd is Sound))
			{
				Log.warn("createSound:: Could not create sound from " + sound + ".", this);
				return null;
			}
			
			if (!isNaN(pitchRate))
			{
				return new PitchableSound(id, snd, isNaN(volume) ? _effectsVolume : volume,
					isNaN(pan) ? 0.0 : pan, loops, pitchRate);
			}
			
			return new BasicSound(id, snd, isNaN(volume) ? _effectsVolume : volume,
				isNaN(pan) ? 0.0 : pan, loops);
		}
		
		
		/**
		 * @private
		 */
		private function getUniqueSoundID():String
		{
			return "sound" + _soundIDCounter++;
		}
	}
}
