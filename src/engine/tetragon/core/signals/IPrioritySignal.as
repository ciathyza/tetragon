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
	public interface IPrioritySignal extends ISignal
	{
		/**
		 * Subscribes a listener for the signal. After you successfully register an event
		 * listener, you cannot change its priority through additional calls to add(). To
		 * change a listener's priority, you must first call remove(). Then you can
		 * register the listener again with the new priority level.
		 * 
		 * @param listener A function with an argument that matches the type of event
		 *            dispatched by the signal. If eventClass is not specified, the
		 *            listener and dispatch() can be called without an argument.
		 * @return a ISignalBinding, which contains the Function passed as the parameter
		 * @see ISignalBinding
		 */
		function addWithPriority(listener:Function, priority:int = 0):ISignalBinding
		
		
		/**
		 * Subscribes a one-time listener for this signal. The signal will remove the
		 * listener automatically the first time it is called, after the dispatch to all
		 * listeners is complete.
		 * 
		 * @param listener A function with an argument that matches the type of event
		 *            dispatched by the signal. If eventClass is not specified, the
		 *            listener and dispatch() can be called without an argument.
		 * @param priority The priority level of the event listener. The priority is
		 *            designated by a signed 32-bit integer. The higher the number, the
		 *            higher the priority. All listeners with priority n are processed
		 *            before listeners of priority n-1.
		 * @return a ISignalBinding, which contains the Function passed as the parameter
		 * @see ISignalBinding
		 */
		function addOnceWithPriority(listener:Function, priority:int = 0):ISignalBinding
	}
}
