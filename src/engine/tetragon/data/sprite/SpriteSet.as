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
package tetragon.data.sprite
{
	import tetragon.data.DataObject;
	
	
	/**
	 * A SpriteSet is a set of one or more defined sprites 
	 */
	public class SpriteSet extends DataObject
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const SPRITE_SET:String = "SpriteSet";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _spriteSheetID:String;
		private var _spriteSheet:SpriteSheet;
		private var _propertyDefinitions:Object;
		private var _globalProperties:Object;
		private var _sprites:Object;
		private var _spriteCount:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function SpriteSet(id:String)
		{
			_id = id;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function getPropertyDefinition(id:String):SpritePropertyDefinition
		{
			if (!_propertyDefinitions) return null;
			return _propertyDefinitions[id];
		}
		
		
		/**
		 * Returns an array with all sprites that posses a property named by the
		 * specified propertyKey.
		 * 
		 * @param propertyKey
		 * @return An array with SpriteObject objects.
		 */
		public function getSpritesWithProperty(propertyKey:String):Array
		{
			var a:Array = [];
			for each (var s:SpriteObject in _sprites)
			{
				if (s.properties.hasOwnProperty(propertyKey))
				{
					a.push(s);
				}
			}
			return a;
		}
		
		
		/**
		 * Returns an array with all sprites that posses a property named by the
		 * specified propertyKey and where that property's value equals the specified
		 * propertyValue.
		 * 
		 * @param propertyKey
		 * @param propertyValue
		 * @return An array with SpriteObject objects.
		 */
		public function getSpritesWithPropertyValue(propertyKey:String, propertyValue:*):Array
		{
			var sprites:Array = getSpritesWithProperty(propertyKey);
			var a:Array = [];
			for each (var s:SpriteObject in sprites)
			{
				var sp:SpriteProperty = s.properties[propertyKey];
				if (sp.value == propertyValue)
				{
					a.push(s);
				}
			}
			return a;
		}
		
		
		/**
		 * Creates a SpritePropertyMappings that contains all sprites, that posses the specified
		 * propertyKey, stored into arrays and those arrays mapped by any of the propertyKey
		 * property's values.
		 * 
		 * @param propertyKey
		 * @return A SpritePropertyMappings object.
		 */
		public function generateSpritePropertyMappings(propertyKey:String):SpritePropertyMappings
		{
			var sprites:Array = getSpritesWithProperty(propertyKey);
			var map:Object = {};
			for each (var s:SpriteObject in sprites)
			{
				var sp:SpriteProperty = s.properties[propertyKey];
				var mappingID:String = sp.value;
				if (mappingID == null) continue;
				
				var a:Vector.<SpriteObject> = map[mappingID];
				if (!a)
				{
					a = new Vector.<SpriteObject>();
					map[mappingID] = a;
				}
				
				a.push(s);
			}
			return new SpritePropertyMappings(map);
		}
		
		
		/**
		 * Returns the value of a specific sprite's property.
		 * 
		 * @param spriteID
		 * @param propertyKey
		 * @return The property value or null.
		 */
		public function getPropertyValueOf(spriteID:String, propertyKey:String):*
		{
			var s:SpriteObject = _sprites[spriteID];
			if (!s) return null;
			var sp:SpriteProperty = s.properties[propertyKey];
			if (!sp) return null;
			return sp.value;
		}
		
		
		/**
		 * Returns a sorted array of all property definitions.
		 */
		public function definitionsToArray():Array
		{
			var a:Array = [];
			for each (var pd:SpritePropertyDefinition in _propertyDefinitions)
			{
				a.push(pd);
			}
			a.sortOn("id", Array.CASEINSENSITIVE);
			return a;
		}
		
		
		/**
		 * Returns a sorted array of all global properties.
		 */
		public function globalPropertiesToArray():Array
		{
			var a:Array = [];
			for each (var sp:SpriteProperty in _globalProperties)
			{
				a.push(sp);
			}
			a.sortOn("id", Array.CASEINSENSITIVE);
			return a;
		}
		
		
		/**
		 * Returns a sorted array of all sprite objects.
		 */
		public function spritesToArray():Array
		{
			var a:Array = [];
			for each (var so:SpriteObject in _sprites)
			{
				a.push(so);
			}
			a.sortOn("id", Array.CASEINSENSITIVE);
			return a;
		}
		
		
		override public function toString(...args):String
		{
			return super.toString("id=" + _id, "sprites=" + _spriteCount);
		}
		
		
		public function dump():String
		{
			var a:Array;
			var i:int;
			var s:String = "\n" + toString() + "\n\tspriteSheet: " + _spriteSheet
				+ "\n\tProperty Definitions:";
			a = definitionsToArray();
			for (i = 0; i < a.length; i++)
			{
				var p:SpritePropertyDefinition = a[i];
				s += "\n\t\t[" + p.id + "] name: " + p.name + ", defaultValue: " + p.defaultValue;
			}
			s += "\n\tGlobal Properties:";
			a = globalPropertiesToArray();
			for (i = 0; i < a.length; i++)
			{
				var p2:SpriteProperty = a[i];
				s += "\n\t\t" + p2.id + ": " + p2.value;
			}
			s += "\n\tSprites:";
			a = spritesToArray();
			for (i = 0; i < a.length; i++)
			{
				var so:SpriteObject = a[i];
				s += "\n\t\t[" + so.id + "] spriteSheetID: " + so.spriteSheetID + ", sequences: "
					+ so.sequenceCount;
				s += "\n\t\t\tproperties:";
				for each (var sp:SpriteProperty in so.properties)
				{
					s += "\n\t\t\t\t" + sp.id + ": " + sp.value;
				}
				s += "\n\t\t\tsequences:";
				for each (var sq:SpriteSequence in so.sequences)
				{
					s += "\n\t\t\t\t[" + sq.id + "] length: " + sq.length;
					//	+ "\n\t\t\t\t\tloops: " + sq.loops
					//	+ "\n\t\t\t\t\tplayMode: " + sq.playMode
					//	+ "\n\t\t\t\t\tfollowSequence: " + sq.followSequence
					//	+ "\n\t\t\t\t\tfollowDelay: " + sq.followDelay;
				}
			}
			
			return s;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get spriteSheetID():String
		{
			return _spriteSheetID;
		}
		public function set spriteSheetID(v:String):void
		{
			_spriteSheetID = v;
		}
		
		
		public function get spriteSheet():SpriteSheet
		{
			return _spriteSheet;
		}
		public function set spriteSheet(v:SpriteSheet):void
		{
			_spriteSheet = v;
		}
		
		
		/**
		 * The SpriteSet's property definitions. This is a map of key-value pairs
		 * that represent properties definitions which are used in the SpriteSet's
		 * global properties and in the properties of any SpriteObject's in the set.
		 */
		public function get propertyDefinitions():Object
		{
			return _propertyDefinitions;
		}
		public function set propertyDefinitions(v:Object):void
		{
			_propertyDefinitions = v;
		}
		
		
		/**
		 * Global properties a sprite properties that apply to all sprite objects that
		 * are in the spriteset.
		 */
		public function get globalProperties():Object
		{
			return _globalProperties;
		}
		public function set globalProperties(v:Object):void
		{
			_globalProperties = v;
		}
		
		
		public function get sprites():Object
		{
			return _sprites;
		}
		public function set sprites(v:Object):void
		{
			_sprites = v;
		}
		
		
		public function get spriteCount():int
		{
			return _spriteCount;
		}
		public function set spriteCount(v:int):void
		{
			_spriteCount = v;
		}
	}
}
