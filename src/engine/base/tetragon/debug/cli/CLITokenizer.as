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
	import tetragon.debug.Log;

	
	public class CLITokenizer
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		private static const NUM_TABLE:String		= "0123456789.";
		private static const CHAR_TABLE:String		= "abcdefghijklmnopqrstuvwxyz";
		private static const OPS_TABLE:String		= "+-*/%^=";
		private static const STRUCT_TABLE:String	= "()[]{}";
		private static const SEP_TABLE:String		= " ,";
		private static const QUOTES_TABLE:String	= "'" + '"';
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private static var _currentType:String;
		/** @private */
		private static var _lastType:String;
		/** @private */
		private static var _stringBuffer:Vector.<String>;
		/** @private */
		private static var _openStack:Vector.<String> = new Vector.<String>();
		/** @private */
		private static var _out:Vector.<CLIToken>;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Tokenizes the specified input string.
		 * 
		 * @return A Vector of CLITokens.
		 */
		public static function tokenize(input:String):Vector.<CLIToken> 
		{
			clearBuffer();
			
			_out = new Vector.<CLIToken>;
			if (input.length < 1) return _out;
			
			var split:Array = input.split("");
			split.reverse();
			
			var lastItem:String = "";
			var lookingAt:String = "";
			
			while (split.length > 0)
			{
				/* left to right, no look forward */
				lastItem = lookingAt;
				lookingAt = split.pop();
				
				if (isQuote(lookingAt))
				{
					if (_openStack.length == 0)
					{
						setCurrentType(CLITokenType.STRING);
						_openStack.push(lookingAt);
					}
					else if (_openStack[_openStack.length - 1] == lookingAt)
					{
						_openStack.pop();
						reduce();
					}
					else
					{
						setCurrentType(CLITokenType.STRING);
						_openStack.push(lookingAt);
					}
					continue;
				}
				
				/* If we're currently a string, simply push to buffer */
				if (_currentType == CLITokenType.STRING) 
				{
					_stringBuffer.push(lookingAt);
				}
				/* if we're currently not a string, and the current symbol is
				 * an operator or a separator ... */
				else if (isSeparator(lookingAt) || isOperator(lookingAt) || isStructure(lookingAt))
				{
					/* reduce the current buffer */
					reduce();
					
					if (!isSeparator(lookingAt))
					{
						/* simply ignore all separators */
						switch(lookingAt)
						{
							case "+":
								setCurrentType(CLITokenType.OP_PLUS);
								break;
							case "-":
								setCurrentType(CLITokenType.OP_MINUS);
								break;
							case "/":
								setCurrentType(CLITokenType.OP_DIV);
								break;
							case "*":
								setCurrentType(CLITokenType.OP_MULT);
								break;
							case "=":
								setCurrentType(CLITokenType.OP_EQUAL);
								break;
							case "(":
								setCurrentType(CLITokenType.PARENTHESIS_OPEN);
								break;
							case ")":
								setCurrentType(CLITokenType.PARENTHESIS_CLOSE);
								break;
							case "[":
								setCurrentType(CLITokenType.BRACKET_OPEN);
								break;
							case "]":
								setCurrentType(CLITokenType.BRACKET_CLOSE);
								break;
							case "{":
								setCurrentType(CLITokenType.CURLYBRACE_OPEN);
								break;
							case "}":
								setCurrentType(CLITokenType.CURLYBRACE_CLOSE);
								break;
							default:
								setCurrentType(CLITokenType.UNKNOWN);
						}
						_stringBuffer.push(lookingAt);
					}
					
					/* the current buffer should only contain an operator or be empty, so reduce */
					reduce();
				}
				else
				{
					/* we are probably an identifier or a number.. assuming this is
					 * the first pass after a buffer clear, check the type */
					if (isNumber(lookingAt) && _currentType != CLITokenType.IDENTIFIER)
					{
						setCurrentType(CLITokenType.NUMBER);
					}
					else if (getTypeTable(lookingAt) == CHAR_TABLE)
					{
						setCurrentType(CLITokenType.IDENTIFIER);
					}
					_stringBuffer.push(lookingAt);
				}
			}
			
			if (_stringBuffer.length > 0)
			{
				reduce();
			}
			
			return _out;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public static function toString():String
		{
			return "CLITokenizer";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static function clearBuffer():void
		{
			_stringBuffer = new Vector.<String>();
			setCurrentType(CLITokenType.UNKNOWN);
		}
		
		
		/**
		 * @private
		 */
		private static function setCurrentType(t:String):void 
		{
			_lastType = _currentType;
			_currentType = t;
		}
		
		
		/**
		 * Reduce the current buffer to a token.
		 * @private
		 * 
		 * @param type
		 */
		private static function reduce():void
		{
			if (_stringBuffer.length < 1) return;
			
			try
			{
				//var t:XML = makeTokenNode(stringBuffer.join(""), currentType);
				//out.appendChild(t);
				var t:CLIToken = makeTokenObject(_stringBuffer.join(""), _currentType);
				_out.push(t);
			}
			catch (err:Error)
			{
				// Debug only!
				Log.error("reduce(): " + err.message, toString());
			}
			
			clearBuffer();
		}
		
		
		/**
		 * @private
		 */
		private static function makeTokenObject(data:String, type:String):CLIToken
		{
			var malformed:Boolean = false;
			
			if (type == CLITokenType.IDENTIFIER)
			{
				if (isNumber(data.charAt(0)))
				malformed = true;
			}
			
			var t:CLIToken = new CLIToken();
			if (malformed) t.malformed = malformed;
			t.type = type;
			t.value = data;
			return t;
		}
		
		
		/**
		 * @private
		 */
		private static function isNumber(input:String):Boolean
		{
			return NUM_TABLE.indexOf(input) > -1;
		}

		
		/**
		 * @private
		 */
		private static function isOperator(input:String):Boolean
		{
			return OPS_TABLE.indexOf(input) > -1;
		}

		
		/**
		 * @private
		 */
		private static function isSeparator(input:String):Boolean
		{
			return SEP_TABLE.indexOf(input) > -1;
		}

		
		/**
		 * @private
		 */
		private static function isQuote(input:String):Boolean
		{
			return QUOTES_TABLE.indexOf(input) > -1;
		}

		
		/**
		 * @private
		 */
		private static function isStructure(input:String):Boolean
		{
			return STRUCT_TABLE.indexOf(input) > -1;
		}
		
		
		/**
		 * @private
		 */
		private static function getTypeTable(input:String):String
		{
			input = input.toLowerCase();
			
			if (NUM_TABLE.indexOf(input) > -1) return NUM_TABLE;
			if (CHAR_TABLE.indexOf(input) > -1) return CHAR_TABLE;
			if (OPS_TABLE.indexOf(input) > -1) return OPS_TABLE;
			if (STRUCT_TABLE.indexOf(input) > -1) return STRUCT_TABLE;
			if (SEP_TABLE.indexOf(input) > -1) return SEP_TABLE;
			if (QUOTES_TABLE.indexOf(input) > -1) return QUOTES_TABLE;
			
			Log.error("getTypeTable(): unrecognized type: " + input, toString());
			return null;
		}
	}
}
