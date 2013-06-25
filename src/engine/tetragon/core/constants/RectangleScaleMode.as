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
package tetragon.core.constants
{
	/**
	 * A class that provides constant values for the 'RectangleUtil.fit' method.
	 */
	public class RectangleScaleMode
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/** Specifies that the rectangle is not scaled, but simply centered within the 
		 *  specified area. */
		public static const NONE:String = "none";
		
		/** Specifies that the rectangle fills the specified area without distortion 
		 *  but possibly with some cropping, while maintaining the original aspect ratio. */
		public static const NO_BORDER:String = "noBorder";
		
		/** Specifies that the entire rectangle will be scaled to fit into the specified 
		 *  area, while maintaining the original aspect ratio. This might leave empty bars at
		 *  either the top and bottom, or left and right. */
		public static const SHOW_ALL:String = "showAll";
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/** Indicates whether the given scale mode string is valid. */
		public static function isValid(scaleMode:String):Boolean
		{
			return scaleMode == NONE || scaleMode == NO_BORDER || scaleMode == SHOW_ALL;
		}
	}
}
