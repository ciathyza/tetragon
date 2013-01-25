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
	import tetragon.Main;
	import tetragon.debug.Log;
	import tetragon.view.render2d.display.Image2D;
	import tetragon.view.render2d.display.View2D;
	import tetragon.view.render2d.events.Event2D;
	import tetragon.view.render2d.textures.Texture2D;

	import flash.system.System;
	
	
	/**
	 * BenchmarkView class
	 *
	 * @author hexagon
	 */
	public class BenchmarkView extends View2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _texture:Texture2D;
        private var _frameCount:int;
        private var _failCount:int;
        private var _waitFrames:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function BenchmarkView()
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		override protected function onAddedToStage(e:Event2D):void
		{
			super.onAddedToStage(e);
			
			_texture = Texture2D.fromBitmapData(Main.instance.resourceManager.resourceIndex.getImage("123"));
			
			_failCount = 0;
			_waitFrames = 2;
			_frameCount = 0;
			
			_gameLoop.renderSignal.add(onRender);
		}
		
		
		override protected function onRender(ticks:uint, ms:uint, fps:uint):void
		{
			_frameCount++;
			
			if (_frameCount % _waitFrames == 0)
			{
				var targetFPS:int = _gameLoop.frameRate;
				if (fps >= targetFPS)
				{
					_failCount = 0;
					addTestObjects();
				}
				else
				{
					_failCount++;
					
					// slow down creation process to be more exact
					if (_failCount > 20) _waitFrames = 5;
					if (_failCount > 30) _waitFrames = 10;
					// target fps not reached for a while
					if (_failCount == 40) benchmarkComplete();
				}
				
				_frameCount = 0;
			}
			
			var numObjects:int = numChildren;
			for (var i:int = 0; i < numObjects; ++i)
			{
				getChildAt(i).rotation += Math.PI / 4 * (ms / 60);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function addTestObjects():void
		{
			var padding:int = 15;
			var numObjects:int = _failCount > 20 ? 2 : 10;
			
			for (var i:int = 0; i < numObjects; ++i)
			{
				var img:Image2D = new Image2D(_texture);
				//var img:Quad2D = new Quad2D(40, 40, Math.random() * 0xFFFFFF);
				img.x = padding + Math.random() * (_frameWidth - 2 * padding);
				img.y = padding + Math.random() * (_frameHeight - 2 * padding);
				addChild(img);
			}
		}


		private function benchmarkComplete():void
		{
			_gameLoop.renderSignal.remove(onRender);

			Log.trace("Benchmark complete!");
			Log.trace("FPS: " + _gameLoop.renderFPS);
			Log.trace("Number of objects: " + numChildren);
			
			System.pauseForGCIfCollectionImminent();
		}
	}
}
