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
package tetragon.view.render2d.core.events
{
	import flash.utils.Dictionary;
	import tetragon.view.render2d.core.DisplayObject2D;


	
	
	/**
	 * The EventDispatcher class is the base class for all classes that dispatch events.
	 * This is the Starling version of the Flash class with the same name.
	 * 
	 * <p>
	 * The event mechanism is a key feature of Starling's architecture. Objects can
	 * communicate with each other through events. Compared the the Flash event system,
	 * Starling's event system was simplified. The main difference is that Starling events
	 * have no "Capture" phase. They are simply dispatched at the target and may
	 * optionally bubble up. They cannot move in the opposite direction.
	 * </p>
	 * 
	 * <p>
	 * As in the conventional Flash classes, display objects inherit from EventDispatcher
	 * and can thus dispatch events. Beware, though, that the Starling event classes are
	 * <em>not compatible with Flash events:</em> Starling display objects dispatch
	 * Starling events, which will bubble along Starling display objects - but they cannot
	 * dispatch Flash events or bubble along Flash display objects.
	 * </p>
	 * 
	 * @see Event2D
	 * @see starling.display.DisplayObject DisplayObject
	 */
	public class EventDispatcher2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _listeners:Dictionary;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Registers an event listener at a certain object.
		 * 
		 * @param type
		 * @param listener
		 */
		public function addEventListener(type:String, listener:Function):void
		{
			if (!_listeners) _listeners = new Dictionary();
			var listeners:Vector.<Function> = _listeners[type];
			if (!listeners) _listeners[type] = new <Function>[listener];
			else _listeners[type] = listeners.concat(new <Function>[listener]);
		}
		
		
		/**
		 * Removes an event listener from the object.
		 * 
		 * @param type
		 * @param listener
		 */
		public function removeEventListener(type:String, listener:Function):void
		{
			if (_listeners)
			{
				var listeners:Vector.<Function> = _listeners[type];
				if (listeners)
				{
					listeners = listeners.filter(function(item:Function, ...rest):Boolean
					{
						return item != listener;
					});
					
					if (listeners.length == 0) delete _listeners[type];
					else _listeners[type] = listeners;
				}
			}
		}
		
		
		/**
		 * Removes all event listeners with a certain type, or all of them if type is
		 * null. Be careful when removing all event listeners: you never know who else was
		 * listening.
		 * 
		 * @param type
		 */
		public function removeEventListeners(type:String = null):void
		{
			if (type && _listeners) delete _listeners[type];
			else _listeners = null;
		}
		
		
		/**
		 * Dispatches an event to all objects that have registered for events of the same type.
		 * 
		 * @param e
		 */
		public function dispatchEvent(e:Event2D):void
		{
			var listeners:Vector.<Function> = _listeners ? _listeners[e.type] : null;
			if (!listeners && !e.bubbles) return; // no need to do anything

			// if the event already has a current target, it was re-dispatched by user -> we change
			// the target to 'this' for now, but undo that later on (instead of creating a clone).
			var previousTarget:EventDispatcher2D = e.target;
			if (!previousTarget || e.currentTarget) e.setTarget(this);
			
			var stopImmediatePropagation:Boolean = false;
			var numListeners:int = listeners == null ? 0 : listeners.length;
			
			if (numListeners != 0)
			{
				e.setCurrentTarget(this);

				// we can enumerate directly over the vector, since "add"- and "removeEventListener"
				// won't change it, but instead always create a new vector.
				for (var i:int = 0; i < numListeners; ++i)
				{
					listeners[i](e);
					if (e.stopsImmediatePropagation)
					{
						stopImmediatePropagation = true;
						break;
					}
				}
			}
			
			if (!stopImmediatePropagation && e.bubbles && !e.stopsPropagation && this is DisplayObject2D)
			{
				var targetDisplayObject:DisplayObject2D = this as DisplayObject2D;
				if (targetDisplayObject.parent)
				{
					e.setCurrentTarget(null);
					// to find out later if the event was redispatched.
					targetDisplayObject.parent.dispatchEvent(e);
				}
			}
			
			if (previousTarget) e.setTarget(previousTarget);
		}
		
		
		/**
		 * Returns if there are listeners registered for a certain event type.
		 * 
		 * @param type
		 * @return true or false.
		 */
		public function hasEventListener(type:String):Boolean
		{
			return _listeners && type in _listeners;
		}
	}
}