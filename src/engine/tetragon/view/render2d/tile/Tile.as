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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	
	/**
	 * The Tile class represents a concrete tile object that is put inside a tilegroup
	 * and by that is being placed on a scrollable tilemap. Tiles are created by using
	 * TileDefinition and TileModel objects. The TileDefinition provides all definition
	 * data for the tile and the TileModel provides the coordinates that describe where
	 * the tile is being positioned inside it's parent tilegroup.
	 */
	public class Tile
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The unique ID of the tile.
		 */
		public var id:String;
		
		/**
		 * The width of the tile.
		 */
		public var width:int;
		
		/**
		 * The height of the tile.
		 */
		public var height:int;
		
		/**
		 * The x coordinate of the tile inside it's parent tilegroup.
		 */
		public var x:int;
		
		/**
		 * The y coordinate of the tile inside it's parent tilegroup.
		 */
		public var y:int;
		
		/**
		 * If this tile is a virtual copy of another tile then this contains the ID of the
		 * tile which this tile is a copy of.
		 */
		public var copyOf:String;
		
		/**
		 * The tile's tile properties, contains TileProperty objects.
		 * @private
		 */
		public var properties:Object;
		
		/**
		 * A reference to the bitmapdata of the TileDefinition of this Tile.
		 * @private
		 */
		public var bitmapData:BitmapData;
		
		/**
		 * The tile's bitmap.
		 * @private
		 */
		public var bitmap:Bitmap;
	}
}
