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
package tetragon.core.ioc
{
	import tetragon.core.ioc.injectionresults.InjectionResult;

	import flash.utils.getQualifiedClassName;
	
	
	public class InjectionConfig
	{
		/*******************************************************************************************
		 *								public properties										   *
		 *******************************************************************************************/
		public var request:Class;
		public var injectionName:String;
		/*******************************************************************************************
		 *								private properties										   *
		 *******************************************************************************************/
		private var m_injector:Injector;
		private var m_result:InjectionResult;


		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function InjectionConfig(request:Class, injectionName:String)
		{
			this.request = request;
			this.injectionName = injectionName;
		}


		public function getResponse(injector:Injector):Object
		{
			if (m_result)
			{
				return m_result.getResponse(m_injector || injector);
			}
			var parentConfig:InjectionConfig = (m_injector || injector).getAncestorMapping(request, injectionName);
			if (parentConfig)
			{
				return parentConfig.getResponse(injector);
			}
			return null;
		}


		public function hasResponse(injector:Injector):Boolean
		{
			if (m_result)
			{
				return true;
			}
			var parentConfig:InjectionConfig = (m_injector || injector).getAncestorMapping(request, injectionName);
			return parentConfig != null;
		}


		public function hasOwnResponse():Boolean
		{
			return m_result != null;
		}


		public function setResult(result:InjectionResult):void
		{
			if (m_result != null && result != null)
			{
				trace('Warning: Injector already has a rule for type "' + getQualifiedClassName(request) + '", named "' + injectionName + '".\n ' + 'If you have overwritten this mapping intentionally you can use ' + '"injector.unmap()" prior to your replacement mapping in order to ' + 'avoid seeing this message.');
			}
			m_result = result;
		}


		public function setInjector(injector:Injector):void
		{
			m_injector = injector;
		}
	}
}
