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
package tetragon.entity
{
	import tetragon.core.types.IDisposable;
	
	
	/**
	 * The base interface for Entity Systems.
	 * 
	 * <p>An entity system is a class that executes the logic that is applied to entities
	 * through their components. A system contains the dedicated implementation logic
	 * for a specific entity component or for a specific group of entity components
	 * (identified by entity families). Entity systems provide the methods that act
	 * upon entity components which on the other hand don't contain any methods but
	 * only properties.</p>
	 * 
	 * <p>Each System runs continuously after it is started (as though each System had it’s own
	 * private thread) and performs global actions on every Entity that possesses a Component
	 * of the same aspect as that System.</p>
	 * 
	 * <p>Typical Entity Systems in a game would be: Rendering System, Animation System, Input
	 * System, etc.</p>
	 */
	public interface IEntitySystem extends IDisposable
	{
		/**
		 * Automatically called by the entity system manager when a system is registered.
		 */
		function register():void;
		
		
		/**
		 * Starts the system.
		 * Automatically called by the entity system manager when a system is started.
		 */
		function start():void;
		
		
		/**
		 * Stops the system.
		 * Automatically called by the entity system manager when a system is stopped.
		 */
		function stop():void;
		
		
		function toString():String;
		
		
		/**
		 * An array of all entity component classes that are being affected by this
		 * entity system.
		 */
		function get componentClasses():Array;
		
		
		function get entityFamilySignature():String;
		function set entityFamilySignature(v:String):void;
	}
}
