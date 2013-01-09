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
	import tetragon.Main;
	import tetragon.file.resource.ResourceIndex;

	import com.hexagonstar.audio.PitchableSound;

	import flash.media.Sound;
	
	
	/**
	 * AudioPlayer class
	 */
	public class AudioPlayer
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _resourceIndex:ResourceIndex;
		
		//private var _globalVolume:Number = 1.0;
		//private var _musicVolume:Number = 1.0;
		//private var _soundVolume:Number = 1.0;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function AudioPlayer()
		{
			_resourceIndex = Main.instance.resourceManager.resourceIndex;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Maps a sound so that can be played later.
		 */
		public function mapSound():void
		{
			
		}
		
		/**
		 * Plays a sound.
		 * 
		 * @param sound Can be a Sound object or a sound resource ID string.
		 * @param loops
		 * @param volume
		 */
		public function play(sound:*, loops:int = 0, volume:Number = NaN):void
		{
			var s:*;
			
			if (sound is String)
			{
				var r:* = _resourceIndex.getResource(sound);
				if (r is Sound) s = r;
			}
			else if (sound is Sound)
			{
				s = sound;
			}
			else if (sound is PitchableSound)
			
			if (!s) return;
			
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
	}
}
