/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * Tetragon : Game Engine for multi-platform ActionScript projects.
 * http://www.tetragonengine.com/ - Copyright (C) 2012 Sascha Balkau
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
package tetragon.audio
{
	import tetragon.util.tween.Tween;
	import tetragon.util.tween.TweenVars;

	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	
	/**
	 * A SoundSequence can be useds to play a sequence of succeeding sounds and
	 * loop the sequence infinitely.
	 * 
	 * TODO Obsolete class!
	 */
	public class SoundSequence
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _sounds:Vector.<Sound>;
		/** @private */
		private var _sequence:Array;
		/** @private */
		private var _soundTransform:SoundTransform;
		/** @private */
		private var _soundChannel:SoundChannel;
		/** @private */
		private var _tweenVars:TweenVars;
		/** @private */
		private var _bar:int;
		/** @private */
		private var _volume:Number;
		/** @private */
		private var _fadeInDuration:Number = 1.0;
		/** @private */
		private var _fadeOutDuration:Number = 0.5;
		/** @private */
		private var _isPlaying:Boolean;
		/** @private */
		private var _isFadeOut:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param sequence Array of sound numbers.
		 * @param volume
		 */
		public function SoundSequence(sequence:Array = null, volume:Number = 1.0)
		{
			_soundTransform = new SoundTransform();
			_tweenVars = new TweenVars();
			_tweenVars.onUpdate = onTweenUpdate;
			_tweenVars.onComplete = onTweenComplete;
			
			this.sequence = sequence;
			this.volume = volume;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds a sound.
		 * 
		 * @param sound
		 */
		public function addSound(sound:Sound):void
		{
			if (!_sounds) _sounds = new Vector.<Sound>();
			_sounds.push(sound);
		}
		
		
		/**
		 * Plays the sound sequence.
		 */
		public function play():void
		{
			if (!_sounds || !_sequence) return;
			
			_bar = -1;
			_soundTransform.volume = 0.0;
			_isPlaying = true;
			_isFadeOut = false;
			
			playNextLoop();
			
			if (_fadeInDuration > 0.0)
			{
				_tweenVars.setProperty("volume", _volume);
				Tween.to(_soundTransform, _fadeInDuration, _tweenVars);
			}
			else
			{
				_soundTransform.volume = _volume;
				onTweenUpdate();
				onTweenComplete();
			}
		}
		
		
		/**
		 * Stops the sound sequence.
		 */
		public function stop():void
		{
			if (!_sounds || !_isPlaying) return;
			_isFadeOut = true;
			
			if (_fadeOutDuration > 0.0)
			{
				_tweenVars.setProperty("volume", 0.0);
				Tween.to(_soundTransform, _fadeOutDuration, _tweenVars);
			}
			else
			{
				_soundTransform.volume = 0.0;
				onTweenUpdate();
				onTweenComplete();
			}
		}
		
		
		/**
		 * Disposes the object.
		 */
		public function dispose():void
		{
			Tween.killTweensOf(_soundTransform);
			if (_soundChannel)
			{
				_soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Playback volume of the sound sequence (range 0.0 - 1.0).
		 * 
		 * @default 1.0
		 */
		public function get volume():Number
		{
			return _volume;
		}
		public function set volume(v:Number):void
		{
			_volume = v < 0 ? 0 : v > 1.0 ? 1.0 : v;
			_soundTransform.volume = _volume;
			if (_soundChannel) _soundChannel.soundTransform = _soundTransform;
		}
		
		
		/**
		 * Time it takes to fade in the sound (in seconds).
		 * 
		 * @default 1.0
		 */
		public function get fadeInDuration():Number
		{
			return _fadeInDuration;
		}
		public function set fadeInDuration(v:Number):void
		{
			_fadeInDuration = v < 0.0 ? 0.0 : v;
		}
		
		
		/**
		 * Time it takes to fade out the sound (in seconds).
		 * 
		 * @default 0.5
		 */
		public function get fadeOutDuration():Number
		{
			return _fadeOutDuration;
		}
		public function set fadeOutDuration(v:Number):void
		{
			_fadeOutDuration = v < 0.0 ? 0.0 : v;
		}
		
		
		/**
		 * An array with numbers representing the sound number in the sequence (zero based).
		 */
		public function get sequence():Array
		{
			return _sequence;
		}
		public function set sequence(v:Array):void
		{
			_sequence = v;
		}
		
		
		/**
		 * Determines whether the sound sequence is currently playing or not.
		 */
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onTweenUpdate():void
		{
			_soundChannel.soundTransform = _soundTransform;
		}
		
		
		/**
		 * @private
		 */
		private function onTweenComplete():void
		{
			if (_isFadeOut)
			{
				_soundChannel.stop();
				_soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
				_soundChannel = null;
				_isPlaying = false;
			}
		}
		
		
		/**
		 * @private
		 */
		private function onSoundComplete(e:Event):void
		{
			_soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			playNextLoop();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function playNextLoop():void
		{
			var bar:Sound = getNextBar();
			_soundChannel = bar.play(0.0, 1, _soundTransform);
			_soundChannel.soundTransform = _soundTransform;
			_soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		}
		
		
		/**
		 * @private
		 */
		private function getNextBar():Sound
		{
			if (_bar == _sequence.length - 1) _bar = -1;
			++_bar;
			var loopNr:int = _sequence[_bar];
			return _sounds[loopNr];
		}
	}
}
