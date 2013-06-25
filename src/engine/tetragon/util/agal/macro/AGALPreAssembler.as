/*
 * hexagonlib - Multi-Purpose ActionScript 3 Library.
 *       __    __
 *    __/  \__/  \__    __
 *   /  \__/HEXAGON \__/  \
 *   \__/  \__/  LIBRARY _/
 *            \__/  \__/
 *
 * Licensed under the MIT License
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package tetragon.util.agal.macro
{
	import tetragon.util.debug.HLog;
	
	
	/*
	 * The AGALPreAssembler implements a pre-processing language for AGAL.
	 * The preprocessor is interpreted at compile time, which allows
	 * run time generation of different shader types, often from one
	 * main shader.
	 * 
	 * <pre>
	 *			Language:
	 *			#define FOO num
	 *			#define FOO
	 *			#undef FOO	
	 *			
	 *			#if <expression>
	 *			#elif <expression>
	 *			#else
	 *			#endif	
	 *	</pre>
	 */
	public class AGALPreAssembler
	{
		// -----------------------------------------------------------------------------------------
		// Constants
		// -----------------------------------------------------------------------------------------
		
		public static const TRACE_VM:Boolean = false;
		public static const TRACE_AST:Boolean = false;
		public static const TRACE_PREPROC:Boolean = false;
		
		
		// -----------------------------------------------------------------------------------------
		// Properties
		// -----------------------------------------------------------------------------------------
		
		/** @private */
		private var _vm:VM;
		/** @private */
		private var _expressionParser:ExpressionParser;
		
		
		// -----------------------------------------------------------------------------------------
		// Constructor
		// -----------------------------------------------------------------------------------------
		
		public function AGALPreAssembler()
		{
			_vm = new VM();
			_expressionParser = new ExpressionParser();
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Public Methods
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @param tokens
		 * @param types
		 * @return true or false
		 */
		public function processLine(tokens:Vector.<String>, types:String):Boolean
		{
			// read per-line. Either handle:
			// - preprocessor tags (and call the proprocessor 'vm')
			// - check the current 'if' state and stream out tokens.
			
			var slot:String = "";
			var num:Number;
			var exp:Expression = null;
			var result:Number;
			var pos:int = 0;
			
			if (types.charAt(pos) == "#")
			{
				slot = "";
				num = Number.NaN;
				
				if (tokens[pos] == "#define")
				{
					// #define FOO 1
					// #define FOO
					// #define FOO=1
					
					if (types.length >= 3 && types.substr(pos, 3) == "#in")
					{
						slot = tokens[pos + 1];
						_vm.vars[ slot ] = Number.NaN;
						if (TRACE_PREPROC) HLog.trace("#define #i");
						pos += 3;
					}
					else if (types.length >= 3 && types.substr(pos, 3) == "#i=")
					{
						exp = _expressionParser.parse(tokens.slice(3), types.substr(3));
						exp.exec(_vm);
						result = _vm.stack.pop();
						slot = tokens[pos + 1];
						_vm.vars[slot] = result;
						if (TRACE_PREPROC) HLog.trace("#define= " + slot + "=" + result);
					}
					else
					{
						exp = _expressionParser.parse(tokens.slice(2), types.substr(2));
						exp.exec(_vm);
						result = _vm.stack.pop();
						slot = tokens[pos + 1];
						_vm.vars[slot] = result;
						if (TRACE_PREPROC) HLog.trace("#define " + slot + "=" + result);
					}
				}
				else if (tokens[pos] == "#undef")
				{
					slot = tokens[pos + 1];
					_vm.vars[slot] = null;
					if (TRACE_PREPROC) HLog.trace("#undef");
					pos += 3;
				}
				else if (tokens[pos] == "#if")
				{
					++pos;
					exp = _expressionParser.parse(tokens.slice(1), types.substr(1));
					_vm.pushIf();
					exp.exec(_vm);
					result = _vm.stack.pop();
					_vm.setIf(result);
					if (TRACE_PREPROC) HLog.trace("#if " + ((result) ? "true" : "false"));
				}
				else if (tokens[pos] == "#elif")
				{
					++pos;
					exp = _expressionParser.parse(tokens.slice(1), types.substr(1));
					exp.exec(_vm);
					result = _vm.stack.pop();
					_vm.setIf(result);
					if (TRACE_PREPROC) HLog.trace("#elif " + ((result) ? "true" : "false"));
				}
				else if (tokens[pos] == "#else")
				{
					++pos;
					_vm.setIf(_vm.ifWasTrue() ? 0 : 1);
					if (TRACE_PREPROC)
					{
						HLog.trace("#else " + ((_vm.ifWasTrue()) ? "true" : "false"));
					}
				}
				else if (tokens[pos] == "#endif")
				{
					_vm.popEndif();
					++pos;
					if (TRACE_PREPROC) HLog.trace("#endif");
				}
				else
				{
					throw new Error("AGALPreAssembler: unrecognized processor directive.");
				}
				
				/* Eat the newlines */
				while (pos < types.length && types.charAt(pos) == "n")
				{
					++pos;
				}
			}
			else
			{
				throw new Error("AGALPreAssembler: PreProcessor called without preprocessor directive.");
			}
			
			return _vm.ifIsTrue();
		}
	}
}
