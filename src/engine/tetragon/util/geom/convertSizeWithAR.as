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
package tetragon.util.geom
{
	import tetragon.core.types.Rect;
	
	
	/**
	 * Converts a rectangular size to a new rectangular size while keeping the aspect
	 * ratio of the new size.
	 * 
	 * @param oldSize A Rect with the old size.
	 * @param newSize A Rect with the new size.
	 * @param portrait By default the aspect ratio is calculated for landscape format.
	 *        If this is set to true the ratio is instead calculated for Portrait format.
	 * @return A Rect with the new size.
	 */
	public function convertSizeWithAR(oldSize:Rect, newSize:Rect, portrait:Boolean = false):Rect
	{
		var oldRatio:Number;
		var newRatio:Number;
		
		if (!portrait)
		{
			oldRatio = oldSize.width / oldSize.height;
			newRatio = newSize.width / newSize.height;
			if (newRatio == oldRatio) return new Rect(oldSize.width, oldSize.height);
			else if (newRatio > oldRatio) return new Rect(oldSize.width, oldSize.width / newRatio);
			else return new Rect(oldSize.height * newRatio, oldSize.height);
		}
		else
		{
			oldRatio = oldSize.height / oldSize.width;
			newRatio = newSize.height / newSize.width;
			if (newRatio == oldRatio) return new Rect(oldSize.width, oldSize.height);
			else if (newRatio > oldRatio) return new Rect(oldSize.height / newRatio, oldSize.height);
			else return new Rect(oldSize.width, oldSize.width * newRatio);
		}
		return null;
	}
}
