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
	import tetragon.debug.LogLevel;
	import tetragon.input.KeyCodes;
	import tetragon.input.KeyCombination;
	import tetragon.input.KeyInputManager;
	import tetragon.input.KeyMode;
	import tetragon.util.string.TabularText;
	
	
	public class ListKeyAssignmentsCommand extends CLICommand
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function execute():void 
		{
			var km:KeyInputManager = main.keyInputManager;
			var assignments:Object = km.assignments;
			var count:int = 0;
			var t:TabularText = new TabularText(8, true, "  ", null, "  ", 40,
				["KEY(S)", "CODE(S)", "LENGTH", "MODE", "LOCATION", "ID", "BINDING IDENTIFIER", "PARAMS"]);
			
			for (var id:String in assignments)
			{
				var kc:KeyCombination = assignments[id];
				var p:String = kc.params ? kc.params.toString() : "";
				var string:String = "";
				var code:String = "";
				var codes:Vector.<uint> = kc.codes;
				var len:uint = codes.length;
				
				for (var i:uint = 0; i < len; i++)
				{
					var c:uint = codes[i];
					code += c + (i < len - 1 ? "," : "");
					if (kc.mode == KeyMode.SEQ)
					{
						string += String.fromCharCode(c);
					}
					else
					{
						var s:String = KeyCodes.getKeyString(c);
						if (s) string += s.toUpperCase() + (i < len - 1 ? "+" : "");
					}
				}
				
				var mode:String = kc.mode == KeyMode.DOWN ? "down"
					: kc.mode == KeyMode.REPEAT ? "repeat"
					: kc.mode == KeyMode.UP ? "up"
					: kc.mode == KeyMode.SEQ ? "seq"
					: "" + kc.mode;
				
				var loc:String = "s" + kc.shiftKeyLocation + " c" + kc.ctrlKeyLocation
					+ " a" + kc.altKeyLocation;
				
				var binding:String = km.getBindingIdentifier(string);
				if (!binding) binding = "";
				
				t.add([string, code, kc.codes.length, mode, loc, id, binding, p]);
				count++;
			}
			
			main.console.log("Key Assignments (count: " + count + "):\n" + t.toString(), LogLevel.INFO);
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
			return "listKeyAssignments";
		}
	}
}
