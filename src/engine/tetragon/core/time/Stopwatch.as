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
package tetragon.core.time
{
	import flash.utils.getTimer;

	
	/**
	 * Simple stopwatch class that records elapsed time in milliseconds.
	 * 
	 * @example
	 * <pre>
	 *	package
	 *	{
	 *		import flash.display.Sprite;
	 *		import com.hexagonstar.time.Stopwatch;
	 *		
	 *		public class Example extends Sprite
	 *		{
	 *			public function Example()
	 *			{
	 *				var stopwatch:Stopwatch = new Stopwatch();
	 *				stopwatch.start();
	 *				
	 *				var t:int = 1000000;
	 *				while (t--)
	 *				{
	 *					doSomething();
	 *				}
	 *				
	 *				trace(stopwatch.time);
	 *			}
	 *			
	 *			public function doSomething():void
	 *			{
	 *			}
	 *		}
	 *	}
	 * </pre>
	 */
	public final class Stopwatch
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _elapsedTime:int;
		private var _startTime:int;
		private var _isStopped:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Starts the Stopwatch and resets any previous elapsed time.
		 */
		public function start():void
		{
			_elapsedTime = 0;
			_startTime = timer;
			_isStopped = false;
		}
		
		
		/**
		 * Stops the Stopwatch.
		 */
		public function stop():void 
		{
			_elapsedTime = time;
			_startTime = 0;
			_isStopped = true;
		}
		
		
		/**
		 * Resumes the Stopwatch after it has been stopped.
		 */
		public function resume():void
		{
			if (_isStopped) _startTime = timer;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the time elapsed since start() or until stop() was called.
		 * Can be called before or after calling stop().
		 * 
		 * @return the elapsed time in milliseconds.
		 */
		public function get time():int
		{
			return (_startTime != 0) ? timer - _startTime + _elapsedTime : _elapsedTime;
		}
		
		
		private function get timer():int
		{
			return getTimer();
		}
	}
}
