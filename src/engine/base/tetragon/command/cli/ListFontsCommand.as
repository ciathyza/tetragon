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
package tetragon.command.cli
{
	import tetragon.command.CLICommand;

	import com.hexagonstar.util.debug.LogLevel;
	import com.hexagonstar.util.string.TabularText;

	import flash.text.Font;
	
	
	public class ListFontsCommand extends CLICommand
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _includeDeviceFonts:Boolean = false;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function execute():void 
		{
			var a:Array = Font.enumerateFonts(_includeDeviceFonts);
			var s:String;
			
			if (a.length > 0)
			{
				var c:TabularText = new TabularText(4, true, "  ", null, "  ", 0,
					["NR.", "NAME", "STYLE", "TYPE"]);
				for (var i:int = 0; i < a.length; i++)
				{
					var f:Font = a[i];
					c.add([(i + 1), f.fontName, f.fontStyle, f.fontType]);
				}
				s = "\n" + c.toString();
			}
			else
			{
				s = "No embedded fonts found.";
			}
			
			main.console.log(s, LogLevel.INFO);
			complete();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get name():String
		{
			return "listFonts";
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get signature():Array
		{
			return ["+includeDeviceFonts:Boolean"];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// CLI Command Signature Arguments
		//-----------------------------------------------------------------------------------------
		
		public function set includeDeviceFonts(v:String):void
		{
			_includeDeviceFonts = v == "true" ? true : false;
		}
	}
}
