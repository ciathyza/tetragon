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
	import tetragon.util.math.ceilPositive;

	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.ByteArray;
	
	
	/**
	 * Turns a sound into a pitchable sound.
	 */
	public class PitchableSound extends BasicSound
	{
		// -----------------------------------------------------------------------------------------
		// Constants
		// -----------------------------------------------------------------------------------------
		
		/** @private */
		private static const BLOCK_SIZE:int = 3072;
		
		
		// -----------------------------------------------------------------------------------------
		// Properties
		// -----------------------------------------------------------------------------------------
		
		/**
		 * How many bytes to skip at the start of the sound.
		 * @default 0
		 */
		public var skippedStartBytes:uint;
		
		/**
		 * How many bytes to skip at the end of the sound.
		 * @default 0
		 */
		public var skippedEndBytes:uint;
		
		/** @private */
		protected var _buffer:Sound;
		/** @private */
		protected var _target:ByteArray;
		/** @private */
		protected var _position:Number;
		/** @private */
		protected var _rate:Number;
		
		
		// -----------------------------------------------------------------------------------------
		// Constructor
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @param id
		 * @param sound
		 * @param volume
		 * @param pan
		 * @param loops
		 * @param rate
		 * @param skippedStartBytes
		 * @param skippedEndBytes
		 */
		public function PitchableSound(id:String, sound:Sound, volume:Number = 1.0, pan:Number = 0.0,
			loops:int = 0, rate:Number = 1.0, skippedStartBytes:uint = 0, skippedEndBytes:uint = 0)
		{
			super(id, sound, volume, pan, loops);
			
			this.skippedStartBytes = skippedStartBytes;
			this.skippedEndBytes = skippedEndBytes;
			this.rate = rate;
			
			_position = 0.0;
			
			_target = new ByteArray();
			_buffer = new Sound();
			_buffer.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Public Methods
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function play(startTime:Number = NaN, loops:Number = NaN,
			st:SoundTransform = null):SoundChannel
		{
			if (!sound || _soundChannel) return _soundChannel;
			
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
			
			_soundChannel = _buffer.play(_startTime, (_loops == -1 ? int.MAX_VALUE : _loops),
				_soundTransform);
			return _soundChannel;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			_buffer.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Accessors
		// -----------------------------------------------------------------------------------------
		
		/**
		 * The pitch rate of the sound.
		 * 
		 * @default 1.0
		 */
		public function get rate():Number
		{
			return _rate;
		}
		public function set rate(v:Number):void
		{
			if (v < 0.0) v = 0.0;
			_rate = v;
		}


		// -----------------------------------------------------------------------------------------
		// Event Handlers
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function onSampleData(e:SampleDataEvent):void
		{
			if (!sound) return;
			
			_target.position = 0;
			
			var data:ByteArray = e.data;
			var scaledBlockSize:Number = BLOCK_SIZE * _rate;
			var positionInt:int = _position;
			var alpha:Number = _position - positionInt;
			var positionTargetNum:Number = alpha;
			var positionTargetInt:int = -1;
			var need:int = ceilPositive(scaledBlockSize) + 2;
			var read:int = sound.extract(_target, need, positionInt);
			var n:int = read == need ? BLOCK_SIZE : read / _rate;
			
			for (var i:int = 0; i < n; ++i)
			{
				if (int(positionTargetNum) != positionTargetInt)
				{
					positionTargetInt = positionTargetNum;
					_target.position = positionTargetInt << 3;
					var l0:Number = _target.readFloat();
					var r0:Number = _target.readFloat();
					var l1:Number = _target.readFloat();
					var r1:Number = _target.readFloat();
				}
				
				data.writeFloat(l0 + alpha * (l1 - l0));
				data.writeFloat(r0 + alpha * (r1 - r0));
				positionTargetNum += _rate;
				
				if (_position > sound.bytesTotal - skippedEndBytes)
				{
					_position = skippedStartBytes;
				}
				alpha += _rate;
				while (alpha >= 1.0) --alpha;
			}
			
			if (i < BLOCK_SIZE)
			{
				while (i < BLOCK_SIZE)
				{
					data.writeFloat(0.0);
					data.writeFloat(0.0);
					++i;
				}
			}
			_position += scaledBlockSize;
		}
	}
}
