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
	import tetragon.debug.Console;
	import tetragon.debug.cli.CLICommandVO;

	import com.hexagonstar.util.string.TabularText;
	
	
	/**
	 * CLI command that lists all available CLI commands.
	 */
	public class ListCLICommandsCommand extends CLICommand
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _filter:String = "all";
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function execute():void 
		{
			var console:Console = main.console;
			var cmds:Object = console.cli.commandMap;
			var t:TabularText = new TabularText(4, true, "  ", null, "  ", 0,
				["COMMAND", "SHORTCUT", "CATEGORY", "DESCRIPTION"]);
			
			for (var c:String in cmds)
			{
				var vo:CLICommandVO = cmds[c];
				
				/* Apply filters. */
				if (_filter != "all")
				{
					if (vo.category != _filter) continue;
				}
				
				var shortcut:String = vo.shortcut ? vo.shortcut : "";
				t.add([c, shortcut, vo.category, vo.descr]);
			}
			
			console.log("\n" + t.toString());
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
			return "listCLICommands";
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get signature():Array
		{
			return ["+filter:Identifier"];
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get helpText():String
		{
			return "Outputs a list of all CLI commands that can be used with the console. Optionally the output can be"
				+ " filtered to a specific command group by using the command category's name as an argument:\n\n"
				+ "\t\tall:      List all commands (default).\n"
				+ "\t\tcli:      Only list commands that are part of the CLI category.\n"
				+ "\t\tecs:      Only list commands that are part of the 'entity component system' category.\n\n";
				+ "\t\tenv:      Only list commands that are part of the env category.\n"
				+ "\t\tfile:     Only list commands that are part of the file category.\n\n";
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get example():String
		{
			return "commands cli";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// CLI Command Signature Arguments
		//-----------------------------------------------------------------------------------------
		
		public function set filter(v:String):void
		{
			_filter = v;
		}
	}
}
