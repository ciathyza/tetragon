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
package tetragon.debug.cli
{
	import tetragon.Main;
	import tetragon.command.CLICommand;
	import tetragon.command.CommandManager;
	import tetragon.debug.Console;
	import tetragon.debug.Log;
	import tetragon.debug.LogLevel;
	
	
	/**
	 * A Comand Line Interpreter that processes inputs made in the Console's command line.
	 */
	public final class CLI
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _console:Console;
		/** @private */
		private var _commandManager:CommandManager;
		/** @private */
		private var _commandMap:Object;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new CLI instance.
		 */
		public function CLI(console:Console)
		{
			_console = console;
			_commandManager = Main.instance.commandManager;
			_commandMap = {};
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function parseInput(input:String):String 
		{
			// TODO Filter out any non-visible characters (CTRL/SHIFT/ALT)!
			
			var tokens:Vector.<CLIToken> = CLITokenizer.tokenize(input);
			if (tokens.length < 1) return null;
			
			/* Check that the first token is the command trigger */
			if (tokens[0].type != CLITokenType.IDENTIFIER)
			{
				Log.warn("first token is not an identifier.", this);
				return null;
			}
			
			var token:CLIToken = tokens.shift();
			var trigger:String = token.value;
			var type:String = token.type;
			var vo:CLICommandVO = _commandMap[trigger];
			var cmd:CLICommand;
			
			/* If commandVO wasn't found by it's mapped key, try with shortcut. */
			if (!vo)
			{
				for (var tr:String in _commandMap)
				{
					var o:CLICommandVO = _commandMap[tr];
					if (trigger == o.shortcut)
					{
						trigger = tr;
						vo = o;
						break;
					}
				}
			}
			
			if (vo)
			{
				try
				{
					cmd = new vo.clazz();
				}
				catch (err:Error)
				{
					Log.error("command class for input '" + input + "' is not of type Command.", this);
					return null;
				}
				
				/* Echo input in the console output if it's not suppressed */
				if (!cmd.suppressEcho)
				{
					_console.log(input, LogLevel.INFO);
				}
				
				var sig:Array = cmd.signature;
				var args:Vector.<Argument>;
				var argCount:int = 0;
				var i:int;
				
				if (sig != null)
				{
					args = new Vector.<Argument>();
					
					/* Analyse the argument signature of the command */
					for (i = 0; i < sig.length; i++)
					{
						var arg:String = sig[i];
						var argName:String = arg;
						var argType:String = "String";
						var optional:Boolean = false;
						var isBoolean:Boolean = false;
						
						/* Argument comes with specified type */
						if (arg.indexOf(":") != -1)
						{
							var a:Array = arg.split(":");
							argName = a[0];
							argType = String(a[1]).toLowerCase();
							if (argType == "int" || argType == "uint")
							{
								argType = "number";
							}
							else if (argType == "boolean")
							{
								argType = "identifier";
								isBoolean = true;
							}
						}
						
						/* Check if the argument is optional (starts with +) */
						if (argName.substr(0, 1) == "+")
						{
							argName = argName.substr(1, argName.length);
							optional = true;
						}
						else
						{
							argCount++;
						}
						
						args.push(new Argument(argName, argType, optional, isBoolean));
					}
				}
				
				if (args)
				{
					var len:int = tokens.length;
					if (len < argCount)
					{
						fail("Command argument count mismatch. Command <" + trigger
							+ "> expects at least " + argCount + " argument(s).");
						return null;
					}
					else if (len > args.length)
					{
						// TODO User has specified more arguments than the command accepts!
						len = args.length;
					}
					
					for (i = 0; i < len; i++)
					{
						var t:CLIToken = tokens[i];
						var ar:Argument = args[i];
						
						/* the user entered a hex number as the argument which is Ok if
						 * the current argument is of type number! */
						if (ar.type == "number" && String(t.value).substr(0, 2) == "0x")
						{
							ar.type = t.type;
						}
						
						/* Special treatment for boolean arguments! */
						if (ar.isBoolean)
						{
							var tValue:String = String(t.value).toLowerCase();
							if (tValue == "false")
							{
								t.value = false;
							}
							else if (tValue == "true")
							{
								t.value = true;
							}
							else
							{
								fail("Command argument type mismatch. Argument nr. " + (i + 1)
									+ " is a boolean and must be either <true> or <false>.");
								return null;
							}
						}
						
						if (ar.type != t.type)
						{
							fail("Command argument type mismatch. Argument nr. " + (i + 1)
								+ " should be a " + ar.type + ".");
							return null;
						}
						cmd[ar.name] = t.value;
					}
				}
				
				_commandManager.execute(cmd);
			}
			else
			{
				fail("Unknown command: " + trigger);
				return null;
			}
			
			return null;
		}
		
		
		public function registerCommand(category:String, trigger:String, shortcut:String,
			commandClass:Class, description:String = null):void
		{
			if (_commandMap[trigger] != null) return;
			_commandMap[trigger] = new CLICommandVO(trigger, shortcut, commandClass, description,
				category);
		}
		
		
		public function fail(msg:String):void
		{
			_console.systemMessage(msg);
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "[CLI]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public function get commandMap():Object
		{
			return _commandMap;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
	}
}


/**
 * @private
 */
final class Argument
{
	public var name:String;
	public var type:String;
	public var optional:Boolean;
	public var isBoolean:Boolean;
	
	public function Argument(n:String, t:String, o:Boolean, b:Boolean)
	{
		name = n;
		type = t;
		optional = o;
		isBoolean = b;
	}
}
