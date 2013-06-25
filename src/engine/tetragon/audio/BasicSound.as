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
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	
	/**
	 * A basic sound.
	 */
	public class BasicSound
	{
		// -----------------------------------------------------------------------------------------
		// Properties
		// -----------------------------------------------------------------------------------------
		
		/**
		 * The source sound that is being used as a sound.
		 */
		public var sound:Sound;
		
		/** @private */
		protected var _volume:Number;
		/** @private */
		protected var _pan:Number;
		/** @private */
		protected var _loops:int;
		/** @private */
		protected var _startTime:Number;
		/** @private */
		protected var _soundTransform:SoundTransform;
		/** @private */
		protected var _soundChannel:SoundChannel;
		/** @private */
		protected var _paused:Boolean;
		
		
		// -----------------------------------------------------------------------------------------
		// Constructor
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @param sound
		 * @param volume
		 * @param pan
		 * @param loops
		 */
		public function BasicSound(sound:Sound = null, volume:Number = 1.0, pan:Number = 0.0,
			loops:int = 0)
		{
			this.sound = sound;
			this.volume = volume;
			this.pan = pan;
			this.loops = loops;
			
			_soundTransform = new SoundTransform();
			_startTime = 0;
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Public Methods
		// -----------------------------------------------------------------------------------------
		
		/**
		 * Plays the sound.
		 */
		public function play():void
		{
			if (!sound) return;
			
			_soundTransform.volume = _volume;
			_soundTransform.pan = _pan;
			_soundChannel = sound.play(_startTime, _loops, _soundTransform);
		}
		
		
		/**
		 * Stops the sound.
		 */
		public function stop():void
		{
			if (!_soundChannel) return;
			_soundChannel.stop();
			_soundChannel = null;
			_startTime = 0;
		}
		
		
		/**
		 * Disposes the object.
		 */
		public function dispose():void
		{
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Accessors
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @default 1.0
		 */
		public function get volume():Number
		{
			return _volume;
		}
		public function set volume(v:Number):void
		{
			_volume = v < 0.0 ? 0.0 : v > 1.0 ? 1.0 : v;
		}
		
		
		/**
		 * @default 0.0
		 */
		public function get pan():Number
		{
			return _pan;
		}
		public function set pan(v:Number):void
		{
			_pan = v < -1.0 ? -1.0 : v > 1.0 ? 1.0 : v;
		}
		
		
		/**
		 * @default 0
		 */
		public function get loops():int
		{
			return _loops;
		}
		public function set loops(v:int):void
		{
			_loops = v < -1 ? -1 : v;
		}
		
		
		public function get soundTransform():SoundTransform
		{
			return _soundTransform;
		}
		
		
		/**
		 * Playback position of the sound, in milliseconds.
		 */
		public function get position():Number
		{
			if (!_soundChannel) return 0;
			return _soundChannel.position;
		}
		
		
		public function get paused():Boolean
		{
			return _paused;
		}
		public function set paused(v:Boolean):void
		{
			if (v == _paused || !_soundChannel) return;
			_paused = v;
			if (v)
			{
				_startTime = _soundChannel.position;
				_soundChannel.stop();
			}
			else
			{
				play();
			}
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Event Handlers
		// -----------------------------------------------------------------------------------------
		
	}
}
