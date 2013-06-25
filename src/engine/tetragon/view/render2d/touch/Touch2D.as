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
package tetragon.view.render2d.touch
{
	import tetragon.util.geom.MatrixUtil;
	import tetragon.util.string.formatString;
	import tetragon.view.render2d.display.DisplayObject2D;
	import tetragon.view.render2d.events.EventDispatcher2D;
	import tetragon.view.render2d.events.TouchEvent2D;

	import flash.geom.Matrix;
	import flash.geom.Point;
	
	
	/** A Touch object contains information about the presence or movement of a finger 
	 *  or the mouse on the screen.
	 *  
	 *  <p>You receive objects of this type from a TouchEvent. When such an event is triggered, you can 
	 *  query it for all touches that are currently present on the screen. One Touch object contains
	 *  information about a single touch. A touch object always moves through a series of
	 *  TouchPhases. Have a look at the TouchPhase class for more information.</p>
	 *  
	 *  <strong>The position of a touch</strong>
	 *  
	 *  <p>You can get the current and previous position in stage coordinates with the corresponding 
	 *  properties. However, you'll want to have the position in a different coordinate system 
	 *  most of the time. For this reason, there are methods that convert the current and previous 
	 *  touches into the local coordinate system of any object.</p>
	 * 
	 *  @see TouchEvent
	 *  @see TouchPhase
	 */
	public class Touch2D
	{
		private var mID:int;
		private var mGlobalX:Number;
		private var mGlobalY:Number;
		private var mPreviousGlobalX:Number;
		private var mPreviousGlobalY:Number;
		private var mTapCount:int;
		private var mPhase:String;
		private var mTarget:DisplayObject2D;
		private var mTimestamp:Number;
		private var mPressure:Number;
		private var mWidth:Number;
		private var mHeight:Number;
		private var mBubbleChain:Vector.<EventDispatcher2D>;
		/** Helper object. */
		private static var sHelperMatrix:Matrix = new Matrix();


		/** Creates a new Touch object. */
		public function Touch2D(id:int, globalX:Number, globalY:Number, phase:String, target:DisplayObject2D)
		{
			mID = id;
			mGlobalX = mPreviousGlobalX = globalX;
			mGlobalY = mPreviousGlobalY = globalY;
			mTapCount = 0;
			mPhase = phase;
			mTarget = target;
			mPressure = mWidth = mHeight = 1.0;
			mBubbleChain = new <EventDispatcher2D>[];
			updateBubbleChain();
		}


		/** Converts the current location of a touch to the local coordinate system of a display 
		 *  object. If you pass a 'resultPoint', the result will be stored in this point instead 
		 *  of creating a new object.*/
		public function getLocation(space:DisplayObject2D, resultPoint:Point = null):Point
		{
			if (resultPoint == null) resultPoint = new Point();
			space.base.getTransformationMatrix(space, sHelperMatrix);
			return MatrixUtil.transformCoords(sHelperMatrix, mGlobalX, mGlobalY, resultPoint);
		}


		/** Converts the previous location of a touch to the local coordinate system of a display 
		 *  object. If you pass a 'resultPoint', the result will be stored in this point instead 
		 *  of creating a new object.*/
		public function getPreviousLocation(space:DisplayObject2D, resultPoint:Point = null):Point
		{
			if (resultPoint == null) resultPoint = new Point();
			space.base.getTransformationMatrix(space, sHelperMatrix);
			return MatrixUtil.transformCoords(sHelperMatrix, mPreviousGlobalX, mPreviousGlobalY, resultPoint);
		}


		/** Returns the movement of the touch between the current and previous location. 
		 *  If you pass a 'resultPoint', the result will be stored in this point instead 
		 *  of creating a new object. */
		public function getMovement(space:DisplayObject2D, resultPoint:Point = null):Point
		{
			if (resultPoint == null) resultPoint = new Point();
			getLocation(space, resultPoint);
			var x:Number = resultPoint.x;
			var y:Number = resultPoint.y;
			getPreviousLocation(space, resultPoint);
			resultPoint.setTo(x - resultPoint.x, y - resultPoint.y);
			return resultPoint;
		}


		/** Indicates if the target or one of its children is touched. */
		public function isTouching(target:DisplayObject2D):Boolean
		{
			return mBubbleChain.indexOf(target) != -1;
		}


		/** Returns a description of the object. */
		public function toString():String
		{
			return formatString("Touch {0}: globalX={1}, globalY={2}, phase={3}", mID, mGlobalX, mGlobalY, mPhase);
		}


		/** Creates a clone of the Touch object. */
		public function clone():Touch2D
		{
			var clone:Touch2D = new Touch2D(mID, mGlobalX, mGlobalY, mPhase, mTarget);
			clone.mPreviousGlobalX = mPreviousGlobalX;
			clone.mPreviousGlobalY = mPreviousGlobalY;
			clone.mTapCount = mTapCount;
			clone.mTimestamp = mTimestamp;
			clone.mPressure = mPressure;
			clone.mWidth = mWidth;
			clone.mHeight = mHeight;
			return clone;
		}


		// helper methods
		private function updateBubbleChain():void
		{
			if (mTarget)
			{
				var length:int = 1;
				var element:DisplayObject2D = mTarget;

				mBubbleChain.length = 1;
				mBubbleChain[0] = element;

				while ((element = element.parent) != null)
					mBubbleChain[int(length++)] = element;
			}
			else
			{
				mBubbleChain.length = 0;
			}
		}


		// properties
		/** The identifier of a touch. '0' for mouse events, an increasing number for touches. */
		public function get id():int
		{
			return mID;
		}


		/** The x-position of the touch in stage coordinates. */
		public function get globalX():Number
		{
			return mGlobalX;
		}


		/** The y-position of the touch in stage coordinates. */
		public function get globalY():Number
		{
			return mGlobalY;
		}


		/** The previous x-position of the touch in stage coordinates. */
		public function get previousGlobalX():Number
		{
			return mPreviousGlobalX;
		}


		/** The previous y-position of the touch in stage coordinates. */
		public function get previousGlobalY():Number
		{
			return mPreviousGlobalY;
		}


		/** The number of taps the finger made in a short amount of time. Use this to detect 
		 *  double-taps / double-clicks, etc. */
		public function get tapCount():int
		{
			return mTapCount;
		}


		/** The current phase the touch is in. @see TouchPhase */
		public function get phase():String
		{
			return mPhase;
		}


		/** The display object at which the touch occurred. */
		public function get target():DisplayObject2D
		{
			return mTarget;
		}


		/** The moment the touch occurred (in seconds since application start). */
		public function get timestamp():Number
		{
			return mTimestamp;
		}


		/** A value between 0.0 and 1.0 indicating force of the contact with the device. 
		 *  If the device does not support detecting the pressure, the value is 1.0. */
		public function get pressure():Number
		{
			return mPressure;
		}


		/** Width of the contact area. 
		 *  If the device does not support detecting the pressure, the value is 1.0. */
		public function get width():Number
		{
			return mWidth;
		}


		/** Height of the contact area. 
		 *  If the device does not support detecting the pressure, the value is 1.0. */
		public function get height():Number
		{
			return mHeight;
		}


		// internal methods
		/** @private 
		 *  Dispatches a touch event along the current bubble chain (which is updated each time
		 *  a target is set). */
		public function dispatchEvent(event:TouchEvent2D):void
		{
			if (mTarget) event.dispatch(mBubbleChain);
		}


		/** @private */
		public  function get bubbleChain():Vector.<EventDispatcher2D>
		{
			return mBubbleChain.concat();
		}


		/** @private */
		public  function setTarget(value:DisplayObject2D):void
		{
			mTarget = value;
			updateBubbleChain();
		}


		/** @private */
		public function setPosition(globalX:Number, globalY:Number):void
		{
			mPreviousGlobalX = mGlobalX;
			mPreviousGlobalY = mGlobalY;
			mGlobalX = globalX;
			mGlobalY = globalY;
		}


		/** @private */
		public  function setSize(width:Number, height:Number):void
		{
			mWidth = width;
			mHeight = height;
		}


		/** @private */
		public  function setPhase(value:String):void
		{
			mPhase = value;
		}


		/** @private */
		public  function setTapCount(value:int):void
		{
			mTapCount = value;
		}


		/** @private */
		public  function setTimestamp(value:Number):void
		{
			mTimestamp = value;
		}


		/** @private */
		public  function setPressure(value:Number):void
		{
			mPressure = value;
		}
	}
}
