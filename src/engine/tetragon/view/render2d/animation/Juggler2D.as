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
	
	
	/** The Juggler takes objects that implement IAnimatable (like Tweens) and executes them.
	 * 
	 *  <p>A juggler is a simple object. It does no more than saving a list of objects implementing 
	 *  "IAnimatable" and advancing their time if it is told to do so (by calling its own 
	 *  "advanceTime"-method). When an animation is completed, it throws it away.</p>
	 *  
	 *  <p>There is a default juggler available at the Render2D class:</p>
	 *  
	 *  <pre>
	 *  var juggler:Juggler = Render2D.juggler;
	 *  </pre>
	 *  
	 *  <p>You can create juggler objects yourself, just as well. That way, you can group 
	 *  your game into logical components that handle their animations independently. All you have
	 *  to do is call the "advanceTime" method on your custom juggler once per frame.</p>
	 *  
	 *  <p>Another handy feature of the juggler is the "delayCall"-method. Use it to 
	 *  execute a function at a later time. Different to conventional approaches, the method
	 *  will only be called when the juggler is advanced, giving you perfect control over the 
	 *  call.</p>
	 *  
	 *  <pre>
	 *  juggler.delayCall(object.removeFromParent, 1.0);
	 *  juggler.delayCall(object.addChild, 2.0, theChild);
	 *  juggler.delayCall(function():void { doSomethingFunny(); }, 3.0);
	 *  </pre>
	 * 
	 *  @see Tween
	 *  @see DelayedCall 
	 */
	public class Juggler2D implements IAnimatable2D
	{
		private var mObjects:Vector.<IAnimatable2D>;
		private var mElapsedTime:Number;


		/** Create an empty juggler. */
		public function Juggler2D()
		{
			mElapsedTime = 0;
			mObjects = new <IAnimatable2D>[];
		}


		/** Adds an object to the juggler. */
		public function add(object:IAnimatable2D):void
		{
			if (object && mObjects.indexOf(object) == -1)
			{
				mObjects.push(object);

				var dispatcher:EventDispatcher2D = object as EventDispatcher2D;
				if (dispatcher) dispatcher.addEventListener(Event2D.REMOVE_FROM_JUGGLER, onRemove);
			}
		}


		/** Determines if an object has been added to the juggler. */
		public function contains(object:IAnimatable2D):Boolean
		{
			return mObjects.indexOf(object) != -1;
		}


		/** Removes an object from the juggler. */
		public function remove(object:IAnimatable2D):void
		{
			if (object == null) return;

			var dispatcher:EventDispatcher2D = object as EventDispatcher2D;
			if (dispatcher) dispatcher.removeEventListener(Event2D.REMOVE_FROM_JUGGLER, onRemove);

			var index:int = mObjects.indexOf(object);
			if (index != -1) mObjects[index] = null;
		}


		/** Removes all tweens with a certain target. */
		public function removeTweens(target:Object):void
		{
			if (target == null) return;

			for (var i:int = mObjects.length - 1; i >= 0; --i)
			{
				var tween:Tween2D = mObjects[i] as Tween2D;
				if (tween && tween.target == target)
				{
					tween.removeEventListener(Event2D.REMOVE_FROM_JUGGLER, onRemove);
					mObjects[i] = null;
				}
			}
		}


		/** Removes all objects at once. */
		public function purge():void
		{
			// the object vector is not purged right away, because if this method is called
			// from an 'advanceTime' call, this would make the loop crash. Instead, the
			// vector is filled with 'null' values. They will be cleaned up on the next call
			// to 'advanceTime'.

			for (var i:int = mObjects.length - 1; i >= 0; --i)
			{
				var dispatcher:EventDispatcher2D = mObjects[i] as EventDispatcher2D;
				if (dispatcher) dispatcher.removeEventListener(Event2D.REMOVE_FROM_JUGGLER, onRemove);
				mObjects[i] = null;
			}
		}


		/** Delays the execution of a function until a certain time has passed. Creates an
		 *  object of type 'DelayedCall' internally and returns it. Remove that object
		 *  from the juggler to cancel the function call. */
		public function delayCall(call:Function, delay:Number, ...args):DelayedCall2D
		{
			if (call == null) return null;

			var delayedCall:DelayedCall2D = new DelayedCall2D(call, delay, args);
			add(delayedCall);
			return delayedCall;
		}


		/** Utilizes a tween to animate the target object over a certain time. Internally, this
		 *  method uses a tween instance (taken from an object pool) that is added to the
		 *  juggler right away. This method provides a convenient alternative for creating 
		 *  and adding a tween manually.
		 *  
		 *  <p>Fill 'properties' with key-value pairs that describe both the 
		 *  tween and the animation target. Here is an example:</p>
		 *  
		 *  <pre>
		 *  juggler.tween(object, 2.0, {
		 *      transition: Transitions.EASE_IN_OUT,
		 *      delay: 20, // -> tween.delay = 20
		 *      x: 50      // -> tween.animate("x", 50)
		 *  });
		 *  </pre> 
		 */
		public function tween(target:Object, time:Number, properties:Object):void
		{
			var tween:Tween2D = Tween2D.fromPool(target, time);

			for (var property:String in properties)
			{
				var value:Object = properties[property];

				if (tween.hasOwnProperty(property))
					tween[property] = value;
				else if (target.hasOwnProperty(property))
					tween.animate(property, value as Number);
				else
					throw new ArgumentError("Invalid property: " + property);
			}

			tween.addEventListener(Event2D.REMOVE_FROM_JUGGLER, onPooledTweenComplete);
			add(tween);
		}


		private function onPooledTweenComplete(event:Event2D):void
		{
			Tween2D.toPool(event.target as Tween2D);
		}


		/** Advances all objects by a certain time (in seconds). */
		public function advanceTime(time:Number):void
		{
			var numObjects:int = mObjects.length;
			var currentIndex:int = 0;
			var i:int;

			mElapsedTime += time;
			if (numObjects == 0) return;

			// there is a high probability that the "advanceTime" function modifies the list
			// of animatables. we must not process new objects right now (they will be processed
			// in the next frame), and we need to clean up any empty slots in the list.

			for (i = 0; i < numObjects; ++i)
			{
				var object:IAnimatable2D = mObjects[i];
				if (object)
				{
					// shift objects into empty slots along the way
					if (currentIndex != i)
					{
						mObjects[currentIndex] = object;
						mObjects[i] = null;
					}

					object.advanceTime(time);
					++currentIndex;
				}
			}

			if (currentIndex != i)
			{
				numObjects = mObjects.length;
				// count might have changed!

				while (i < numObjects)
					mObjects[int(currentIndex++)] = mObjects[int(i++)];

				mObjects.length = currentIndex;
			}
		}


		private function onRemove(event:Event2D):void
		{
			remove(event.target as IAnimatable2D);

			var tween:Tween2D = event.target as Tween2D;
			if (tween && tween.isComplete)
				add(tween.nextTween);
		}


		/** The total life time of the juggler. */
		public function get elapsedTime():Number
		{
			return mElapsedTime;
		}
	}
}