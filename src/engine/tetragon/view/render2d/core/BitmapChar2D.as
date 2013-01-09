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
package tetragon.view.render2d.core
{
	import flash.utils.Dictionary;


	/**
	 * A BitmapChar2D contains the information about one character of a bitmap font.
	 * <em>You don't have to use this class directly in most cases. 
	 *  The TextField2D class contains methods that handle bitmap fonts for you.</em>
	 */
	public class BitmapChar2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _texture:Texture2D;
		/** @private */
		private var _charID:int;
		/** @private */
		private var _xOffset:Number;
		/** @private */
		private var _yOffset:Number;
		/** @private */
		private var _xAdvance:Number;
		/** @private */
		private var _kernings:Dictionary;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a char with a texture and its properties.
		 * 
		 * @param id
		 * @param texture
		 * @param xOffset
		 * @param yOffset
		 * @param xAdvance
		 */
		public function BitmapChar2D(id:int, texture:Texture2D, xOffset:Number, yOffset:Number,
			xAdvance:Number)
		{
			_charID = id;
			_texture = texture;
			_xOffset = xOffset;
			_yOffset = yOffset;
			_xAdvance = xAdvance;
			_kernings = null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds kerning information relative to a specific other character ID.
		 * 
		 * @param charID
		 * @param amount
		 */
		public function addKerning(charID:int, amount:Number):void
		{
			if (!_kernings) _kernings = new Dictionary();
			_kernings[charID] = amount;
		}
		
		
		/**
		 * Retrieve kerning information relative to the given character ID.
		 * 
		 * @param charID
		 * @return Number
		 */
		public function getKerning(charID:int):Number
		{
			if (!_kernings || _kernings[charID] == undefined) return 0.0;
			else return _kernings[charID];
		}
		
		
		/**
		 * Creates an image of the char.
		 * 
		 * @return Image2D
		 */
		public function createImage():Image2D
		{
			return new Image2D(_texture);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The unicode ID of the char.
		 */
		public function get charID():int
		{
			return _charID;
		}
		
		
		/**
		 * The number of pixels to move the char in x direction on character arrangement.
		 */
		public function get xOffset():Number
		{
			return _xOffset;
		}
		
		
		/**
		 * The number of pixels to move the char in y direction on character arrangement.
		 */
		public function get yOffset():Number
		{
			return _yOffset;
		}
		
		
		/**
		 * The number of pixels the cursor has to be moved to the right for the next char.
		 */
		public function get xAdvance():Number
		{
			return _xAdvance;
		}
		
		
		/**
		 * The texture of the character.
		 */
		public function get texture():Texture2D
		{
			return _texture;
		}
	}
}
