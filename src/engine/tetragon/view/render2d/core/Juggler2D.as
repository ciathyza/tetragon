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
	 * The Juggler takes objects that implement IAnimatable (like Tweens) and executes
	 * them.
	 * 
	 * <p>
	 * A juggler is a simple object. It does no more than saving a list of objects
	 * implementing "IAnimatable" and advancing their time if it is told to do so (by
	 * calling its own "advanceTime"-method). When an animation is completed, it throws it
	 * away.
	 * </p>
	 * 
	 * <p>
	 * There is a default juggler available at the Starling class:
	 * </p>
	 * 
	 * <pre>
	 *  var juggler:Juggler = Starling.juggler;
	 * </pre>
	 * 
	 * <p>
	 * You can create juggler objects yourself, just as well. That way, you can group your
	 * game into logical components that handle their animations independently. All you
	 * have to do is call the "advanceTime" method on your custom juggler once per frame.
	 * </p>
	 * 
	 * <p>
	 * Another handy feature of the juggler is the "delayCall"-method. Use it to execute a
	 * function at a later time. Different to conventional approaches, the method will
	 * only be called when the juggler is advanced, giving you perfect control over the
	 * call.
	 * </p>
	 * 
	 * <pre>
	 *  juggler.delayCall(object.removeFromParent, 1.0);
	 *  juggler.delayCall(object.addChild, 2.0, theChild);
	 *  juggler.delayCall(function():void { doSomethingFunny(); }, 3.0);
	 * </pre>
	 * 
	 * @see Tween2D
	 * @see DelayedCall2D
	 */
	public class Juggler2D implements IAnimatable2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _objects:Vector.<IAnimatable2D>;
		/** @private */
		private var _elapsedTime:Number;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Create an empty juggler.
		 */
		public function Juggler2D()
		{
			_elapsedTime = 0;
			_objects = new <IAnimatable2D>[];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds an object to the juggler.
		 * 
		 * @param object
		 */
		public function add(object:IAnimatable2D):void
		{
			if (object) _objects.push(object);
			var d:EventDispatcher2D = object as EventDispatcher2D;
			if (d) d.addEventListener(Event2D.REMOVE_FROM_JUGGLER, onRemove);
		}
		
		
		/**
		 * Removes an object from the juggler.
		 * 
		 * @param object
		 */
		public function remove(object:IAnimatable2D):void
		{
			if (!object) return;
			var d:EventDispatcher2D = object as EventDispatcher2D;
			if (d) d.removeEventListener(Event2D.REMOVE_FROM_JUGGLER, onRemove);
			for (var i:int = _objects.length - 1; i >= 0; --i)
			{
				if (_objects[i] == object) _objects.splice(i, 1);
			}
		}
		
		
		/**
		 * Removes all tweens with a certain target.
		 * 
		 * @param target
		 */
		public function removeTweens(target:Object):void
		{
			if (!target) return;
			var numObjects:int = _objects.length;
			for (var i:int = numObjects - 1; i >= 0; --i)
			{
				var tween:Tween2D = _objects[i] as Tween2D;
				if (tween && tween.target == target) _objects.splice(i, 1);
			}
		}
		
		
		/**
		 * Removes all objects at once.
		 */
		public function purge():void
		{
			_objects.length = 0;
		}
		
		
		/**
		 * Delays the execution of a function until a certain time has passed. Creates an
		 * object of type 'DelayedCall' internally and returns it. Remove that object from
		 * the juggler to cancel the function call.
		 * 
		 * @param call
		 * @param delay
		 * @param args
		 * @return DelayedCall2D
		 */
		public function delayCall(call:Function, delay:Number, ...args):DelayedCall2D
		{
			if (call == null) return null;
			var delayedCall:DelayedCall2D = new DelayedCall2D(call, delay, args);
			add(delayedCall);
			return delayedCall;
		}
		
		
		/**
		 * Advances all objects by a certain time (in seconds).
		 * 
		 * @param time
		 */
		public function advanceTime(time:Number):void
		{
			_elapsedTime += time;
			if (_objects.length == 0) return;
			// since 'advanceTime' could modify the juggler (through a callback), we iterate
			// over a copy of 'mObjects'.
			var numObjects:uint = _objects.length;
			var objectCopy:Vector.<IAnimatable2D> = _objects.concat();
			for (var i:uint = 0; i < numObjects; ++i)
			{
				objectCopy[i].advanceTime(time);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The total life time of the juggler.
		 */
		public function get elapsedTime():Number
		{
			return _elapsedTime;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onRemove(e:Event2D):void
		{
			remove(e.target as IAnimatable2D);
		}
	}
}
