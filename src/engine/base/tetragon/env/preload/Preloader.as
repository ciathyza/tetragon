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
	import tetragon.Main;
	import tetragon.data.Params;

	import com.hexagonstar.constants.Alignment;

	import mx.core.BitmapAsset;
	import mx.core.ByteArrayAsset;
	import mx.core.FontAsset;
	import mx.core.MovieClipAsset;
	import mx.core.MovieClipLoaderAsset;
	import mx.core.SoundAsset;
	import mx.core.SpriteAsset;

	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	
	
	/**
	 * The Preloader preloads the web-based application SWF which it is part of. This
	 * class becomes the root of the SWF by delegation in the entry class. After
	 * preloading has finished, the Entry class is instantiated inside this class and is
	 * notified that the preload process has been finished (by calling
	 * onApplicationPreloaded).
	 * 
	 * <p>This class acts as a wrapper for various different preload display classes. The
	 * default used implementation is TetragonPreloadDisplay. You can write your own
	 * preload displays by implementing the IPreloadDisplay interface and then configure
	 * your class for use with this preloader inside the <code>configure()</code>
	 * method.</p>
	 */
	public class Preloader extends MovieClip
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The qualified class name of the entry class.
		 * 
		 * <p>IMPORTANT: If the base package and/or entry class name is changed this
		 * name needs to be adapted to the new name!</p>
		 * 
		 * @private
		 */
		private var _entryClass:String = "Entry";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _preloadDisplay:IPreloadDisplay;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new AppPreloader instance. super() must be called with
		 * the app's entry class (and package) name as the argument. By
		 * default this class name is 'App'.
		 */
		public function Preloader()
		{
			super();
			stop();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			/* Fetch Flashvars */
			Main.params = new Params();
			Main.params.parse(LoaderInfo(root.loaderInfo).parameters);
			
			configure();
			start();
		}
		
		
		/**
		 * This method is called by the underlying preload display class after
		 * it finished preloading the application.
		 */
		public function finish():void
		{
			if (_preloadDisplay is DisplayObject)
			{
				removeChild(_preloadDisplay as DisplayObject);
			}
			_preloadDisplay.dispose();
			_preloadDisplay = null;
			
			/* SpriteAsset is always embedded! */
			var link1:SpriteAsset;
			
			/* Forces inclusion of Flex asset classes if we use embedded resources. */
			var link2:ByteArrayAsset;
			var link3:BitmapAsset;
			var link4:MovieClipAsset;
			var link5:MovieClipLoaderAsset;
			var link6:FontAsset;
			var link7:SoundAsset;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		protected function get entryClass():String
		{
			return _entryClass;
		}
		protected function set entryClass(v:String):void
		{
			_entryClass = v;
		}
		
		
		protected function get preloadDisplay():IPreloadDisplay
		{
			return _preloadDisplay;
		}
		protected function set preloadDisplay(v:IPreloadDisplay):void
		{
			_preloadDisplay = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onEnterFrame(e:Event):void
		{
			if (currentFrame == 1)
			{
				gotoAndStop(2);
			}
			else if (currentFrame == 2)
			{
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				initiateEntry();
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Can be used to configure the preloader with a different preload display
		 * and different preload display parameters.
		 * 
		 * Override this method to create a preloader with a custom preload display.
		 */
		protected function configure():void
		{
			preloadDisplay = new TetragonPreloadDisplay(this);
			preloadDisplay.testMode = true;
			preloadDisplay.padding = 20;
			preloadDisplay.horizontalAlignment = Alignment.CENTER;
			preloadDisplay.verticalAlignment = Alignment.VERTICAL_CENTER;
			preloadDisplay.color = 0xFFFFFF;
			preloadDisplay.fadeOutDelay = 40;
		}
		
		
		/**
		 * Starts the preloader.
		 */
		private function start():void
		{
			if (Main.params.getParam(Params.SKIP_PRELOADER))
			{
				preloadDisplay = new BasicPreloadDisplay(this);
			}
			if (!preloadDisplay)
			{
				preloadDisplay = new TetragonPreloadDisplay(this);
			}
			if (preloadDisplay is DisplayObject)
			{
				addChild(DisplayObject(preloadDisplay));
			}
			
			preloadDisplay.start();
		}
		
		
		/**
		 * Instanciates the entry class and enters it.
		 */
		private function initiateEntry():void
		{
			var clazz:Class = Class(getDefinitionByName(_entryClass));
			if (clazz)
			{
				var entry:IPreloadable = new clazz();
				entry.onApplicationPreloaded(this);
			}
			else
			{
				throw new Error("Entry class named \"" + _entryClass
					+ "\" could not be instantiated!");
			}
		}
	}
}
