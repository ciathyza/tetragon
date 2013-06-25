/*
 * hexagonlib - Multi-Purpose ActionScript 3 Library.
 *       __    __
 *    __/  \__/  \__    __
 *   /  \__/HEXAGON \__/  \
 *   \__/  \__/  LIBRARY _/
 *            \__/  \__/
 *
 * Licensed under the MIT License
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package tetragon.core.types
{
	/**
	 * A palette with the standard Apple II colors.
	 */
	public class PaletteAppleII extends Palette
	{
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function PaletteAppleII(name:String = null)
		{
			super("Apple II");
			addColor(0xFF000000, "Black");
			addColor(0xFF853A51, "Magenta");
			addColor(0xFF504789, "Dark Blue");
			addColor(0xFFEA5DF1, "Purple");
			addColor(0xFF006852, "Dark Green");
			addColor(0xFF929292, "Grey 1");
			addColor(0xFF00A8F1, "Medium Blue");
			addColor(0xFFCAC3F8, "Light Blue");
			addColor(0xFF515C0F, "Brown");
			addColor(0xFFEB7F23, "Orange");
			addColor(0xFF929292, "Grey 2");
			addColor(0xFFF7B9CB, "Pink");
			addColor(0xFF00CA28, "Green");
			addColor(0xFFCBD39B, "Yellow");
			addColor(0xFF9ADCCB, "Aqua");
			addColor(0xFFFFFFFF, "White");
		}
	}
}
