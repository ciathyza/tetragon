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
package tetragon.env.settings
{
	import com.hexagonstar.net.SharedObjectStatus;
	import com.hexagonstar.signals.Signal;

	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	
	
	/**
	 * This is a class that manages LocalSharedObject settings. You can use this class to
	 * store and recall persistent data to the users harddisk into a local shared object.
	 * 
	 * <p>To store local settings with the LocalSettingsManager you first create a
	 * LocalSettings object and put all settings values into it that need to be stored.
	 * Then you use the <code>store()</code> method to store the settings to disk.</p>
	 * 
	 * @example
	 * <pre>
	 *     // Create a new settings object:
	 *     var ls:LocalSettings = new LocalSettings();
	 *     ls.put("windowPosX", 200);
	 *     ls.put("windowPosY", 150);
	 *     ls.put("dataPath", "c:/user/documents/test/");
	 * 
	 *     // Create the LocalSettingsManager, add signal listeners and store the settings:
	 *     var lsm:LocalSettingsManager = LocalSettingsManager.instance;
	 *     lsm.store(ls);
	 * </pre>
	 * 
	 * <p>At any time you can recall either single or all settings by using the
	 * <code>recall()</code> or <code>recallAll()</code> method:</p>
	 * 
	 * @example
	 * <pre>
	 *     var windowPosX:int = int(LocalSettingsManager.instance.recall("windowPosX"));
	 *     var ls:LocalSettings = LocalSettingsManager.instance.recallAll();
	 * </pre>
	 * 
	 * @see LocalSettings
	 */
	public class LocalSettingsManager
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _settings:LocalSettings;
		/** @private */
		private var _so:SharedObject;
		/** @private */
		private var _minDiskSpace:int = 65536; /* 64 Kilobyte */
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Dispatched when the settings flush is pending, i.e. if the user has permitted
		 * local information storage for objects, but the amount of space allotted is not
		 * sufficient to store the object and Flash Player prompts the user to allow more
		 * space.
		 */
		public var pendingSignal:Signal;
		
		/**
		 * Dispatched when the settings have been successfully written to a file on the
		 * local disk.
		 */
		public var flushedSignal:Signal;
		
		/**
		 * Dispatched when the settings flush failed and the settings could not be stored,
		 * in particular if the user didn't grant more storage space after a FLUSH_PENDING
		 * occured.
		 */
		public var failedSignal:Signal;
		
		/**
		 * Dispatched when an error occured and the settings could not be stored, e.g.
		 * the user did not allow any storage of local data.
		 */
		public var errorSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new LocalSettingsManager instance.
		 */
		public function LocalSettingsManager()
		{
			setup();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Stores the specified value in the local settings object mapped under
		 * the specified key.
		 * 
		 * @example
		 * <pre>
		 *	var ls:LocalSettings = new LocalSettings();
		 *	ls.put("windowPosX", 200);
		 *	ls.put("windowPosY", 150);
		 *	ls.put("dataPath", "c:/user/documents/test/");
		 * </pre>
		 * 
		 * @param key The key under which to store the value.
		 * @param value The value to store.
		 */
		public function put(key:String, value:Object):void
		{
			_settings.put(key, value);
		}
		
		
		/**
		 * Returns the settings value that is mapped with the specified key or
		 * null if the key was not found in the settings.
		 * 
		 * @param key The key under that the value is stored.
		 * @return The settings value or undefined.
		 */
		public function getValue(key:String):Object
		{
			return _settings.getValue(key);
		}
		
		
		/**
		 * Checks whether the local settings contain a settings property.
		 * 
		 * @param key The key to check for existance.
		 * @return true or false.
		 */
		public function contains(key:String):Boolean
		{
			return _so.data.hasOwnProperty(key);
		}
		
		
		/**
		 * Returns the specified setting value from the LocalSharedObject.
		 * 
		 * @param key The key under which the setting is stored.
		 * @return The specified setting value from the LocalSharedObject.
		 */
		public function recall(key:String):*
		{
			var v:* = _so.data[key];
			_settings.put(key, v);
			return v;
		}
		
		
		/**
		 * Returns a LocalSettings object with all settings that are stored in the
		 * LocalSharedObject.
		 * 
		 * @see #LocalSettings
		 * @return A LocalSettings object with all settings.
		 */
		public function recallAll():LocalSettings
		{
			for (var key:String in _so.data)
			{
				_settings.put(key, _so.data[key]);
			}
			return _settings;
		}
		
		
		/**
		 * Tries to store the specified settings.
		 * 
		 * @see #LocalSettings
		 */
		public function store():void
		{
			var status:String;
			var data:Object = _settings.data;
			
			for (var key:Object in data)
			{
				_so.data[key] = data[key];
			}
			
			try
			{
				status = _so.flush(_minDiskSpace);
			}
			catch (err:Error)
			{
				errorSignal.dispatch(err.message);
			}
			
			if (status != null)
			{
				switch (status)
				{
					case SharedObjectFlushStatus.PENDING:
						_so.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
						pendingSignal.dispatch();
						break;
					case SharedObjectFlushStatus.FLUSHED:
						flushedSignal.dispatch();
						break;
				}
			}
		}
		
		
		/**
		 * Purges all of the stored data and deletes the shared object from the disk.
		 */
		public function clear():void
		{
			_so.clear();
		}
		
		
		/**
		 * Returns a String Representation of LocalSettingsManager.
		 * 
		 * @return A String Representation of LocalSettingsManager.
		 */
		public function toString():String
		{
			return "LocalSettingsManager";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The minimum disk space available in bytes that the user must
		 * grant for the settings data to be stored on disk. The default is 51200 (50Kb).
		 */
		public function get minDiskSpace():int
		{
			return _minDiskSpace;
		}
		public function set minDiskSpace(v:int):void
		{
			_minDiskSpace = v;
		}
		
		
		/**
		 * The current size of the local settings object, in bytes.
		 */
		public function get size():uint
		{
			return _so.size;
		}
		
		
		/**
		 * The LocalSettings object used by the local settings manager.
		 */
		public function get settings():LocalSettings
		{
			return _settings;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onNetStatus(e:NetStatusEvent):void
		{
			_so.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			
			switch (e.info["code"])
			{
				case SharedObjectStatus.FLUSH_SUCCESS:
					/* User granted permission, data saved! */
					flushedSignal.dispatch();
					break;
				case SharedObjectStatus.FLUSH_FAILED:
					/* User denied permission, data not saved! */
					failedSignal.dispatch();
					break;
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Sets up the class.
		 * @private
		 */
		private function setup():void
		{
			_settings = new LocalSettings();
			pendingSignal = new Signal();
			flushedSignal = new Signal();
			failedSignal = new Signal();
			errorSignal = new Signal();
			
			try
			{
				_so = SharedObject.getLocal("localSettings");	
			}
			catch (err:Error)
			{
				errorSignal.dispatch(err.message);
			}
		}
	}
}
