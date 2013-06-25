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
	/**
	 * The ISignalBinding interface defines the basic properties of a listener associated
	 * with a Signal.
	 */
	public interface ISignalBinding
	{
		/**
		 * The listener associated with this binding.
		 */
		function get listener():Function;
		function set listener(v:Function):void;
		
		
		/**
		 * If the binding should use strict mode or not. Useful if you would like to use
		 * the ...rest argument or if you don't want an exact match up of listener arguments
		 * and signal arguments.
		 */
		function get strict():Boolean;
		function set strict(v:Boolean):void;
		
		
		/**
		 * Allows the ISignalBinding to inject parameters when dispatching. The params will
		 * be at the tail of the arguments and the ISignal arguments will be at the head
		 * follow.
		 * 
		 * @example
		 * <pre>
		 *    var signal:ISignal = new Signal(int, String);
		 *    signal.add(handler).params = [1];
		 *    signal.dispatch("a");
		 *    function handler(num:int, str:String):void {};
		 * </pre>
		 */
		function get params():Array;
		function set params(v:Array):void;
		
		
		/**
		 * Whether this binding is disposed after it has been used once.
		 */
		function get once():Boolean;
		
		
		/**
		 * The priority of this binding.
		 */
		function get priority():int;
		
		
		/**
		 * Whether the listener is called on execution. Defaults to true.
		 */
		function get enabled():Boolean;
		function set enabled(v:Boolean):void;
		
		
		/**
		 * Executes a listener of arity <code>n</code> where <code>n</code> is
		 * <code>valueObjects.length</code>.
		 *
		 * @param valueObjects The array of arguments to be applied to the listener.
		 */
		function execute(valueObjects:Array):void;
		
		
		/**
		 * Removes the binding from its signal.
		 */
		function remove():void;
	}
}
