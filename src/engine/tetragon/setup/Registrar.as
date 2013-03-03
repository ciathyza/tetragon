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
package tetragon.setup
{
	import tetragon.ClassRegistry;
	import tetragon.Main;
	import tetragon.debug.Console;
	import tetragon.debug.Log;
	import tetragon.debug.cli.CLI;
	import tetragon.entity.EntitySystemManager;
	import tetragon.state.StateManager;
	import tetragon.view.ScreenManager2;
	import tetragon.view.theme.UIThemeManager;

	import flash.text.Font;
	
	
	/**
	 * Registrar is used in setup classes to register all kinds of classes and objects.
	 */
	public class Registrar
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _main:Main;
		/** @private */
		//private var _textFormats:TextFormats;
		/** @private */
		private var _themeManager:UIThemeManager;
		/** @private */
		private var _stateManager:StateManager;
		/** @private */
		private var _screenManager:ScreenManager2;
		/** @private */
		private var _entitySystemManager:EntitySystemManager;
		/** @private */
		private var _classRegistry:ClassRegistry;
		/** @private */
		private var _cli:CLI;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function Registrar()
		{
			_main = Main.instance;
			_themeManager = _main.themeManager;
			_stateManager = _main.stateManager;
			_screenManager = _main.screenManager;
			_entitySystemManager = _main.entitySystemManager;
			_classRegistry = _main.classRegistry;
			
			var console:Console = _main.console;
			if (console) _cli = console.cli;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Registers a module.
		 * 
		 * @param moduleID
		 * @param moduleClass
		 * @param initParams
		 * @param initInstantly If true inits the module instantly.
		 */
		public function registerModule(moduleID:String, moduleClass:Class,
			initParams:Object = null, initInstantly:Boolean = true):void
		{
			if (_main.moduleManager.addModuleClass(moduleID, moduleClass, initParams))
			{
				Log.verbose("Registered module class with ID \"" + moduleID + "\".", this);
				if (initInstantly) _main.moduleManager.initModule(moduleID, false);
			}
		}
		
		
		/**
		 * @param themeID
		 * @param themeClass
		 * @param activate
		 */
		public function registerTheme(themeID:String, themeClass:Class, activate:Boolean = false):Boolean
		{
			return _themeManager.registerTheme(themeID, themeClass, activate);
		}
		
		
		/**
		 * Deprecated method!
		 * 
		 * @deprecated
		 * @param fontClass
		 */
		public function registerFont(fontClass:Class):void
		{
			Font.registerFont(fontClass);
			Log.verbose("Registered font " + fontClass + ".", this);
		}
		
		
		/**
		 * @param category
		 * @param trigger
		 * @param shortcut
		 * @param commandClass
		 * @param description
		 */
		public function registerCommand(category:String, trigger:String, shortcut:String,
			commandClass:Class, description:String = null):void
		{
			if (!_cli) return;
			_cli.registerCommand(category, trigger, shortcut, commandClass, description);
		}
		
		
		/**
		 * @param wrapperClass
		 * @param fileTypeName
		 * @param fileTypeIDs
		 * @param fileTypeExtensions
		 */
		protected function registerFileType(wrapperClass:Class, fileTypeName:String,
			fileTypeIDs:Array, fileTypeExtensions:Array = null):void
		{
			_classRegistry.mapResourceFileType(wrapperClass, fileTypeName, fileTypeIDs, fileTypeExtensions);
			Log.verbose("Registered resource file type for IDs \"" + fileTypeIDs + "\".", this);
		}
		
		
		/**
		 * @param complexTypeID
		 * @param clazz
		 */
		public function registerComplexType(complexTypeID:String, clazz:Class):void
		{
			_classRegistry.mapComplexType(complexTypeID, clazz);
			Log.verbose("Registered complex type for ID \"" + complexTypeID + "\".", this);
		}
		
		
		/**
		 * @param dataTypeID
		 * @param dataTypeParserClass
		 */
		public function registerDataType(dataTypeID:String, dataTypeParserClass:Class):void
		{
			_classRegistry.mapDataType(dataTypeID, dataTypeParserClass);
			Log.verbose("Registered datatype parser class for ID \"" + dataTypeID + "\".", this);
		}
		
		
		/**
		 * @param resourceTypeID
		 * @param processorClass
		 */
		public function registerResourceProcessor(resourceTypeID:String, processorClass:Class):void
		{
			_classRegistry.mapResourceProcessor(resourceTypeID, processorClass);
			Log.verbose("Registered resource processor class for resource type \"" + resourceTypeID + "\".", this);
		}
		
		
		/**
		 * @param systemClass
		 */
		public function registerEntitySystem(systemClass:Class):void
		{
			_entitySystemManager.registerSystem(systemClass);
			Log.verbose("Registered entity system class: " + systemClass + ".", this);
		}
		
		
		/**
		 * @param classID
		 * @param componentClass
		 */
		public function registerEntityComponent(classID:String, componentClass:Class):void
		{
			_classRegistry.mapComponentClass(classID, componentClass);
			Log.verbose("Registered entity component class for ID \"" + classID + "\".", this);
		}
		
		
		/**
		 * @param stateID
		 * @param stateClass
		 */
		public function registerState(stateID:String, stateClass:Class):void
		{
			if (_stateManager.registerState(stateID, stateClass))
			{
				Log.verbose("Registered state class for ID \"" + stateID + "\".", this);
			}
		}
		
		
		/**
		 * @param screenID
		 * @param screenClass
		 */
		public function registerScreen(screenID:String, screenClass:Class):void
		{
			_screenManager.registerScreen(screenID, screenClass);
			Log.verbose("Registered screen class for ID \"" + screenID + "\".", this);
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "Registrar";
		}
	}
}
