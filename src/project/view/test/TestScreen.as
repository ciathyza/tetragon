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
package view.test
{
	import lib.display.TetragonLogo;

	import tetragon.debug.Log;
	import tetragon.util.color.colorHexToColorTransform;
	import tetragon.util.display.centerChild;
	import tetragon.view.Screen;
	import tetragon.view.loadprogress.LoadProgressDisplay;
	import tetragon.view.render2d.core.Render2D;

	import flash.filters.DropShadowFilter;
	import flash.media.Sound;
	
	
	/**
	 * Screen used for Tetragon testing and demonstration.
	 * 
	 * @author Hexagon
	 */
	public class TestScreen extends Screen
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const ID:String = "testScreen";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _render2D:Render2D;
		private var _view:TestView;
		private var _logo:TetragonLogo;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function start():void
		{
			super.start();
			
			if (main.appInfo.isIOSBuild && main.console)
			{
				main.console.toggle();
			}
			
			main.audioManager.startMusic("demoMusic");
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function update():void
		{
			super.update();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function reset():void
		{
			super.reset();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function stop():void
		{
			super.stop();
			_render2D.stop();
			main.gameLoop.stop();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines whether the screen will unload all it's loaded resources once it is
		 * closed. You can override this getter and return false for screens where you don't
		 * want resources to be unloaded, .e.g. for a dedicated resource preload screen.
		 * 
		 * @default true
		 */
		override protected function get unload():Boolean
		{
			return true;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get loadProgressDisplay():LoadProgressDisplay
		{
			return super.loadProgressDisplay;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Invoked whenever the display stage is resized. By default this method calls the
		 * layoutChildren() method of the screen class. You can override it to replace
		 * this handler with custom code or to disabled it.
		 */
		override protected function onStageResize():void
		{
			super.onStageResize();
		}
		
		
		/**
		 * @private
		 */
		private function onTick():void
		{
		}
		
		
		/**
		 * @private
		 */
		private function onRender(ticks:uint, ms:uint, fps:uint):void
		{
			_render2D.render();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initializes the screen. Called right after instantiation. If you override this
		 * method you must call <code>super.setup()</code> in your overriden method.
		 */
		override protected function setup():void
		{
			super.setup();
			_render2D = screenManager.render2D;
		}
		
		
		/**
		 * Registers resources for loading that are required for the screen.
		 * 
		 * <p>This is an abstract method. Override this method in your screen sub-class and
		 * register as many resources as you need for the screen. The resources are being
		 * preloaded before the screen is opened by the screen manager.</p>
		 * 
		 * @see tetragon.view.Screen#registerResource()
		 * 
		 * @example
		 * <pre>
		 *     registerResource("resource1");
		 *     registerResource("resource2");
		 * </pre>
		 */
		override protected function registerResources():void
		{
			registerResource("settings");
			registerResource("demoMusic");
			registerResource("bgFillImage");
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			_view = new TestView();
			_render2D.rootView = _view;
			
			var ds:DropShadowFilter = new DropShadowFilter(1.0, 45, 0x000000, 0.4, 8.0, 8.0, 2);
			_logo = new TetragonLogo();
			_logo.filters = [ds];
			_logo.transform.colorTransform = colorHexToColorTransform(0xFF0000);
			
			var music:* = resourceIndex.getInstanceFromSWFResource("demoMusic", "assets.audio.DemoMusic");
			if (music && music is Sound)
			{
				main.audioManager.createMusic("demoMusic", [music]);
			}
			else
			{
				Log.notice("Music could not be created: " + music, this);
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerChildren():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void
		{
			addChild(_logo);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addListeners():void
		{
			main.gameLoop.tickSignal.add(onTick);
			main.gameLoop.renderSignal.add(onRender);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function removeListeners():void
		{
			main.gameLoop.tickSignal.remove(onTick);
			main.gameLoop.renderSignal.remove(onRender);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function updateDisplayText():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function layoutChildren():void
		{
			_logo.scaleX = _logo.scaleY = 1.5;
			centerChild(_logo);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function enableChildren():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function disableChildren():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function pauseChildren():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function unpauseChildren():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function executeBeforeStart():void
		{
			main.statsMonitor.toggle();
			_render2D.start();
		}
	}
}
