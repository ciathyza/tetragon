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
package tetragon.data.audio
{
	import tetragon.data.DataObject;
	
	
	/**
	 * A SoundObject defines a sound and properties that describe how the sound should
	 * be played.
	 */
	public class SoundObject extends DataObject
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _nameID:String;
		private var _audioResourceID:String;
		private var _volume:Number;
		private var _pan:Number;
		private var _startOffset:Number;
		private var _loops:int;
		private var _loopStartOffset:Number;
		private var _loopEndOffset:Number;
		private var _fadeInDuration:Number;
		private var _fadeOutDuration:Number;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function SoundObject(id:String)
		{
			_id = id;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * An optional ID to the name string for the sound for displaying in-game.
		 */
		public function get nameID():String
		{
			return _nameID;
		}
		public function set nameID(v:String):void
		{
			_nameID = v;
		}
		
		
		/**
		 * ID of the audio resource that is associated with the sound.
		 */
		public function get audioResourceID():String
		{
			return _audioResourceID;
		}
		public function set audioResourceID(v:String):void
		{
			_audioResourceID = v;
		}
		
		
		/**
		 * Volume of the sound, a value from 0.0 to 1.0.
		 */
		public function get volume():Number
		{
			return _volume;
		}
		public function set volume(v:Number):void
		{
			_volume = v;
		}
		
		
		/**
		 * Panning of the sound, a value from -1.0 to 1.0.
		 */
		public function get pan():Number
		{
			return _pan;
		}
		public function set pan(v:Number):void
		{
			_pan = v;
		}
		
		
		/**
		 * Start offset in ms.
		 */
		public function get startOffset():Number
		{
			return _startOffset;
		}
		public function set startOffset(v:Number):void
		{
			_startOffset = v;
		}
		
		
		/**
		 * Nr. of times to loop the sound. 0 is one-shot, -1 is endless.
		 */
		public function get loops():int
		{
			return _loops;
		}
		public function set loops(v:int):void
		{
			_loops = v;
		}
		
		
		/**
		 * Start offset in ms. at which the loop starts.
		 */
		public function get loopStartOffset():Number
		{
			return _loopStartOffset;
		}
		public function set loopStartOffset(v:Number):void
		{
			_loopStartOffset = v;
		}
		
		
		/**
		 * End offset in ms. at which the loop ends.
		 */
		public function get loopEndOffset():Number
		{
			return _loopEndOffset;
		}
		public function set loopEndOffset(v:Number):void
		{
			_loopEndOffset = v;
		}
		
		
		/**
		 * Duration in seconds that the sound takes to reach full volume.
		 */
		public function get fadeInDuration():Number
		{
			return _fadeInDuration;
		}
		public function set fadeInDuration(v:Number):void
		{
			_fadeInDuration = v;
		}
		
		
		/**
		 * Duration in seconds that the sound takes to reach muted volume.
		 */
		public function get fadeOutDuration():Number
		{
			return _fadeOutDuration;
		}
		public function set fadeOutDuration(v:Number):void
		{
			_fadeOutDuration = v;
		}
	}
}
