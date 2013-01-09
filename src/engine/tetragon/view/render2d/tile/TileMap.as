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
package tetragon.view.render2d.tile
{
	import tetragon.data.DataObject;

	import com.hexagonstar.types.KeyValuePair;
	
	
	/**
	 * Base class for tilemaps.
	 *
	 * @author Hexagon
	 */
	public class TileMap extends DataObject
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _type:String;
		/** @private */
		private var _width:int;
		/** @private */
		private var _height:int;
		/** @private */
		private var _margin:int;
		/** @private */
		private var _edgeMode:String;
		/** @private */
		private var _mapProperties:Object;
		/** @private */
		private var _groups:Vector.<TileGroup>;
		/** @private */
		private var _groupCount:int;
		/** @private */
		private var _fixedGroupCount:int;
		/** @private */
		private var _areas:Object;
		/** @private */
		private var _areaCount:int;
		/** @private */
		private var _bgColor:uint;
		/** @private */
		private var _maxAreaX:int;
		/** @private */
		private var _maxAreaY:int;
		/** @private */
		public var layers:Vector.<TileLayer>;
		/** @private */
		public var tileSetID:String;
		/** @private */
		private var _wrap:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function TileMap(fixedGroupCount:int = 0)
		{
			_fixedGroupCount = fixedGroupCount;
			_wrap = false;
			setup();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds a new map property to the tilemap.
		 * 
		 * @param property The map property to add.
		 */
		public function addMapProperty(property:KeyValuePair):void
		{
			_mapProperties[property.key] = property;
		}
		
		
		/**
		 * Disposes the tilemap. the map cannot be used anymore after this.
		 */
		override public function dispose():void
		{
			for each (var g:TileGroup in _groups)
			{
				g.dispose();
				g.tiles = null;
			}
			_groups = null;
			_areas = null;
		}
		
		
		/**
		 * Creates a String dump of the tilemap's data.
		 */
		public function dump():String
		{
			var s:String = toString() + "\n";
			for (var i:int = 0; i < _groups.length; i++)
			{
				s += i + ". " + _groups[i].toString() + "\n";
			}
			return s;
		}
		
		
		/**
		 * Creates a String dump of the tilemap's areas.
		 */
		public function dumpAreas():String
		{
			var a:Array = [];
			var area:TileArea;
			for each (area in _areas)
			{
				a.push(area);
			}
			a.sortOn("nr", Array.NUMERIC);
			
			var s:String = toString() + "\n";
			for (var i:int = 0; i < a.length; i++)
			{
				area = a[i];
				s += area.x + "_" + area.y + ":\t" +  area.toString() + "\n";
			}
			return s;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		override public function toString(...args):String
		{
			return super.toString("groups=" + _groupCount, "areas=" + _areaCount);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The type of the map.
		 * 
		 * @see TileMapType
		 */
		public function get type():String
		{
			return _type;
		}
		public function set type(v:String):void
		{
			_type = v;
		}
		
		
		/**
		 * Total width of the tile map, in pixels.
		 */
		public function get width():int
		{
			return _width;
		}
		
		
		/**
		 * Total height of the tile map, in pixels.
		 */
		public function get height():int
		{
			return _height;
		}
		
		
		/**
		 * The size of space around the tilemap before scrolling stops if edgeMode is set to halt.
		 */
		public function get margin():int
		{
			return _margin;
		}
		public function set margin(v:int):void
		{
			_margin = v;
		}
		
		
		/**
		 * Determines how the map behaves if scrolling reaches any of it's edges.
		 * 
		 * @see TileMapEdgeMode
		 */
		public function get edgeMode():String
		{
			return _edgeMode;
		}
		public function set edgeMode(v:String):void
		{
			_edgeMode = v;
			_wrap = (_edgeMode == TileMapEdgeMode.WRAP);
		}
		
		
		/**
		 * Determines if the tilemap uses wrapping edge mode.
		 */
		public function get wrap():Boolean
		{
			return _wrap;
		}
		
		
		/**
		 * A list of all tilegroups that are on the tilemap.
		 */
		public function get groups():Vector.<TileGroup>
		{
			return _groups;
		}
		
		
		/**
		 * The number of tilegroups that are on the tilemap.
		 */
		public function get groupCount():uint
		{
			return _groupCount;
		}
		
		
		/**
		 * A map that contains all the tile areas of the tile map.
		 */
		public function get areas():Object
		{
			return _areas;
		}
		
		
		/**
		 * The number of tileareas that are on the tilemap.
		 */
		public function get areaCount():int
		{
			return _areaCount;
		}
		
		
		/**
		 * The background color of the tilemap. Can be an alpha color value.
		 */
		public function get backgroundColor():uint
		{
			return _bgColor;
		}
		public function set backgroundColor(v:uint):void
		{
			_bgColor = v;
		}
		
		
		/**
		 * The x position of the right-most column of areas.
		 */
		public function get maxAreaX():int
		{
			return _maxAreaX;
		}
		
		
		/**
		 * The y position of the bottom-most row of areas.
		 */
		public function get maxAreaY():int
		{
			return _maxAreaY;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function setup():void
		{
			if (_fixedGroupCount > 0)
			{
				_groups = new Vector.<TileGroup>(_fixedGroupCount, true);
			}
			else
			{
				_groups = new Vector.<TileGroup>();
			}
			
			_mapProperties = {};
			_bgColor = 0xFF004488;
		}
		
		
		/**
		 * Calculates the total width and height of the tilemap. Called automatically
		 * by any tilemap factory or generator after the tilemap has been created.
		 * 
		 * @private
		 */
		internal function measure():void
		{
		}
	}
}
