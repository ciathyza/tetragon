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
	/*
	 * The parse is based on Dijkstra's shunting yard:
	 * http://en.wikipedia.org/wiki/Shunting_yard_algorithm
	 * 
	 * As aproached here:
	 * http://www.engr.mun.ca/~theo/Misc/exp_parsing.htm
	 *
	 * Precedence (subset of C rules):
	 * -------------------------------
	 * ()		Parens						left-to-right		
	 * !		not												
	 * *		Multiplication, division	left-to-right		
	 * +		Addition, subtraction		left-to-right		
	 * > >=		relational					left-to-right		
	 * == !=	relational					left-to-right		
	 * &&		Logical AND					left-to-right		
	 * ||		Logical OR					left-to-right		
	 */
	public class ExpressionParser
	{
		// -----------------------------------------------------------------------------------------
		// Properties
		// -----------------------------------------------------------------------------------------
		
		/** @private */
		private var pos:int;
		/** @private */
		private var newline:int;
		/** @private */
		private static const UNARY_PRECEDENCE:int = 5;
		/** @private */
		private var tokens:Vector.<String>;
		/** @private */
		private var types:String;
		
		
		// -----------------------------------------------------------------------------------------
		// Private Methods
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @param e
		 */
		private function expectTok(e:String):void
		{
			if (tokens[pos] != e) throw new Error("ExpressionParser: Unexpected token.");
			++pos;
		}
		
		
		private function parseChunk():Expression
		{
			if (pos == newline) throw new Error("ExpressionParser: parseBit out of tokens.");
			
			// Unary operator
			if (tokens[pos] == "!")
			{
				var notExp:UnaryExpression = new UnaryExpression();
				++pos;
				notExp.right = parseExpression(UNARY_PRECEDENCE);
				return notExp;
			}
			
			if (tokens[pos] == "(")
			{
				++pos;
				var exp:Expression = parseExpression(0);
				expectTok(")");
				return exp;
			}
			
			if (types.charAt(pos) == "i")
			{
				var varExp:VariableExpression = new VariableExpression(tokens[pos]);
				++pos;
				return varExp;
			}
			
			if (types.charAt(pos) == "0")
			{
				var numExp:NumberExpression = new NumberExpression(Number(tokens[pos]));
				++pos;
				return numExp;
			}
			
			throw new Error("ExpressionParser: end of parseChunk: token="
				+ tokens[pos] + " type=" + types.charAt(pos));
		}
		
		
		/**
		 * @param minPrecedence
		 * @return Expression
		 */
		private function parseExpression(minPrecedence:int):Expression
		{
			var t:Expression = parseChunk();
			
			// consumes what is before the binop
			// numbers are immutable...
			if (t is NumberExpression) return t;
			
			var opInfo:OpInfo = new OpInfo();
			if (pos < tokens.length) calcOpInfo(tokens[pos], opInfo);
			
			while (opInfo.order == 2 && opInfo.precedence >= minPrecedence)
			{
				var binExp:BinaryExpression = new BinaryExpression();
				binExp.op = tokens[pos];
				++pos;
				binExp.left = t;
				binExp.right = parseExpression(1 + opInfo.precedence);
				t = binExp;
				
				if (pos < tokens.length) calcOpInfo(tokens[pos], opInfo);
				else break;
			}
			return t;
		}
		
		
		/**
		 * @param tokens
		 * @param types
		 * @return Expression
		 */
		public function parse(tokens:Vector.<String>, types:String):Expression
		{
			pos = 0;
			newline = types.indexOf("n", pos + 1);
			if ( newline < 0 ) newline = types.length;
			
			this.tokens = tokens;
			this.types = types;
			
			var exp:Expression = parseExpression(0);
			// HLog.trace( "--eparser--" );
			if (AGALPreAssembler.TRACE_AST) exp.print(0);
			if (pos != newline) throw new Error("ExpressionParser: parser didn't end.");
			return exp;
		}
		
		
		/**
		 * @param op
		 * @param opInfo
		 * @return true or false
		 */
		private function calcOpInfo(op:String, opInfo:OpInfo):Boolean
		{
			opInfo.order = 0;
			opInfo.precedence = -1;
			
			var groups:Array =
			[
				["&&", "||"],
				["==", "!="],
				[">", "<", ">=", "<="],
				["+", "-"],
				["*", "/"],
				["!"]
			];
			
			for (var i:int = 0; i < groups.length; ++i)
			{
				var arr:Array = groups[i];
				var index:int = arr.indexOf(op);
				if (index >= 0)
				{
					opInfo.order = (i == UNARY_PRECEDENCE) ? 1 : 2;
					opInfo.precedence = i;
					return true;
				}
			}
			return false;
		}
		
		
		// private function parseSingle(token:String, type:String):Expression
		// {
		// if ( type == "i" )
		// {
		// var varExp:VariableExpression = new VariableExpression(token);
		// return varExp;
		// }
		// else if ( type == "0" )
		// {
		// var numExp:NumberExpression = new NumberExpression(Number(token));
		// return numExp;
		// }
		// return null;
		// }
	}
}


final class OpInfo
{
	public var precedence:int;
	public var order:int; // 1: unary, 2: binary
}
