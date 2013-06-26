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
	import tetragon.util.tween.Tween;
	import tetragon.util.tween.TweenVars;

	import flash.events.Event;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	
	/**
	 * A music uses several sound loops and a sequence of numbers that indicate in
	 * which order the sound loops are played. It can be used to create more diverse
	 * arrangements of looped music by only using a limited number of audio loops.
	 */
	public class Music
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _id:String;
		private var _loops:Vector.<BasicSound>;
		private var _sequence:Array;
		private var _soundTransform:SoundTransform;
		private var _soundChannel:SoundChannel;
		private var _tweenVars:TweenVars;
		
		private var _volume:Number;
		private var _bar:int;
		private var _pausedPosition:Number;
		private var _pausedBar:int;
		
		private var _isPlaying:Boolean;
		private var _isFadeOut:Boolean;
		private var _isPausing:Boolean;
		private var _isUnpausing:Boolean;
		private var _paused:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function Music(id:String, volume:Number = 1.0)
		{
			_id = id;
			_soundTransform = new SoundTransform(0);
			_tweenVars = new TweenVars();
			_tweenVars.onUpdate = onTweenUpdate;
			_tweenVars.onComplete = onTweenComplete;
			this.volume = volume;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function addLoop(loop:BasicSound):void
		{
			if (!_loops) _loops = new Vector.<BasicSound>();
			_loops.push(loop);
		}
		
		
		public function play():void
		{
			if (!_sequence || !_loops || _loops.length < 1 || _sequence.length < 1) return;
			
			_soundTransform.volume = 0;
			
			if (_isUnpausing)
			{
				_bar = _pausedBar;
				playNextLoop();
				_tweenVars.setProperty("volume", _volume);
				Tween.to(_soundTransform, 0.2, _tweenVars);
			}
			else
			{
				_bar = -1;
				_pausedPosition = 0;
				_isPlaying = true;
				_isFadeOut = false;
				playNextLoop();
				_tweenVars.setProperty("volume", _volume);
				Tween.to(_soundTransform, 1, _tweenVars);
			}
		}
		
		
		public function stop():void
		{
			if (!_loops || !_isPlaying) return;
			
			if (_isPausing)
			{
				_tweenVars.setProperty("volume", 0);
				Tween.to(_soundTransform, 0.2, _tweenVars);
			}
			else
			{
				_isFadeOut = true;
				_pausedPosition = 0;
				_tweenVars.setProperty("volume", 0);
				Tween.to(_soundTransform, 0.4, _tweenVars);
			}
		}
		
		
		/**
		 * Disposes the class.
		 */
		public function dispose():void
		{
			if (_soundTransform)
			{
				Tween.killTweensOf(_soundTransform);
			}
			if (_soundChannel)
			{
				_soundChannel.stop();
				_soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get id():String
		{
			return _id;
		}
		
		
		public function get volume():Number
		{
			return _volume;
		}
		public function set volume(v:Number):void
		{
			_volume = v < 0 ? 0 : v > 1 ? 1 : v;
			_soundTransform.volume = _volume;
			if (_soundChannel) _soundChannel.soundTransform = _soundTransform;
			if (_isPlaying)
			{
				Tween.killTweensOf(_soundTransform);
				onTweenUpdate();
			}
		}
		
		
		public function get sequence():Array
		{
			return _sequence;
		}
		public function set sequence(v:Array):void
		{
			_sequence = v;
		}
		
		
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		
		public function get paused():Boolean
		{
			return _paused;
		}
		public function set paused(v:Boolean):void
		{
			if (v == _paused) return;
			if (!_soundChannel) return;
			_paused = v;
			_isFadeOut = false;
			if (_paused)
			{
				_isPausing = true;
				stop();
			}
			else
			{
				_isUnpausing = true;
				play();
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onTweenUpdate():void
		{
			_soundChannel.soundTransform = _soundTransform;
		}
		
		
		private function onTweenComplete():void
		{
			if (_isFadeOut)
			{
				_soundChannel.stop();
				_soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
				_soundChannel = null;
				_isPlaying = false;
			}
			else if (_isPausing)
			{
				_pausedBar = _bar;
				_pausedPosition = _soundChannel.position;
				_soundChannel.stop();
				_isPausing = false;
			}
			_isUnpausing = false;
		}
		
		
		private function onSoundComplete(e:Event):void
		{
			_soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			playNextLoop();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function playNextLoop():void
		{
			var bar:BasicSound = getNextBar();
			_soundChannel = bar.play(_pausedPosition, 1, _soundTransform);
			_soundChannel.soundTransform = _soundTransform;
			_soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		}
		
		
		private function getNextBar():BasicSound
		{
			if (_bar == _sequence.length - 1) _bar = -1;
			_bar++;
			var loopNr:int = _sequence[_bar];
			return _loops[loopNr];
		}
	}
}
