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
package tetragon.view.ui.util
{
	import tetragon.view.ui.controls.TextArea;

	import flash.text.TextFormat;
	
	
	/**
	 * Creates a UI TextArea.
	 * 
	 * @param x
	 * @param y
	 * @param width
	 * @param height
	 * @param textFormat
	 * @param multiline
	 * @param editable
	 * @param text
	 */
	public function createTextArea(x:int = 0, y:int = 0, width:int = 0, height:int = 0,
		textFormat:TextFormat = null, multiline:Boolean = true, editable:Boolean = false,
		text:String = null):TextArea
	{
		var item:TextArea = new TextArea(x, y, width, height);
		item.wordWrap = multiline;
		item.editable = editable;
		if (textFormat)
		{
			item.setStyle("textFormat", textFormat);
			item.setStyle("embedFonts", true);
		}
		item.text = text;
		return item;
	}
}
