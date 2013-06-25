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
	/**
	 * The SignalBinding class represents a signal binding.
	 */
	public final class SignalBinding implements ISignalBinding
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _signal:ISignal;
		private var _enabled:Boolean = true;
		private var _strict:Boolean = true;
		private var _listener:Function;
		private var _once:Boolean = false;
		private var _priority:int = 0;
		private var _params:Array;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates and returns a new SignalBinding object.
		 * 
		 * @param listener The listener associated with the binding.
		 * @param once Whether or not the listener should be executed only once.
		 * @param signal The signal associated with the binding.
		 * @param priority The priority of the binding.
		 * 
		 * @throws ArgumentError An error is thrown if the given listener closure is
		 *             <code>null</code>.
		 */
		public function SignalBinding(listener:Function, signal:ISignal, once:Boolean = false,
			priority:int = 0)
		{
			_listener = listener;
			_once = once;
			_signal = signal;
			_priority = priority;
			
			// Work out what the strict mode is from the signal and set it here. You can change
			// the value of strict mode on the binding itself at a later date.
			_strict = signal.strict;
			
			verifyListener(listener);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function execute(valueObjects:Array):void
		{
			if (!_enabled) return;
			if (_once) remove();

			// If we have parameters, add them to the valueObject
			// Note: This could be exensive if we're after the fastest dispatch possible.
			if (_params != null && _params.length > 0)
			{
				// Should there be any checking on the params against the listener?
				valueObjects = valueObjects.concat(_params);
			}
			
			if (_strict)
			{
				// Dispatch as normal
				var numValueObjects:uint = valueObjects.length;
				if (numValueObjects == 0)
				{
					_listener();
				}
				else if (numValueObjects == 1)
				{
					_listener(valueObjects[0]);
				}
				else if (numValueObjects == 2)
				{
					_listener(valueObjects[0], valueObjects[1]);
				}
				else if (numValueObjects == 3)
				{
					_listener(valueObjects[0], valueObjects[1], valueObjects[2]);
				}
				else
				{
					_listener.apply(null, valueObjects);
				}
			}
			else
			{
				// We're going to pass everything in one bulk run so that varargs can be
				// passed through to the listeners
				_listener.apply(null, valueObjects);
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function remove():void
		{
			_signal.remove(_listener);
		}
		
		
		/**
		 * Creates and returns the string representation of the current object.
		 *
		 * @return The string representation of the current object.
		 */
		public function toString():String
		{
			return "[SignalBinding listener: " + _listener + ", once: " + _once
				+ ", priority: " + _priority + ", enabled: " + _enabled + "]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function get listener():Function
		{
			return _listener;
		}
		public function set listener(v:Function):void
		{
			if (v == null)
			{
				Signal.fail("SignalBinding.set.listener", "Given listener is null. Did you want"
					+ " to set enabled to false instead?", ArgumentError);
			}
			verifyListener(v);
			_listener = v;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get once():Boolean
		{
			return _once;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get priority():int
		{
			return _priority;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get enabled():Boolean
		{
			return _enabled;
		}
		public function set enabled(v:Boolean):void
		{
			_enabled = v;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get strict():Boolean
		{
			return _strict;
		}
		public function set strict(v:Boolean):void
		{
			_strict = v;
			// Check that when we move from one strict mode to another strict mode and verify the
			// listener again.
			verifyListener(listener);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get params():Array
		{
			return _params;
		}
		public function set params(v:Array):void
		{
			_params = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function verifyListener(listener:Function):void
		{
			if (listener == null)
			{
				Signal.fail("SignalBinding.verifyListener", "The specified listener is null.",
					ArgumentError);
			}
			
			if (_signal == null)
			{
				Signal.fail("SignalBinding.verifyListener", "Internal signal reference has not"
					+ " been set yet.", Error);
			}
			
			const c:int = listener.length;
			if (_strict)
			{
				if (c < _signal.valueClasses.length)
				{
					Signal.fail("SignalBinding.verifyListener", "Listener has " + c
						+ " arguments but it needs to be " + _signal.valueClasses.length
						+ " to match the signal's value classes.", ArgumentError);
				}
			}
		}
	}
}
