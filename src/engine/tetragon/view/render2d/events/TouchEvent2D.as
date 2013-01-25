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
package tetragon.view.render2d.events
{
	import tetragon.view.render2d.display.DisplayObject2D;
	import tetragon.view.render2d.touch.Touch2D;
	import tetragon.view.render2d.touch.TouchPhase2D;
	
	
	/** A TouchEvent is triggered either by touch or mouse input.  
	 *  
	 *  <p>In Render2D, both touch events and mouse events are handled through the same class: 
	 *  TouchEvent. To process user input from a touch screen or the mouse, you have to register
	 *  an event listener for events of the type <code>TouchEvent.TOUCH</code>. This is the only
	 *  event type you need to handle; the long list of mouse event types as they are used in
	 *  conventional Flash are mapped to so-called "TouchPhases" instead.</p> 
	 * 
	 *  <p>The difference between mouse input and touch input is that</p>
	 *  
	 *  <ul>
	 *    <li>only one mouse cursor can be present at a given moment and</li>
	 *    <li>only the mouse can "hover" over an object without a pressed button.</li>
	 *  </ul> 
	 *  
	 *  <strong>Which objects receive touch events?</strong>
	 * 
	 *  <p>In Render2D, any display object receives touch events, as long as the  
	 *  <code>touchable</code> property of the object and its parents is enabled. There 
	 *  is no "InteractiveObject" class in Render2D.</p>
	 *  
	 *  <strong>How to work with individual touches</strong>
	 *  
	 *  <p>The event contains a list of all touches that are currently present. Each individual
	 *  touch is stored in an object of type "Touch". Since you are normally only interested in 
	 *  the touches that occurred on top of certain objects, you can query the event for touches
	 *  with a specific target:</p>
	 * 
	 *  <code>var touches:Vector.&lt;Touch&gt; = touchEvent.getTouches(this);</code>
	 *  
	 *  <p>This will return all touches of "this" or one of its children. When you are not using 
	 *  multitouch, you can also access the touch object directly, like this:</p>
	 * 
	 *  <code>var touch:Touch = touchEvent.getTouch(this);</code>
	 *  
	 *  @see Touch
	 *  @see TouchPhase
	 */
	public class TouchEvent2D extends Event2D
	{
		/** Event type for touch or mouse input. */
		public static const TOUCH:String = "touch";
		private var mShiftKey:Boolean;
		private var mCtrlKey:Boolean;
		private var mTimestamp:Number;
		private var mVisitedObjects:Vector.<EventDispatcher2D>;
		/** Helper object. */
		private static var sTouches:Vector.<Touch2D> = new <Touch2D>[];


		/** Creates a new TouchEvent instance. */
		public function TouchEvent2D(type:String, touches:Vector.<Touch2D>, shiftKey:Boolean = false, ctrlKey:Boolean = false, bubbles:Boolean = true)
		{
			super(type, bubbles, touches);

			mShiftKey = shiftKey;
			mCtrlKey = ctrlKey;
			mTimestamp = -1.0;
			mVisitedObjects = new <EventDispatcher2D>[];

			var numTouches:int = touches.length;
			for (var i:int = 0; i < numTouches; ++i)
				if (touches[i].timestamp > mTimestamp)
					mTimestamp = touches[i].timestamp;
		}


		/** Returns a list of touches that originated over a certain target. If you pass a
		 *  'result' vector, the touches will be added to this vector instead of creating a new 
		 *  object. */
		public function getTouches(target:DisplayObject2D, phase:String = null, result:Vector.<Touch2D>=null):Vector.<Touch2D>
		{
			if (result == null) result = new <Touch2D>[];
			var allTouches:Vector.<Touch2D> = data as Vector.<Touch2D>;
			var numTouches:int = allTouches.length;

			for (var i:int = 0; i < numTouches; ++i)
			{
				var touch:Touch2D = allTouches[i];
				var correctTarget:Boolean = touch.isTouching(target);
				var correctPhase:Boolean = (phase == null || phase == touch.phase);

				if (correctTarget && correctPhase)
					result.push(touch);
			}
			return result;
		}


		/** Returns a touch that originated over a certain target. */
		public function getTouch(target:DisplayObject2D, phase:String = null):Touch2D
		{
			getTouches(target, phase, sTouches);
			if (sTouches.length)
			{
				var touch:Touch2D = sTouches[0];
				sTouches.length = 0;
				return touch;
			}
			else return null;
		}


		/** Indicates if a target is currently being touched or hovered over. */
		public function interactsWith(target:DisplayObject2D):Boolean
		{
			if (getTouch(target) == null)
				return false;
			else
			{
				var touches:Vector.<Touch2D> = getTouches(target);

				for (var i:int = touches.length - 1; i >= 0; --i)
					if (touches[i].phase != TouchPhase2D.ENDED)
						return true;

				return false;
			}
		}


		// custom dispatching
		/** @private
		 *  Dispatches the event along a custom bubble chain. During the lifetime of the event,
		 *  each object is visited only once. */
		public function dispatch(chain:Vector.<EventDispatcher2D>):void
		{
			if (chain && chain.length)
			{
				var chainLength:int = bubbles ? chain.length : 1;
				var previousTarget:EventDispatcher2D = target;
				setTarget(chain[0] as EventDispatcher2D);

				for (var i:int = 0; i < chainLength; ++i)
				{
					var chainElement:EventDispatcher2D = chain[i] as EventDispatcher2D;
					if (mVisitedObjects.indexOf(chainElement) == -1)
					{
						var stopPropagation:Boolean = chainElement.invokeEvent(this);
						mVisitedObjects.push(chainElement);
						if (stopPropagation) break;
					}
				}

				setTarget(previousTarget);
			}
		}


		// properties
		/** The time the event occurred (in seconds since application launch). */
		public function get timestamp():Number
		{
			return mTimestamp;
		}


		/** All touches that are currently available. */
		public function get touches():Vector.<Touch2D>
		{
			return (data as Vector.<Touch2D>).concat();
		}


		/** Indicates if the shift key was pressed when the event occurred. */
		public function get shiftKey():Boolean
		{
			return mShiftKey;
		}


		/** Indicates if the ctrl key was pressed when the event occurred. (Mac OS: Cmd or Ctrl) */
		public function get ctrlKey():Boolean
		{
			return mCtrlKey;
		}
	}
}