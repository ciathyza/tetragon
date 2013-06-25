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
package tetragon.util.display
{
	import tetragon.core.constants.Alignment;

	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	
	/**
	 * Fits a DisplayObject into a rectangular area with several options for scale and
	 * alignment. This method will return the Matrix required to duplicate the
	 * transformation and can optionally apply this matrix to the DisplayObject.
	 * 
	 * @param displayObject
	 * 
	 *            The DisplayObject that needs to be fitted into the Rectangle.
	 * 
	 * @param rectangle
	 * 
	 *            A Rectangle object representing the space which the DisplayObject should
	 *            fit into.
	 * 
	 * @param fillRect
	 * 
	 *            Whether the DisplayObject should fill the entire Rectangle or just fit
	 *            within it. If true, the DisplayObject will be cropped if its aspect
	 *            ratio differs to that of the target Rectangle.
	 * 
	 * @param alignment
	 * 
	 *            The alignment of the DisplayObject within the target Rectangle. Use a
	 *            constant from the Alignment class.
	 * 
	 * @param applyTransform
	 * 
	 *            Whether to apply the generated transformation matrix to the
	 *            DisplayObject. By setting this to false you can leave the DisplayObject
	 *            as it is but store the returned Matrix for to use either with a
	 *            DisplayObject's transform property or with, for example,
	 *            BitmapData.draw()
	 */
	public function createResizeMatrix(displayObject:DisplayObject, rectangle:Rectangle,
		fillRect:Boolean = true, alignment:String = Alignment.CENTER,
		applyTransform:Boolean = true):Matrix
	{
		var matrix:Matrix = new Matrix();
		var wD:Number = displayObject.width / displayObject.scaleX;
		var hD:Number = displayObject.height / displayObject.scaleY;
		var wR:Number = rectangle.width;
		var hR:Number = rectangle.height;
		var sX:Number = wR / wD;
		var sY:Number = hR / hD;
		var rD:Number = wD / hD;
		var rR:Number = wR / hR;
		var sH:Number = fillRect ? sY : sX;
		var sV:Number = fillRect ? sX : sY;
		var s:Number = rD >= rR ? sH : sV;
		var w:Number = wD * s;
		var h:Number = hD * s;
		var tX:Number = 0.0;
		var tY:Number = 0.0;
		
		switch (alignment)
		{
			case Alignment.LEFT:
			case Alignment.TOP_LEFT:
			case Alignment.BOTTOM_LEFT:
				tX = 0.0;
				break;
			case Alignment.RIGHT:
			case Alignment.TOP_RIGHT:
			case Alignment.BOTTOM_RIGHT:
				tX = w - wR;
				break;
			default:
				tX = 0.5 * (w - wR);
		}
		
		switch (alignment)
		{
			case Alignment.TOP:
			case Alignment.TOP_LEFT:
			case Alignment.TOP_RIGHT:
				tY = 0.0;
				break;
			case Alignment.BOTTOM:
			case Alignment.BOTTOM_LEFT:
			case Alignment.BOTTOM_RIGHT:
				tY = h - hR;
				break;
			default:
				tY = 0.5 * (h - hR);
		}
		
		matrix.scale(s, s);
		matrix.translate(rectangle.left - tX, rectangle.top - tY);
		
		if (applyTransform)
		{
			displayObject.transform.matrix = matrix;
		}
		
		return matrix;
	}
}
