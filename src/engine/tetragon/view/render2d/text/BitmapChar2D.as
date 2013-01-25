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
package tetragon.view.render2d.text
{
	import tetragon.view.render2d.display.Image2D;
	import tetragon.view.render2d.textures.Texture2D;

	import flash.utils.Dictionary;

	/** A BitmapChar contains the information about one char of a bitmap font.  
	 *  <em>You don't have to use this class directly in most cases. 
	 *  The TextField class contains methods that handle bitmap fonts for you.</em>    
	 */
	public class BitmapChar2D
	{
		private var mTexture:Texture2D;
		private var mCharID:int;
		private var mXOffset:Number;
		private var mYOffset:Number;
		private var mXAdvance:Number;
		private var mKernings:Dictionary;


		/** Creates a char with a texture and its properties. */
		public function BitmapChar2D(id:int, texture:Texture2D, xOffset:Number, yOffset:Number, xAdvance:Number)
		{
			mCharID = id;
			mTexture = texture;
			mXOffset = xOffset;
			mYOffset = yOffset;
			mXAdvance = xAdvance;
			mKernings = null;
		}


		/** Adds kerning information relative to a specific other character ID. */
		public function addKerning(charID:int, amount:Number):void
		{
			if (mKernings == null)
				mKernings = new Dictionary();

			mKernings[charID] = amount;
		}


		/** Retrieve kerning information relative to the given character ID. */
		public function getKerning(charID:int):Number
		{
			if (mKernings == null || mKernings[charID] == undefined) return 0.0;
			else return mKernings[charID];
		}


		/** Creates an image of the char. */
		public function createImage():Image2D
		{
			return new Image2D(mTexture);
		}


		/** The unicode ID of the char. */
		public function get charID():int
		{
			return mCharID;
		}


		/** The number of points to move the char in x direction on character arrangement. */
		public function get xOffset():Number
		{
			return mXOffset;
		}


		/** The number of points to move the char in y direction on character arrangement. */
		public function get yOffset():Number
		{
			return mYOffset;
		}


		/** The number of points the cursor has to be moved to the right for the next char. */
		public function get xAdvance():Number
		{
			return mXAdvance;
		}


		/** The texture of the character. */
		public function get texture():Texture2D
		{
			return mTexture;
		}


		/** The width of the character in points. */
		public function get width():Number
		{
			return mTexture.width;
		}


		/** The height of the character in points. */
		public function get height():Number
		{
			return mTexture.height;
		}
	}
}