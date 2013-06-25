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
package tetragon.util.display
{
	import tetragon.core.constants.Alignment;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;


	/**
	 * Creates a thumbnail of a BitmapData. The thumbnail can be any size as the copied
	 * image will be scaled proportionally and cropped if necessary to fit into the
	 * thumbnail area. If the image needs to be cropped in order to fit the thumbnail
	 * area, the alignment of the crop can be specified.
	 * 
	 * @param image
	 * 
	 *            The source image for which a thumbnail should be created. The source
	 *            will not be modified
	 * 
	 * @param width
	 * 
	 *            The width of the thumbnail
	 * 
	 * @param height
	 * 
	 *            The height of the thumbnail
	 * 
	 * @param alignment
	 * 
	 *            If the thumbnail has a different aspect ratio to the source image,
	 *            although the image will be scaled to fit along one axis it will be
	 *            necessary to crop the image. Use this parameter to specify how the
	 *            copied and scaled image should be aligned within the thumbnail
	 *            boundaries. Use a constant from the Alignment enumeration class
	 * 
	 * @param smooth
	 * 
	 *            Whether to apply bitmap smoothing to the thumbnail
	 */
	public function resizeBitmap(image:BitmapData, width:int, height:int,
		alignment:String = Alignment.CENTER, smooth:Boolean = true):Bitmap
	{
		var s:Bitmap = new Bitmap(image);
		var t:BitmapData = new BitmapData(width, height, false, 0x000000);
		t.draw(image, createResizeMatrix(s, t.rect, true, alignment, false), null, null, null, smooth);
		s = null;
		return new Bitmap(t, PixelSnapping.AUTO, smooth);
	}
}
