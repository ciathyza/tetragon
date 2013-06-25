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
package tetragon.core.ioc.injectionpoints
{
	import tetragon.core.ioc.Injector;

	import flash.utils.describeType;
	
	
	public class ConstructorInjectionPoint extends MethodInjectionPoint
	{
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @param node
		 * @param clazz
		 * @param injector
		 */
		public function ConstructorInjectionPoint(node:XML, clazz:Class, injector:Injector = null)
		{
			/* In many cases, the flash player doesn't give us type information for constructors
			 * until the class has been instantiated at least once. Therefore, we do just that
			 * if we don't get type information for at least one parameter. */
			if (node.parameter.(@type == "*").length() == node.parameter.@type.length())
			{
				createDummyInstance(node, clazz);
			}
			super(node, injector);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @param target
		 * @param injector
		 */
		override public function applyInjection(target:Object, injector:Injector):Object
		{
			var ctor:Class = Class(target);
			var p:Array = gatherParameterValues(target, injector);
			
			/* the only way to implement ctor injections, really! */
			switch (p.length)
			{
				case 0: return (new ctor());
				case 1: return (new ctor(p[0]));
				case 2: return (new ctor(p[0], p[1]));
				case 3: return (new ctor(p[0], p[1], p[2]));
				case 4: return (new ctor(p[0], p[1], p[2], p[3]));
				case 5: return (new ctor(p[0], p[1], p[2], p[3], p[4]));
				case 6: return (new ctor(p[0], p[1], p[2], p[3], p[4], p[5]));
				case 7: return (new ctor(p[0], p[1], p[2], p[3], p[4], p[5], p[6]));
				case 8: return (new ctor(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]));
				case 9: return (new ctor(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8]));
				case 10: return (new ctor(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9]));
			}
			return null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function initializeInjection(node:XML):void
		{
			var nameArgs:XMLList = XMLList(node.parent()).metadata.(@name == "Inject").arg.(@key == "name");
			_methodName = "constructor";
			gatherParameters(node, nameArgs);
		}
		
		
		/**
		 * @private
		 */
		private function createDummyInstance(constructorNode:XML, clazz:Class):void
		{
			try
			{
				switch (constructorNode.children().length())
				{
					case 0:
						new clazz();
						break;
					case 1:
						new clazz(null);
						break;
					case 2 :
						new clazz(null, null);
						break;
					case 3:
						new clazz(null, null, null);
						break;
					case 4:
						new clazz(null, null, null, null);
						break;
					case 5:
						new clazz(null, null, null, null, null);
						break;
					case 6:
						new clazz(null, null, null, null, null, null);
						break;
					case 7:
						new clazz(null, null, null, null, null, null, null);
						break;
					case 8:
						new clazz(null, null, null, null, null, null, null, null);
						break;
					case 9:
						new clazz(null, null, null, null, null, null, null, null, null);
						break;
					case 10:
						new clazz(null, null, null, null, null, null, null, null, null, null);
						break;
				}
			}
			catch (error:Error)
			{
				trace("Exception caught while trying to create dummy instance for constructor "
					+ "injection. It's almost certainly ok to ignore this exception, but you "
					+ "might want to restructure your constructor to prevent errors from "
					+ "happening. See the SwiftSuspenders documentation for more details. "
					+ "The caught exception was:\n" + error);
			}
			
			constructorNode.setChildren(describeType(clazz).factory.constructor[0].children());
		}
	}
}
