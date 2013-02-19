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
package tetragon.data
{
	/**
	 * A DataList is a data structure that stores a list of data objects that belong
	 * together. Data lists are typically used for lookup tables.
	 * 
	 * A DataList consists of item objects that are mapped by an ID. The items in turn
	 * can contain any number of properties and/or item sets. A property is simply mapped
	 * by a key and an item set is a list of properties where each is mapped by a key.
	 * 
	 * Consider the following item example to get an idea about where using item sets
	 * makes sense.
	 * 
	 * @example
	 * <pre>
	 * item id="movementTypeInfantry"
	 * 	-properties
	 * 		nameID: textLists/nameMovementTypeInfantry
	 * 		domainID: domainTypes/domainGround
	 * 	-sets
	 * 		-terrainModifiers
	 * 			terrainGrassland: 0
	 * 			terrainPlains: 0
	 * 			terrainTundra: 0
	 * 			terrainDesert: 0
	 * 			terrainHills: 0
	 * 			terrainMountains: -3
	 * 			terrainSnow: -1
	 * 			terrainIce: -1
	 * 			terrainForest: -1
	 * 			terrainJungle: -1
	 * 		-weatherModifiers
	 * 			weatherFair: 0
	 * 			weatherOvercast: 0
	 * 			weatherRain: 0
	 * 			weatherHeavyRain: -1
	 * 			weatherHail: -1
	 * 			weatherSnow: 0
	 * 			weatherBlizzard: -3
	 * </pre>
	 */
	public class DataList extends DataObject
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * A map that stores objects of type DataListItem.
		 * @private
		 */
		private var _items:Object;
		
		/** @private */
		private var _dataType:String;
		/** @private */
		private var _size:uint;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param id
		 * @param dataType
		 */
		public function DataList(id:String, dataType:String = null)
		{
			_id = id;
			_dataType = dataType;
			_items = {};
			_size = 0;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new list item in the data list mapped under the specified id.
		 * 
		 * @param itemID The ID to map the new list item under.
		 * @return true if the item was created, false if an item with the id already
		 *         exists in the map.
		 */
		public function createItem(itemID:String):Boolean
		{
			if (_items[itemID]) return false;
			_items[itemID] = new Item();
			_size++;
			return true;
		}
		
		
		/**
		 * Creates a new dataset with the specified setID in the list item that is
		 * mapped in the list under the specified itemID.
		 * 
		 * @param itemID
		 * @param setID
		 * @return true or false.
		 */
		public function createSet(itemID:String, setID:String):Boolean
		{
			var item:Item = _items[itemID];
			if (!item) return false;
			item.createSet(setID);
			return true;
		}
		
		
		/**
		 * Maps a property to the list item which is mapped under the given itemID.
		 * If the item was found and a value is already mapped in the item under
		 * the specified key, it is overwritten.
		 * 
		 * @param itemID The ID of the item in which to map the property.
		 * @param key The key under which the value is mapped in the item.
		 * @param value The property value.
		 * @return true if the property was added successfully, false if the
		 *         specified itemID was not found in the data list.
		 */
		public function mapProperty(itemID:String, key:String, value:*):Boolean
		{
			var item:Item = _items[itemID];
			if (!item) return false;
			item.mapProperty(key, value);
			return true;
		}
		
		
		/**
		 * Maps the specified value under the given key in a data set in the list.
		 * 
		 * @param itemID
		 * @param setID
		 * @param key
		 * @param value
		 * @return true or false.
		 */
		public function mapSetProperty(itemID:String, setID:String, key:String, value:*):Boolean
		{
			var item:Item = _items[itemID];
			if (!item) return false;
			return item.mapSetProperty(setID, key, value);
		}
		
		
		/**
		 * Returns the property that is mapped under the specified key from the list
		 * item that is mapped under the specified itemID. Or return null if the item
		 * is not mapped in the data list or if the property is not mapped in the item.
		 * 
		 * @param itemID
		 * @param key
		 * @return The mapped property or null.
		 */
		public function getProperty(itemID:String, key:String):*
		{
			var item:Item = _items[itemID];
			if (!item) return null;
			return item.getProperty(key);
		}
		
		
		/**
		 * Returns a property from a set that is mapped inside an item in the list.
		 * 
		 * @param itemID
		 * @param setID
		 * @param key
		 * @return The mapped set property or null.
		 */
		public function getSetProperty(itemID:String, setID:String, key:String):*
		{
			var item:Item = _items[itemID];
			if (!item) return null;
			return item.getSetProperty(setID, key);
		}
		
		
		/**
		 * Returns the datalist item that is mapped under the specified itemID.
		 */
		public function getItem(itemID:String):Item
		{
			return _items[itemID];
		}
		
		
		/**
		 * Returns an Array of DataListItem objects.
		 */
		public function toArray():Array
		{
			var a:Array = [];
			for (var id:String in _items)
			{
				var dli:DataListItem = new DataListItem(id);
				var item:Item = _items[id];
				dli.properties = item.getProperties();
				dli.sets = item.getSets();
				a.push(dli);
			}
			return a;
		}
		
		
		/**
		 * Returns a typed, fixed-length Vector of DataListItem objects.
		 */
		public function toVector():Vector.<DataListItem>
		{
			var a:Vector.<DataListItem> = new Vector.<DataListItem>(_size, true);
			var c:uint = 0;
			for (var id:String in _items)
			{
				var dli:DataListItem = new DataListItem(id);
				var item:Item = _items[id];
				dli.properties = item.getProperties();
				dli.sets = item.getSets();
				a[c++] = dli;
			}
			return a;
		}
		
		
		/**
		 * dump
		 */
		override public function dump():String
		{
			var s:String = "\nDataList (id: " + _id + ", size: " + _size + ", datatype: " + _dataType + ")";
			for (var key:String in _items)
			{
				s += "\n\titem: " + key + Item(_items[key]).dump();
			}
			return s;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The data type that the list represents.
		 */
		public function get dataType():String
		{
			return _dataType;
		}
		
		
		/**
		 * The number of items in the data list.
		 */
		public function get size():uint
		{
			return _size;
		}
	}
}



import tetragon.data.DataListItemSet;
import com.hexagonstar.types.KeyValuePair;


final class Item
{
	private var _properties:Object;
	private var _sets:Object;
	
	public function Item()
	{
		_properties = {};
	}
	
	public function createSet(setID:String):Boolean
	{
		if (!_sets) _sets = {};
		if (_sets[setID]) return false;
		_sets[setID] = new ItemSet();
		return true;
	}
	
	public function mapProperty(key:String, value:*):void
	{
		_properties[key] = value;
	}
	
	public function mapSetProperty(setID:String, key:String, value:*):Boolean
	{
		if (!_sets) return false;
		var dataset:ItemSet = _sets[setID];
		if (!dataset) return false;
		dataset.mapProperty(key, value);
		return true;
	}
	
	public function getProperty(key:String):*
	{
		return _properties[key];
	}
	
	public function getSetProperty(setID:String, key:String):*
	{
		if (!_sets) return null;
		var dataset:ItemSet = _sets[setID];
		if (!dataset) return null;
		return dataset.getProperty(key);
	}
	
	public function getProperties():Vector.<KeyValuePair>
	{
		var a:Vector.<KeyValuePair> = new Vector.<KeyValuePair>();
		for (var key:String in _properties)
		{
			a.push(new KeyValuePair(key, _properties[key]));
		}
		return a;
	}
	
	public function getSets():Vector.<DataListItemSet>
	{
		if (!_sets) return null;
		var a:Vector.<DataListItemSet> = new Vector.<DataListItemSet>();
		for (var setID:String in _sets)
		{
			a.push(new DataListItemSet(setID, ItemSet(_sets[setID]).getProperties()));
		}
		return a;
	}
	
	public function toArray():Array
	{
		var a:Array = [];
		for (var key:String in _properties)
		{
			a.push({key: key, value: _properties[key]});
		}
		return a;
	}
	
	public function dump():String
	{
		var s:String = "";
		var key:String;
		for (key in _properties)
		{
			s += "\n\t\t" + key + ": " + _properties[key];
		}
		for (key in _sets)
		{
			s += "\n\t\tset: " + key + ItemSet(_sets[key]).dump();
		}
		return s;
	}
}


final class ItemSet
{
	private var _properties:Object;
	
	public function ItemSet()
	{
		_properties = {};
	}
	
	public function mapProperty(key:String, value:*):void
	{
		_properties[key] = value;
	}
	
	public function getProperty(key:String):*
	{
		return _properties[key];
	}
	
	public function getProperties():Vector.<KeyValuePair>
	{
		var a:Vector.<KeyValuePair> = new Vector.<KeyValuePair>();
		for (var key:String in _properties)
		{
			a.push(new KeyValuePair(key, _properties[key]));
		}
		return a;
	}
	
	public function dump():String
	{
		var s:String = "";
		for (var key:String in _properties)
		{
			s += "\n\t\t\t" + key + ": " + _properties[key];
		}
		return s;
	}
}
