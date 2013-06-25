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
 */package tetragon.util.time{	import tetragon.core.exception.IllegalArgumentException;	import tetragon.util.display.StageReference;	import flash.events.Event;	import flash.events.EventDispatcher;	import flash.events.TimerEvent;		/**	 * A more precise timer class than the default ActionScript Timer class.	 * You must set StageReference.stage before using this class!	 */	public class PreciseTimer extends EventDispatcher	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------				protected var _delay:Number;		protected var _repeatCount:int;		protected var _currentCount:int;		protected var _offset:int;		protected var _currentTime:Date;		protected var _isRunning:Boolean = false;				
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------				/**		 * Constructs a new PreciseTimer object with the specified delay and repeatCount states.		 * The timer does not start automatically; you must call the start() method to start it.		 * 		 * @param delay The delay between timer events, in milliseconds.		 * @param repeatCount Specifies the number of repetitions. If zero, the timer repeats		 *         infinitely. If nonzero, the timer runs the specified number of times and then		 *         stops.		 */		public function PreciseTimer(delay:Number = 1000, repeatCount:int = 0)		{			this.delay = delay;			this.repeatCount = repeatCount;			reset();		}		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------				/**		 * Starts the timer, if it is not already running.		 */		public function start():void		{			if (_isRunning) return;			_isRunning = true;			_currentTime = new Date();			StageReference.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);		}						/**		 * Stops the timer. When start() is called after stop(), the timer instance runs		 * for the remaining number of repetitions, as set by the repeatCount property.		 */		public function stop():void		{			if (!_isRunning) return;			_isRunning = false;			StageReference.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);		}						/**		 * Stops the timer, if it is running, and sets the currentCount property back		 * to 0, like the reset button of a stopwatch. Then, when start() is called,		 * the timer instance runs for the specified number of repetitions, as set by		 * the repeatCount value.		 */		public function reset():void		{			stop();			_currentCount = _offset = 0;		}						/**		 * Returns a String Representation of PreciseTimer.
		 * 		 * @return A String Representation of PreciseTimer.		 */		override public function toString():String		{			return "[PreciseTimer, currentCount=" + _currentCount + "]";		}				
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------				/**		 * The delay, in milliseconds, between timer events. If you set the delay		 * interval while the timer is running, the timer will restart at the same		 * repeatCount iteration.		 * 		 * @throws com.hexagonstar.env.exception.IllegalArgumentException if the		 *          delay specified is negative or not a finite number.		 */		public function get delay():Number		{			return _delay;		}		public function set delay(v:Number):void		{			if (v < 0 || v == Number.POSITIVE_INFINITY)			{				throw new IllegalArgumentException(toString()					+ " The specified delay is negative or not a finite number.");				return;			}			_delay = v;		}						/**		 * The total number of times the timer is set to run. If the repeat count is		 * set to 0, the timer continues forever or until the stop() method is invoked		 * or the program stops. If the repeat count is nonzero, the timer runs the		 * specified number of times. If repeatCount is set to a total that is the same		 * or less then currentCount  the timer stops and will not fire again.		 */		public function get repeatCount():int		{			return _repeatCount;		}		public function set repeatCount(v:int):void		{			_repeatCount = v;		}						/**		 * The total number of times the timer has fired since it started at zero.		 * If the timer has been reset, only the fires since the reset are counted.		 */		public function get currentCount():int		{			return _currentCount;		}						/**		 * The timer's current state; true if the timer is running, otherwise false.		 */		public function get isRunning():Boolean		{			return _isRunning;		}				
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------				protected function onEnterFrame(e:Event):void		{			var now:Date = new Date();			var msDiff:int = now.valueOf() - _currentTime.valueOf();						_offset += msDiff;			_currentTime = now;						if (_offset > _delay)			{				while (_offset > _delay)				{					_currentCount++;					_offset -= _delay;										if (_repeatCount != 0)					{						if (_currentCount == _repeatCount)						{							dispatchEvent(new TimerEvent(TimerEvent.TIMER));							dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));							stop();						}						else if (_currentCount < _repeatCount)						{							dispatchEvent(new TimerEvent(TimerEvent.TIMER));						}					}					else					{						dispatchEvent(new TimerEvent(TimerEvent.TIMER));					}				}			}		}	}}