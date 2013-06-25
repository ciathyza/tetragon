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
package tetragon.util.time
{
	/**
	 * A simple organizational class to easily create a sequence of intervals
	 * and/or timeouts.
	 */
	public class IntervalSequence
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _intervals:Vector.<Interval>;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function IntervalSequence()
		{
			_intervals = new Vector.<Interval>();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Addsa new interval that runs a function at a specified periodic interval.
		 *
		 * @param delay The time in milliseconds between calls.
		 * @param callBack The function to execute after specified delay.
		 * @param repeatCount How many times the interval should repeat. 0 means endless.
		 * @param args The arguments to be passed to the callback function when executed.
		 * @return An Interval reference.
		 */
		public function addInterval(delay:Number, callBack:Function, repeatCount:int = 0,
			...args):Interval
		{
			var i:Interval = new Interval(delay, repeatCount, callBack, args);
			_intervals.push(i);
			return i;
		}
		
		
		/**
		 * Adds a new timeout to the sequence.
		 * 
		 * @param delay The time in milliseconds between calls.
		 * @param callBack The function to execute after specified delay.
		 * @param args The arguments to be passed to the callback function when executed.
		 * @return An Interval reference.
		 */
		public function addTimeOut(delay:Number, callBack:Function, ...args):Interval
		{
			var i:Interval = new Interval(delay, 1, callBack, args);
			_intervals.push(i);
			return i;
		}
		
		
		public function start():void
		{
			for (var i:uint = 0; i < _intervals.length; i++)
			{
				_intervals[i].start();
			}
		}
		
		
		public function stop():void
		{
			for (var i:uint = 0; i < _intervals.length; i++)
			{
				_intervals[i].stop();
			}
		}
		
		
		public function reset():void
		{
			for (var i:uint = 0; i < _intervals.length; i++)
			{
				_intervals[i].reset();
			}
		}
		
		
		public function dispose():void
		{
			for (var i:uint = 0; i < _intervals.length; i++)
			{
				_intervals[i].dispose();
			}
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "[IntervalSequence]";
		}
	}
}
