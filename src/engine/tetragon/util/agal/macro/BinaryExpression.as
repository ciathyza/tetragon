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
	import tetragon.debug.Log;
	
	
	internal class BinaryExpression extends Expression
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		public var op:String;
		public var left:Expression;
		public var right:Expression;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @param depth
		 */
		override public function print(depth:int):void
		{
			if (AGALPreAssembler.TRACE_VM) Log.trace(spaces(depth) + "binary op " + op, this);
			left.print(depth + 1);
			right.print(depth + 1);
		}
		
		
		/**
		 * @param vm
		 */
		override public function exec(vm:VM):void
		{
			var varLeft:Number = NaN;
			var varRight:Number = NaN;
			
			left.exec(vm);
			varLeft = vm.stack.pop();
			right.exec(vm);
			varRight = vm.stack.pop();
			
			if (isNaN(varLeft))
			{
				throw new Error("BinaryExpression: Left side of binary expression ("
					+ op + ") is NaN.");
			}
			if (isNaN(varRight))
			{
				throw new Error("BinaryExpression: Right side of binary expression ("
					+ op + ") is NaN.");
			}
			
			switch (op)
			{
				case "*":
					vm.stack.push(varLeft * varRight);
					break;
				case "/":
					vm.stack.push(varLeft / varRight);
					break;
				case "+":
					vm.stack.push(varLeft + varRight);
					break;
				case "-":
					vm.stack.push(varLeft - varRight);
					break;
				case ">":
					vm.stack.push((varLeft > varRight) ? 1 : 0);
					break;
				case "<":
					vm.stack.push((varLeft < varRight) ? 1 : 0);
					break;
				case ">=":
					vm.stack.push((varLeft >= varRight) ? 1 : 0);
					break;
				case ">=":
					vm.stack.push((varLeft <= varRight) ? 1 : 0);
					break;
				case "==":
					vm.stack.push((varLeft == varRight) ? 1 : 0);
					break;
				case "!=":
					vm.stack.push((varLeft != varRight) ? 1 : 0);
					break;
				case "&&":
					vm.stack.push((Boolean(varLeft) && Boolean(varRight)) ? 1 : 0);
					break;
				case "||":
					vm.stack.push((Boolean(varLeft) || Boolean(varRight)) ? 1 : 0);
					break;
				default:
					throw new Error("BinaryExpression: unimplemented BinaryExpression exec: " + op);
					break;
			}
			
			if (AGALPreAssembler.TRACE_VM)
			{
				Log.trace("::BinaryExpression op" + op + " left=" + varLeft
					+ " right=" + varRight + " push " + vm.stack[vm.stack.length - 1], this);
			}
		}
	}
}
