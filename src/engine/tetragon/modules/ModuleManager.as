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
package tetragon.modules
{
	import tetragon.core.signals.Signal;
	import tetragon.debug.Log;
	import tetragon.util.string.TabularText;
	
	
	/**
	 * ModuleManager class
	 */
	public final class ModuleManager
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Contains ModuleClassVO objects.
		 * @private
		 */
		private var _moduleClasses:Object;
		/** @private */
		private var _moduleCount:uint;
		
		/**
		 * Map with IModule objects.
		 * @private
		 */
		private var _initializedModules:Object;
		/** @private */
		private var _initializedModuleCount:uint;
		
		/** @private */
		private var _modulePriority:int;
		
		/** @private */
		private var _asyncModules:Object;
		/** @private */
		private var _asyncComplete:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _allModulesCompleteSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Used to add module classes. Only used internally. Do not touch!
		 * 
		 * @param id
		 * @param priority
		 * @param moduleClass
		 * @param initParams
		 * 
		 * @return true or false.
		 */
		public function addModuleClass(id:String, moduleClass:Class, initParams:Object):Boolean
		{
			if (!_moduleClasses)
			{
				_moduleClasses = {};
				_moduleCount = 0;
				_modulePriority = 0;
			}
			if (!_moduleClasses[id])
			{
				_moduleClasses[id] = new ModuleClassVO(id, _modulePriority, moduleClass, initParams);
				_moduleCount++;
				_modulePriority++;
				return true;
			}
			return false;
		}
		
		
		/**
		 * Used to add modules. Only used internally. Do not touch!
		 * 
		 * @param module
		 * @return true or false.
		 */
		public function addModule(module:IModule):Boolean
		{
			if (!_initializedModules)
			{
				_initializedModules = {};
				_initializedModuleCount = 0;
			}
			
			if (!_initializedModules[module.id])
			{
				_initializedModules[module.id] = module;
				_initializedModuleCount++;
				return true;
			}
			return false;
		}
		
		
		/**
		 * Initializes a module. This instanciates a module class and calls it's
		 * init method.
		 * 
		 * @param moduleID
		 * @param start If true starts  the module automatically if it's autoStart
		 *        property is set to true.
		 * @return true if the module was initialized  successfully, false if not.
		 */
		public function initModule(moduleID:String, start:Boolean = true):Boolean
		{
			var vo:ModuleClassVO = _moduleClasses[moduleID];
			if (!vo)
			{
				fail("Could not initialize module with ID \"" + moduleID
					+ "\"! No module class with this ID was found.");
				return false;
			}
			
			var obj:* = new vo.clazz();
			if (obj is IModule)
			{
				var module:IModule = obj;
				module.id = vo.id;
				module.priority = vo.priority;
				module.initParams = vo.initParams;
				
				if (!_initializedModules)
				{
					_initializedModules = {};
					_initializedModuleCount = 0;
				}
				
				/* Module is already running! */
				if (_initializedModules[module.id])
				{
					fail("Module with ID \"" + moduleID + "\" is already initialized.", true);
					return false;
				}
				
				_initializedModules[module.id] = module;
				_initializedModuleCount++;
				module.init();
				verbose("Initialized module \"" + module.id + "\".");
				if (start) startModule(module);
				return true;
			}
			else
			{
				fail("Tried to initialize a module class that is not of type IModule.");
				return false;
			}
		}
		
		
		/**
		 * Disposes (de-initializes) a module.
		 * 
		 * @param moduleID
		 * @return true if the module was disposed successfully, false if not.
		 */
		public function disposeModule(moduleID:String):Boolean
		{
			var module:IModule = _initializedModules[moduleID];
			if (!module)
			{
				fail("Could not dispose module with ID \"" + moduleID
					+ "\"! Module was not initialized or not found.");
				return false;
			}
			
			module.dispose();
			delete _initializedModules[moduleID];
			_initializedModuleCount--;
			verbose("Disposed module \"" + module.id + "\".");
			return true;
		}
		
		
		/**
		 * Starts all initialized module classes in the same order they were added. This
		 * method exists mainly for being used by the application startup command.
		 * 
		 * @param autoStartOnly If true only starts modules that have autoStartOnly
		 *        set to true.
		 */
		public function startModules(autoStartOnly:Boolean = false):void
		{
			if (!_initializedModules)
			{
				onAsyncModuleComplete();
				return;
			}
			
			_asyncModules = null;
			
			var sortArray:Array = [];
			var count:uint = 0;
			var m:IModule;
			
			for each (m in _initializedModules)
			{
				sortArray.push(m);
			}
			sortArray.sortOn("priority", Array.NUMERIC);
			
			for (var i:uint = 0; i < sortArray.length; i++)
			{
				m = sortArray[i];
				if (autoStartOnly && !m.autoStart)
				{
					continue;
				}
				startModule(m);
				++count;
			}
			
			/* Still need to dispatch in case no modules (or no async modules) found! */
			if (count == 0 || !_asyncModules) onAsyncModuleComplete();
		}
		
		
		/**
		 * Starts a module.
		 * 
		 * @param module
		 */
		public function startModule(module:IModule):void
		{
			if (module.started) return;
			if (module is IAsyncModule)
			{
				if (!_asyncModules)
				{
					_asyncModules = {};
					_asyncComplete = false;
				}
				_asyncModules[module.id] = module;
				(module as IAsyncModule).asyncCompleteSignal.addOnce(onAsyncModuleComplete);
			}
			debug("Starting module \"" + module.id + "\" (priority: " + module.priority
				+ ", async: " + (module is IAsyncModule) + ") ...");
			module.start();
			module.started = true;
		}
		
		
		/**
		 * Stops a module.
		 * 
		 * @param module
		 */
		public function stopModule(module:IModule):void
		{
			if (!module.started) return;
			debug("Stopping module \"" + module.id + "\" ...");
			module.stop();
			module.started = false;
		}
		
		
		/**
		 * Returns the started module that is mapped with the specified moduleID or null if
		 * no module was mapped with that ID.
		 * 
		 * @param moduleID
		 * @return An IModule object or null.
		 */
		public function getModule(moduleID:String):*
		{
			if (!_initializedModules) return null;
			return _initializedModules[moduleID];
		}
		
		
		/**
		 * Removes a mapped module class.
		 * 
		 * @param moduleID
		 */
		public function removeModuleClass(moduleID:String):void
		{
			if (!_moduleClasses) return;
			if (_initializedModules[moduleID])
			{
				disposeModule(moduleID);
			}
			if (_moduleClasses[moduleID])
			{
				delete _moduleClasses[moduleID];
				_moduleCount--;
			}
		}
		
		
		/**
		 * Returns a string dump of all mapped modules.
		 */
		public function dump():String
		{
			var t:TabularText = new TabularText(8, true, "  ", null, "  ", 0, ["ID", "PRIORITY", "INIT", "STARTED", "ASYNC", "NAME", "VERSION", "AUTHOR"]);
			for (var id:String in _moduleClasses)
			{
				var vo:ModuleClassVO = _moduleClasses[id];
				var init:String = "";
				var started:String;
				var async:String;
				var m:IModule = null;
				var mi:IModuleInfo = null;
				var name:String = "";
				var version:String = "";
				var author:String = "";
				
				if (_initializedModules && _initializedModules[id])
				{
					m = _initializedModules[id];
					mi = m.moduleInfo;
					init = "true";
					started = m.started ? "true" : "";
					async = (m is IAsyncModule) ? "true" : "";
					if (mi)
					{
						name = mi.name;
						version = mi.version + "." + mi.build;
						author = mi.author;
					}
				}
				t.add([vo.id, vo.priority, init, started, async, name, version, author]);
			}
			return toString() + ": Modules\n" + t;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "ModuleManager";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get allModulesCompleteSignal():Signal
		{
			if (!_allModulesCompleteSignal) _allModulesCompleteSignal = new Signal();
			return _allModulesCompleteSignal;
		}
		
		
		/**
		 * Amount of all currently mapped modules.
		 */
		public function get moduleCount():uint
		{
			return _moduleCount;
		}
		
		
		/**
		 * Amount of all currently initialized modules.
		 */
		public function get initializedModuleCount():uint
		{
			return _initializedModuleCount;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onAsyncModuleComplete():void
		{
			/* Check if all async started modules are complete. */
			for each (var m:IAsyncModule in _asyncModules)
			{
				if (!m.asyncComplete) return;
			}
			_asyncModules = null;
			
			/* Prevent dispatching allModulesCompleteSignal more than once per init session. */
			if (_asyncComplete) return;
			
			if (_initializedModules) debug("All modules started.");
			if (!_allModulesCompleteSignal) return;
			_allModulesCompleteSignal.dispatch();
			_asyncComplete = true;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @param message
		 */
		private function debug(message:String):void
		{
			Log.debug(message, this);
		}
		
		
		/**
		 * @param message
		 */
		private function verbose(message:String):void
		{
			Log.verbose(message, this);
		}
		
		
		/**
		 * @param message
		 * @param warn
		 */
		private function fail(message:String, warn:Boolean = false):void
		{
			if (!warn) Log.error(message, this);
			else Log.warn(message, this);
		}
	}
}


final class ModuleClassVO
{
	public var id:String;
	public var priority:int;
	public var clazz:Class;
	public var initParams:Object;
	
	public function ModuleClassVO(id:String, priority:int, clazz:Class, initParams:Object)
	{
		this.id = id;
		this.priority = priority;
		this.clazz = clazz;
		this.initParams = initParams;
	}
}
