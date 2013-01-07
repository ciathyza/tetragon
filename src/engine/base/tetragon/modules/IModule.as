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
package tetragon.modules
{
	
	
	/**
	 * Interface that should be implemented by any Tetragon Module class.
	 */
	public interface IModule
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initializes the module.
		 */
		function init():void;
		
		
		/**
		 * Starts the module.
		 */
		function start():void;
		
		
		/**
		 * Stops the module.
		 */
		function stop():void;
		
		
		/**
		 * Disposes the module.
		 */
		function dispose():void;
		
		
		/**
		 * Returns a String representation of the class.
		 * 
		 * @return A String representation of the class.
		 */
		function toString():String;
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Unique ID of the module. Automatically set when registering module classes.
		 * Treat as read-only! Can only be set once!
		 */
		function get id():String;
		function set id(v:String):void;
		
		
		/**
		 * Used internally to prioritize in which order module classes are initlialized.
		 * @private
		 */
		function get priority():int;
		function set priority(v:int):void;
		
		
		/**
		 * Used to set/get an object with optional init params.
		 */
		function get initParams():Object;
		function set initParams(v:Object):void;
		
		
		/**
		 * Determines wether the module will be automatically started (i.e. it's start
		 * method called) after the module is created by the ModuleManager. This happens
		 * right after all modules have been registered. If a module returns false for
		 * autoStart, it's start method has to be called manually before it can be used,
		 * or it should be started via the ModuleManager later.
		 * 
		 * <p>To disable auto-start of your module override this getter and have
		 * it return false instead.</p>
		 * 
		 * @default true
		 */
		function get autoStart():Boolean;
		
		
		/**
		 * Determines whether the module has been started and is running.
		 */
		function get started():Boolean;
		function set started(v:Boolean):void;
		
		
		/**
		 * The info object of the tetragon module, or null ifd the module has no dedicated
		 * info class.
		 */
		function get moduleInfo():IModuleInfo;
	}
}
