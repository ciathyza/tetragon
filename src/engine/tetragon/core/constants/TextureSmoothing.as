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
package tetragon.core.constants
{
	/**
	 * A class that provides constant values for the possible smoothing algorithms of a texture.
	 */
	public final class TextureSmoothing
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
        /** No smoothing, also called "Nearest Neighbor". Pixels will scale up as big rectangles. */
        public static const NONE:String      = "none";
		
        /** Bilinear filtering. Creates smooth transitions between pixels. */
        public static const BILINEAR:String  = "bilinear";
		
        /** Trilinear filtering. Highest quality by taking the next mip map level into account. */
        public static const TRILINEAR:String = "trilinear";
		
		
        /**
         * Determines whether a smoothing value is valid.
         * 
         * @param smoothing
         * @return true or false
         */
        public static function isValid(smoothing:String):Boolean
        {
            return smoothing == NONE || smoothing == BILINEAR || smoothing == TRILINEAR;
        }
	}
}
