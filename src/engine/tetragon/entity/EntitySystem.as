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
	import tetragon.Main;
	import tetragon.systems.gl.RenderSignal;
	import tetragon.systems.gl.TickSignal;
	import tetragon.util.reflection.getClassName;
	
	
	/**
	 * Abstract entity system base class. Any entity system should extends this class.
	 */
	public class EntitySystem
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _main:Main;
		/** @private */
		private var _tickSignal:TickSignal;
		/** @private */
		private var _renderSignal:RenderSignal;
		/** @private */
		private var _entities:Vector.<IEntity>;
		/** @private */
		private var _entityFamilySignature:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function EntitySystem()
		{
			_main = Main.instance;
			_tickSignal = _main.gameLoop.tickSignal;
			_renderSignal = _main.gameLoop.renderSignal;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function toString():String
		{
			return getClassName(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Reference to main for use in system subclasses.
		 */
		protected function get main():Main
		{
			return _main;
		}
		
		
		/**
		 * Reference to tick signal for use in system subclasses.
		 */
		public function get tickSignal():TickSignal
		{
			return _tickSignal;
		}
		
		
		/**
		 * Reference to render signal for use in system subclasses.
		 */
		public function get renderSignal():RenderSignal
		{
			return _renderSignal;
		}
		
		
		/**
		 * An array of all entity component classes that are being affected by this
		 * entity system.
		 * 
		 * <p>This is an abstract accessor! Override this getter in your entity system
		 * subclass and return an array that contains all class objects of entity
		 * components that are being affected by this system. The order of the classes
		 * in the array is not important.</p>
		 */
		public function get componentClasses():Array
		{
			return null;
		}
		
		
		/**
		 * The signature of the entity family that is associated with this entity system.
		 * Treat as read-only! This property is set automatically after the entity system is
		 * created.
		 */
		public function get entityFamilySignature():String
		{
			return _entityFamilySignature;
		}
		public function set entityFamilySignature(v:String):void
		{
			_entityFamilySignature = v;
		}
		
		
		/**
		 * A vector of all entities that are being affected by this system.
		 */
		protected function get entities():Vector.<IEntity>
		{
			return _entities;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Obtains all entities that are affected by this system depending on their
		 * entity family (i.e their set of components).
		 */
		protected function obtainEntities():void
		{
			_entities = main.entityManager.getEntitiesOfFamily(entityFamilySignature);
		}
	}
}
