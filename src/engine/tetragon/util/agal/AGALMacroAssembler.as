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
package tetragon.util.agal
{
	import tetragon.debug.Log;
	import tetragon.util.agal.macro.AGALPreAssembler;
	import tetragon.util.agal.macro.AGALVar;

	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;


	/**
	 * TODO Obsolete Version!
	 * 
	 * <p>
	 * A richer version of the AGALMiniAssembler. The MacroAssembler is a macro based
	 * assembly substitution "compiler". Basically it adds some nice, more human readable
	 * syntax to the MiniAssembler.
	 * </p>
	 * 
	 * <p>
	 * It never generates temporaries and doesn't have an AST. (Use PixelBender for that.)
	 * </p>
	 * 
	 * <p>
	 * Features:
	 * </p>
	 * <p>Math expressions on float4: addition, subtraction, multiplication, division,
	 * negation. Note that expression must be simple operations.</p>
	 * 
	 * <pre>
	 * 		a = b ~~ c;			// Simple binary operation
	 * 		a = -a;				// Simple unary operation
	 * 		a = b~~c + d;		// Bonus: multiply-add is supported
	 * 		a = b~~c + d~~c;	// ERROR! this isn't simple enough. (3 binary operations)
	 * </pre>
	 * 
	 * <p>Macro definitions. Like functions, but are actually substitutions into your
	 * code. The actual operation is very similar to the C preprocessor. The Macros are
	 * processed ahead of parsing, so order order doesn't matter, and A() can call B() as
	 * well as B() calling A(). Recursion is not supported (or possible.).</p>
	 * 
	 * <pre>
	 * 		macro Foo(arg0) {
	 * 		out = arg0;	// 'out' is always the return value.
	 * 		}
	 * </pre>
	 * 
	 * <p>Aliases. Very handy for keeping track of your attribute and constant registers.
	 * It's a good idea to start any AGALMacro program with an alias block, that defines
	 * the mapping from the shader to the constant pool and vertex stream.</p>
	 * 
	 * <pre>
	 * 		alias va0, pos
	 * 		alias vc0, objToClip
	 * 		op = MultMat4x4(pos, objToClip);
	 * </pre>
	 * 
	 * <p>Constant use. All constants must be in the constant pool. However, if you tell
	 * the macro assembler about your constants, it can use them automatically. You can
	 * also query what constants are expected by a shader. The 'aliases' member contains
	 * information about all the aliases and constants used by the shader.</p>
	 * 
	 * <pre>
	 * 		alias vc0, CONST_0(0.5, 1);	// declares that vc0.x=0.5 and vc0.y=1. This must be true in your constant pool.
	 * 		macro Half(arg0) {
	 * 		out = arg0 ~~ 0.5;			// will automatically use vc0.x, since you declared this to be 0.5
	 * 		}
	 * </pre>
	 * 
	 * <p>Pre-processor. Sometimes you will one a shader to have multiple flavors. For
	 * example:</p>
	 * <pre>
	 * 		ft0 = tex&lt;2d,linear,miplinear&gt;(v0, fs0);
	 * 		#if USE_ALPHA;
	 * 		ft0 = ft0 * fc_alpha;
	 * 		#endif;
	 * 		#if USE_COLOR_XFORM;
	 * 		ft0 = ft0 + fc_colorXForm;
	 * 		#endif;
	 * 		oc = ft0;
	 * </pre>
	 * 
	 * <p>Can be configured 4 ways with USE_ALPHA and USE_COLOR_XFORM on and off. You can
	 * easily compile an minimal, efficient shader with just alpha support by saying:</p>
	 * <pre>
	 * 		macroAssembler.assemble('USE_ALPHA=1;' + SHADER_SRC_STRING);
	 * </pre>
	 * 
	 * <p>The preprocessor supports the following operations:</p>
	 * <pre>
	 * 		#define FOO num
	 * 		#define FOO
	 * 		#define FOO=&lt;expression&gt;
	 * 		#undef FOO
	 * 		#if &lt;expression&gt;
	 * 		#elif &lt;expression&gt;
	 * 		#else
	 * 		#endif
	 * </pre>
	 * 
	 * <p>Note that the preprocessor does NOT (currently) support the notions of
	 * "is defined". A variable has a value. The expression parser is rich and follows the
	 * c precedence rules.</p>
	 * 
	 * <pre>
	 * 		#if VAR_ONE*VAR_TWO+VAR_THREE != VAR_ONE+VAR_THREE*VAR_TWO
	 * 		...
	 * 		#endif
	 * </pre>
	 * 
	 * <p>Simple standard library. The following macros are always available:</p>
	 * <pre>
	 * 		ft0 = tex&lt;2d,linear,miplinear&gt;(v0, fs0);		Function syntax for textures.
	 * 		ft0 = mul3x3(vec, mat)							Matrix multiplication
	 * 		ft0 = mul4x4(vec, mat)							Matrix multiplication
	 * </pre>
	 */
	public class AGALMacroAssembler extends AGAL
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const IDENTIFIER:RegExp = /((2d)|(3d)|[_a-zA-Z])+([_a-zA-Z0-9.]*)/;
		public static const NUMBER:RegExp = /[0-9]+(?:\.[0-9]*)?/;
		
		// Nasty regex, even by regex standards:   2 char ops                       1 char ops
		public static const OPERATOR:RegExp = /(==)|(!=)|(<=)|(>=)|(&&)|(\|\|)|[*=+-\/()\[\]{}!<>&|]/;
		public static const SEPERATOR:RegExp = /\n/;
		public static const PREPROC:RegExp = /\#[a-z]+/;
		
		// # (space) identifier
		public static const TOKEN:RegExp = new RegExp(IDENTIFIER.source + "|" + NUMBER.source
			+ "|" + SEPERATOR.source + "|" + OPERATOR.source + "|" + PREPROC.source, "g");
		
		public static const STDLIB:String =
			"macro mul3x3(vec, mat) {" + "	m33 out, vec, mat; " + "}" + // Matrix multiply 3x3
			"macro mul4x4(vec, mat) {" + "	m44 out, vec, mat; " + "}";  // Matrix multiply 4x5
		
		/** @private */
		private static const REGEXP_LINE_BREAKER:RegExp = /[\f\n\r\v;]+/g;
		/** @private */
		private static const COMMENT:RegExp = /\/\/[^\n]*\n/g;
		
		// private static const MACRO:RegExp = /([\w.]+)(\s*)=(\s*)(\w+)(\s*)\(/;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The generated AGAL Mini Assembler code. Available after the call to assemble().
		 */
		public var asmCode:String = "";
		
		/**
		 * After assemble() is called, the aliases contain
		 * information about all the variables used in the
		 * shader. Of particular important is the constant
		 * registers that are required to be set for the
		 * shader to function. Each alias is of type AGALVar.
		 * A constant, required to be set, will have agalVar.isConstant() == true
		 */
		public var aliases:Dictionary = new Dictionary();
		
		public var profile:Boolean;
		public var profileTrace:String = "";
		
		/** @private */
		private var _isFrag:Boolean;
		/** @private */
		private var _stages:Vector.<PerfStage>;
		/** @private */
		private var _macros:Dictionary = new Dictionary();
		/** @private */
		private var _preproc:AGALPreAssembler = new AGALPreAssembler();
		/** @private */
		private var _tokens:Vector.<String>;
		/** @private */
		private var _types:String = "";
		
		/** @private */
		private var _emptyStringVector:Vector.<String> = new Vector.<String>(0, true);
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @param debug
		 */
		public function AGALMacroAssembler(debug:Boolean = false):void
		{
			super(debug);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Generate AGAL byte code from source.
		 * 
		 * @param mode
		 * @param source
		 * @return ByteArray
		 */
		override public function assemble(mode:String, source:String):ByteArray
		{
			if (profile)
			{
				var start:uint = getTimer();
				_stages = new Vector.<PerfStage>();
				_stages.push(new PerfStage("start"));
			}
			
			_isFrag = (mode == "fragment");
			source = STDLIB + source;
			
			// Note that Macros are object scope (kept around from run to run)
			// but Alias are program scope
			aliases = new Dictionary();
			
			source = cleanInput(source);
			// C-style comments /* */ makes this a little tricky per line.
			_tokens = tokenize(source);
			_types = tokenizeTypes(_tokens);
			
			mainLoop();
			
			if (profile) _stages.push(new PerfStage("join"));
			asmCode = joinTokens(_tokens);
			if (profile) _stages.push(new PerfStage("mini"));
			
			var result:ByteArray = super.assemble(mode, asmCode);
			if (profile)
			{
				_stages.push(new PerfStage("end"));
				for (var k:int = 0; k < _stages.length - 1; ++k)
				{
					var desc:String = _stages[k].name + " --> " + _stages[k + 1].name + " = "
						+ ((_stages[k + 1].time - _stages[k].time) / 1000);
					Log.trace(desc, this);
					profileTrace += desc + "\n";
				}
			}
			
			return result;
		}
		
		
		/**
		 * @internal
		 */
		public static function joinTokens(tokens:Vector.<String>):String
		{
			var pos:int = 0;
			var newline:int = 0;
			var s:String = "";
			var tokensLength:uint = tokens.length;
			
			while (pos < tokensLength)
			{
				if (tokens[pos] == "\n")
				{
					++pos;
					continue;
				}
				
				newline = tokens.indexOf("\n", pos + 1);
				if (newline < 0) newline = tokensLength;
				
				s += tokens[pos++];
				if (pos < tokensLength && tokens[pos] != ".") s += " ";
				
				while (pos < newline)
				{
					s += tokens[pos];
					if (tokens[pos] == ",") s += " ";
					++pos;
				}
				
				s += "\n";
				pos = newline + 1;
			}
			
			return s;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Takes a string input, normalizes newlines, and removes comments.
		 * @private
		 */
		private function cleanInput(source:String):String
		{
			// Pull out the c-style comments first.
			var start:int = source.indexOf("/*");
			while (start >= 0)
			{
				var end:int = source.indexOf("*/", start + 1);
				if (end < 0) throw new Error("AGALMacroAssembler: Comment end not found.");
				
				source = source.substr(0, start) + source.substr(end + 2);
				start = source.indexOf("/*");
			}
			
			source = source.replace(REGEXP_LINE_BREAKER, "\n");
			source = source.replace(COMMENT, "");
			return source;
		}
		
		
		/**
		 * @private
		 */
		private function tokenize(input:String):Vector.<String>
		{
			// Tokens:
			// identifiers:	/w+
			// operators:  	=+-/*
			return Vector.<String>(input.match(TOKEN));
		}
		
		
		/**
		 * @private
		 */
		private function tokenizeTypes(tokens:Vector.<String>):String
		{
			var types:String = "";
			var tokensLength:uint = tokens.length;
			
			for (var i:uint = 0; i < tokensLength; ++i)
			{
				var token:String = tokens[i];
				
				if (token.search(IDENTIFIER) == 0)
				{
					types += "i";
				}
				else if (token.search(NUMBER) == 0)
				{
					types += "0";
				}
				else if (token.search(SEPERATOR) == 0)
				{
					types += "n";
				}
				else if (token.search(OPERATOR) == 0)
				{
					if (token.length == 1) types += token;
					else types += "2"; // ==, !=, etc.
				}
				else if (token.search(PREPROC) == 0)
				{
					types += "#";
				}
				else
				{
					throw new Error("AGALMacroAssembler: Unrecognized token: " + tokens[i]);
				}
			}
			
			if (types.length != tokens.length)
			{
				throw new Error("AGALMacroAssembler: Tokens and types must have the same length.");
			}
			
			return types;
		}
		
		
		/**
		 * @private
		 */
		private function createMangledName(name:String, types:int):String
		{
			// All we really need is the nArgs, since that is all that can change.
			return name + "-" + types;
		}
		
		
		/**
		 * @private
		 */
		private function splice(pos:int, deleteCount:int, newTokens:Vector.<String>,
			newTypes:String):void
		{
			if (!newTokens) newTokens = _emptyStringVector;
			if (newTypes == null) newTypes = "";
			
			var t:Vector.<String> = _tokens.slice(0, pos);
			t = t.concat(newTokens);
			t = t.concat(_tokens.slice(pos + deleteCount));
			_tokens = t;
			
			_types = _types.substr(0, pos) + newTypes + _types.substr(pos + deleteCount);
			if (_types.length != _tokens.length)
			{
				throw new Error("AGALMacroAssembler: AGAL.splice internal error. types.length="
					+ _types.length + " tokens.length=" + _tokens.length);
			}
		}
		
		
		/**
		 * @private
		 */
		private function basicOp(op:String, target:String, src1:String, src2:String):String
		{
			return op + " " + target + ", " + src1 + ", " + src2;
		}
		
		
		/**
		 * @private
		 */
		private function convertMath(pos:int):Boolean
		{
			// dest = rega
			// dest = rega + regb
			// dest = rega - regb
			// dest = rega / regb
			// dest = rega * regb
			// dest = -rega

			var end:int = _types.indexOf("n", pos + 1);
			if (end < pos + 1) throw new Error("AGALMacroAssembler: End of expression not found.");
			
			var body:String = "";
			var s:String = _types.substr(pos, end - pos);
			
			switch(s)
			{
				case "i=i":
					body = "mov " + _tokens[pos + 0] + ", " + _tokens[pos + 2];
					break;
				case "i=i+i":
					body = basicOp("add", _tokens[pos + 0], _tokens[pos + 2], _tokens[pos + 4]);
					break;
				case "i=i-i":
					body = basicOp("sub", _tokens[pos + 0], _tokens[pos + 2], _tokens[pos + 4]);
					break;
				case "i=i*i":
					body = basicOp("mul", _tokens[pos + 0], _tokens[pos + 2], _tokens[pos + 4]);
					break;
				case "i=i/i":
					body = basicOp("div", _tokens[pos + 0], _tokens[pos + 2], _tokens[pos + 4]);
					break;
				case "i=-i":
					body = "neg " + _tokens[pos + 0] + ", " + _tokens[pos + 3];
					break;
				case "i*=i":
					body = basicOp("mul", _tokens[pos + 0], _tokens[pos + 0], _tokens[pos + 3]);
					break;
				case "i/=i":
					body = basicOp("div", _tokens[pos + 0], _tokens[pos + 0], _tokens[pos + 3]);
					break;
				case "i+=i":
					body = basicOp("add", _tokens[pos + 0], _tokens[pos + 0], _tokens[pos + 3]);
					break;
				case "i-=i":
					body = basicOp("sub", _tokens[pos + 0], _tokens[pos + 0], _tokens[pos + 3]);
					break;
				case "i=i*i+i":
					body = basicOp("mul", _tokens[pos + 0], _tokens[pos + 2], _tokens[pos + 4]) + "\n" + basicOp("add", _tokens[pos + 0], _tokens[pos + 0], _tokens[pos + 6]);
					break;
				case "i=i+i*i":
					body = basicOp("mul", _tokens[pos + 0], _tokens[pos + 4], _tokens[pos + 6]) + "\n" + basicOp("add", _tokens[pos + 0], _tokens[pos + 0], _tokens[pos + 2]);
					break;
				default:
					return false;
			}
			
			if (body.length > 0)
			{
				var tok:Vector.<String> = tokenize(body);
				var typ:String = tokenizeTypes(tok);
				splice(pos, end - pos, tok, typ);
			}
			
			return true;
		}
		
		
		/**
		 * Add the macros to the internal table.
		 * Returns a string without the macros.
		 * @private
		 */
		private function processMacro(pos:int):void
		{
			// function Foo( arg0, arg1, arg2, ... )
			var NAME:int = 1;
			var OPENPAREN:int = 2;
			var ARG0:int = 3;
			
			var openParen:int = 0;
			var closeParen:int = 0;
			var openBracket:int = 0;
			var closeBracket:int = 0;
			var i:int = 0;
			
			if (_tokens[pos] != "macro")
			{
				throw new Error("AGALMacroAssembler: Expected 'macro' not found.");
			}
			
			openParen = pos + OPENPAREN;
			if (_tokens[openParen] != "(")
			{
				throw new Error("AGALMacroAssembler: Macro open paren not found.");
			}
			
			closeParen = _types.indexOf(")", openParen + 1);
			openBracket = _types.indexOf("{", closeParen + 1);
			closeBracket = _types.indexOf("}", openBracket + 1);
			
			var macro:Macro = new Macro(); // name, args, body
			macro.name = _tokens[pos + NAME];
			
			// normally: (a, b, c)
			// but also: (a, b, <c,d>)
			var argc:int = 0;
			
			for (i = openParen + 1; i < closeParen; ++i)
			{
				if (_types.charAt(i) == "i")
				{
					macro.args.push(_tokens[i]);
					++argc;
				}
			}
			macro.mangledName = createMangledName(macro.name, argc);
			
			// Copy to the new macro:
			for (i = openBracket + 1; i < closeBracket; ++i)
			{
				macro.body.push(_tokens[i]);
			}
			macro.types = _types.substr(openBracket + 1, closeBracket - openBracket - 1);
			
			// Remove from parsing:
			splice(pos, closeBracket - pos + 1, _emptyStringVector, "");
			_macros[macro.mangledName] = macro;
			// macro.traceMacro();
		}
		
		
		/**
		 * @private
		 */
		private function expandTexture(pos:int):int
		{
			var openParen:int = _types.indexOf("(", pos);
			var closeParen:int = _types.indexOf(")", openParen + 1);
			var openBracket:int = _types.indexOf("<", pos);
			var closeBracket:int = _types.indexOf(">", openBracket + 1);
			var eol:int = _types.indexOf("n", pos);
			if (eol < 0) eol = _types.length;
			
			// oc = tex.<2d,linear,miplinear>( v0, fs0 )
			// to:
			// tex oc, v0, fs0 <2d,linear,miplinear>"
			var s:String = "tex " + _tokens[pos] + "," + _tokens[openParen + 1] + ","
				+ _tokens[openParen + 3]
				+ "<" + _tokens.slice(openBracket + 1, closeBracket).join("") + ">;";
			
			var newTokens:Vector.<String> = tokenize(s);
			var newTypes:String = tokenizeTypes(newTokens);
			
			splice(pos, eol - pos, newTokens, newTypes);
			return pos + newTypes.length;
		}


		/**
		 * @private
		 */
		private function expandMacro(pos:int):void
		{
			// Macro is:
			// ident = ident(
			
			var NAME:int = 2;
			var OPENPAREN:int = 3;
			var closeParen:int = 0;
			var i:uint = 0;
			
			var name:String = _tokens[pos + NAME];
			closeParen = _types.indexOf(")", pos + OPENPAREN) - pos;
			var argc:int = ( closeParen - OPENPAREN ) / 2;
			var mangledName:String = createMangledName(name, argc);
			
			if (_macros[mangledName] == null)
			{
				throw new Error("AGALMacroAssembler: Macro '" + mangledName + "' not found.");
			}
			
			var macro:Macro = _macros[mangledName];
			
			var output:String = _tokens[pos];
			var args:Vector.<String> = _tokens.slice(pos + OPENPAREN + 1, pos + closeParen);
			var body:Vector.<String> = new Vector.<String>();
			var macroBodyLength:uint = macro.body.length;
			
			for (i = 0; i < macroBodyLength; ++i)
			{
				var processed:Boolean = false;
				if (macro.types.charAt(i) == "i")
				{
					if (macro.body[i].substr(0, 3) == "out")
					{
						body.push(output + macro.body[i].substr(3));
						processed = true;
					}
					else
					{
						var index:int = macro.args.indexOf(macro.body[i]);
						if (index >= 0)
						{
							body.push(args[2 * index]); // parameter substitution
							processed = true;
						}
					}
				}
				
				if (!processed)
				{
					body.push(macro.body[i]);
				}
			}
			
			splice(pos, // where to start 
			closeParen + 1, body, macro.types);
		}
		
		
		/**
		 * @private
		 */
		private function getConstant(numConst:String):String
		{
			var num:Number = Number(numConst);
			
			// Search the aliases, with constants, for something that works.
			for each (var agalVar:AGALVar in aliases)
			{
				if (agalVar.isConstant())
				{
					if (agalVar.x == num) return agalVar.target + ".x";
					if (agalVar.y == num) return agalVar.target + ".y";
					if (agalVar.z == num) return agalVar.target + ".z";
					if (agalVar.w == num) return agalVar.target + ".w";
				}
			}
			
			throw new Error("AGALMacroAssembler: Numeric constant used that is not declared in a constant register.");
			return "error";
		}
		
		
		/**
		 * @private
		 */
		private function readAlias(pos:int):void
		{
			// "alias va3.x, xform0Ref \n" +
			// "alias va3.y, xform1Ref \n" +
			// "alias va3.z, weight0 \n" +
			
			if (_tokens[pos] == "alias")
			{
				var agalVar:AGALVar = new AGALVar();
				agalVar.name = _tokens[pos + 3];
				agalVar.target = _tokens[pos + 1];
				aliases[agalVar.name] = agalVar;
				
				// trace( "alias name=" + agalVar.name + " target=" + agalVar.target );
				
				if (_tokens[pos + 4] == "(")
				{
					// Read the default value.
					var end:int = _tokens.indexOf(")", pos + 5);
					if (end < 0)
					{
						throw new Error("AGALMacroAssembler: Closing paren of default alias value not found.");
					}
					
					agalVar.x = 0;
					agalVar.y = 0;
					agalVar.z = 0;
					agalVar.w = 0;
					
					if (end > (pos + 5)) agalVar.x = Number(_tokens[pos + 5]);
					if (end > (pos + 7)) agalVar.y = Number(_tokens[pos + 7]);
					if (end > (pos + 9)) agalVar.z = Number(_tokens[pos + 9]);
					if (end > (pos + 11)) agalVar.w = Number(_tokens[pos + 11]);
				}
			}
		}
		
		
		/**
		 * Return the new pos.
		 * @private
		 */
		private function processTokens(pos:int, newline:int):int
		{
			var brackets:int = 0;
			if (_types.length >= 4 && _types.substr(pos, 4) == "i=i(")
			{
				// Macro!
				expandMacro(pos);
				return pos; // re-process. Could be anything.
			}
			else if (_types.length >= 4 && _types.substr(pos, 4) == "i=i<" && _tokens[pos + 2] == "tex")
			{
				// Special texture handling.
				return expandTexture(pos);
			}
			else if (_tokens[pos] == "alias")
			{
				readAlias(pos);
				splice(pos, newline - pos + 1, null, null);
				return pos;
			}
			else if (_tokens[pos] == "macro")
			{
				processMacro(pos); // macros remove themselves
				return pos;
			}
			
			// Substitute aliases
			// Substitute constants (a special kind of alias)
			for (var p:int = pos; p < newline; ++p)
			{
				var t:String = _types.charAt(p);
				if (t == "[")
				{
					++brackets;
				}
				else if (t == "]")
				{
					--brackets;
				}
				else if (t == "0")
				{
					if (brackets == 0)
					{
						_tokens[p] = getConstant(_tokens[p]);
						_types = _types.substr(0, p) + "i" + _types.substr(p + 1);
					}
				}
				else if (t == "i")
				{
					// foo.xy is a valid token:
					var dot:int = _tokens[p].indexOf(".");
					if (dot < 0) dot = _tokens[p].length;

					var agalVar:AGALVar = aliases[ _tokens[p].substr(0, dot) ];
					if (agalVar != null)
					{
						_tokens[p] = agalVar.target + _tokens[p].substr(dot);
					}
				}
			}
			
			// finally, do math conversion.
			if (convertMath(pos))
			{
				// changes length; reset newline.
				newline = _types.indexOf("n", pos + 1);
				if (newline < 0) newline = _types.length;
			}
			return newline + 1;
		}
		
		
		/**
		 * @private
		 */
		private function mainLoop():void
		{
			var pos:int = 0;
			var newline:int = 0;
			var processing:Boolean = true;
			
			while (pos < _tokens.length)
			{
				// Read in a line.
				while (pos < _tokens.length && _types.charAt(pos) == "n")
				{
					++pos;
				}
				
				if (pos == _tokens.length) break;
				newline = _types.indexOf("n", pos + 1);
				if (newline < 0) newline = _types.length;
				
				var type:String = _types.charAt(pos);
				if (type == "#")
				{
					if (!_preproc) _preproc = new AGALPreAssembler();
					processing = _preproc.processLine(_tokens.slice(pos, newline), _types.substr(pos, newline - pos));
					// The preprocessing line is consumed.
					splice(pos, newline - pos + 1, null, null);
				}
				else
				{
					if (processing)
					{
						// Keep the tokens, update the position.
						pos = processTokens(pos, newline);
					}
					else
					{
						splice(pos, newline - pos + 1, null, null);
					}
				}
			}
		}
	}
}


import tetragon.debug.Log;
import tetragon.util.agal.AGALMacroAssembler;

import flash.utils.getTimer;


/**
 * @private
 */
final class Macro
{
	public var mangledName:String = "";
	public var name:String = "";
	public var args:Vector.<String> = new Vector.<String>();
	public var body:Vector.<String> = new Vector.<String>();
	public var types:String = "";
	
	public function traceMacro():void
	{
		Log.trace("Macro: " + name + " [" + mangledName + "]", this);
		Log.trace("  args: " + args, this);
		Log.trace("<==", this);
		var s:String = AGALMacroAssembler.joinTokens(body);
		Log.trace(s, this);
		Log.trace("==>", this);
	}
}


/**
 * @private
 */
final class PerfStage
{
	public var name:String;
	public var time:uint;
	
	public function PerfStage(name:String)
	{
		this.name = name;
		this.time = getTimer();
	}
}
