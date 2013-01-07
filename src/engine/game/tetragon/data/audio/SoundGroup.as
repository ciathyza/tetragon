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
	 * A SoundGroup defines a collection of SoundObjects that are played in a linear
	 * or random order.
	 */
	public class SoundGroup extends DataObject
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _loops:int;
		private var _playMode:String;
		private var _pauseMinDuration:Number;
		private var _pauseMaxDuration:Number;
		private var _allowRandomRepeats:Boolean;
		private var _soundIDs:Vector.<String>;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function SoundGroup(id:String)
		{
			_id = id;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The number of times the whole sound group should loop. 0 is one-shot, -1 is endless.
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
		 * Playback mode of the sound group. One of the following: "forward", "backward",
		 * "pingpong", "random" or "triggered". Sounds in the group are played according to
		 * the order that they are placed in the group and the specified play mode.
		 * 
		 * @see SoundPlayMode
		 */
		public function get playMode():String
		{
			return _playMode;
		}
		public function set playMode(v:String):void
		{
			_playMode = v;
		}
		
		
		/**
		 * This property together with pauseMaxDuration can be used to determine a pause
		 * between sounds played in the group. If both min and max are 0, no pause occurs,
		 * if both values are different, a random value will be calculated between min and
		 * max duration.
		 */
		public function get pauseMinDuration():Number
		{
			return _pauseMinDuration;
		}
		public function set pauseMinDuration(v:Number):void
		{
			_pauseMinDuration = v;
		}
		
		
		/**
		 * This property together with pauseMinDuration can be used to determine a pause
		 * between sounds played in the group. If both min and max are 0, no pause occurs,
		 * if both values are different, a random value will be calculated between min and
		 * max duration.
		 */
		public function get pauseMaxDuration():Number
		{
			return _pauseMaxDuration;
		}
		public function set pauseMaxDuration(v:Number):void
		{
			_pauseMaxDuration = v;
		}
		
		
		/**
		 * If playmode is "random" this value can be set to false to prevent a random sound
		 * from being played twice successively.
		 */
		public function get allowRandomRepeats():Boolean
		{
			return _allowRandomRepeats;
		}
		public function set allowRandomRepeats(v:Boolean):void
		{
			_allowRandomRepeats = v;
		}
		
		
		/**
		 * A list of all SoundObject IDs that are part of the sound group.
		 */
		public function get soundIDs():Vector.<String>
		{
			return _soundIDs;
		}
		public function set soundIDs(v:Vector.<String>):void
		{
			_soundIDs = v;
		}
	}
}
