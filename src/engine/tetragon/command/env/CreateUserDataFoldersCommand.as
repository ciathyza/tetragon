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
	import tetragon.command.CLICommand;
	import tetragon.data.Config;
	import tetragon.data.Settings;
	import tetragon.debug.Log;
	import tetragon.util.file.getUserDataPath;

	import flash.filesystem.File;
	
	
	/**
	 * This command makes sure that the user data folder and it's subfolders exist.
	 * If any of these folders don't exist, they are created.
	 */
	public class CreateUserDataFoldersCommand extends CLICommand
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _config:Config;
		/** @private */
		private var _settings:Settings;
		/** @private */
		private var _sep:String;
		/** @private */
		private var _userDataPath:File;
		/** @private */
		private var _failed:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function execute():void 
		{
			_config = main.registry.config;
			_settings = main.registry.settings;
			_sep = File.separator;
			
			createUserDataFolder();
			createSubFolder(Settings.USER_CONFIG_DIR, _config.getString(Config.USER_CONFIG_FOLDER));
			createSubFolder(Settings.USER_LOGS_DIR, _config.getString(Config.USER_LOGS_FOLDER));
			createSubFolder(Settings.USER_MODS_DIR, _config.getString(Config.USER_MODS_FOLDER));
			createSubFolder(Settings.USER_RESOURCES_DIR, _config.getString(Config.USER_RESOURCES_FOLDER));
			createSubFolder(Settings.USER_SAVEGAMES_DIR, _config.getString(Config.USER_SAVEGAMES_FOLDER));
			createSubFolder(Settings.USER_SCREENSHOTS_DIR, _config.getString(Config.USER_SCREENSHOTS_FOLDER));
			copyDefaultFiles();
			
			complete();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get name():String 
		{
			return "createUserDataFolders";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function createUserDataFolder():void
		{
			_userDataPath = new File(getUserDataPath());
			
			/* Create user data folder if it doesn't exist already. */
			if (!_userDataPath.exists)
			{
				Log.debug("Creating user data folder at \"" + _userDataPath.nativePath + "\" ...", this);
				try
				{
					_userDataPath.createDirectory();
				}
				catch (err:Error)
				{
					fail(err.message);
				}
			}
			
			if (!_failed)
			{
				_settings.setProperty(Settings.USER_DATA_DIR, _userDataPath.nativePath);
			}
		}
		
		
		/**
		 * @private
		 * 
		 * @param settingsKey
		 * @param subFolderName
		 */
		private function createSubFolder(settingsKey:String, subFolderName:String):void
		{
			if (_failed) return;
			if (subFolderName && subFolderName.length > 0)
			{
				var f:File = _userDataPath.resolvePath(subFolderName.toLowerCase());
				if (!f.exists)
				{
					Log.debug("Creating " + subFolderName + " folder at \"" + f.nativePath + "\" ...", this);
					try
					{
						f.createDirectory();
					}
					catch (err:Error)
					{
						fail(err.message);
					}
				}
				if (!_failed)
				{
					_settings.setProperty(settingsKey, f.nativePath);
				}
			}
		}
		
		
		/**
		 * @private
		 */
		private function copyDefaultFiles():void
		{
			var userConfigFolder:String = _settings.getString(Settings.USER_CONFIG_DIR);
			if (userConfigFolder != null)
			{
				var appDir:String = File.applicationDirectory.nativePath;
				
				var appCfg:String = _config.getString(Config.FILENAME_ENGINECONFIG);
				var sourcePath:String = appDir + _sep + main.appInfo.configFolder + _sep + appCfg;
				var targetPath:String = userConfigFolder + _sep + appCfg;
				copyFile(Settings.USER_CONFIG_FILE, sourcePath, targetPath);
				
				var keyBindings:String = _config.getString(Config.FILENAME_KEYBINDINGS);
				sourcePath = appDir + _sep + main.appInfo.configFolder + _sep + keyBindings;
				targetPath = userConfigFolder + _sep + keyBindings;
				copyFile(Settings.USER_KEYBINDINGS_FILE, sourcePath, targetPath);
			}
		}
		
		
		/**
		 * @private
		 * 
		 * @param settingsKey
		 * @param sourcePath
		 * @param targetPath
		 */
		private function copyFile(settingsKey:String, sourcePath:String, targetPath:String):void
		{
			var source:File = new File(sourcePath);
			var target:File = new File(targetPath);
			if (source.exists && !target.exists)
			{
				Log.debug("Copying \"" + sourcePath + "\" to \"" + targetPath + "\" ...", this);
				try
				{
					source.copyTo(target, false);
				}
				catch (err:Error)
				{
					fail(err.message);
				}
			}
			if (!_failed)
			{
				_settings.setProperty(settingsKey, targetPath);
			}
		}
		
		
		/**
		 * @private
		 * 
		 * @param message
		 */
		private function fail(message:String):void
		{
			_failed = true;
			Log.warn("Could not create user data folder or any of it's subfolders. ("
				+ message + ")", this);
		}
	}
}
