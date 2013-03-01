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
package view.render2d
{
	import tetragon.view.Screen;
	import tetragon.view.render2d.core.Render2D;
	import tetragon.view.render2d.display.Quad2D;
	import tetragon.view.render2d.display.View2D;
	import tetragon.view.render2d.events.Event2D;

	
	/**
	 * @author hexagon
	 */
	public class Render2DTestScreen extends Screen
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const ID:String = "render2DTestScreen";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _render2D:Render2D;
		private var _view2D:View2D;
		
		
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
		 * @inheritDoc
		 */
		override protected function get unload():Boolean
		{
			return true;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function onStageResize():void
		{
			super.onStageResize();
		}
		
		
		/**
		 * @private
		 */
		private function onContext3DCreated(e:Event2D):void
		{
			/* Texture can only be processed after we have a Context3D! */
			resourceManager.process("textureAtlas");
			main.gameLoop.start();
		}
		
		
		/**
		 * @private
		 */
		private function onRoot2DCreated(e:Event2D):void
		{
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
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function setup():void
		{
			super.setup();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerResources():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			_view2D = new View2D();
			_view2D.background = new Quad2D(10, 10, 0x000033);
			_render2D = new Render2D(_view2D);
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
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addListeners():void
		{
			_render2D.addEventListener(Event2D.CONTEXT3D_CREATE, onContext3DCreated);
			_render2D.addEventListener(Event2D.ROOT_CREATED, onRoot2DCreated);
			main.gameLoop.tickSignal.add(onTick);
			main.gameLoop.renderSignal.add(onRender);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function removeListeners():void
		{
			_render2D.removeEventListener(Event2D.CONTEXT3D_CREATE, onContext3DCreated);
			_render2D.removeEventListener(Event2D.ROOT_CREATED, onRoot2DCreated);
			main.gameLoop.tickSignal.remove(onTick);
			main.gameLoop.renderSignal.remove(onRender);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function executeBeforeStart():void
		{
			main.statsMonitor.toggle();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function updateDisplayText():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function layoutChildren():void
		{
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
	}
}
