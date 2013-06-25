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
	public class DeluxeSignal extends Signal implements IPrioritySignal
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _target:Object;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a DeluxeSignal instance to dispatch events on behalf of a target
		 * object.
		 * 
		 * @param target The object the signal is dispatching events on behalf of.
		 * @param valueClasses Any number of class references that enable type checks in
		 *            dispatch(). For example, new DeluxeSignal(this, String, uint) would
		 *            allow: signal.dispatch("the Answer", 42) but not:
		 *            signal.dispatch(true, 42.5) nor: signal.dispatch()
		 * 
		 *            NOTE: Subclasses cannot call super.apply(null, valueClasses), but
		 *            this constructor has logic to support super(valueClasses).
		 */
		public function DeluxeSignal(target:Object = null, ...valueClasses)
		{
			_target = target;
			
			// Cannot use super.apply(null, valueClasses), so allow the subclass to
			// call super(valueClasses).
			valueClasses = (valueClasses.length == 1 && valueClasses[0] is Array)
				? valueClasses[0] : valueClasses;
			super(valueClasses);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function add(listener:Function):ISignalBinding
		{
			return addWithPriority(listener);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function addOnce(listener:Function):ISignalBinding
		{
			return addOnceWithPriority(listener);
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
		public function addOnceWithPriority(listener:Function, priority:int = 0):ISignalBinding
		{
			return registerListenerWithPriority(listener, true, priority);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispatch(...valueObjects):void
		{
			// Validate value objects against pre-defined value classes.
			var vo:Object;
			var vc:Class;
			const numVC:uint = _valueClasses.length;
			const numVO:uint = valueObjects.length;
			
			if (numVO < numVC)
			{
				fail("DeluxeSignal.dispatch", "Incorrect number of arguments. Expected at least "
					+ numVC + " but received " + numVO + ".", ArgumentError);
			}
			
			for (var i:uint = 0; i < numVC; i++)
			{
				vo = valueObjects[i];
				vc = _valueClasses[i];
				if (vo === null || vo is vc) continue;
				fail("DeluxeSignal.dispatch", "Value object <" + vo + "> is not an instance of <"
					+ vc + ">!", ArgumentError);
			}
			
			// Extract and clone event object if necessary.
			var e:IEvent = valueObjects[0];
			if (e)
			{
				if (e.target)
				{
					e = e.clone();
					valueObjects[0] = e;
				}
				
				e.target = target;
				e.currentTarget = target;
				e.signal = this;
			}
			
			// Broadcast to listeners.
			var bindingsToProcess:SignalBindingList = _bindings;
			while (bindingsToProcess.nonEmpty)
			{
				bindingsToProcess.head.execute(valueObjects);
				bindingsToProcess = bindingsToProcess.tail;
			}
			
			// Bubble the event as far as possible.
			if (!e || !e.bubbles) return;
			var currentTarget:Object = target;
			
			while (currentTarget && currentTarget.hasOwnProperty("parent") && (currentTarget == currentTarget["parent"]))
			{
				if (currentTarget is IBubbleEventHandler)
				{
					// onEventBubbled() can stop the bubbling by returning false.
					if (!IBubbleEventHandler(e.currentTarget = currentTarget).onEventBubbled(e))
						break;
				}
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		public function get target():Object
		{
			return _target;
		}
		public function set target(v:Object):void
		{
			if (v == _target) return;
			removeAll();
			_target = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function registerListener(listener:Function, once:Boolean = false):ISignalBinding
		{
			return registerListenerWithPriority(listener, once);
		}
		
		
		/**
		 * @private
		 */
		protected function registerListenerWithPriority(listener:Function, once:Boolean = false, priority:int = 0):ISignalBinding
		{
			if (isRegistrationPossible(listener, once))
			{
				const binding:ISignalBinding = new SignalBinding(listener, this, once, priority);
				_bindings = _bindings.insertWithPriority(binding);
				return binding;
			}
			return _bindings.find(listener);
		}
	}
}
