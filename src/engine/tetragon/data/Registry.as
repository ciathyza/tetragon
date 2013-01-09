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
package tetragon.data
{
	import com.hexagonstar.util.string.TabularText;

	import flash.utils.Dictionary;
	
	
	/**
	 * A global registry for data objects that should be easily accessible. You
	 * can create any number of data objects that act as holders for your game's
	 * data (i.e. as the data model) and map them into the registry for easier
	 * access in any classes where the data object(s) might be needed.
	 * 
	 * <p>Tetragon provides two default data objects, Config and Settings, that
	 * are mapped by default into the registry.</p>
	 */
	public final class Registry
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _registryObjects:Dictionary;
		/** @private */
		private var _config:Config;
		/** @private */
		private var _settings:Settings;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function Registry()
		{
			_registryObjects = new Dictionary();
			map(Config, _config = new Config());
			map(Settings, _settings = new Settings());
			
			init();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Maps a data object into the registry. The object is mapped with
		 * it's class object as the key.
		 * 
		 * @param clazz The class object of the mappable object.
		 * @param object The object to map in the registry.
		 */
		public function map(clazz:Class, object:IRegistryObject):void
		{
			_registryObjects[clazz] = object;
		}
		
		
		/**
		 * Returns the data object that is mapped in the registry under the specified
		 * class object.
		 * 
		 * @param clazz The class object with that the data object is mapped.
		 * @return The mapped data object or null.
		 */
		public function get(clazz:Class):*
		{
			return _registryObjects[clazz];
		}
		
		
		/**
		 * Initializes the Registry and all it's mapped data objects.
		 */
		public function init():void
		{
			for each (var i:IRegistryObject in _registryObjects)
			{
				i.init();
			}
		}
		
		
		/**
		 * Clears all data objects mapped in the registry.
		 */
		public function clear():void
		{
			for each (var i:IRegistryObject in _registryObjects)
			{
				i.clear();
			}
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "Registry";
		}
		
		
		/**
		 * Returns a string dump of the registry list.
		 */
		public function dump():String
		{
			var t:TabularText = new TabularText(2, true, "  ", null, "  ", 0, ["CLASS", "OBJECT"]);
			for (var key:String in _registryObjects)
			{
				t.add([key, _registryObjects[key]]);
			}
			return toString() + "\n" + t;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * A helper accessor for quickly retrieving the Config data object. Can be used
		 * instead of getObject().
		 */
		public function get config():Config
		{
			return _config;
		}
		
		
		/**
		 * A helper accessor for quickly retrieving the Settings data object. Can be used
		 * instead of getObject().
		 */
		public function get settings():Settings
		{
			return _settings;
		}
	}
}
