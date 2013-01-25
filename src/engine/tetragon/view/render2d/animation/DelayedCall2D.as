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
package tetragon.view.render2d.animation
{
	import tetragon.view.render2d.events.Event2D;
	import tetragon.view.render2d.events.EventDispatcher2D;

	/** A DelayedCall allows you to execute a method after a certain time has passed. Since it 
	 *  implements the IAnimatable interface, it can be added to a juggler. In most cases, you 
	 *  do not have to use this class directly; the juggler class contains a method to delay
	 *  calls directly. 
	 * 
	 *  <p>DelayedCall dispatches an Event of type 'Event.REMOVE_FROM_JUGGLER' when it is finished,
	 *  so that the juggler automatically removes it when its no longer needed.</p>
	 * 
	 *  @see Juggler
	 */
	public class DelayedCall2D extends EventDispatcher2D implements IAnimatable2D
	{
		private var mCurrentTime:Number;
		private var mTotalTime:Number;
		private var mCall:Function;
		private var mArgs:Array;
		private var mRepeatCount:int;


		/** Creates a delayed call. */
		public function DelayedCall2D(call:Function, delay:Number, args:Array = null)
		{
			reset(call, delay, args);
		}


		/** Resets the delayed call to its default values, which is useful for pooling. */
		public function reset(call:Function, delay:Number, args:Array = null):DelayedCall2D
		{
			mCurrentTime = 0;
			mTotalTime = Math.max(delay, 0.0001);
			mCall = call;
			mArgs = args;
			mRepeatCount = 1;

			return this;
		}


		/** @inheritDoc */
		public function advanceTime(time:Number):void
		{
			var previousTime:Number = mCurrentTime;
			mCurrentTime = Math.min(mTotalTime, mCurrentTime + time);

			if (previousTime < mTotalTime && mCurrentTime >= mTotalTime)
			{
				mCall.apply(null, mArgs);

				if (mRepeatCount == 0 || mRepeatCount > 1)
				{
					if (mRepeatCount > 0) mRepeatCount -= 1;
					mCurrentTime = 0;
					advanceTime((previousTime + time) - mTotalTime);
				}
				else
				{
					dispatchEventWith(Event2D.REMOVE_FROM_JUGGLER);
				}
			}
		}


		/** Indicates if enough time has passed, and the call has already been executed. */
		public function get isComplete():Boolean
		{
			return mRepeatCount == 1 && mCurrentTime >= mTotalTime;
		}


		/** The time for which calls will be delayed (in seconds). */
		public function get totalTime():Number
		{
			return mTotalTime;
		}


		/** The time that has already passed (in seconds). */
		public function get currentTime():Number
		{
			return mCurrentTime;
		}


		/** The number of times the call will be repeated. 
		 *  Set to '0' to repeat indefinitely. @default 1 */
		public function get repeatCount():int
		{
			return mRepeatCount;
		}


		public function set repeatCount(value:int):void
		{
			mRepeatCount = value;
		}
	}
}