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
	import tetragon.view.render2d.core.events.Event2D;
	import tetragon.view.render2d.core.events.EventDispatcher2D;


	/**
	 * A DelayedCall2D allows you to execute a method after a certain time has passed. Since
	 * it implements the IAnimatable interface, it can be added to a juggler. In most
	 * cases, you do not have to use this class directly; the juggler class contains a
	 * method to delay calls directly.
	 * 
	 * <p>
	 * DelayedCall2D dispatches an Event of type 'Event.REMOVE_FROM_JUGGLER' when it is
	 * finished, so that the juggler automatically removes it when its no longer needed.
	 * </p>
	 * 
	 * @see Juggler2D
	 */
	public class DelayedCall2D extends EventDispatcher2D implements IAnimatable2D
	{
		// -----------------------------------------------------------------------------------------
		// Properties
		// -----------------------------------------------------------------------------------------
		
		/** @private */
		private var _currentTime:Number = 0;
		/** @private */
		private var _totalTime:Number;
		/** @private */
		private var _call:Function;
		/** @private */
		private var _args:Array;
		/** @private */
		private var _repeatCount:int = 1;
		
		
		// -----------------------------------------------------------------------------------------
		// Constructor
		// -----------------------------------------------------------------------------------------
		
		/**
		 * Creates a delayed call.
		 * 
		 * @param call
		 * @param delay
		 * @param args
		 */
		public function DelayedCall2D(call:Function, delay:Number, args:Array = null)
		{
			_call = call;
			_totalTime = Math.max(delay, 0.0001);
			_args = args;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function advanceTime(time:Number):void
		{
			var previousTime:Number = _currentTime;
			_currentTime = Math.min(_totalTime, _currentTime + time);
			
			if (previousTime < _totalTime && _currentTime >= _totalTime)
			{
				_call.apply(null, _args);
				
				if (_repeatCount > 1)
				{
					_repeatCount -= 1;
					_currentTime = 0;
					advanceTime((previousTime + time) - _totalTime);
				}
				else
				{
					dispatchEvent(new Event2D(Event2D.REMOVE_FROM_JUGGLER));
				}
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Indicates if enough time has passed, and the call has already been executed.
		 */
		public function get isComplete():Boolean
		{
			return _repeatCount == 1 && _currentTime >= _totalTime;
		}
		
		
		/**
		 * The time for which calls will be delayed (in seconds).
		 */
		public function get totalTime():Number
		{
			return _totalTime;
		}
		
		
		/**
		 * The time that has already passed (in seconds).
		 */
		public function get currentTime():Number
		{
			return _currentTime;
		}
		
		
		/**
		 * The number of times the call will be repeated.
		 */
		public function get repeatCount():int
		{
			return _repeatCount;
		}
		public function set repeatCount(v:int):void
		{
			_repeatCount = v;
		}
	}
}
