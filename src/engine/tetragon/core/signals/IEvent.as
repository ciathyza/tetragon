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
	public interface IEvent
	{
		/**
		 * The object that originally dispatched the event. When dispatched from an
		 * signal, the target is the object containing the signal.
		 */
		function get target():Object;
		function set target(v:Object):void;


		/**
		 * The object that added the listener for the event.
		 */
		function get currentTarget():Object;
		function set currentTarget(v:Object):void;


		/**
		 * The signal that dispatched the event.
		 */
		function get signal():IPrioritySignal;
		function set signal(v:IPrioritySignal):void;


		/**
		 * Indicates whether the event is a bubbling event.
		 */
		function get bubbles():Boolean;
		function set bubbles(v:Boolean):void;


		/**
		 * Returns a new copy of the instance.
		 */
		function clone():IEvent;
	}
}
