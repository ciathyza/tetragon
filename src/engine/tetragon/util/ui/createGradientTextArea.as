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
package tetragon.util.ui
{
	import tetragon.Main;
	import tetragon.core.display.text.GradientTextArea;
	import tetragon.core.types.Gradient;
	import tetragon.view.theme.TextFormats;

	import flash.text.TextFormat;
	
	
	/**
	 * Creates a createGradientTextArea.
	 * 
	 * @param textFormat Can be either a TextFormat object or a String ID for a defined
	 *        text format.
	 * @param gradient
	 * @param gradientAffordance
	 * @return GradientTextArea object
	 */
	public function createGradientTextArea(textFormat:Object = null, gradient:Gradient = null,
		gradientAffordance:int = -1):GradientTextArea
	{
		var formats:TextFormats = Main.instance.themeManager.currentTheme.textFormats;
		var fm:TextFormat;
		
		if (textFormat is String) fm = formats.getFormat(textFormat as String);
		else if (textFormat is TextFormat) fm = textFormat as TextFormat;
		else fm = formats.getFormat(TextFormats.DEFAULT_FORMAT_ID);
		
		return new GradientTextArea(fm, null, gradient, gradientAffordance);
	}
}
