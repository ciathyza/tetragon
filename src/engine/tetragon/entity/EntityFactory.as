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
	import tetragon.ClassRegistry;
	import tetragon.Main;
	import tetragon.debug.Log;
	import tetragon.file.resource.Resource;
	import tetragon.file.resource.ResourceIndex;
	
	
	/**
	 * EntityFactory class
	 */
	public class EntityFactory
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _resourceIndex:ResourceIndex;
		/** @private */
		private var _classRegistry:ClassRegistry;
		/** @private */
		private var _entityManager:EntityManager;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function EntityFactory()
		{
			_classRegistry = Main.instance.classRegistry;
			_entityManager = Main.instance.entityManager;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates an entity from the entity template of the specified id.
		 * 
		 * @param resourceID The ID of the data resource from which to create an entity.
		 * @return An object of type IEntity or null.
		 */
		public function createEntity(resourceID:String):IEntity
		{
			var resource:Resource = resourceIndex.getResource(resourceID);
			if (!resource)
			{
				fail("Could not create entity. Resource with ID \"" + resourceID + "\" was null.");
				return null;
			}
			else if (!(resource.content is EntityDefinition))
			{
				fail("Could not create entity. Resource content is not of type EntityDefinition.");
				return null;
			}
			
			var e:IEntity = _entityManager.createEntity(resource.type, resource.content);
			if (!e) return null;
			
			var mappings:Object = EntityDefinition(resource.content).componentMappings;
			
			/* Create components in entity and assign properties to them from definition. */
			for (var classID:String in mappings)
			{
				var c:IEntityComponent = _classRegistry.createEntityComponent(classID);
				var m:Object = mappings[classID];
				for (var property:String in m)
				{
					// TODO Need to move generation of complex property types here from
					// EntityDataParser! Otherwise we might end up with components
					// sharing the same complex type instances.
					if (Object(c).hasOwnProperty(property))
					{
						c[property] = m[property];
					}
					else
					{
						Log.warn("Tried to set a non-existing property <" + property
							+ "> in component " + c.toString() + " for entity definition "
							+ EntityDefinition(resource.content).toString() + ".", this);
					}
				}
				e.addComponent(c);
			}
			
			return e;
		}
		
		
		/**
		 * Creates an entity from it's template class instead of a resource.
		 * Mainly used for testing!
		 */
//		public function createEntityFromClass(entityTemplateClass:Class, id:String, dataType:String):IEntity
//		{
//			var et:* = new entityTemplateClass(id);
//			
//			if (!(et is EntityDefinition))
//			{
//				fail("Could not create entity. Class is not of type EntityTemplate.");
//				return null;
//			}
//			
//			var e:IEntity = _entityManager.createEntity(dataType);
//			if (!e)
//			{
//				fail("Could not create entity. EntityManager.createEntity() returned null.");
//				return null;
//			}
//			
//			var mappings:Object = EntityDefinition(et).componentMappings;
//			
//			/* Create components on entity and assign properties to them. */
//			for (var classID:String in mappings)
//			{
//				var c:IEntityComponent = _dcFactory.createComponent(classID);
//				var m:Object = mappings[classID];
//				for (var property:String in m)
//				{
//					if (Object(c).hasOwnProperty(property))
//					{
//						c[property] = m[property];
//					}
//					else
//					{
//						Log.warn("Tried to set a non-existing property <" + property
//							+ "> in component " + c + " for template "
//							+ EntityDefinition(et).toString() + ".");
//					}
//				}
//			}
//			
//			return e;
//		}
		
		
		/**
		 * Returns a String representation of the class.
		 * 
		 * @return A String representation of the class.
		 */
		public function toString():String
		{
			return "EntityFactory";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Lazy getter.
		 */
		protected function get resourceIndex():ResourceIndex
		{
			if (!_resourceIndex) _resourceIndex = Main.instance.resourceManager.resourceIndex;
			return _resourceIndex;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function fail(message:String):void
		{
			Log.error(message, this);
		}
	}
}
