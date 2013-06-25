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
package tetragon.util.number
{
	/**
	 * Scales a number from one range of numbers into another range of numbers. Allows
	 * to example for example scale a number in the range from 0.0 to 1.0 into the
	 * range of -1.0 to 1.0.
	 * 
	 * Another approach to scale a number manually is to use the formula:
	 * (Scales number from 0 to 99 to a range of -1 to 1)
	 * 
	 * y = ((x / 99.0) * 2) - 1
	 * 
	 * Divide by 99: This normalizes the range from [0, 99] to [0, 1].
	 * Multiply by 2: This increases the range to [0, 2].
	 * Subtract 1: This is a translation which gives [-1, 1].
	 * 
	 * @param value The value to scale.
	 * @param s1 Start of source range.
	 * @param s2 End of source range.
	 * @param d1 Start of destination range.
	 * @param d2 End of destination range.
	 * 
	 * @return The scaled number.
	 * 
	 */
	public function scaleNumber(value:Number, s1:Number, s2:Number, d1:Number, d2:Number):Number
	{
		return ((value - s1) / (s2 - s1)) * (d2 - d1) + d1;
	}
}
