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
	/**
	 * A TileArea represents an area on a tile map that the tile engine uses to decide
	 * which tile groups are currently visible and which are not. The tile engine divides
	 * a tile map into areas where every area's size is equal to the size of the tile
	 * scroller's view port size. The TileArea class keeps track of which tile groups on
	 * it are currently visible.
	 */
	public class TileArea
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Unique ID number of the tilearea.
		 * @private
		 */
		public var nr:int;
		
		/**
		 * The x coordinate of the tilearea on the tilemap. This is not a pixel coordinate
		 * but the area rectangle's x coordinate.
		 * @private
		 */
		public var x:int;
		
		/**
		 * The y coordinate of the tilearea on the tilemap. This is not a pixel coordinate
		 * but the area rectangle's y coordinate.
		 * @private
		 */
		public var y:int;
		
		/**
		 * A map that determines which tilegroups are located in this area. Every tilegroup
		 * that exists in this area is mapped by it's tilegroup ID and it's value set to true.
		 * @private
		 */
		public var flags:Object;
		
		/**
		 * A flags map used for tilegroups in wrapped areas.
		 * @private
		 */
		public var wrapFlags:Object;
		
		/**
		 * Horizontal offset of area used for map edge wrapping.
		 * @private
		 */
		public var offsetH:int;
		
		/**
		 * Vertical offset of area used for map edge wrapping.
		 * @private
		 */
		public var offsetV:int;
		
		/**
		 * The number of groups that are located in this tilearea.
		 * @private
		 */
		private var _groupCount:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param nr
		 * @param x
		 * @param y
		 */
		public function TileArea(nr:int, x:int, y:int)
		{
			this.nr = nr;
			this.x = x;
			this.y = y;
			
			flags = {};
			_groupCount = 0;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Flags the tilegroup of the specified groupID as existing in this TileArea.
		 * 
		 * @param groupID
		 */
		public function addTileGroup(groupID:int):void
		{
			flags[groupID] = true;
			_groupCount++;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "[TileArea, nr=" + nr + ", coord=" + x + "_" + y + ", groups=" + _groupCount + "]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The number of tilegroups that are located in this tilearea.
		 */
		public function get groupCount():int
		{
			return _groupCount;
		}
	}
}
