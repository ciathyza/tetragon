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
package tetragon.core.ioc.injectionpoints
{
	import tetragon.core.ioc.InjectionConfig;
	import tetragon.core.ioc.Injector;
	import tetragon.core.ioc.InjectorError;
	
	
	public class PropertyInjectionPoint extends InjectionPoint
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _propertyName:String;
		private var _propertyType:String;
		private var _injectionName:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @param node
		 * @param injector
		 */
		public function PropertyInjectionPoint(node:XML, injector:Injector = null)
		{
			super(node, null);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function applyInjection(target:Object, injector:Injector):Object
		{
			var injectionConfig:InjectionConfig = injector.getMapping(Class(injector.applicationDomain.getDefinition(_propertyType)), _injectionName);
			var injection:Object = injectionConfig.getResponse(injector);
			if (injection == null)
			{
				throw(new InjectorError("Injector is missing a rule to handle injection into property \""
					+ _propertyName + "\" of object \"" + target + "\". Target dependency: \""
					+ _propertyType + "\", named \"" + _injectionName + "\""));
			}
			target[_propertyName] = injection;
			return target;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function initializeInjection(node:XML):void
		{
			_propertyType = XMLList(node.parent().@type).toString();
			_propertyName = XMLList(node.parent().@name).toString();
			_injectionName = node.arg.attribute("value").toString();
		}
	}
}
