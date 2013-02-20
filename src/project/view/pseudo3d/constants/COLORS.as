/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * tetragon : Engine for Flash-based web and desktop games.
 * Licensed under the MIT License.
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
package view.pseudo3d.constants
{
	public final class COLORS
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const SKY:uint = 0x72D7EE;
		public static const TREE:uint = 0x005108;
		public static const LIGHT:Light = new Light();
		public static const DARK:Dark = new Dark();
		public static const START:Start = new Start();
		public static const FINISH:Finish = new Finish();
	}
}


class Light
{
	public const road:uint = 0x6B6B6B;
	public const grass:uint = 0x10AA10;
	public const rumble:uint = 0x555555;
	public const lane:uint = 0xCCCCCC;
}


class Dark
{
	public const road:uint = 0x696969;
	public const grass:uint = 0x009A00;
	public const rumble:uint = 0xBBBBBB;
}


class Start
{
	public const road:uint = 0xFFFFFF;
	public const grass:uint = 0xFFFFFF;
	public const rumble:uint = 0xFFFFFF;
}


class Finish
{
	public const road:uint = 0x000000;
	public const grass:uint = 0x000000;
	public const rumble:uint = 0x000000;
}
