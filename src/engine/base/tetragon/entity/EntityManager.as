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
	import tetragon.debug.Log;

	import com.hexagonstar.util.string.TabularText;

	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	
	/**
	 * Manages the relations between components and entites and keeps entity families
	 * up to date.
	 */
	public class EntityManager
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Maps objects of type Dictionary, mapped by entityID which in turn contain
		 * objects of type IEntityComponent, mapped by their componentClass, e.g.
		 * 
		 * _components[entityID] = Dictionary[componentClass] = IEntityComponent
		 * 
		 * @private
		 */
		private var _components:Object;
		
		/** @private */
		private var _families:Object;
		/** @private */
		private var _entityIDCount:uint;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function EntityManager()
		{
			_components = {};
			_families = {};
			_entityIDCount = 0;
			Entity.entityManager = this;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Maps an entity family in the entity manager.
		 * 
		 * @param entityFamily
		 */
		public function mapEntityFamily(entityFamily:EntityFamily):void
		{
			if (_families[entityFamily.signature]) return;
			Log.debug("Mapping entity family with signature \"" + entityFamily.signature + "\" ...", this);
			_families[entityFamily.signature] = entityFamily;
			EntityFamily.idCounter++;
		}
		
		
		/**
		 * Creates a new entity with the ID provided. If no ID is provided a unique ID will
		 * be auto-generated. If an ID is provided but the entityManager already has an entity
		 * with the same ID, no entity will be created and <code>null</code> is returned.
		 * 
		 * @param type
		 * @param entityDefinition
		 * @param entityID Optional ID of the new created entity.
		 * @return The new entity or <code>null</code>.
		 */
		public function createEntity(type:String, entityDefinition:EntityDefinition,
			entityID:String = null):IEntity
		{
			if (!entityID || entityID == "")
			{
				_entityIDCount++;
				entityID = "entity" + _entityIDCount;
			}
			else if (_components[entityID])
			{
				Log.warn("Tried to create an entity whose ID already exists.", this);
				return null;
			}
			
			var entity:IEntity = new Entity(entityID, type, entityDefinition);
			_components[entityID] = new Dictionary();
			var family:EntityFamily = _families[entityDefinition.familySignature];
			family.addEntity(entity);
			return entity;
		}
		
		
		/**
		 * Determines whether the entity manager has an entity mapped with the specified ID.
		 * 
		 * @param entityID The ID to check.
		 * @return true if an entity with the provided ID exists.
		 */
		public function hasEntity(entityID:String):Boolean
		{
			return _components[entityID] != null;
		}
		
		
		/**
		 * Removes an entity from the entity manager.
		 * 
		 * @param entityID ID of entity to remove.
		 */
		public function removeEntity(entityID:String):void
		{
		}
		
		
		/**
		 * Removes all entities and resets the entity manager.
		 */
		public function removeAll():void
		{
		}
		
		
		/**
		 * Registers a component with an entity.
		 * 
		 * @param entityID ID of the entity the component is to be registered with.
		 * @param component Component to be registered.
		 * @return true if the component was added, false if not.
		 */
		public function addComponent(entityID:String, component:IEntityComponent):Boolean
		{
			var componentClass:Class = getClass(component);
			if (!hasEntity(entityID))
			{
				return false;
			}
			_components[entityID][componentClass] = component;
			return true;
		}
		
		
		/**
		 * Retrieves a component.
		 *  
		 * @param entityID the ID that the component is registered with.
		 * @param componentClass Component to be retrieved.
		 * @return component.
		 */
		public function getComponent(entityID:String, componentClass:Class):IEntityComponent
		{
			var entityComponents:Dictionary = _components[entityID];
			if (!entityComponents)
			{
				Log.error("Entity with ID \"" + entityID + "\" not found in entity manager.", this);
				return null;
			}
			return entityComponents[componentClass];
		}
		
		
		/**
		 * Retrieves all of an entities components.
		 *  
		 * @param id Entity ID the components are registered with.
		 * @return a dictionary of the entites components with the component Class as the key.
		 */
		public function getComponents(entityID:String):Dictionary
		{
			var entityComponents:Dictionary = _components[entityID];
			if (!entityComponents)
			{
				Log.error("Entity with ID \"" + entityID + "\" not found in entity manager.", this);
			}
			return entityComponents;
		}
		
		
		/**
		 * Unregisters a component from an entity.
		 *  
		 * @param entityID Entity ID the component is registered with.
		 * @param componentClass to be unregistered.
		 */
		public function removeComponent(entityID:String, componentClass:Class):void
		{
			delete _components[entityID][componentClass];
		}
		
		
		/**
		 * Returns a vector of all entities that are part of the entity family with
		 * the specified familyID or null if no family with that ID exists.
		 * 
		 * @param familySignature
		 * @return A vector of type IEntity or null.
		 */
		public function getEntitiesOfFamily(familySignature:String):Vector.<IEntity>
		{
			var family:EntityFamily = _families[familySignature];
			if (family) return family.entities;
			return null;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "EntityManager";
		}
		
		
		/**
		 * Returns a string dump of all mapped entities.
		 */
		public function dumpEntities():String
		{
			var count:uint = 0;
			var t:TabularText = new TabularText(4, true, "  ", null, "  ", 0, ["ID",
				"DEF.ID", "COMP.COUNT", "FAMILY.ID"]);
			for each (var f:EntityFamily in _families)
			{
				for each (var e:IEntity in f.entities)
				{
					t.add([e.id, e.definition.id, e.definition.componentCount, f.id]);
					count++;
				}
			}
			return toString() + ": Entities (" + count + ")\n" + t;
		}
		
		
		/**
		 * Returns a string dump of all mapped entity families.
		 */
		public function dumpEntityFamilies():String
		{
			var count:uint = 0;
			var t:TabularText = new TabularText(3, true, "  ", null, "  ", 0, ["ID", "SIGNATURE",
				"ENTITY.COUNT"]);
			for each (var f:EntityFamily in _families)
			{
				t.add([f.id, f.signature, f.entityCount]);
				count++;
			}
			return toString() + ": Entity Families (" + count + ")\n" + t;
		}
		
		
		/**
		 * Returns a string dump of all currently mapped entity components.
		 */
		public function dumpEntityComponents():String
		{
			var count:uint = 0;
			var t:TabularText = new TabularText(3, true, "  ", null, "  ", 0, ["ID", "CLASS",
				"ENTITY.ID"]);
			for (var id:String in _components)
			{
				var d:Dictionary = _components[id];
				for (var clazz:* in d)
				{
					var c:IEntityComponent = d[clazz];
					if (c)
					{
						t.add([c.id, clazz, id]);
						count++;
					}
				}
			}
			return toString() + ": Entity Components (" + count + ")\n" + t;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Gets class definition from instance.
		 */
		private function getClass(obj:Object):Class
		{
			return Class(getDefinitionByName(getQualifiedClassName(obj)));
		}
	}
}
