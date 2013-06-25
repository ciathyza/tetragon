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
	import tetragon.debug.Log;

	import flash.utils.Dictionary;
	
	
	/**
	 * Responsible for registering and unregistering systems in the entity architecture.
	 */
	public class EntitySystemManager implements IDisposable
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _systems:Dictionary;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function EntitySystemManager()
		{
			_systems = new Dictionary();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Registers a system.
		 */
		public function registerSystem(systemClass:Class):IEntitySystem
		{
			if (_systems[systemClass])
			{
				Log.warn("System " + systemClass + " already exists in entity system manager.", this);
				return null;
			}
			
			var s:IEntitySystem = new systemClass();
			s.entityFamilySignature = EntityFamily.getComponentSignatureFor(s.componentClasses);
			var cc:Array = s.componentClasses;
			_systems[systemClass] = s;
			s.register();
			return s;
		}
		
		
		/**
		 * Unregisters a system.
		 */
		public function unregisterSystem(system:Class):void
		{
			if (!_systems[system])
			{
				Log.warn("System " + system + " doesn't exist in entity system manager.", this);
				return;
			}
			
			IDisposable(_systems[system]).dispose();
			delete _systems[system];
		}
		
		
		/**
		 * Returns a specific system.
		 */
		public function getSystem(systemClass:Class):IEntitySystem
		{
			return _systems[systemClass];
		}
		
		
		/**
		 * Starts all systems.
		 */
		public function start():void
		{
			for each (var s:IEntitySystem in _systems)
			{
				Log.debug("Starting " + s.toString() + " ...", this);
				s.start();
			}
		}
		
		
		/**
		 * Stops all systems.
		 */
		public function stop():void
		{
			for each (var s:IEntitySystem in _systems)
			{
				s.stop();
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			for each (var s:IEntitySystem in _systems)
			{
				s.dispose();
			}
			_systems = new Dictionary();
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "EntitySystemManager";
		}
	}
}
