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
package tetragon.command.env
{
	import tetragon.EngineInfo;
	import tetragon.IAppInfo;
	import tetragon.Main;
	import tetragon.command.CLICommand;
	import tetragon.data.Params;
	import tetragon.debug.Console;
	import tetragon.debug.Log;
	import tetragon.debug.LogLevel;
	import tetragon.file.loaders.ConfigLoader;
	import tetragon.file.loaders.KeyBindingsLoader;
	import tetragon.file.resource.Resource;
	import tetragon.file.resource.ResourceIndex;
	import tetragon.file.resource.ResourceManager;
	import tetragon.file.resource.ResourceStatus;
	import tetragon.setup.*;

	import flash.events.Event;
	
	
	/**
	 * Executes the application initialization procedure. This command creates
	 * the setup for any application (web- and desktop-based) and additionally
	 * the air setup for desktop-based applications and utilizes these to run
	 * through the initialization which consists of the following steps:
	 * 
	 * 1. Initial
	 * 2. Load application config file "app.ini" (if not set to ignored by params!)
	 * 3. Post-Config
	 * 4. Resource Manager initialization
	 * 5. Post-Resource
	 * 6. Final
	 */
	public class StartupApplicationCommand extends CLICommand
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _configLoader:ConfigLoader;
		/** @private */
		private var _keyBindingsLoader:KeyBindingsLoader;
		/** @private */
		private var _setups:Vector.<SetupVO>;
		/** @private */
		private var _settingsFileIDs:Array;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Execute the command.
		 */ 
		override public function execute():void
		{
			Log.info("Starting up...", this);
			
			createSetups();
			startupInitial();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
			if (_configLoader) _configLoader.dispose();
			if (_keyBindingsLoader) _keyBindingsLoader.dispose();
			_configLoader = null;
			_keyBindingsLoader = null;
			_setups = null;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		override public function toString():String
		{
			return "Startup";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get name():String
		{
			return "startupApplication";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onSetupStepComplete(setupStep:String, setupName:String):void
		{
			if (checkComplete(setupName, setupStep))
			{
				switch (setupStep)
				{
					case Setup.INITIAL:
						loadApplicationConfig();
						break;
					case Setup.POST_CONFIG:
						initResourceManager();
						break;
					case Setup.POST_SETTINGS:
						startupFinal();
						break;
					case Setup.FINAL:
						startupRegistration();
				}
			}
		}
		
		
		private function onConfigLoadComplete():void
		{
			_configLoader.completeSignal.remove(onConfigLoadComplete);
			_configLoader.errorSignal.remove(onConfigLoadError);
			loadKeyBindings();
		}
		
		
		private function onConfigLoadError(message:String):void
		{
			//Log.warn("Config file not loaded! (error was: " + message + ")", this);
			_configLoader.completeSignal.remove(onConfigLoadComplete);
			_configLoader.errorSignal.remove(onConfigLoadError);
			loadKeyBindings();
		}
		
		
		private function onKeyBindingsLoadComplete():void
		{
			_keyBindingsLoader.completeSignal.remove(onKeyBindingsLoadComplete);
			_keyBindingsLoader.errorSignal.remove(onKeyBindingsLoadError);
			startupPostConfig();
		}
		
		
		private function onKeyBindingsLoadError(message:String):void
		{
			//Log.warn("Keybindings file not loaded! (error was: " + message + ")", this);
			_keyBindingsLoader.completeSignal.remove(onKeyBindingsLoadComplete);
			_keyBindingsLoader.errorSignal.remove(onKeyBindingsLoadError);
			startupPostConfig();
		}
		
		
		private function onResourceManagerReady(e:Event):void
		{
			main.resourceManager.removeEventListener(e.type, onResourceManagerReady);
			loadSettings();
		}
		
		
		private function onSettingsLoadComplete():void
		{
			if (_settingsFileIDs && _settingsFileIDs.length > 0)
			{
				var rm:ResourceManager = main.resourceManager;
				var ri:ResourceIndex = rm.resourceIndex;
				for (var i:uint = 0; i < _settingsFileIDs.length; i++)
				{
					var r:Resource = ri.getResource(_settingsFileIDs[i]);
					if (r.status == ResourceStatus.FAILED)
					{
						Log.error("Failed loading settings: \"" + r.id + "\".", this);
					}
					else
					{
						Log.verbose("Loaded settings: \"" + r.id + "\".", this);
						/* Settings have been parsed into settings map so their resource
						 * can be unloaded again. */
						rm.unload(_settingsFileIDs);
					}
				}
			}
			
			startupPostSettings();
		}
		
		
		private function onResourcePreloadComplete():void
		{
			Log.debug("Preloading resources complete.", this);
			finalize();
		}
		
		
		private function onResourcePreloadError(r:Resource):void
		{
			if (r) Log.warn("Failed to preload resource with ID \"" + r.id + "\".", this);
			else Log.warn("Failed to preload an undefined resource.", this);
			finalize();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function createSetups():void
		{
			var i:uint;
			_setups = new Vector.<SetupVO>();
			
			/* Add any additional setups that are listed in AppSetups ... */
			var a:Array = main.setups;
			for (i = 0; i < a.length; i++)
			{
				var clazz:Class = a[i];
				if (clazz)
				{
					var setup:* = new clazz();
					if (setup is Setup)
					{
						_setups.push(new SetupVO(setup));
					}
					else
					{
						Log.fatal("Setup \"" + setup + "\" is not of type Setup!", this);
					}
				}
			}
			
			if (Log.verboseLoggingEnabled)
			{
				var s:String = "Used setups: ";
				for (i = 0; i < _setups.length; i++)
				{
					s += _setups[i].setup.name + ", ";
				}
				Log.verbose(s.substr(0, s.length - 2), this);
			}
		}
		
		
		/**
		 * Executes setup code that should be taken care of before the application
		 * config is loaded.
		 */
		private function startupInitial():void
		{
			if (Log.verboseLoggingEnabled)
			{
				Log.delimiter(40, LogLevel.DEBUG);
				Log.verbose("INITIAL SETUP ...", this);
			}
			executeSetup(Setup.INITIAL);
		}
		
		
		/**
		 * Initiates the loading of the application config file (app.ini).
		 */
		private function loadApplicationConfig():void
		{
			/* If config should not be loaded, carry on to the next step directly. */
			if (Main.params && (Main.params.getParam(Params.IGNORE_INI_FILE) == true))
			{
				loadKeyBindings();
			}
			else
			{
				/* Create ini filename that uses the same first part as the SWF. This
				 * assures that we can have several SWFs with their own ini file if needed. */
				_configLoader = new ConfigLoader();
				_configLoader.completeSignal.addOnce(onConfigLoadComplete);
				_configLoader.errorSignal.addOnce(onConfigLoadError);
				_configLoader.load();
			}
		}
		
		
		/**
		 * Initiates the loading of the key bindings file (keybindings.ini).
		 */
		private function loadKeyBindings():void
		{
			/* If key bindings should not be loaded, carry on to the next step directly. */
			if (Main.params && (Main.params.getParam(Params.IGNORE_KEYBINDINGS_FILE) == true))
			{
				startupPostConfig();
			}
			else
			{
				_keyBindingsLoader = new KeyBindingsLoader();
				_keyBindingsLoader.completeSignal.addOnce(onKeyBindingsLoadComplete);
				_keyBindingsLoader.errorSignal.addOnce(onKeyBindingsLoadError);
				_keyBindingsLoader.load();
			}
		}
		
		
		/**
		 * Executes setup code that should be taken care of after the application
		 * config is loaded but before the application UI (and console) is created.
		 */
		private function startupPostConfig():void
		{
			if (Log.verboseLoggingEnabled)
			{
				Log.delimiter(40, LogLevel.DEBUG);
				Log.verbose("POST-CONFIG SETUP ...", this);
			}
			executeSetup(Setup.POST_CONFIG);
		}
		
		
		/**
		 * Initializes the Resource Manager.
		 */
		private function initResourceManager():void
		{
			main.resourceManager.addEventListener(Event.COMPLETE, onResourceManagerReady);
			main.resourceManager.init(main.resourceBundleClass);
		}
		
		
		/**
		 * Loads the settings from the resources.
		 */
		private function loadSettings():void
		{
			_settingsFileIDs = main.resourceManager.resourceIndex.getSettingsFileIDs();
			if (_settingsFileIDs && _settingsFileIDs.length > 0)
			{
				main.resourceManager.load(_settingsFileIDs, onSettingsLoadComplete);
			}
			else
			{
				onSettingsLoadComplete();
			}
		}
		
		
		private function startupPostSettings():void
		{
			if (Log.verboseLoggingEnabled)
			{
				Log.delimiter(40, LogLevel.DEBUG);
				Log.verbose("POST-SETTINGS SETUP ...", this);
			}
			executeSetup(Setup.POST_SETTINGS);
		}
		
		
		private function startupFinal():void
		{
			if (Log.verboseLoggingEnabled)
			{
				Log.delimiter(40, LogLevel.DEBUG);
				Log.verbose("FINAL SETUP ...", this);
			}
			executeSetup(Setup.FINAL);
		}
		
		
		private function startupRegistration():void
		{
			if (Log.verboseLoggingEnabled)
			{
				Log.delimiter(40, LogLevel.DEBUG);
				Log.verbose("REGISTRATION SETUP ...", this);
			}
			executeSetup(Setup.REGISTRATION);
			Log.verbose("All registrations complete.", this);
			
			preloadResources();
		}
		
		
		private function preloadResources():void
		{
			var ids:Array = main.resourceManager.resourceIndex.preloadResourceIDs;
			if (ids && ids.length > 0)
			{
				if (Log.verboseLoggingEnabled)
				{
					Log.delimiter(40, LogLevel.DEBUG);
					Log.verbose("PRELOADING RESOURCES ...", this);
				}
				main.resourceManager.load(ids, onResourcePreloadComplete, null,
					onResourcePreloadError);
			}
			else
			{
				finalize();
			}
		}
		
		
		private function finalize():void
		{
			var i:IAppInfo = main.appInfo;
			Log.info("Application startup complete.", this);
			Log.linefeed();
			Log.info(Console.LINED + i.name + " v" + i.version + " build #" + i.build
				+ (i.milestone.length > 0 ? " \"" + i.milestone + "\"" : "")
				+ " " + i.releaseStage + " (" + i.buildType
				+ (i.isDebug ? " debug" : "") + ")" + Console.LINED);
			Log.info(EngineInfo.NAME + " v" + EngineInfo.VERSION + "." + EngineInfo.BUILD
				+ " \"" + EngineInfo.MILESTONE + "\"");
			if (main.console) main.console.welcome();
			Log.linefeed();
			
			complete();
		}
		
		
		private function executeSetup(step:String):void
		{
			var len:uint = _setups.length;
			for (var i:uint = 0; i < len; i++)
			{
				var vo:SetupVO = _setups[i];
				var s:Setup = vo.setup;
				
				Log.verbose("-- Executing " + step + " setup on " + s.name + " ...", this);
				
				switch (step)
				{
					case Setup.INITIAL:
						s.stepCompleteCallback = onSetupStepComplete;
						s.startupInitial();
						break;
					case Setup.POST_CONFIG:
						s.stepCompleteCallback = onSetupStepComplete;
						s.startupPostConfig();
						break;
					case Setup.POST_SETTINGS:
						s.stepCompleteCallback = onSetupStepComplete;
						s.startupPostSettings();
						break;
					case Setup.FINAL:
						s.stepCompleteCallback = onSetupStepComplete;
						s.startupFinal();
						break;
					case Setup.REGISTRATION:
						s.startupRegistration();
				}
			}
		}
		
		
		private function checkComplete(setupID:String, step:String):Boolean
		{
			var vo:SetupVO;
			var complete:Boolean = false;
			
			/* Find current finished setup and mark current setup step as complete. */
			for (var i:uint = 0; i < _setups.length; i++)
			{
				if (_setups[i].setup.name == setupID)
				{
					vo = _setups[i];
					switch (step)
					{
						case Setup.INITIAL:
							vo.initialStepComplete = true;
							complete = checkAllEqualSetupStepsComplete(step);
							break;
						case Setup.POST_CONFIG:
							vo.postConfigStepComplete = true;
							complete = checkAllEqualSetupStepsComplete(step);
							break;
						case Setup.POST_SETTINGS:
							vo.postSettingsStepComplete = true;
							complete = checkAllEqualSetupStepsComplete(step);
							break;
						case Setup.FINAL:
							vo.finalStepComplete = true;
							complete = checkAllEqualSetupStepsComplete(step);
							break;
					}
				}
			}
			return complete;
		}
		
		
		private function checkAllEqualSetupStepsComplete(step:String):Boolean
		{
			for (var i:uint = 0; i < _setups.length; i++)
			{
				var vo:SetupVO = _setups[i];
				switch (step)
				{
					case Setup.INITIAL:
						if (!vo.initialStepComplete) return false;
						break;
					case Setup.POST_CONFIG:
						if (!vo.postConfigStepComplete) return false;
						break;
					case Setup.POST_SETTINGS:
						if (!vo.postSettingsStepComplete) return false;
						break;
					case Setup.FINAL:
						if (!vo.finalStepComplete) return false;
						break;
				}
			}
			return true;
		}
	}
}


import tetragon.setup.Setup;

/**
 * @private
 */
final class SetupVO
{
	public var setup:Setup;
	public var initialStepComplete:Boolean;
	public var postConfigStepComplete:Boolean;
	public var postSettingsStepComplete:Boolean;
	public var finalStepComplete:Boolean;
	
	public function SetupVO(setup:Setup = null)
	{
		this.setup = setup;
	}
}
