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

	import flash.utils.Dictionary;
	
	
	/** The EventDispatcher class is the base class for all classes that dispatch events. 
	 *  This is the Render2D version of the Flash class with the same name. 
	 *  
	 *  <p>The event mechanism is a key feature of Render2D's architecture. Objects can communicate 
	 *  with each other through events. Compared the the Flash event system, Render2D's event system
	 *  was simplified. The main difference is that Render2D events have no "Capture" phase.
	 *  They are simply dispatched at the target and may optionally bubble up. They cannot move 
	 *  in the opposite direction.</p>  
	 *  
	 *  <p>As in the conventional Flash classes, display objects inherit from EventDispatcher 
	 *  and can thus dispatch events. Beware, though, that the Render2D event classes are 
	 *  <em>not compatible with Flash events:</em> Render2D display objects dispatch 
	 *  Render2D events, which will bubble along Render2D display objects - but they cannot 
	 *  dispatch Flash events or bubble along Flash display objects.</p>
	 *  
	 *  @see Event2D
	 *  @see Render2D.display.DisplayObject2D DisplayObject2D
	 */
	public class EventDispatcher2D
	{
		private var _eventListeners:Dictionary;
		/** Helper object. */
		private static var _bubbleChains:Array = [];


		/** Creates an EventDispatcher. */
		public function EventDispatcher2D()
		{
		}


		/** Registers an event listener at a certain object. */
		public function addEventListener(type:String, listener:Function):void
		{
			if (_eventListeners == null)
				_eventListeners = new Dictionary();

			var listeners:Vector.<Function> = _eventListeners[type] as Vector.<Function>;
			if (listeners == null)
				_eventListeners[type] = new <Function>[listener];
			else if (listeners.indexOf(listener) == -1) // check for duplicates
				listeners.push(listener);
		}


		/** Removes an event listener from the object. */
		public function removeEventListener(type:String, listener:Function):void
		{
			if (_eventListeners)
			{
				var listeners:Vector.<Function> = _eventListeners[type] as Vector.<Function>;
				if (listeners)
				{
					var numListeners:int = listeners.length;
					var remainingListeners:Vector.<Function> = new <Function>[];

					for (var i:int = 0; i < numListeners; ++i)
						if (listeners[i] != listener) remainingListeners.push(listeners[i]);

					_eventListeners[type] = remainingListeners;
				}
			}
		}


		/** Removes all event listeners with a certain type, or all of them if type is null. 
		 *  Be careful when removing all event listeners: you never know who else was listening. */
		public function removeEventListeners(type:String = null):void
		{
			if (type && _eventListeners)
				delete _eventListeners[type];
			else
				_eventListeners = null;
		}


		/** Dispatches an event to all objects that have registered listeners for its type. 
		 *  If an event with enabled 'bubble' property is dispatched to a display object, it will 
		 *  travel up along the line of parents, until it either hits the root object or someone
		 *  stops its propagation manually. */
		public function dispatchEvent(event:Event2D):void
		{
			var bubbles:Boolean = event.bubbles;

			if (!bubbles && (_eventListeners == null || !(event.type in _eventListeners)))
				return;
			// no need to do anything

			// we save the current target and restore it later;
			// this allows users to re-dispatch events without creating a clone.

			var previousTarget:EventDispatcher2D = event.target;
			event.setTarget(this);

			if (bubbles && this is DisplayObject2D) bubbleEvent(event);
			else invokeEvent(event);

			if (previousTarget) event.setTarget(previousTarget);
		}


		/** @private
		 *  Invokes an event on the current object. This method does not do any bubbling, nor
		 *  does it back-up and restore the previous target on the event. The 'dispatchEvent' 
		 *  method uses this method internally. */
		internal function invokeEvent(event:Event2D):Boolean
		{
			var listeners:Vector.<Function> = _eventListeners ? _eventListeners[event.type] as Vector.<Function> : null;
			var numListeners:int = listeners == null ? 0 : listeners.length;

			if (numListeners)
			{
				event.setCurrentTarget(this);

				// we can enumerate directly over the vector, because:
				// when somebody modifies the list while we're looping, "addEventListener" is not
				// problematic, and "removeEventListener" will create a new Vector, anyway.

				for (var i:int = 0; i < numListeners; ++i)
				{
					var listener:Function = listeners[i] as Function;
					var numArgs:int = listener.length;

					if (numArgs == 0) listener();
					else if (numArgs == 1) listener(event);
					else listener(event, event.data);

					if (event.stopsImmediatePropagation)
						return true;
				}

				return event.stopsPropagation;
			}
			else
			{
				return false;
			}
		}


		/** @private */
		internal function bubbleEvent(event:Event2D):void
		{
			// we determine the bubble chain before starting to invoke the listeners.
			// that way, changes done by the listeners won't affect the bubble chain.

			var chain:Vector.<EventDispatcher2D>;
			var element:DisplayObject2D = this as DisplayObject2D;
			var length:int = 1;

			if (_bubbleChains.length > 0)
			{
				chain = _bubbleChains.pop();
				chain[0] = element;
			}
			else chain = new <EventDispatcher2D>[element];

			while ((element = element.parent) != null)
				chain[int(length++)] = element;

			for (var i:int = 0; i < length; ++i)
			{
				var stopPropagation:Boolean = chain[i].invokeEvent(event);
				if (stopPropagation) break;
			}

			chain.length = 0;
			_bubbleChains.push(chain);
		}


		/** Dispatches an event with the given parameters to all objects that have registered 
		 *  listeners for the given type. The method uses an internal pool of event objects to 
		 *  avoid allocations. */
		public function dispatchEventWith(type:String, bubbles:Boolean = false, data:Object = null):void
		{
			if (bubbles || hasEventListener(type))
			{
				var event:Event2D = Event2D.fromPool(type, bubbles, data);
				dispatchEvent(event);
				Event2D.toPool(event);
			}
		}


		/** Returns if there are listeners registered for a certain event type. */
		public function hasEventListener(type:String):Boolean
		{
			var listeners:Vector.<Function> = _eventListeners ? _eventListeners[type] as Vector.<Function> : null;
			return listeners ? listeners.length != 0 : false;
		}
	}
}
