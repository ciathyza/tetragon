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

	import flash.utils.getQualifiedClassName;
	
	
	public class MethodInjectionPoint extends InjectionPoint
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _methodName:String;
		protected var _parameterInjectionConfigs:Vector.<ParameterInjectionConfig>;
		protected var _requiredParameters:int = 0;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @param node
		 * @param injector
		 */
		public function MethodInjectionPoint(node:XML, injector:Injector = null)
		{
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
			var parameters:Array = gatherParameterValues(target, injector);
			var method:Function = target[_methodName];
			method.apply(target, parameters);
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
			var nameArgs:XMLList = node.arg.(@key == "name");
			var methodNode:XML = node.parent();
			_methodName = XMLList(methodNode.@name).toString();
			gatherParameters(methodNode, nameArgs);
		}
		
		
		/**
		 * @private
		 */
		protected function gatherParameters(methodNode:XML, nameArgs:XMLList):void
		{
			_parameterInjectionConfigs = new Vector.<ParameterInjectionConfig>();
			var i:int = 0;
			for each (var parameter : XML in methodNode.parameter)
			{
				var injectionName:String = "";
				if (nameArgs[i])
				{
					injectionName = XMLList(nameArgs[i].@value).toString();
				}
				var parameterTypeName:String = XMLList(parameter.@type).toString();
				if (parameterTypeName == "*")
				{
					if (XMLList(parameter.@optional).toString() == "false")
					{
						/* TODO: Find a way to trace name of affected class here */
						throw new InjectorError("Error in method definition of injectee. "
							+ "Required parameters can't have type \"*\".");
					}
					else
					{
						parameterTypeName = null;
					}
				}
				_parameterInjectionConfigs.push(new ParameterInjectionConfig(parameterTypeName, injectionName));
				if (XMLList(parameter.@optional).toString() == "false")
				{
					_requiredParameters++;
				}
				i++;
			}
		}
		
		
		/**
		 * @private
		 */
		protected function gatherParameterValues(target:Object, injector:Injector):Array
		{
			var parameters:Array = [];
			var length:int = _parameterInjectionConfigs.length;
			for (var i:int = 0; i < length; i++)
			{
				var parameterConfig:ParameterInjectionConfig = _parameterInjectionConfigs[i];
				var config:InjectionConfig = injector.getMapping(Class(injector.applicationDomain.getDefinition(parameterConfig.typeName)), parameterConfig.injectionName);
				var injection:Object = config.getResponse(injector);
				if (injection == null)
				{
					if (i >= _requiredParameters)
					{
						break;
					}
					throw(new InjectorError("Injector is missing a rule to handle injection into target "
						+ target + ". Target dependency: " + getQualifiedClassName(config.request)
						+ ", method: " + _methodName + ", parameter: " + (i + 1)));
				}
				parameters[i] = injection;
			}
			return parameters;
		}
	}
}


final class ParameterInjectionConfig
{
	public var typeName:String;
	public var injectionName:String;
	
	public final function ParameterInjectionConfig(typeName:String, injectionName:String)
	{
		this.typeName = typeName;
		this.injectionName = injectionName;
	}
}
