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
	import tetragon.data.sprite.SpriteSet;
	
	
	/**
	 * TileMapGenerator class
	 *
	 * @author Hexagon
	 */
	public class TileMapGenerator
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _spriteSet:SpriteSet;
		/** @private */
		private var _tileMap:TileMap;
		/** @private */
		private var _tileIDCount:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Generates a tilemap.
		 * 
		 * @param spriteSet
		 * @param mapWidth
		 * @param mapHeight
		 * @return A TileMap object.
		 */
		public function generate(spriteSet:SpriteSet, mapWidth:int, mapHeight:int):TileMap
		{
			_spriteSet = spriteSet;
			_tileIDCount = 0;
			
			_tileMap = generateRandomMap(mapWidth, mapHeight);
			_tileMap.measure();
			var tileMap:TileMap = _tileMap;
			_tileMap = null;
			_spriteSet = null;
			return tileMap;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "TileMapGenerator";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function generateRandomMap(mapWidth:int, mapHeight:int):TileMap
		{
			var tileMap:TileMap = new TileMap();
			tileMap.margin = 20;
			tileMap.edgeMode = TileMapEdgeMode.HALT;
			
			return tileMap;
		}
	}
}
