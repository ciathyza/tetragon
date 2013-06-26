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
	import tetragon.util.reflection.getClassName;

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
		protected var _id:String;
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
		 * @param id
		 * @param sound
		 * @param volume
		 * @param pan
		 * @param loops
		 */
		public function BasicSound(id:String, sound:Sound, volume:Number = 1.0, pan:Number = 0.0,
			loops:int = 0)
		{
			_id = id;
			
			this.sound = sound;
			setParams(volume, pan, loops);
			
			_soundTransform = new SoundTransform();
			_startTime = 0;
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Public Methods
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @param volume
		 * @param pan
		 * @param loops
		 */
		public function setParams(volume:Number = 1.0, pan:Number = 0.0, loops:int = 0):void
		{
			_volume = volume < 0.0 ? 0.0 : volume > 1.0 ? 1.0 : volume;
			_pan = pan < -1.0 ? -1.0 : pan > 1.0 ? 1.0 : pan;
			_loops = loops < -1 ? -1 : loops > int.MAX_VALUE ? int.MAX_VALUE : loops;
		}
		
		
		/**
		 * Plays the sound.
		 */
		public function play(startTime:Number = NaN, loops:Number = NaN,
			st:SoundTransform = null):SoundChannel
		{
			if (!sound) return null;
			
			/* Stop sound if already playing. */
			if (_soundChannel)
			{
				_soundChannel.stop();
				_startTime = 0;
			}
			
			if (!isNaN(startTime)) _startTime = startTime;
			if (!isNaN(loops)) _loops = loops;
			
			if (st)
			{
				_soundTransform = st;
			}
			else
			{
				_soundTransform.volume = _volume;
				_soundTransform.pan = _pan;
			}
			
			_soundChannel = sound.play(_startTime, (_loops == -1 ? int.MAX_VALUE : _loops),
				_soundTransform);
			
			return _soundChannel;
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
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return getClassName(this);
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Accessors
		// -----------------------------------------------------------------------------------------
		
		/**
		 * Unique ID of the sound.
		 */
		public function get id():String
		{
			return _id;
		}
		
		
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
		 * If set to -1 the sound will loop indefinitely.
		 * 
		 * @default 0
		 */
		public function get loops():int
		{
			return _loops;
		}
		public function set loops(v:int):void
		{
			_loops = v < -1 ? -1 : v > int.MAX_VALUE ? int.MAX_VALUE : v;
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
			if (v == _paused) return;
			_paused = v;
			
			if (v)
			{
				if (_soundChannel)
				{
					_startTime = _soundChannel.position;
					_soundChannel.stop();
				}
			}
			else
			{
				play();
			}
		}
		
		
		public function get playing():Boolean
		{
			return _soundChannel != null;
		}
	}
}
