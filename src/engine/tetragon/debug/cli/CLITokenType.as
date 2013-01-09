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
	public final class CLITokenType
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const UNKNOWN:String			= "unknown";
		public static const NUMBER:String			= "number";
		public static const IDENTIFIER:String		= "identifier";
		public static const STRING:String			= "string";
		public static const COMMA:String			= "comma";
		public static const PERIOD:String			= "period";
		public static const EXPRESSION:String		= "expression";
		
		public static const OP_EQUAL:String			= "op_equal";
		public static const OP_PLUS:String			= "op_plus";
		public static const OP_MINUS:String			= "op_minus";
		public static const OP_MULT:String			= "op_mult";
		public static const OP_DIV:String			= "op_div";
		
		public static const PARENTHESIS_OPEN:String	= "parenthesis_open";
		public static const PARENTHESIS_CLOSE:String= "parenthesis_close";
		public static const BRACKET_OPEN:String		= "bracket_open";
		public static const BRACKET_CLOSE:String	= "bracket_close";
		public static const CURLYBRACE_OPEN:String	= "curlybrace_open";
		public static const CURLYBRACE_CLOSE:String	= "curlybrace_close";
		
	}
}
