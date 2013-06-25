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
	 * A palette with the standard CGA colors.
	 */
	public class PaletteCGA extends Palette
	{
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function PaletteCGA(name:String = null)
		{
			super("CGA");
			addColor(0xFF000000, "Black");
			addColor(0xFF0019B6, "Low Blue");
			addColor(0xFF00B41C, "Low Green");
			addColor(0xFF00B6B8, "Low Cyan");
			addColor(0xFFC41F0C, "Low Red");
			addColor(0xFFC22AB7, "Low Magenta");
			addColor(0xFFC16A14, "Brown");
			addColor(0xFFB9B9B9, "Light Gray");
			addColor(0xFF686868, "Dark Gray");
			addColor(0xFF5F6EFC, "High Blue");
			addColor(0xFF39FB6F, "High Green");
			addColor(0xFF23FDFF, "High Cyan");
			addColor(0xFFFF706A, "High Red");
			addColor(0xFFFF76FD, "High Magenta");
			addColor(0xFFFFFE71, "Yellow");
			addColor(0xFFFFFFFF, "White");
		}
	}
}
