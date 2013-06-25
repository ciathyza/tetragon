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
package tetragon.util.hash
{
	/**
	 * P. J. Weinberger Hash Function.
	 */
	public function pjwhash(string:String):String
	{
		var bitsInUnsignedInt:uint = uint(4 * 8);
		var threeQuarters:uint = (uint)((bitsInUnsignedInt * 3) / 4);
		var oneEighth:uint = (uint)(bitsInUnsignedInt / 8);
		var highBits:uint = (uint)(0xFFFFFFFF) << (bitsInUnsignedInt - oneEighth);
		var hash:uint = 0;
		var test:uint = 0;
		var l:int = string.length;
		
		for (var i:int = 0; i < l; i++)
		{
			hash = (hash << oneEighth) + uint(string.charCodeAt(i));
			if ((test = hash & highBits) != 0)
			{
				hash = ((hash ^ (test >> threeQuarters)) & (~highBits));
			}
		}
		
		return hash.toString(16);
	}
}
