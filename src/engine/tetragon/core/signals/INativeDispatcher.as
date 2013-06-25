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
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	/**
	 * Similar to IDispatcher but using strong types specific to Flash's native event system.
	 */
	public interface INativeDispatcher extends IPrioritySignal
	{
		/**
		 * The type of event permitted to be dispatched. Corresponds to flash.events.Event.type.
		 */
		function get eventType():String;
		
		
		/**
		 * The class of event permitted to be dispatched. Will be flash.events.Event or a subclass.
		 */
		function get eventClass():Class;
		
		
		/**
		 * The object considered the source of the dispatched events.
		 */
		function get target():IEventDispatcher;
		function set target(v:IEventDispatcher):void;
		
		
		/**
		 * Dispatches an event to listeners.
		 * 
		 * @param event An instance of a class that is or extends flash.events.Event.
		 * @throws ArgumentError <code>ArgumentError</code>: Event object is
		 *             <code>null</code>.
		 * @throws ArgumentError <code>ArgumentError</code>: Event object [event] is not
		 *             an instance of [eventClass].
		 * @throws ArgumentError <code>ArgumentError</code>: Event object has incorrect
		 *             type. Expected [eventType] but was [event.type].
		 */
		function dispatchEvent(event:Event):Boolean;
	}
}
