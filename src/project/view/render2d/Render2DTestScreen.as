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
	import tetragon.view.stage3d.Stage3DEvent;
	import tetragon.view.stage3d.Stage3DProxy;

	import flash.events.Event;

	
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
		
		//private var _stage3DManager:Stage3D;
		
		private var _stage3DProxy:Stage3DProxy;
		
		private var _render2D1:Render2D;
		private var _render2D2:Render2D;
		private var _render2D3:Render2D;
		
		
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
			main.statsMonitor.toggle();
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
		
		
		private function onContext3DCreated(e:Stage3DEvent):void
		{
			var view1:View2D = new BenchmarkView();
			view1.x = 10;
			view1.y = 10;
			view1.frameWidth = (main.stage.stageWidth * 0.5) - 20;
			view1.frameHeight = (main.stage.stageHeight) - 20;
			view1.background = new Quad2D(10, 10, 0x888888);
			view1.touchable = false;
			
//			var view2:View2D = new BenchmarkView();
//			view2.x = view1.x + view1.frameWidth + 10;
//			view2.y = 10;
//			view2.frameWidth = (main.stage.stageWidth * 0.5) - 10;
//			view2.frameHeight = (main.stage.stageHeight * 0.5) - 20;
//			view2.background = new Quad2D(10, 10, 0x888888);
//			view2.touchable = false;
			
//			var view3:View2D = new BenchmarkView();
//			view3.x = view2.x;
//			view3.y = view2.y + view2.frameHeight + 10;
//			view3.frameWidth = (main.stage.stageWidth * 0.5) - 10;
//			view3.frameHeight = (main.stage.stageHeight * 0.5) - 10;
//			view3.background = new Quad2D(10, 10, 0x888888);
//			view3.touchable = false;
			
			_render2D1 = new Render2D(view1, _stage3DProxy);
			//_render2D1.simulateMultitouch = true;
			//_render2D1.enableErrorChecking = true;
			//_render2D1.antiAliasing = 2;
			_render2D1.start();
			
			//_render2D2 = new Render2D(view2, _stage3DProxy);
			//_render2D2.simulateMultitouch = true;
			//_render2D2.enableErrorChecking = true;
			//_render2D2.antiAliasing = 2;
			//_render2D2.start();
			
			//_render2D3 = new Render2D(view3, _stage3DProxy);
			//_render2D3.simulateMultitouch = true;
			//_render2D3.enableErrorChecking = true;
			//_render2D3.antiAliasing = 2;
			//_render2D3.start();
			
			_stage3DProxy.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		
		private function onEnterFrame(event:Event):void
		{
			_render2D1.nextFrame();
			if (_render2D2) _render2D2.nextFrame();
			if (_render2D3) _render2D3.nextFrame();
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
			_stage3DProxy = main.stage3DManager.getFreeStage3DProxy();
			_stage3DProxy.antiAlias = 2;
			_stage3DProxy.color = 0x000000;
			_stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContext3DCreated);
			_stage3DProxy.requestContext3D();
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
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function removeListeners():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function executeBeforeStart():void
		{
			main.gameLoop.start();
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
