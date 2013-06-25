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
package tetragon.core.ioc
{
	import tetragon.core.ioc.injectionpoints.ConstructorInjectionPoint;
	import tetragon.core.ioc.injectionpoints.InjectionPoint;
	import tetragon.core.ioc.injectionpoints.MethodInjectionPoint;
	import tetragon.core.ioc.injectionpoints.NoParamsConstructorInjectionPoint;
	import tetragon.core.ioc.injectionpoints.PostConstructInjectionPoint;
	import tetragon.core.ioc.injectionpoints.PropertyInjectionPoint;
	import tetragon.core.ioc.injectionresults.InjectClassResult;
	import tetragon.core.ioc.injectionresults.InjectOtherRuleResult;
	import tetragon.core.ioc.injectionresults.InjectSingletonResult;
	import tetragon.core.ioc.injectionresults.InjectValueResult;
	import tetragon.util.reflection.getConstructor;

	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	
	public class Injector
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private static var INJECTION_POINTS_CACHE:Dictionary = new Dictionary(true);
		
		private var _parentInjector:Injector;
		private var _applicationDomain:ApplicationDomain;
		private var _mappings:Dictionary;
		private var _injecteeDescriptions:Dictionary;
		private var _attendedToInjectees:Dictionary;
		private var _xmlMetaData:XML;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function Injector(xmlConfig:XML = null)
		{
			_mappings = new Dictionary();
			if (xmlConfig != null)
			{
				_injecteeDescriptions = new Dictionary(true);
			}
			else
			{
				_injecteeDescriptions = INJECTION_POINTS_CACHE;
			}
			_attendedToInjectees = new Dictionary(true);
			_xmlMetaData = xmlConfig;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function mapValue(whenAskedFor:Class, useValue:Object, named:String = ""):*
		{
			var config:InjectionConfig = getMapping(whenAskedFor, named);
			config.setResult(new InjectValueResult(useValue));
			return config;
		}
		
		
		public function mapClass(whenAskedFor:Class, instantiateClass:Class, named:String = ""):*
		{
			var config:InjectionConfig = getMapping(whenAskedFor, named);
			config.setResult(new InjectClassResult(instantiateClass));
			return config;
		}
		
		
		public function mapSingleton(whenAskedFor:Class, named:String = ""):*
		{
			return mapSingletonOf(whenAskedFor, whenAskedFor, named);
		}
		
		
		public function mapSingletonOf(whenAskedFor:Class, useSingletonOf:Class, named:String = ""):*
		{
			var config:InjectionConfig = getMapping(whenAskedFor, named);
			config.setResult(new InjectSingletonResult(useSingletonOf));
			return config;
		}
		
		
		public function mapRule(whenAskedFor:Class, useRule:*, named:String = ""):*
		{
			var config:InjectionConfig = getMapping(whenAskedFor, named);
			config.setResult(new InjectOtherRuleResult(useRule));
			return useRule;
		}
		
		
		public function getMapping(whenAskedFor:Class, named:String = ""):InjectionConfig
		{
			var requestName:String = getQualifiedClassName(whenAskedFor);
			var config:InjectionConfig = _mappings[requestName + "#" + named];
			if (!config)
			{
				config = _mappings[requestName + "#" + named] = new InjectionConfig(whenAskedFor, named);
			}
			return config;
		}
		
		
		public function injectInto(target:Object):void
		{
			if (_attendedToInjectees[target])
			{
				return;
			}
			_attendedToInjectees[target] = true;

			/* get injection points or cache them if this target's
			 * class wasn't encountered before. */
			var targetClass:Class = getConstructor(target);
			var injecteeDescription:InjecteeDescription = _injecteeDescriptions[targetClass] || getInjectionPoints(targetClass);

			var injectionPoints:Vector.<InjectionPoint> = injecteeDescription.injectionPoints;
			var length:int = injectionPoints.length;
			
			for (var i:int = 0; i < length; i++)
			{
				var injectionPoint:InjectionPoint = injectionPoints[i];
				injectionPoint.applyInjection(target, this);
			}
		}
		
		
		public function instantiate(clazz:Class):*
		{
			var injecteeDescription:InjecteeDescription = _injecteeDescriptions[clazz];
			if (!injecteeDescription)
			{
				injecteeDescription = getInjectionPoints(clazz);
			}
			var injectionPoint:InjectionPoint = injecteeDescription.ctor;
			var instance:* = injectionPoint.applyInjection(clazz, this);
			injectInto(instance);
			return instance;
		}
		
		
		public function unmap(clazz:Class, named:String = ""):void
		{
			var mapping:InjectionConfig = getConfigurationForRequest(clazz, named);
			if (!mapping)
			{
				throw new InjectorError("Error while removing an injector mapping: "
					+ "No mapping defined for class " + getQualifiedClassName(clazz)
					+ ", named \"" + named + "\"");
			}
			mapping.setResult(null);
		}
		
		
		public function hasMapping(clazz:Class, named:String = ""):Boolean
		{
			var mapping:InjectionConfig = getConfigurationForRequest(clazz, named);
			if (!mapping)
			{
				return false;
			}
			return mapping.hasResponse(this);
		}
		
		
		public function getInstance(clazz:Class, named:String = ""):*
		{
			var mapping:InjectionConfig = getConfigurationForRequest(clazz, named);
			if (!mapping || !mapping.hasResponse(this))
			{
				throw new InjectorError("Error while getting mapping response: "
					+ "No mapping defined for class " + getQualifiedClassName(clazz)
					+ ", named \"" + named + "\"");
			}
			return mapping.getResponse(this);
		}
		
		
		public function createChildInjector(applicationDomain:ApplicationDomain = null):Injector
		{
			var injector:Injector = new Injector();
			injector.applicationDomain = applicationDomain;
			injector.parentInjector = this;
			return injector;
		}
		
		
		public static function purgeInjectionPointsCache():void
		{
			INJECTION_POINTS_CACHE = new Dictionary(true);
		}
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		public function get applicationDomain():ApplicationDomain
		{
			return _applicationDomain ? _applicationDomain : ApplicationDomain.currentDomain;
		}
		public function set applicationDomain(v:ApplicationDomain):void
		{
			_applicationDomain = v;
		}
		
		
		public function get parentInjector():Injector
		{
			return _parentInjector;
		}
		public function set parentInjector(v:Injector):void
		{
			/* restore own map of worked injectees if parent injector is removed */
			if (_parentInjector && !v)
			{
				_attendedToInjectees = new Dictionary(true);
			}
			_parentInjector = v;
			/* use parent's map of worked injectees */
			if (v)
			{
				_attendedToInjectees = v.attendedToInjectees;
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Internal
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		internal function getAncestorMapping(whenAskedFor:Class, named:String = null):InjectionConfig
		{
			var parent:Injector = _parentInjector;
			while (parent)
			{
				var parentConfig:InjectionConfig = parent.getConfigurationForRequest(whenAskedFor, named, false);
				if (parentConfig && parentConfig.hasOwnResponse())
				{
					return parentConfig;
				}
				parent = parent.parentInjector;
			}
			return null;
		}
		
		
		/**
		 * @private
		 */
		internal function get attendedToInjectees():Dictionary
		{
			return _attendedToInjectees;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function getInjectionPoints(clazz:Class):InjecteeDescription
		{
			var description:XML = describeType(clazz);
			if (description.@name != "Object" && description.factory.extendsClass.length() == 0)
			{
				throw new InjectorError("Interfaces can't be used as instantiatable classes.");
			}
			var injectionPoints:Vector.<InjectionPoint> = new Vector.<InjectionPoint>();
			var node:XML;
			
			/* This is where we have to wire in the XML... */
			if (_xmlMetaData)
			{
				createInjectionPointsFromConfigXML(description);
				addParentInjectionPoints(description, injectionPoints);
			}
			
			/* get constructor injections */
			var ctorInjectionPoint:InjectionPoint;
			node = description.factory.constructor[0];
			if (node)
			{
				ctorInjectionPoint = new ConstructorInjectionPoint(node, clazz, this);
			}
			else
			{
				ctorInjectionPoint = new NoParamsConstructorInjectionPoint();
			}
			
			/* get injection points for variables */
			var injectionPoint:InjectionPoint;
			for each (node in description.factory.*.(name() == "variable" || name() == "accessor").metadata.(@name == "Inject"))
			{
				injectionPoint = new PropertyInjectionPoint(node);
				injectionPoints.push(injectionPoint);
			}
			
			/* get injection points for methods */
			for each (node in description.factory.method.metadata.(@name == "Inject"))
			{
				injectionPoint = new MethodInjectionPoint(node, this);
				injectionPoints.push(injectionPoint);
			}
			
			/* get post construct methods */
			var postConstructMethodPoints:Array = [];
			for each (node in description.factory.method.metadata.(@name == "PostConstruct"))
			{
				injectionPoint = new PostConstructInjectionPoint(node, this);
				postConstructMethodPoints.push(injectionPoint);
			}
			
			if (postConstructMethodPoints.length > 0)
			{
				postConstructMethodPoints.sortOn("order", Array.NUMERIC);
				injectionPoints.push.apply(injectionPoints, postConstructMethodPoints);
			}
			
			var injecteeDescription:InjecteeDescription = new InjecteeDescription(ctorInjectionPoint, injectionPoints);
			_injecteeDescriptions[clazz] = injecteeDescription;
			return injecteeDescription;
		}
		
		
		/**
		 * @private
		 */
		private function getConfigurationForRequest(clazz:Class, named:String, traverseAncestors:Boolean = true):InjectionConfig
		{
			var requestName:String = getQualifiedClassName(clazz);
			var config:InjectionConfig = _mappings[requestName + "#" + named];
			if (!config && traverseAncestors && _parentInjector && _parentInjector.hasMapping(clazz, named))
			{
				config = getAncestorMapping(clazz, named);
			}
			return config;
		}
		
		
		/**
		 * @private
		 */
		private function createInjectionPointsFromConfigXML(description:XML):void
		{
			var n:XML;
			
			/* first, clear out all "Inject" metadata, we want a clean slate to have
			 * the result work the same in the Flash IDE and MXMLC. */
			for each (n in description..metadata.(@name == "Inject" || @name == "PostConstruct"))
			{
				delete XMLList(n.parent()).metadata.(@name == "Inject" || @name == "PostConstruct")[0];
			}
			
			/* Now, we create the new injection points based on the given xml file. */
			var className:String = description.factory.@type;
			for each (n in _xmlMetaData.type.(@name == className).children())
			{
				var metaNode:XML = <metadata/>;
				if (n.name() == "postconstruct")
				{
					metaNode.@name = "PostConstruct";
					if (XMLList(n.@order).length())
					{
						metaNode.appendChild(<arg key='order' value={n.@order}/>);
					}
				}
				else
				{
					metaNode.@name = "Inject";
					if (XMLList(n.@injectionname).length())
					{
						metaNode.appendChild(<arg key="name" value={n.@injectionname}/>);
					}
					for each (var arg:XML in n.arg)
					{
						metaNode.appendChild(<arg key="name" value={arg.@injectionname}/>);
					}
				}
				
				var typeNode:XML;
				
				if (n.name() == "constructor")
				{
					typeNode = description.factory[0];
				}
				else
				{
					typeNode = description.factory.*.(attribute("name") == n.@name)[0];
					if (!typeNode)
					{
						throw new InjectorError("Error in XML configuration: Class \"" + className
							+ "\" doesn't contain the instance member \"" + n.@name + "\"");
					}
				}
				typeNode.appendChild(metaNode);
			}
		}
		
		
		/**
		 * @private
		 */
		private function addParentInjectionPoints(description:XML, injectionPoints:Vector.<InjectionPoint>):void
		{
			var parentClassName:String = description.factory.extendsClass.@type[0];
			if (!parentClassName) return;
			var parentClass:Class = Class(getDefinitionByName(parentClassName));
			var parentDescription:InjecteeDescription = _injecteeDescriptions[parentClass] || getInjectionPoints(parentClass);
			var parentInjectionPoints:Vector.<InjectionPoint> = parentDescription.injectionPoints;
			injectionPoints.push.apply(injectionPoints, parentInjectionPoints);
		}
	}
}



import tetragon.core.ioc.injectionpoints.InjectionPoint;


final class InjecteeDescription
{
	public var ctor:InjectionPoint;
	public var injectionPoints:Vector.<InjectionPoint>;
	
	
	public function InjecteeDescription(ctor:InjectionPoint, injectionPoints:Vector.<InjectionPoint>)
	{
		this.ctor = ctor;
		this.injectionPoints = injectionPoints;
	}
}
