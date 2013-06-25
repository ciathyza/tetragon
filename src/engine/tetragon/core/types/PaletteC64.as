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
package tetragon.core.types
{
	/**
	 * A palette with the standard C64 colors.
	 */
	public class PaletteC64 extends Palette
	{
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function PaletteC64(name:String = null)
		{
			super("C64");
			addColor(0xFF000000, "Black");
			addColor(0xFFFFFFFF, "White");
			addColor(0xFFA24D42, "Red");
			addColor(0xFF6AC2C8, "Cyan");
			addColor(0xFFA256A5, "Purple");
			addColor(0xFF5CAD5F, "Green");
			addColor(0xFF4F449D, "Blue");
			addColor(0xFFCBD689, "Yellow");
			addColor(0xFFA3683A, "Orange");
			addColor(0xFF6D530B, "Brown");
			addColor(0xFFCD7F76, "Light Red");
			addColor(0xFF636363, "Dark Grey");
			addColor(0xFF8B8B8B, "Grey");
			addColor(0xFF9CE49D, "Light Green");
			addColor(0xFF8A7FCD, "Light Blue");
			addColor(0xFFAFAFAF, "Light Grey");
		}
	}
}
