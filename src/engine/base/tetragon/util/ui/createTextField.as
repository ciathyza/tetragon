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
	import tetragon.view.ui.theme.TextFormats;

	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	
	/**
	 * Creates a basic text field. If width and/or height is smaller than 0 an autosized
	 * textfield is created with TextFieldAutoSize.LEFT.
	 * 
	 * If the specified textFormat is null the engine's default text format is used.
	 * 
	 * @param width -1 for autosize textfield.
	 * @param height -1 for autosize textfield.
	 * @param textFormat Must be either a TextFormat or a TextFormat ID String.
	 * @param multiline
	 * @param selectable
	 * @param autoSize
	 * @param antiAliasType
	 * @param gridFitType
	 */
	public function createTextField(width:int = -1, height:int = -1, textFormat:Object = null,
		multiline:Boolean = false, selectable:Boolean = false,
		autoSize:String = TextFieldAutoSize.LEFT,
		antiAliasType:String = AntiAliasType.ADVANCED,
		gridFitType:String = GridFitType.PIXEL):TextField
	{
		var formats:TextFormats = Main.instance.themeManager.currentTheme.textFormats;
		var tf:TextField = new TextField();
		var fm:TextFormat;
		
		if (textFormat)
		{
			if (textFormat is String) fm = formats.getFormat(textFormat as String);
			else fm = textFormat as TextFormat;
			tf.defaultTextFormat = fm ? fm : formats.getFormat(TextFormats.DEFAULT_FORMAT_ID);
		}
		else
		{
			tf.defaultTextFormat = formats.getFormat(TextFormats.DEFAULT_FORMAT_ID);
		}
		
		if (width > -1 && height > -1)
		{
			tf.autoSize = TextFieldAutoSize.NONE;
			tf.width = width;
			tf.height = height;
		}
		else
		{
			tf.autoSize = autoSize || TextFieldAutoSize.LEFT;
		}
		
		tf.embedFonts = true;
		tf.mouseEnabled = false;
		tf.multiline = multiline;
		tf.selectable = selectable;
		tf.antiAliasType = antiAliasType || AntiAliasType.ADVANCED;
		tf.gridFitType = gridFitType || (tf.antiAliasType == AntiAliasType.NORMAL ? GridFitType.NONE : GridFitType.PIXEL);
		
		return tf;
	}
}
