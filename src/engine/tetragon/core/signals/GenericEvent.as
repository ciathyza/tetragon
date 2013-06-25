/*
 * hexagonlib - Multi-Purpose ActionScript 3 Library.
 *       __    __
 *    __/  \__/  \__    __
 *   /  \__/HEXAGON \__/  \
 *   \__/  \__/  LIBRARY _/
 *            \__/  \__/
 *
 * Licensed under the MIT License
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package tetragon.core.signals
{
	public class GenericEvent implements IEvent
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _bubbles:Boolean;
		protected var _target:Object;
		protected var _currentTarget:Object;
		protected var _signal:IPrioritySignal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function GenericEvent(bubbles:Boolean = false)
		{
			_bubbles = bubbles;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function clone():IEvent
		{
			return new GenericEvent(_bubbles);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function get signal():IPrioritySignal
		{
			return _signal;
		}
		public function set signal(v:IPrioritySignal):void
		{
			_signal = v;
		}


		/**
		 * @inheritDoc
		 */
		public function get target():Object
		{
			return _target;
		}
		public function set target(v:Object):void
		{
			_target = v;
		}


		/**
		 * @inheritDoc
		 */
		public function get currentTarget():Object
		{
			return _currentTarget;
		}
		public function set currentTarget(v:Object):void
		{
			_currentTarget = v;
		}


		/**
		 * @inheritDoc
		 */
		public function get bubbles():Boolean
		{
			return _bubbles;
		}
		public function set bubbles(v:Boolean):void
		{
			_bubbles = v;
		}
	}
}
