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
package tetragon.view.render2d.core
{
	import tetragon.view.render2d.display.BlendMode2D;
	import tetragon.view.render2d.display.Quad2D;
	import tetragon.view.render2d.display.Sprite2D;
	import tetragon.view.render2d.events.EnterFrameEvent2D;
	import tetragon.view.render2d.events.Event2D;
	import tetragon.view.render2d.text.BitmapFont2D;
	import tetragon.view.render2d.text.TextField2D;

	import com.hexagonstar.constants.HAlign;
	import com.hexagonstar.constants.VAlign;

	import flash.system.System;

	/** A small, lightweight box that displays the current framerate, memory consumption and
	 *  the number of draw calls per frame.
	 *  
	 *  TODO Depricated!
	 *  
	 *  */
	internal class StatsDisplay2D extends Sprite2D
	{
		private var mBackground:Quad2D;
		private var mTextField:TextField2D;
		private var mFrameCount:int = 0;
		private var mDrawCount:int = 0;
		private var mTotalTime:Number = 0;


		/** Creates a new Statistics Box. */
		public function StatsDisplay2D()
		{
			mBackground = new Quad2D(50, 25, 0x0);
			mTextField = new TextField2D(48, 25, "", BitmapFont2D.MINI, BitmapFont2D.NATIVE_SIZE, 0xffffff);
			mTextField.x = 2;
			mTextField.hAlign = HAlign.LEFT;
			mTextField.vAlign = VAlign.TOP;

			addChild(mBackground);
			addChild(mTextField);

			addEventListener(Event2D.ENTER_FRAME, onEnterFrame);
			updateText(0, getMemory(), 0);
			blendMode = BlendMode2D.NONE;
		}


		private function updateText(fps:Number, memory:Number, drawCount:int):void
		{
			mTextField.text = "FPS: " + fps.toFixed(fps < 100 ? 1 : 0) + "\nMEM: " + memory.toFixed(memory < 100 ? 1 : 0) + "\nDRW: " + drawCount;
		}


		private function getMemory():Number
		{
			return System.totalMemory * 0.000000954;
			// 1 / (1024*1024) to convert to MB
		}


		private function onEnterFrame(event:EnterFrameEvent2D):void
		{
			mTotalTime += event.passedTime;
			mFrameCount++;

			if (mTotalTime > 1.0)
			{
				updateText(mFrameCount / mTotalTime, getMemory(), mDrawCount - 2);
				// DRW: ignore self
				mFrameCount = mTotalTime = 0;
			}
		}


		/** The number of Stage3D draw calls per second. */
		public function get drawCount():int
		{
			return mDrawCount;
		}


		public function set drawCount(value:int):void
		{
			mDrawCount = value;
		}
	}
}