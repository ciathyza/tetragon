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
package tetragon.env.preload
{
	import flash.events.Event;

	
	
	/**
	 * A very basic implementation of IPreloadDisplay. The BasicPreloadDisplay only waits
	 * until the application is fully loaded and doesn't show any indication about the
	 * load progress.
	 */
	public class BasicPreloadDisplay implements IPreloadDisplay
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * A reference to the Preloader (which wraps this preload display).
		 * @private
		 */
		protected var _preloader:IPreloader;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new BasicPreloadDisplay instance. This class does not need
		 * to be instatiated directly. The Preloader class does this on it's own.
		 * 
		 * @param preloader A reference to the wrapping Preloader.
		 */
		public function BasicPreloadDisplay(preloader:IPreloader)
		{
			super();
			_preloader = preloader;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function start():void
		{
			_preloader.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			_preloader.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Not used for BasicPreloadDisplay.
		 */
		public function set fadeOutDelay(v:int):void
		{
		}
		
		/**
		 * Not used for BasicPreloadDisplay.
		 */
		public function set color(v:uint):void
		{
		}
		
		/**
		 * Not used for BasicPreloadDisplay.
		 */
		public function set horizontalAlignment(v:String):void
		{
		}
		
		/**
		 * Not used for BasicPreloadDisplay.
		 */
		public function set verticalAlignment(v:String):void
		{
		}
		
		/**
		 * Not used for BasicPreloadDisplay.
		 */
		public function set padding(v:int):void
		{
		}
		
		/**
		 * Not used for BasicPreloadDisplay.
		 */
		public function set testMode(v:Boolean):void
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function onEnterFrame(e:Event):void
		{
			if (_preloader.framesLoaded == _preloader.totalFrames)
			{
				_preloader.finish();
			}
		}
	}
}
