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
package tetragon.core.signals
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	
	/**
	 * The NativeSignal class provides a strongly-typed facade for an IEventDispatcher. A
	 * NativeSignal is essentially a mini-dispatcher locked to a specific event type and
	 * class. It can become part of an interface.
	 */
	public class NativeSignal implements INativeDispatcher
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _target:IEventDispatcher;
		protected var _eventType:String;
		protected var _eventClass:Class;
		protected var _valueClasses:Array;
		protected var _strict:Boolean = true;
		protected var _bindings:SignalBindingList;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a NativeSignal instance to dispatch events on behalf of a target
		 * object.
		 * 
		 * @param target The object on whose behalf the signal is dispatching events.
		 * @param eventType The type of Event permitted to be dispatched from this signal.
		 *            Corresponds to Event.type.
		 * @param eventClass An optional class reference that enables an event type check
		 *            in dispatch(). Defaults to flash.events.Event if omitted.
		 */
		public function NativeSignal(target:IEventDispatcher = null, eventType:String = "",
			eventClass:Class = null)
		{
			_bindings = SignalBindingList.NIL;
			this.target = target;
			this.eventType = eventType;
			this.eventClass = eventClass;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function add(listener:Function):ISignalBinding
		{
			return addWithPriority(listener);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function addWithPriority(listener:Function, priority:int = 0):ISignalBinding
		{
			return registerListenerWithPriority(listener, false, priority);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function addOnce(listener:Function):ISignalBinding
		{
			return addOnceWithPriority(listener);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function addOnceWithPriority(listener:Function, priority:int = 0):ISignalBinding
		{
			return registerListenerWithPriority(listener, true, priority);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function remove(listener:Function):ISignalBinding
		{
			const binding:ISignalBinding = _bindings.find(listener);
			if (!binding) return null;
			_bindings = _bindings.filterNot(listener);

			if (!_bindings.nonEmpty)
				target.removeEventListener(eventType, onNativeEvent);

			return binding;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function removeAll():void
		{
			if (target) target.removeEventListener(eventType, onNativeEvent);
			_bindings = SignalBindingList.NIL;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function dispatch(...valueObjects):void
		{
			// TODO: check if ...valueObjects can ever be null.
			if (null == valueObjects) throw new ArgumentError('Event object expected.');

			if (valueObjects.length != 1) throw new ArgumentError('No more than one Event object expected.');

			dispatchEvent(valueObjects[0] as Event);
		}
		
		
		/**
		 * Unlike other signals, NativeSignal does not dispatch null
		 * because it causes an exception in EventDispatcher.
		 * @inheritDoc
		 */
		public function dispatchEvent(event:Event):Boolean
		{
			if (!target) throw new ArgumentError('Target object cannot be null.');
			if (!event) throw new ArgumentError('Event object cannot be null.');

			if (!(event is eventClass))
				throw new ArgumentError('Event object ' + event + ' is not an instance of ' + eventClass + '.');

			if (event.type != eventType)
				throw new ArgumentError('Event object has incorrect type. Expected <' + eventType + '> but was <' + event.type + '>.');

			return target.dispatchEvent(event);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function get eventType():String
		{
			return _eventType;
		}
		public function set eventType(value:String):void
		{
			_eventType = value;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get eventClass():Class
		{
			return _eventClass;
		}
		public function set eventClass(value:Class):void
		{
			_eventClass = value || Event;
			_valueClasses = [_eventClass];
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get valueClasses():Array
		{
			return _valueClasses;
		}
		public function set valueClasses(value:Array):void
		{
			eventClass = value && value.length > 0 ? value[0] : null;
		}


		/**
		 * @inheritDoc
		 */
		public function get strict():Boolean
		{
			return _strict;
		}
		public function set strict(value:Boolean):void
		{
			_strict = value;
		}


		/**
		 * @inheritDoc
		 */
		public function get numListeners():uint
		{
			return _bindings.length;
		}


		/**
		 * @inheritDoc
		 */
		public function get target():IEventDispatcher
		{
			return _target;
		}


		/**
		 * @inheritDoc
		 */
		public function set target(value:IEventDispatcher):void
		{
			if (value == _target) return;
			if (_target) removeAll();
			_target = value;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function registerListenerWithPriority(listener:Function, once:Boolean = false,
			priority:int = 0):ISignalBinding
		{
			if (!target) throw new ArgumentError('Target object cannot be null.');

			if (_strict && listener.length != 1)
				throw new ArgumentError('Listener for native event must declare exactly 1 argument but had ' + listener.length + '.');

			if (isRegistrationPossible(listener, once))
			{
				const binding:ISignalBinding = new SignalBinding(listener, this, once, priority);
				if (!_bindings.nonEmpty)
					target.addEventListener(eventType, onNativeEvent, false, priority);
				_bindings = _bindings.insertWithPriority(binding);
				return binding;
			}

			return _bindings.find(listener);
		}
		
		
		/**
		 * @private
		 */
		protected function isRegistrationPossible(listener:Function, once:Boolean):Boolean
		{
			if (!_bindings.nonEmpty) return true;

			const existingBinding:ISignalBinding = _bindings.find(listener);
			if (existingBinding)
			{
				if (existingBinding.once != once)
				{
					// If the listener was previously added, definitely don't add it again.
					// But throw an exception if their once value differs.
					throw new IllegalOperationError('You cannot addOnce() then add() the same listener without removing the relationship first.');
				}
				// Listener was already added.
				return false;
			}
			// This listener has not been added before.
			return true;
		}
		
		
		/**
		 * @private
		 */
		protected function onNativeEvent(event:Event):void
		{
			// TODO: We could in theory just cache this array, so that we're not hitting the gc
			// every time we call onNativeEvent
			const singleValue:Array = [event];
			var bindingsToProcess:SignalBindingList = _bindings;
			while (bindingsToProcess.nonEmpty)
			{
				bindingsToProcess.head.execute(singleValue);
				bindingsToProcess = bindingsToProcess.tail;
			}
		}
	}
}
