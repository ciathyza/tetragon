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
	
	
	/**
	 * An entity family is a collection used to group entities by the set of entity
	 * components they are possessing. A new family is created for every combination of
	 * entity components that occur in all entities.
	 */
	public class EntityFamily
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Used to provide an unique ID for every unique entity family. Everytime a new
		 * family is mapped via the EntityManager this counter is increased.
		 * @private
		 */
		internal static var idCounter:uint = 0;
		
		/** @private */
		private var _id:String;
		/** @private */
		private var _signature:String;
		/** @private */
		private var _entities:Vector.<IEntity>;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param componentSignature The component signature of the entity family.
		 */
		public function EntityFamily(signature:String)
		{
			_signature = signature;
			_id = "family" + idCounter;
			_entities = new Vector.<IEntity>();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds an entity to the family.
		 */
		public function addEntity(entity:IEntity):void
		{
			_entities.push(entity);
		}
		
		
		/**
		 * Generates and returns an ID string that is used to identify the entity family
		 * that is associated to all the components of component classes that are mapped
		 * in componentMappings.
		 * 
		 * @param componentMappings An object or an array with entity component class objects.
		 * @return An ID string.
		 */
		public static function getComponentSignatureFor(componentMappings:Object):String
		{
			var main:Main = Main.instance;
			var sortArray:Array = [];
			var signature:String = "";
			var clazz:Class;
			var isArray:Boolean = componentMappings is Array;
			
			for (var s:String in componentMappings)
			{
				if (isArray) clazz = componentMappings[int(s)];
				else clazz = main.classRegistry.getEntityComponentClass(s);
				
				if (clazz)
				{
					var cs:String = String(clazz);
					if (cs && cs.indexOf("[class ") != -1) cs = cs.substr(7, cs.length - 8);
					sortArray.push(cs);
				}
			}
			if (sortArray.length < 1) return null;
			sortArray.sort();
			var len:uint = sortArray.length;
			for (var i:uint = 0; i < len; i++)
			{
				signature += sortArray[i];
				if (i < len - 1) signature += "-";
			}
			return signature;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The unique ID of the entity family.
		 */
		public function get id():String
		{
			return _id;
		}
		
		
		/**
		 * The component signature of the entity family.
		 */		
		public function get signature():String
		{
			return _signature;
		}
		
		
		/**
		 * A vector of all entities in the family.
		 */
		public function get entities():Vector.<IEntity>
		{
			return _entities;
		}
		
		
		/**
		 * The number of entities in the family.
		 */
		public function get entityCount():uint
		{
			if (!_entities) return 0;
			return _entities.length;
		}
	}
}
