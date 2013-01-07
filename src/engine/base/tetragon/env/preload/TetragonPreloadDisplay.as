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
	import lib.display.LoadProgressBar;

	import com.hexagonstar.constants.Alignment;

	import flash.display.Sprite;
	import flash.events.Event;
	
	
	/**
	 * The default preload display implementation for tetragon which displays a simple
	 * progress bar while the application is being preloaded.
	 */
	public class TetragonPreloadDisplay extends Sprite implements IPreloadDisplay
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * A reference to the Preloader (which wraps this preload display).
		 * @private
		 */
		protected var _preloader:Preloader;
		
		/**
		 * How many frames to wait before initiating the preloader. This is a threshold
		 * used to wait for several frames before displaying the preloader bar and text in
		 * case the SWF is already in the cache or locally loaded in which case the
		 * preloader doesn't need to appear. Setting this value to 0 will always display
		 * the preloader.
		 * 
		 * @private
		 */
		protected var _skipDelay:int = 10;
		
		/** @private */
		protected var _bar:LoadProgressBar;
		/** @private */
		protected var _hAlignment:String = Alignment.LEFT;
		/** @private */
		protected var _vAlignment:String = Alignment.TOP;
		/** @private */
		protected var _color:uint = 0xFFFFFF;
		/** @private */
		protected var _fadeOutDelay:int = 40;
		/** @private */
		protected var _padding:int = 20;
		/** @private */
		protected var _factor:Number;
		/** @private */
		protected var _percentage:Number;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new TetragonPreloadDisplay instance. This class does not need
		 * to be instatiated directly. The Preloader class does this on it's own.
		 * 
		 * @param preloader A reference to the wrapping Preloader.
		 */
		public function TetragonPreloadDisplay(preloader:Preloader)
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
		 * @inheritDoc
		 */
		public function set fadeOutDelay(v:int):void
		{
			_fadeOutDelay = v;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set color(v:uint):void
		{
			_color = v;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set horizontalAlignment(v:String):void
		{
			_hAlignment = v;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set verticalAlignment(v:String):void
		{
			_vAlignment = v;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set padding(v:int):void
		{
			_padding = v;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set testMode(v:Boolean):void
		{
			if (v) _skipDelay = 0;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function onEnterFrame(e:Event):void
		{
			if (_skipDelay > 0)
			{
				if (_preloader.framesLoaded == _preloader.totalFrames)
				{
					_preloader.finish();
				}
				_skipDelay -= 1;
			}
			else if (_skipDelay == 0)
			{
				draw();
				_skipDelay = -1;
			}
			else
			{
				if (_preloader.framesLoaded == _preloader.totalFrames)
				{
					if (_fadeOutDelay > 0)
					{
						_percentage = 100;
						updateDisplay();
						_fadeOutDelay--;
					}
					else
					{
						if (alpha > 0)
						{
							alpha -= 0.05;
						}
						else
						{
							alpha = 0.0;
							_preloader.finish();
						}
					}
				}
				else
				{
					_percentage = (_preloader.loaderInfo.bytesLoaded
						/ _preloader.loaderInfo.bytesTotal * 100);
					updateDisplay();
				}
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Updates the loader bar and info text.
		 * @private
		 */
		protected function updateDisplay():void
		{
			_bar.bar.width = _percentage * _factor;
		}
		
		
		/**
		 * Draws the visual preloader assets on the stage.
		 * @private
		 */
		protected function draw():void
		{
			_bar = new LoadProgressBar();
			_factor = _bar.bar.width / 100;
			_bar.bar.width = 1;
			addChild(_bar);
			
			if (_hAlignment == Alignment.LEFT)
			{
				x = _padding;
			}
			else if (_hAlignment == Alignment.RIGHT)
			{
				x = _preloader.stage.stageWidth - width - _padding;
			}
			else
			{
				x = Math.floor((_preloader.stage.stageWidth / 2) - (width / 2));
			}
			
			if (_vAlignment == Alignment.TOP)
			{
				y = _padding;
			}
			else if (_vAlignment == Alignment.BOTTOM)
			{
				y = _preloader.stage.stageHeight - height - _padding;
			}
			else
			{
				y = Math.floor((_preloader.stage.stageHeight / 2) - (height / 2));
			}
		}
	}
}
