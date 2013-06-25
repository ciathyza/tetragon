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
package tetragon.view.loadprogress
{
	import lib.display.LoadProgressBar;

	import tetragon.util.display.StageReference;

	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	
	
	/**
	 * A very basic implementation of a load progress bar that displays a simple
	 * progress bar during loading.
	 * 
	 * @see tetragon.view.loadprogress.LoadProgressDisplay
	 * @see tetragon.view.loadprogress.DebugLoadProgressDisplay
	 */
	public class BasicLoadProgressDisplay extends LoadProgressDisplay
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _loadProgressBar:LoadProgressBar;
		/** @private */
		protected var _factor:Number;
		/** @private */
		protected var _percentage:Number;
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @return false
		 */
		override public function get waitForUserInput():Boolean
		{
			return false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		override protected function onReset():void
		{
			_factor = _loadProgressBar.bar.width / 100;
			_percentage = 0;
			_loadProgressBar.bar.width = 1;
		}
		
		
		override protected function onUpdate():void
		{
			if (allComplete) return;
			if (progress)
			{
				_percentage = progress.ratioPercentage;
				_loadProgressBar.bar.width = _percentage * _factor;
			}
			else if (allFailed)
			{
				_percentage = 100;
			}
			
			if (_percentage == 100) complete();
		}
		
		
		override protected function onComplete():void
		{
			if (waitForUserInput)
			{
				StageReference.stage.addEventListener(MouseEvent.CLICK, onMouseClick);
			}
		}
		
		
		private function onMouseClick(e:MouseEvent):void
		{
			e.preventDefault();
			StageReference.stage.removeEventListener(MouseEvent.CLICK, onMouseClick);
			userInputSignal.dispatch();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		override protected function setup():void
		{
			var filter:GlowFilter = new GlowFilter(0x000000, 1.0, 2.0, 2.0, 100, 4);
			_loadProgressBar = new LoadProgressBar();
			_loadProgressBar.filters = [filter];
			addChild(_loadProgressBar);
			
			x = screenManager.hCenter - (width * 0.5);
			y = screenManager.vCenter - (height * 0.5);
		}
	}
}
