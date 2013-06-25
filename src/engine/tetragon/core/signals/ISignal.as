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
 * Copyright (c) 2007-2008 Sascha Balkau / Hexagon Star Softworks
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
	public interface ISignal
	{
		/**
		 * Subscribes a listener for the signal.
		 * 
		 * @param listener A function with arguments that matches the value classes
		 *            dispatched by the signal. If value classes are not specified (e.g.
		 *            via Signal constructor), dispatch() can be called without arguments.
		 * @return A ISignalBinding, which contains the Function passed as the parameter.
		 */
		function add(listener:Function):ISignalBinding;
		
		
		/**
		 * Subscribes a one-time listener for this signal. The signal will remove the
		 * listener automatically the first time it is called, after the dispatch to all
		 * listeners is complete.
		 * 
		 * @param listener A function with arguments that matches the value classes
		 *            dispatched by the signal. If value classes are not specified (e.g.
		 *            via Signal constructor), dispatch() can be called without arguments.
		 * @return A ISignalBinding, which contains the Function passed as the parameter.
		 */
		function addOnce(listener:Function):ISignalBinding;
		
		
		/**
		 * Unsubscribes a listener from the signal.
		 * 
		 * @param listener to unsubscribe.
		 * @return A ISignalBinding, which contains the Function passed as the parameter.
		 */
		function remove(listener:Function):ISignalBinding;
		
		
		/**
		 * Unsubscribes all listeners from the signal.
		 */
		function removeAll():void
		
		
		/**
		 * Dispatches an object to listeners.
		 * 
		 * @param valueObjects Any number of parameters to send to listeners. Will be
		 *        type-checked against valueClasses.
		 * @throws ArgumentError <code>ArgumentError</code>: valueObjects are not compatible
		 *         with valueClasses.
		 */
		function dispatch(...valueObjects):void;
		
		
		/**
		 * An optional array of classes defining the types of parameters sent to listeners.
		 */
		function get valueClasses():Array;
		function set valueClasses(v:Array):void;
		
		
		/**
		 * If the ISignal should use strict mode or not. Useful if you would like to use
		 * the ...rest argument or if you don't want an exact match up of listener arguments
		 * and signal arguments.
		 */
		function get strict():Boolean;
		function set strict(v:Boolean):void;
		
		
		/**
		 * The current number of listeners for the signal.
		 */
		function get numListeners():uint;
	}
}
