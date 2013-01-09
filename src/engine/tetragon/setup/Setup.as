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
	import tetragon.Main;
	import tetragon.data.Config;
	import tetragon.data.Registry;
	import tetragon.data.Settings;

	import com.hexagonstar.util.reflection.getClassName;
	
	
	/**
	 * Abstract Setup class, used as super class for any other setup classes.
	 */
	public class Setup
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const INITIAL:String			= "initial";
		public static const POST_CONFIG:String		= "postConfig";
		public static const POST_SETTINGS:String	= "postSettings";
		public static const FINAL:String			= "final";
		public static const REGISTRATION:String		= "registration";
		public static const SHUTDOWN:String			= "shutdown";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _main:Main;
		/** @private */
		private var _registrar:Registrar;
		/** @private */
		private var _stepCompleteCallback:Function;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Executes initial startup steps.
		 */
		public function startupInitial():void
		{
			/* Abstract method! */
			complete(INITIAL);
		}
		
		
		/**
		 * Executes startup tasks that need to be done after the config has been loaded but
		 * before the application UI is created.
		 */
		public function startupPostConfig():void
		{
			/* Abstract method! */
			complete(POST_CONFIG);
		}
		
		
		/**
		 * Executes startup tasks that need to be done after app settings have been loaded.
		 */
		public function startupPostSettings():void
		{
			/* Abstract method! */
			complete(POST_SETTINGS);
		}
		
		
		/**
		 * Executes startup tasks that need to be done after the application init process
		 * has finished but before the application grants user interaction or executes
		 * any further logic that happens after the app initialization.
		 */
		public function startupFinal():void
		{
			/* Abstract method! */
			complete(FINAL);
		}
		
		
		/**
		 * Executes the startup's registrations.
		 */
		public function startupRegistration():void
		{
			registerModules();
			registerThemes();
			registerCLICommands();
			registerResourceFileTypes();
			registerComplexTypes();
			registerDataTypes();
			registerResourceProcessors();
			registerEntitySystems();
			registerEntityComponents();
			registerStates();
			registerScreens();
			
			complete(REGISTRATION);
		}
		
		
		/**
		 * Executes the setup's shutdown tasks.
		 */
		public function shutdown():void
		{
			/* Abstract method! */
			complete(SHUTDOWN);
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return getClassName(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The name of the setup.
		 */
		public function get name():String
		{
			/* Abstract method! */
			return "setup";
		}
		
		
		public function get stepCompleteCallback():Function
		{
			return _stepCompleteCallback;
		}
		public function set stepCompleteCallback(v:Function):void
		{
			_stepCompleteCallback = v;
		}
		
		
		/**
		 * A reference to Main.
		 */
		protected function get main():Main
		{
			if (!_main) _main = Main.instance;
			return _main;
		}
		
		
		/**
		 * Config ref, for internal use.
		 */
		protected function get config():Config
		{
			return registry.config;
		}
		
		
		/**
		 * Settings ref, for internal use.
		 */
		protected function get settings():Settings
		{
			return registry.settings;
		}
		
		
		/**
		 * A reference to Registrar.
		 */
		protected function get registrar():Registrar
		{
			if (!_registrar) _registrar = new Registrar();
			return _registrar;
		}
		
		
		/**
		 * A reference to the registry.
		 */
		protected function get registry():Registry
		{
			return main.registry;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Signalizes that the setup has completed a specific setup step.
		 */
		protected function complete(step:String):void
		{
			if (_stepCompleteCallback != null) _stepCompleteCallback(step, name);
		}
		
		
		/**
		 * Used to register module classes.
		 */
		protected function registerModules():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to register themes.
		 */
		protected function registerThemes():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to register commands for the CLI.
		 */
		protected function registerCLICommands():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to register any resource file types to resource file type wrapper classes
		 * for the extra package that this setup is part of. Use the
		 * <code>registerFileType()</code> method inside this method to register any file
		 * types.
		 * 
		 * <p>The engine already maps standard resource file types for image files, data
		 * files, audio files etc. automatically but you can use this method to register
		 * any additional file types.</p>
		 * 
		 * @example
		 * <pre>
		 *    // Register CustomResourceWrapper class to ID "custom" and to file
		 *    // extensions "cst" and "cust" ...
		 *    registerFileType(CustomResourceWrapper, ["custom"], ["cst", "cust"]);
		 * </pre>
		 */
		protected function registerResourceFileTypes():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to register any complex data type classes that are used in entity
		 * component definitions. Complex data types are any data types other than the
		 * basic types like String, Number, Boolean etc. For example Rectangle and Point
		 * would be complex data types. Use the <code>registerComplexType()</code> method
		 * inside this method to register any complex data types.
		 * 
		 * <p>The engine already maps standard complex data types such as Rectangle, Point
		 * Point2D, Point3D etc. automatically but you can use this method to register
		 * any additional types.</p>
		 * 
		 * @example
		 * <pre>
		 *    registerComplexType("customtype", CustomTypeClass);
		 * </pre>
		 */
		protected function registerComplexTypes():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to register any resource data types that require a parser to parse their
		 * data into data objects for the engine. Registering data types is only relevant
		 * for resources defined in the resource index file under the 'data' resource
		 * family. Entity resources are all parsed by the <code>EntityDataParser</code>.
		 * Use the <code>registerDataType</code> method inside this method to register
		 * any custom data types.
		 * 
		 * @example
		 * <pre>
		 *    // Register a data resource type that is defined in the resource index
		 *    // file with group type="MyGameDataResource" ...
		 *    registerDataType("MyGameDataResource", MyGameDataResourceParser);
		 * </pre>
		 */
		protected function registerDataTypes():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to register any resource processor classes that might be required by
		 * certain resource types to process them before they can be used.
		 * 
		 * @example
		 * <pre>
		 *    registerResourceProcessors(SpriteSet.SPRITE_SET, SpriteSetProcessor);
		 * </pre>
		 */
		protected function registerResourceProcessors():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to register entity systems.
		 */
		protected function registerEntitySystems():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to register entity components.
		 */
		protected function registerEntityComponents():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to register states.
		 */
		protected function registerStates():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to register screens.
		 */
		protected function registerScreens():void
		{
			/* Abstract method! */
		}
	}
}
