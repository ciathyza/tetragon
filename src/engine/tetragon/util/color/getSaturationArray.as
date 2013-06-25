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
package tetragon.util.color
{
	/**
	 * Generates an array for use with a ColorMatrixFilter to change the
	 * saturation of a display object.
	 * 
	 * @param value
	 * @return Array of Numbers.
	 */
	public function getSaturationArray(value:Number):Array
	{
		var nRed:Number = 0.3086;
		var nGreen:Number = 0.6094;
		var nBlue:Number = 0.0820;
		var nA:Number = (1 - value) * nRed + value;
		var nB:Number = (1 - value) * nGreen;
		var nC:Number = (1 - value) * nBlue;
		var nD:Number = (1 - value) * nRed;
		var nE:Number = (1 - value) * nGreen + value;
		var nF:Number = (1 - value) * nBlue;
		var nG:Number = (1 - value) * nRed;
		var nH:Number = (1 - value) * nGreen;
		var nI:Number = (1 - value) * nBlue + value;
		return [nA, nB, nC, 0, 0, nD, nE, nF, 0, 0, nG, nH, nI, 0, 0, 0, 0, 0, 1, 0];
	}
}
