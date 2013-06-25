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
	 * A palette with the standard MSX colors.
	 */
	public class PaletteMSX extends Palette
	{
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function PaletteMSX(name:String = null)
		{
			super("MSX");
			addColor(0x00000000, "Transparent");
			addColor(0xFF000000, "Black");
			addColor(0xFF3EB849, "Medium Green");
			addColor(0xFF74D07D, "Light Green");
			addColor(0xFF5955E0, "Dark Blue");
			addColor(0xFF8076F1, "Light Blue");
			addColor(0xFFB95E51, "Dark Red");
			addColor(0xFF65DBEF, "Cyan");
			addColor(0xFFDB6559, "Medium Red");
			addColor(0xFFFF897D, "Light Red");
			addColor(0xFFCCC35E, "Dark Yellow");
			addColor(0xFFDED087, "Light Yellow");
			addColor(0xFF3AA241, "Dark Green");
			addColor(0xFFB766B5, "Magenta");
			addColor(0xFFCCCCCC, "Gray");
			addColor(0xFFFFFFFF, "White");
		}
	}
}
