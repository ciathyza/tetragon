package tetragon.env.update.airupdater
{
	import tetragon.env.update.airupdater.core.UpdaterConfiguration;
	import tetragon.env.update.airupdater.core.UpdaterHSM;
	import tetragon.env.update.airupdater.core.UpdaterState;
	import tetragon.env.update.airupdater.events.DownloadErrorEvent;
	import tetragon.env.update.airupdater.events.StatusFileUpdateErrorEvent;
	import tetragon.env.update.airupdater.events.StatusFileUpdateEvent;
	import tetragon.env.update.airupdater.events.StatusUpdateErrorEvent;
	import tetragon.env.update.airupdater.events.StatusUpdateEvent;
	import tetragon.env.update.airupdater.events.UpdateEvent;
	import tetragon.env.update.airupdater.states.HSM;
	import tetragon.env.update.airupdater.states.HSMEvent;
	import tetragon.env.update.airupdater.states.UpdateState;
	import tetragon.env.update.airupdater.ui.UpdateUIWrapper;
	import tetragon.env.update.airupdater.utils.Constants;
	import tetragon.env.update.airupdater.utils.FileUtils;
	import tetragon.env.update.airupdater.utils.VersionUtils;

	import com.hexagonstar.util.debug.HLog;

	import flash.desktop.Updater;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.utils.Timer;
	
	
	/** Dispatched after the initialization is complete **/
	[Event(name="initialized", type="tetragon.env.update.airupdater.events.UpdateEvent")]
	
	/** Dispatched just before the update process begins **/
	[Event(name="checkForUpdate", type="tetragon.env.update.airupdater.events.UpdateEvent")]
	
	/** Dispatched when the download of the update file begins **/
	[Event(name="downloadStart", type="tetragon.env.update.airupdater.events.UpdateEvent")]
	
	/** Dispatched when the download of the update file is complete **/
	[Event(name="downloadComplete", type="tetragon.env.update.airupdater.events.UpdateEvent")]
	
	/** Dispatched just before installing the update (cancellable) **/
	[Event(name="beforeInstall", type="tetragon.env.update.airupdater.events.UpdateEvent")]
	
	/** Dispatched when status information is available after parsing the update descriptor (cancellable if an update is available)**/
	[Event(name="updateStatus", type="tetragon.env.update.airupdater.events.StatusUpdateEvent")]
	
	/** Dispatched when an error occured while trying to download or parse the update descriptor **/
	[Event(name="updateError", type="tetragon.env.update.airupdater.events.StatusUpdateErrorEvent")]
	
	/** Dispatched when an error occured while downloading the update file **/
	[Event(name="downloadError", type="tetragon.env.update.airupdater.events.DownloadErrorEvent")]
	
	/** Dispatched when status information is available after parsing the AIR file from installFromAIRFile call (cancellable if an update is available)**/
	[Event(name="fileUpdateStatus", type="tetragon.env.update.airupdater.events.StatusFileUpdateEvent")]
	
	/** Dispatched when an error occured while trying to parse the AIR file from installFromAIRFile call **/
	[Event(name="fileUpdateError", type="tetragon.env.update.airupdater.events.StatusFileUpdateErrorEvent")]
	
	/** Dispatched after the initialization is complete **/
	[Event(name="progress", type="flash.events.ProgressEvent")]
	
	/** Dispatched if something goes wrong with our knowledge **/
	[Event(name="error", type="flash.events.ErrorEvent")]
	
	
	/**
	 * ApplicationUpdater class.
	 */
	public class ApplicationUpdater extends HSM
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		private static const EVENT_INITIALIZE:String	= "initialize";
		private static const EVENT_CHECK_URL:String		= "check.url";
		private static const EVENT_CHECK_FILE:String	= "check.file";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _uiWrapper:UpdateUIWrapper;
		protected var _updateUIClass:Class;
		protected var _configuration:UpdaterConfiguration;
		protected var _state:UpdaterState;
		protected var _updaterHSM:UpdaterHSM;
		
		private var _previousVersion:String = "";
		private var _previousStorage:File;
		private var _installFile:File;
		private var _timer:Timer;
		
		private var _isFirstRun:Boolean = false;
		private var _isInitialized:Boolean = false;
		private var _wasPendingUpdate:Boolean = false;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function ApplicationUpdater()
		{
			super(onStateUninitialized);
			
			init();
			_configuration = new UpdaterConfiguration();
			_state = new UpdaterState();
			
			_updaterHSM = new UpdaterHSM();
			_updaterHSM.configuration = _configuration;
			_updaterHSM.addEventListener(UpdateEvent.CHECK_FOR_UPDATE, dispatch);
			_updaterHSM.addEventListener(StatusUpdateEvent.UPDATE_STATUS, dispatch);
			_updaterHSM.addEventListener(UpdateEvent.DOWNLOAD_START, dispatch);
			_updaterHSM.addEventListener(ProgressEvent.PROGRESS, dispatch);
			_updaterHSM.addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, dispatch);
			_updaterHSM.addEventListener(UpdateEvent.BEFORE_INSTALL, dispatch);
			_updaterHSM.addEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, dispatch);
			_updaterHSM.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, dispatch);
			_updaterHSM.addEventListener(UpdaterHSM.EVENT_INSTALL_TRIGGER, dispatch);
			_updaterHSM.addEventListener(UpdaterHSM.EVENT_FILE_INSTALL_TRIGGER, dispatch);
			_updaterHSM.addEventListener(UpdaterHSM.EVENT_STATE_CLEAR_TRIGGER, onStateClear);
			_updaterHSM.addEventListener(ErrorEvent.ERROR, dispatch);
			_updaterHSM.addEventListener(StatusFileUpdateEvent.FILE_UPDATE_STATUS, dispatch);
			_updaterHSM.addEventListener(StatusFileUpdateErrorEvent.FILE_UPDATE_ERROR, dispatch);
			
			_timer = new Timer(0);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function initialize():void
		{
			dispatch(new Event(EVENT_INITIALIZE));
		}
		
		
		public function checkForUpdate():void
		{
			dispatch(new Event(UpdaterHSM.EVENT_CHECK));
		}
		
		
		public function downloadUpdate():void
		{
			dispatch(new Event(UpdaterHSM.EVENT_DOWNLOAD));
		}
		
		
		public function installUpdate():void
		{
			dispatch(new Event(UpdaterHSM.EVENT_INSTALL));
		}
		
		
		public function installLater():void
		{
			closeUI();
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		public function cancelUpdate():void
		{
			closeUI();
			transition(onStateCancelled);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		public function checkNow():void
		{
			dispatch(new Event(EVENT_CHECK_URL));
		}
		
		
		public function installFromAIRFile(file:File):void
		{
			showUI();
			_installFile = file;
			dispatch(new Event(EVENT_CHECK_FILE));
			_updaterHSM.installFile(file);
		}
		
		
		public function showUpdateUI():void
		{
			showUI();
		}
		
		
		/**
		 * Disposes the class.
		 */
		public function dispose():void
		{
			if (_updaterHSM)
			{
				_updaterHSM.removeEventListener(UpdateEvent.CHECK_FOR_UPDATE, dispatch);
				_updaterHSM.removeEventListener(StatusUpdateEvent.UPDATE_STATUS, dispatch);
				_updaterHSM.removeEventListener(UpdateEvent.DOWNLOAD_START, dispatch);
				_updaterHSM.removeEventListener(ProgressEvent.PROGRESS, dispatch);
				_updaterHSM.removeEventListener(UpdateEvent.DOWNLOAD_COMPLETE, dispatch);
				_updaterHSM.removeEventListener(UpdateEvent.BEFORE_INSTALL, dispatch);
				_updaterHSM.removeEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, dispatch);
				_updaterHSM.removeEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, dispatch);
				_updaterHSM.removeEventListener(UpdaterHSM.EVENT_INSTALL_TRIGGER, dispatch);
				_updaterHSM.removeEventListener(UpdaterHSM.EVENT_FILE_INSTALL_TRIGGER, dispatch);
				_updaterHSM.removeEventListener(UpdaterHSM.EVENT_STATE_CLEAR_TRIGGER, onStateClear);
				_updaterHSM.removeEventListener(ErrorEvent.ERROR, dispatch);
				_updaterHSM.removeEventListener(StatusFileUpdateEvent.FILE_UPDATE_STATUS, dispatch);
				_updaterHSM.removeEventListener(StatusFileUpdateErrorEvent.FILE_UPDATE_ERROR, dispatch);
				_updaterHSM.dispose();
			}
			if (_timer) _timer.removeEventListener(TimerEvent.TIMER, onTimer);
			if (_uiWrapper) _uiWrapper.dispose();
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		override public function toString():String
		{
			return "ApplicationUpdater";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function set updateUIClass(v:Class):void
		{
			_updateUIClass = v;
		}
		
		
		public function get updateURL():String
		{
			return _configuration.updateURL;
		}
		public function set updateURL(v:String):void
		{
			_configuration.updateURL = v;
		}


		public function get delay():Number
		{
			return _configuration.delay;
		}
		public function set delay(v:Number):void
		{
			_configuration.delay = v;
			if (_isInitialized) handlePeriodicalCheck();
		}


		public function get configurationFile():File
		{
			return _configuration.configurationFile;
		}
		public function set configurationFile(v:File):void
		{
			_configuration.configurationFile = v;
		}


		public function get updateDescriptor():XML
		{
			if (_updaterHSM.descriptor) return _updaterHSM.descriptor.getXML();
			return null;
		}
		
		
		public function get isNewerVersionFunction():Function
		{
			return _configuration.isNewerVersionFunction;
		}
		public function set isNewerVersionFunction(v:Function):void
		{
			_configuration.isNewerVersionFunction = v;
		}
		
		
		public function get currentState():String
		{
			if (!_isInitialized) return UpdateState.getStateName(UpdateState.UNINITIALIZED);
			return UpdateState.getStateName(_updaterHSM.getUpdateState());
		}


		public function get isFirstRun():Boolean
		{
			return _isFirstRun;
		}


		public function get wasPendingUpdate():Boolean
		{
			return _wasPendingUpdate;
		}


		public function get currentVersion():String
		{
			return VersionUtils.getApplicationVersion();
		}


		public function get previousVersion():String
		{
			return _previousVersion;
		}


		/**
		 * Set to the storage before installing the update
		 * After a certificate migration the storage will be different
		 * This is NULL if it is the same storage
		 */
		public function get previousApplicationStorageDirectory():File
		{
			return _previousStorage;
		}
		
		
		public function set updateVersion(v:String):void
		{
			if (_uiWrapper)
			{
				_uiWrapper.updateVersion = v;
				_uiWrapper.currentVersion = currentVersion;
			}
		}
		public function set applicationName(v:String):void
		{
			if (_uiWrapper) _uiWrapper.applicationName = v;
		}
		public function set description(v:String):void
		{
			if (_uiWrapper) _uiWrapper.description = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		protected function onStateUninitialized(e:Event):void
		{
			switch(e.type)
			{
				case HSMEvent.ENTER:
					_isInitialized = false;
					break;
				case EVENT_INITIALIZE:
					transition(onStateInitializing);
			}
		}
		
		
		protected function onStateInitializing(e:Event):void
		{
			switch(e.type)
			{
				case HSMEvent.ENTER:
					doInitialize();
					break;
				case UpdateEvent.INITIALIZED:
					_isInitialized = true;
					transition(onStateReady);
					dispatchEvent(e);
					handlePeriodicalCheck();
					break;
				case ErrorEvent.ERROR:
					transition(onStateUninitialized);
					dispatchEvent(e.clone());
			}
		}
		
		
		protected function onStateReady(e:Event):void
		{
			switch(e.type)
			{
				case HSMEvent.ENTER:
					break;
				case EVENT_CHECK_URL:
					transition(onStateRunning);
					dispatch(e);
					break;
				case EVENT_CHECK_FILE:
					transition(onStateRunning);
					dispatch(e);
					break;
				case ErrorEvent.ERROR:
					dispatchEvent(e);
			}
		}
		
		
		protected function onStateRunning(e:Event):void
		{
			switch(e.type)
			{
				case HSMEvent.ENTER:
					break;
				case EVENT_CHECK_URL:
					_state.descriptor.lastCheckDate = new Date();
					_state.saveToStorage();
					handlePeriodicalCheck();
					_updaterHSM.checkAsync(_configuration.updateURL);
					break;
				case EVENT_CHECK_FILE:
					_updaterHSM.installFile(_installFile);
					break;
				case UpdaterHSM.EVENT_CHECK:
				case UpdaterHSM.EVENT_DOWNLOAD:
				case UpdaterHSM.EVENT_INSTALL:
					_updaterHSM.dispatch(e);
					break;
				case UpdateEvent.CHECK_FOR_UPDATE:
				case StatusUpdateEvent.UPDATE_STATUS:
				case UpdateEvent.DOWNLOAD_START:
				case ProgressEvent.PROGRESS:
				case UpdateEvent.BEFORE_INSTALL:
					onDispatchProxy(e);
					break;
				case StatusUpdateErrorEvent.UPDATE_ERROR:
				case DownloadErrorEvent.DOWNLOAD_ERROR:
				case StatusFileUpdateErrorEvent.FILE_UPDATE_ERROR:
				case ErrorEvent.ERROR:
					onDispatchProxy(e);
					transition(onStateReady);
					break;
				case StatusFileUpdateEvent.FILE_UPDATE_STATUS:
					onFileStatus(e as StatusFileUpdateEvent);
					break;
				case UpdateEvent.DOWNLOAD_COMPLETE:
					onDownloadComplete(e as UpdateEvent);
					break;
				case UpdaterHSM.EVENT_INSTALL_TRIGGER:
					doInstall();
					break;
				case UpdaterHSM.EVENT_FILE_INSTALL_TRIGGER:
					doFileInstall();
			}
		}
		
		
		protected function onStateCancelled(e:Event):void
		{
			if (e.type != HSMEvent.ENTER) return;
			_updaterHSM.cancel();
			transition(onStateReady);
		}
		
		
		protected function onDispatchProxy(e:Event):void
		{
			if (!dispatchEvent(e)) e.preventDefault();
		}
		
		
		protected function onTimer(e:TimerEvent):void
		{
			// check must be done if the timer run for the repeatCount times
			var isEventDispatched:Boolean = _timer.currentCount == _timer.repeatCount;
			handlePeriodicalCheck();
			if (isEventDispatched) dispatch(new Event(EVENT_CHECK_URL));
		}
		
		
		protected function onDownloadComplete(e:UpdateEvent):void
		{
			_state.descriptor.previousVersion = VersionUtils.getApplicationVersion();
			_state.descriptor.currentVersion = _updaterHSM.descriptor.version;
			_state.descriptor.storage = File.applicationStorageDirectory;
			_state.saveToStorage();
			onDispatchProxy(e);
		}
		
		
		protected function onFileStatus(e:StatusFileUpdateEvent):void
		{
			if (e.available)
			{
				_state.descriptor.previousVersion = VersionUtils.getApplicationVersion();
				_state.descriptor.currentVersion = e.version;
				_state.descriptor.storage = File.applicationStorageDirectory;
				_state.saveToStorage();
			}
			onDispatchProxy(e);
		}
		
		
		protected function onStateClear(e:Event):void
		{
			_state.resetUpdateData();
			try
			{
				_state.saveToStorage();
			}
			catch(err:Error)
			{
				HLog.warn(toString() + ": The application cannot be updated (state file). " + err.message);
			}
		}
		
		
		protected function onUICreated(e:Event):void
		{
			_uiWrapper.removeEventListener(Event.COMPLETE, onUICreated);
			_uiWrapper.removeEventListener(ErrorEvent.ERROR, onUICreated);
			if (e.type == ErrorEvent.ERROR)
			{
				throw new Error(toString() + ": Cannot create update UI.");
				return;
			}
			HLog.debug(toString() + ": Initialized.");
			dispatch(new UpdateEvent(UpdateEvent.INITIALIZED));
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		protected function doInitialize():void
		{
			_configuration.validate();
			_state.load();
			// return false when updater is called
			// workaround for a update bug
			if (handleFirstRun()) doInitializationComplete();
		}
		
		
		protected function doInitializationComplete():void
		{
			_uiWrapper = new UpdateUIWrapper();
			_uiWrapper.applicationUpdater = this;
			_uiWrapper.updateUIClass = _updateUIClass;
			_uiWrapper.addEventListener(Event.COMPLETE, onUICreated);
			_uiWrapper.addEventListener(ErrorEvent.ERROR, onUICreated);
			_uiWrapper.create();
		}
		
		
		protected function doInstall():void
		{
			HLog.debug(toString() + ": doInstall() ...");
			var updateFile:File = FileUtils.getLocalUpdateFile();
			if (!updateFile.exists)
			{
				// Update file
				_state.resetUpdateData();
				_state.saveToStorage();
				_updaterHSM.cancel();
				throw new Error("Missing update file at install time.", Constants.ERROR_APPLICATION_UPDATE_NO_FILE);
				return;
			}
			try
			{
				_state.descriptor.updaterLaunched = true;
				_state.saveToStorage();
				_state.saveToDocuments();
				doUpdate(updateFile, _updaterHSM.descriptor.version);
			}
			catch(err:Error)
			{
				var msg:String = toString() + ": The application cannot be updated (URL). " + err.message;
				HLog.warn(msg);
				_state.resetUpdateData();
				_state.saveToStorage();
				_updaterHSM.cancel();
				throw new Error(msg, Constants.ERROR_APPLICATION_UPDATE);
			}
		}
		
		
		protected function doFileInstall():void
		{
			HLog.debug(toString() + ": doFileInstall() ...");
			var updateFile:File = _updaterHSM.airFile;
			if (!updateFile.exists)
			{
				_state.resetUpdateData();
				_state.saveToStorage();
				_updaterHSM.cancel();
				throw new Error("Missing update file at install time.", Constants.ERROR_APPLICATION_UPDATE_NO_FILE);
				return;
			}
			try
			{
				_state.descriptor.updaterLaunched = true;
				_state.saveToStorage();
				_state.saveToDocuments();
				doUpdate(updateFile, _updaterHSM.applicationDescriptor.version);
			}
			catch(err:Error)
			{
				var msg:String = toString() + ": The application cannot be updated (file). " + err.message;
				HLog.warn(msg);
				_state.resetUpdateData();
				_state.saveToStorage();
				_updaterHSM.cancel();
				throw new Error(msg, Constants.ERROR_APPLICATION_UPDATE);
			}
		}
		
		
		protected function handleFirstRun():Boolean
		{
			var result:Boolean = true;
			// if currentVersion is set means that there is an update
			if (!_state.descriptor.currentVersion)
			{
				return true;
			}
			if (_state.descriptor.updaterLaunched)
			{
				_wasPendingUpdate = true;
				// update installed OK
				if (_state.descriptor.currentVersion == VersionUtils.getApplicationVersion())
				{
					_isFirstRun = true;
					_previousVersion = _state.descriptor.previousVersion;
					if (_state.descriptor.storage.nativePath != File.applicationStorageDirectory.nativePath)
					{
						_previousStorage = _state.descriptor.storage;
					}
					_state.removeAllFailedUpdates();
					_state.resetUpdateData();
					_state.removePreviousStorageData(_previousStorage);
					_state.saveToStorage();
				}  
				// failed update
				else if (_state.descriptor.previousVersion == VersionUtils.getApplicationVersion())
				{
					// add version from state to failed
					_state.addFailedUpdate(_state.descriptor.currentVersion);
					_state.resetUpdateData();
					_state.saveToStorage();
				}
				// maybe installed a different version ? Reset state
				else
				{
					_wasPendingUpdate = false;
					_state.removeAllFailedUpdates();
					_state.resetUpdateData();
					_state.saveToStorage();
				}
			}
			else
			{
				// postponed update
				if (_state.descriptor.previousVersion == VersionUtils.getApplicationVersion())
				{
					var updateFile:File = FileUtils.getLocalUpdateFile();
					if (!updateFile.exists)
					{
						_state.resetUpdateData();
						return true;
					}
					try
					{
						_state.descriptor.updaterLaunched = true;
						_state.saveToStorage();
						_state.saveToDocuments();
						doUpdate(updateFile, _state.descriptor.currentVersion);
						result = false;
					}
					catch(e:Error)
					{
						HLog.warn(toString() + ": The application cannot be updated when launched from ADL. " + e.message);
						_state.resetUpdateData();
						_state.saveToStorage();
					}
				} 
				// possible when user postponed an update and the manually installed the new version
				else if (_state.descriptor.currentVersion == VersionUtils.getApplicationVersion())
				{
					_state.removeAllFailedUpdates();
					_state.resetUpdateData();
					_state.saveToStorage();
				}
				// postponed and manually installed a different version ?
				else
				{
					_state.removeAllFailedUpdates();
					_state.resetUpdateData();
					_state.saveToStorage();
				}
			}
			return result;
		}
		
		
		protected function handlePeriodicalCheck():void
		{
			// no periodical check
			if (_configuration.delay == 0) return;
			
			_timer.reset();
			_timer.repeatCount = 1;
			
			var difference:Number = (new Date()).time - _state.descriptor.lastCheckDate.time;
			if (difference > _configuration.delayAsMilliseconds)
			{
				// start now
				_timer.delay = 1;
			}
			else
			{
				// because setting a delay > MAX_INT will trigger the timer continuously
				// make the timer max delay = 1 day
				var millisecondsToCheck:Number = _configuration.delayAsMilliseconds - difference;
				// We add 1 because if want to timer to run at least once (setting repeatCount to 0 means run indefinitely)
				var daysToComplete:Number = Math.floor(millisecondsToCheck / Constants.DAY_IN_MILLISECONDS) + 1;
				if (millisecondsToCheck > Constants.DAY_IN_MILLISECONDS)
				{
					millisecondsToCheck = Constants.DAY_IN_MILLISECONDS;
				}
				_timer.delay = millisecondsToCheck;
				_timer.repeatCount = daysToComplete;
			}
			_timer.start();
		}
		
		
		private function doUpdate(file:File, version:String):void
		{
			HLog.debug(toString() + ": Approaching update install ... \"" + file.nativePath + "\" (" + version + ")");
			var updater:Updater = new Updater();
			updater.update(file, version);
		}
		
		
		private function showUI():void
		{
			if (_uiWrapper && _uiWrapper.initialized) _uiWrapper.showWindow();
		}
		
		
		private function closeUI():void
		{
			if (_uiWrapper) _uiWrapper.closeWindow();
		}
	}
}
