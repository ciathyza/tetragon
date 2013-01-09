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
package tetragon.file.loaders
{
	import tetragon.BuildType;
	import tetragon.data.Config;
	import tetragon.data.Settings;
	import tetragon.input.KeyInputManager;

	import com.hexagonstar.file.types.TextFile;
	
	
	public final class KeyBindingsLoader extends IniFileLoader
	{
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		override protected function init():void
		{
			var path:String;
			if (main.appInfo.buildType == BuildType.WEB)
			{
				_useDefaultFilePath = true;
				path = getApplicationIniPathFor(config.getString(Config.FILENAME_KEYBINDINGS));
			}
			else
			{
				_useDefaultFilePath = false;
				path = main.registry.settings.getString(Settings.USER_KEYBINDINGS_FILE);
			}
			addFile(path, "keyBindingsFile");
		}
		
		
		override protected function loadFromApplicationPath():void
		{
			var path:String = getApplicationIniPathFor(config.getString(Config.FILENAME_KEYBINDINGS));
			addFile(path, "keyBindingsFile");
			load();
		}
		
		
		override protected function parse(file:TextFile):void
		{
			var km:KeyInputManager = main.keyInputManager;
			var text:String = file.contentAsString;
			var lines:Array = text.match(/^.+$/gm);
			var key:String;
			var val:String;
			
			for each (var l:String in lines)
			{
				const firstChar:String = trim(l).substr(0, 1);
				
				/* Ignore lines that are comments or headers */
				if (firstChar != "#" && firstChar != "[")
				{
					const pos:int = l.indexOf("=");
					key = trim(l.substring(0, pos));
					val = trim(l.substring(pos + 1, l.length));
					km.removeKeyBinding(key);
					km.addKeyBinding(key, val);
				}
			}
			
			if (_completeSignal) _completeSignal.dispatch();
		}
	}
}
