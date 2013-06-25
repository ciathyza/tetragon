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
 */package tetragon.util.time{	import tetragon.core.types.IDisposable;	import flash.events.TimerEvent;		/**	 * To be used instead of flash.utils.setInterval and flash.utils.setTimeout functions.	 * 	 * Advantages over setInterval/setTimeout are:	 * <ul>	 *     <li>Ability to stop and start intervals without redefining.</li>	 *     <li>Change the time delay, callback and arguments without redefining.</li>	 *     <li>Included repeatCount for intervals that only need to fire finitely.</li>	 *     <li>setInterval and setTimeout return an object instead of interval id for	 *     better OOP structure.</li>	 *     <li>Built in events/event dispatcher.</li>	 * </ul>	 * 	 * @example	 * <pre>	 * package	 * {	 * 	import flash.display.MovieClip;	 * 	import com.hexagonstar.time.Interval;	 * 		 * 	public class Example extends MovieClip	 * 	{	 * 		private var _interval:Interval;	 * 			 * 		public function Example()	 *		{	 *			_interval = Interval.setInterval(onInterval, 1000, "Hexagon");	 * 			_interval.repeatCount = 3;	 *			_interval.start();	 * 		}	 *			 *		private function onInterval(name:String):void	 *		{	 *			trace(name);	 *		}	 *	 }	 * }	 * </pre>	 */	public final class Interval extends PreciseTimer implements IDisposable	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------				protected var _callBack:Function;		protected var _args:Array;		protected var _autoDispose:Boolean;
				
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------				/**		 * Creates a new Interval instance.
		 * 
		 * @param delay
		 * @param repeatCount
		 * @param callBack
		 * @param args		 */		public function Interval(delay:Number, repeatCount:int, callBack:Function, args:Array)		{			super(delay, repeatCount);						_callBack = callBack;			_args = args;
			_autoDispose = true;			addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);		}		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------				/**		 * Runs a function at a specified periodic interval.		 *		 * @param delay The time in milliseconds between calls.
		 * @param callBack The function to execute after specified delay.		 * @param repeatCount How many times the interval should repeat. 0 means endless.		 * @param autoStart If true starts the timeout automatically.
		 * @param args The arguments to be passed to the callback function when executed.		 * @return An Interval reference.		 */		public static function setInterval(delay:Number, callBack:Function, repeatCount:int = 0,
			autoStart:Boolean = false, ...args):Interval		{
			var i:Interval = new Interval(delay, repeatCount, callBack, args);			if (autoStart) i.start();
			return i;		}						/**		 * Runs a function at a specified periodic interval. Acts identically		 * like setInterval() except setTimeOut() defaults repeatCount to 1.		 * 		 * @param delay The time in milliseconds between calls.
		 * @param callBack The function to execute after specified delay.		 * @param autoStart If true starts the timeout automatically.		 * @param args The arguments to be passed to the callback function when executed.		 * @return An Interval reference.		 */		public static function setTimeOut(delay:Number, callBack:Function,
			autoStart:Boolean = false, ...args):Interval		{
			var i:Interval = new Interval(delay, 1, callBack, args);
			if (autoStart) i.start();			return i;		}						/**
		 * @inheritDoc		 */		public function dispose():void		{			reset();			removeEventListener(TimerEvent.TIMER, onTimer);		}						/**		 * Returns a String Representation of Interval.
		 * 		 * @return A String Representation of Interval.		 */		override public function toString():String		{			return "[Interval]";		}				
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------				/**		 * The function to execute after the specified delay.		 */		public function get callBack():Function		{			return _callBack;		}		public function set callBack(v:Function):void		{			_callBack = v;		}				/**		 * The arguments to be passed to the call back function when executed.		 */		public function get arguments():Array		{			return _args;		}		public function set arguments(v:Array):void		{			_args = v;		}				
		/**
		 * Determines whether the interval is disposed automatically after it's done.
		 * 
		 * @default true		 */
		public function get autoDispose():Boolean
		{
			return _autoDispose;
		}
		public function set autoDispose(v:Boolean):void
		{
			_autoDispose = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------				protected function onTimer(e:TimerEvent):void		{			_callBack.apply(null, _args);			if (_autoDispose && _currentCount == _repeatCount)
			{
				dispose();			}		}	}}