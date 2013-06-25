package tetragon.core.au.core
{
	import tetragon.core.au.descriptors.AUConfigurationDescriptor;
	import tetragon.core.au.utils.AUConstants;
	import tetragon.core.au.utils.AUFileUtils;
	import tetragon.core.au.utils.AUVersionUtils;

	import flash.filesystem.File;
	
	
	/**
	 * UpdaterConfiguration class.
	 */
	public class AUUpdaterConfiguration
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _updateURL:String;
		private var _delay:Number;
		private var _isNewerVersionFunction:Function;
		private var _configDescriptor:AUConfigurationDescriptor;
		private var _configFile:File;
		private var _isCheckForUpdateVisible:int;
		private var _isDownloadUpdateVisible:int;
		private var _isDownloadProgressVisible:int;
		private var _isInstallUpdateVisible:int;
		private var _isFileUpdateVisible:int;
		private var _isUnexpectedErrorVisible:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function AUUpdaterConfiguration()
		{
			_delay = -1;
			_isCheckForUpdateVisible = -1;
			_isDownloadUpdateVisible = -1;
			_isDownloadProgressVisible = -1;
			_isInstallUpdateVisible = -1;
			_isFileUpdateVisible = -1;
			_isUnexpectedErrorVisible = -1;
			_isNewerVersionFunction = AUVersionUtils.isNewerVersion;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function validate():void
		{
			if (_configFile)
			{
				if (!_configFile.exists)
				{
					throw new Error("Configuration file \"" + _configFile.nativePath
						+ "\" does not exists on disk.", AUConstants.ERROR_CONFIGURATION_FILE_MISSING);
				}
				var xml:XML = AUFileUtils.readXMLFromFile(_configFile);
				_configDescriptor = new AUConfigurationDescriptor(xml);
				_configDescriptor.validate();
			}
			if (!_updateURL && !_configDescriptor)
			{
				throw new Error("Update URL not set.", AUConstants.ERROR_UPDATE_URL_MISSING);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get updateURL():String
		{
			return _updateURL ? _updateURL : _configDescriptor.url;
		}
		public function set updateURL(v:String):void
		{
			_updateURL = v;
		}
		
		
		public function get delay():Number
		{
			if (_delay < 0)
			{
				if (_configDescriptor && _configDescriptor.checkInterval >= 0)
				{
					return _configDescriptor.checkInterval;
				}
				return 0;
			}
			return _delay;
		}
		public function set delay(v:Number):void
		{
			_delay = v;
		}
		
		
		public function get delayAsMilliseconds():Number
		{
			return delay * AUConstants.DAY_IN_MILLISECONDS;
		}
		
		
		public function get configurationFile():File
		{
			return _configFile;
		}
		public function set configurationFile(v:File):void
		{
			_configFile = v;
		}
		
		
		public function get isNewerVersionFunction():Function
		{
			return _isNewerVersionFunction;
		}
		public function set isNewerVersionFunction(v:Function):void
		{
			_isNewerVersionFunction = v;
		}
		
		
		public function get isCheckForUpdateVisible():Boolean
		{
			if (_isCheckForUpdateVisible >= 0) return _isCheckForUpdateVisible == 1;
			var config:int = dialogVisConfig(AUConfigurationDescriptor.DIALOG_CHECK_FOR_UPDATE);
			if (config >= 0) return config == 1;
			return true;
		}
		public function set isCheckForUpdateVisible(v:Boolean):void
		{
			_isCheckForUpdateVisible = v ? 1 : 0;
		}
		
		
		public function get isDownloadUpdateVisible():Boolean
		{
			if (_isDownloadUpdateVisible >= 0) return _isDownloadUpdateVisible == 1;
			var config:int = dialogVisConfig(AUConfigurationDescriptor.DIALOG_DOWNLOAD_UPDATE);
			if (config >= 0) return config == 1;
			return true;
		}
		public function set isDownloadUpdateVisible(v:Boolean):void
		{
			_isDownloadUpdateVisible = v ? 1 : 0;
		}
		
		
		public function get isDownloadProgressVisible():Boolean
		{
			if (_isDownloadProgressVisible >= 0) return _isDownloadProgressVisible == 1;
			var config:int = dialogVisConfig(AUConfigurationDescriptor.DIALOG_DOWNLOAD_PROGRESS);
			if (config >= 0) return config == 1;
			return true;
		}
		public function set isDownloadProgressVisible(v:Boolean):void
		{
			_isDownloadProgressVisible = v ? 1 : 0;
		}
		
		
		public function get isInstallUpdateVisible():Boolean
		{
			if (_isInstallUpdateVisible >= 0) return _isInstallUpdateVisible == 1;
			var config:int = dialogVisConfig(AUConfigurationDescriptor.DIALOG_INSTALL_UPDATE);
			if (config >= 0) return config == 1;
			return true;
		}
		public function set isInstallUpdateVisible(v:Boolean):void
		{
			_isInstallUpdateVisible = v ? 1 : 0;
		}
		
		
		public function get isFileUpdateVisible():Boolean
		{
			if (_isFileUpdateVisible >= 0) return _isFileUpdateVisible == 1;
			var config:int = dialogVisConfig(AUConfigurationDescriptor.DIALOG_FILE_UPDATE);
			if (config >= 0) return config == 1;
			return true;
		}
		public function set isFileUpdateVisible(v:Boolean):void
		{
			_isFileUpdateVisible = v ? 1 : 0;
		}
		
		
		public function get isUnexpectedErrorVisible():Boolean
		{
			if (_isUnexpectedErrorVisible >= 0) return _isUnexpectedErrorVisible == 1;
			var config:int = dialogVisConfig(AUConfigurationDescriptor.DIALOG_UNEXPECTED_ERROR);
			if (config >= 0) return config == 1;
			return true;
		}
		public function set isUnexpectedErrorVisible(v:Boolean):void
		{
			_isUnexpectedErrorVisible = v ? 1 : 0;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 *  Return -1 if not in configuration file
		 *  1 if visible, 0 if not
		 */
		private function dialogVisConfig(name:String):int
		{
			if (!_configDescriptor) return -1;
			var dialogs:Array = _configDescriptor.defaultUI;
			for (var i:int = 0; i < dialogs.length; i++)
			{
				var dlg:Object = dialogs[i];
				if (name.toLowerCase() == String(dlg["name"]).toLowerCase())
				{
					return Boolean(dlg["visible"]) ? 1 : 0;
				}
			}
			return -1;
		}
	}
}
