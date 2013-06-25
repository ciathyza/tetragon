package tetragon.core.au
{
	import tetragon.core.au.core.AUUpdaterConfiguration;
	import tetragon.core.au.core.AUUpdaterHSM;
	import tetragon.core.au.core.AUUpdaterState;
	import tetragon.core.au.events.AUDownloadErrorEvent;
	import tetragon.core.au.events.AUStatusFileUpdateErrorEvent;
	import tetragon.core.au.events.AUStatusFileUpdateEvent;
	import tetragon.core.au.events.AUStatusUpdateErrorEvent;
	import tetragon.core.au.events.AUStatusUpdateEvent;
	import tetragon.core.au.events.AUUpdateEvent;
	import tetragon.core.au.states.AUHSM;
	import tetragon.core.au.states.AUHSMEvent;
	import tetragon.core.au.states.AUUpdateState;
	import tetragon.core.au.ui.AUUpdateUIWrapper;
	import tetragon.core.au.utils.AUConstants;
	import tetragon.core.au.utils.AUFileUtils;
	import tetragon.core.au.utils.AUVersionUtils;
	import tetragon.debug.Log;

	import flash.desktop.Updater;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.utils.Timer;
	
	
	/** Dispatched after the initialization is complete **/
	[Event(name="initialized", type="tetragon.core.au.events.AUUpdateEvent")]
	
	/** Dispatched just before the update process begins **/
	[Event(name="checkForUpdate", type="tetragon.core.au.events.AUUpdateEvent")]
	
	/** Dispatched when the download of the update file begins **/
	[Event(name="downloadStart", type="tetragon.core.au.events.AUUpdateEvent")]
	
	/** Dispatched when the download of the update file is complete **/
	[Event(name="downloadComplete", type="tetragon.core.au.events.AUUpdateEvent")]
	
	/** Dispatched just before installing the update (cancellable) **/
	[Event(name="beforeInstall", type="tetragon.core.au.events.AUUpdateEvent")]
	
	/** Dispatched when status information is available after parsing the update descriptor (cancellable if an update is available)**/
	[Event(name="updateStatus", type="tetragon.core.au.events.AUStatusUpdateEvent")]
	
	/** Dispatched when an error occured while trying to download or parse the update descriptor **/
	[Event(name="updateError", type="tetragon.core.au.events.AUStatusUpdateErrorEvent")]
	
	/** Dispatched when an error occured while downloading the update file **/
	[Event(name="downloadError", type="tetragon.core.au.events.AUDownloadErrorEvent")]
	
	/** Dispatched when status information is available after parsing the AIR file from installFromAIRFile call (cancellable if an update is available)**/
	[Event(name="fileUpdateStatus", type="tetragon.core.au.events.AUStatusFileUpdateEvent")]
	
	/** Dispatched when an error occured while trying to parse the AIR file from installFromAIRFile call **/
	[Event(name="fileUpdateError", type="tetragon.core.au.events.AUStatusFileUpdateErrorEvent")]
	
	/** Dispatched after the initialization is complete **/
	[Event(name="progress", type="flash.events.ProgressEvent")]
	
	/** Dispatched if something goes wrong with our knowledge **/
	[Event(name="error", type="flash.events.ErrorEvent")]
	
	
	/**
	 * ApplicationUpdater class.
	 */
	public class AUApplicationUpdater extends AUHSM
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
		
		protected var _uiWrapper:AUUpdateUIWrapper;
		protected var _updateUIClass:Class;
		protected var _configuration:AUUpdaterConfiguration;
		protected var _state:AUUpdaterState;
		protected var _updaterHSM:AUUpdaterHSM;
		
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
		
		public function AUApplicationUpdater()
		{
			super(onStateUninitialized);
			
			init();
			_configuration = new AUUpdaterConfiguration();
			_state = new AUUpdaterState();
			
			_updaterHSM = new AUUpdaterHSM();
			_updaterHSM.configuration = _configuration;
			_updaterHSM.addEventListener(AUUpdateEvent.CHECK_FOR_UPDATE, dispatch);
			_updaterHSM.addEventListener(AUStatusUpdateEvent.UPDATE_STATUS, dispatch);
			_updaterHSM.addEventListener(AUUpdateEvent.DOWNLOAD_START, dispatch);
			_updaterHSM.addEventListener(ProgressEvent.PROGRESS, dispatch);
			_updaterHSM.addEventListener(AUUpdateEvent.DOWNLOAD_COMPLETE, dispatch);
			_updaterHSM.addEventListener(AUUpdateEvent.BEFORE_INSTALL, dispatch);
			_updaterHSM.addEventListener(AUStatusUpdateErrorEvent.UPDATE_ERROR, dispatch);
			_updaterHSM.addEventListener(AUDownloadErrorEvent.DOWNLOAD_ERROR, dispatch);
			_updaterHSM.addEventListener(AUUpdaterHSM.EVENT_INSTALL_TRIGGER, dispatch);
			_updaterHSM.addEventListener(AUUpdaterHSM.EVENT_FILE_INSTALL_TRIGGER, dispatch);
			_updaterHSM.addEventListener(AUUpdaterHSM.EVENT_STATE_CLEAR_TRIGGER, onStateClear);
			_updaterHSM.addEventListener(ErrorEvent.ERROR, dispatch);
			_updaterHSM.addEventListener(AUStatusFileUpdateEvent.FILE_UPDATE_STATUS, dispatch);
			_updaterHSM.addEventListener(AUStatusFileUpdateErrorEvent.FILE_UPDATE_ERROR, dispatch);
			
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
			dispatch(new Event(AUUpdaterHSM.EVENT_CHECK));
		}
		
		
		public function downloadUpdate():void
		{
			dispatch(new Event(AUUpdaterHSM.EVENT_DOWNLOAD));
		}
		
		
		public function installUpdate():void
		{
			dispatch(new Event(AUUpdaterHSM.EVENT_INSTALL));
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
				_updaterHSM.removeEventListener(AUUpdateEvent.CHECK_FOR_UPDATE, dispatch);
				_updaterHSM.removeEventListener(AUStatusUpdateEvent.UPDATE_STATUS, dispatch);
				_updaterHSM.removeEventListener(AUUpdateEvent.DOWNLOAD_START, dispatch);
				_updaterHSM.removeEventListener(ProgressEvent.PROGRESS, dispatch);
				_updaterHSM.removeEventListener(AUUpdateEvent.DOWNLOAD_COMPLETE, dispatch);
				_updaterHSM.removeEventListener(AUUpdateEvent.BEFORE_INSTALL, dispatch);
				_updaterHSM.removeEventListener(AUStatusUpdateErrorEvent.UPDATE_ERROR, dispatch);
				_updaterHSM.removeEventListener(AUDownloadErrorEvent.DOWNLOAD_ERROR, dispatch);
				_updaterHSM.removeEventListener(AUUpdaterHSM.EVENT_INSTALL_TRIGGER, dispatch);
				_updaterHSM.removeEventListener(AUUpdaterHSM.EVENT_FILE_INSTALL_TRIGGER, dispatch);
				_updaterHSM.removeEventListener(AUUpdaterHSM.EVENT_STATE_CLEAR_TRIGGER, onStateClear);
				_updaterHSM.removeEventListener(ErrorEvent.ERROR, dispatch);
				_updaterHSM.removeEventListener(AUStatusFileUpdateEvent.FILE_UPDATE_STATUS, dispatch);
				_updaterHSM.removeEventListener(AUStatusFileUpdateErrorEvent.FILE_UPDATE_ERROR, dispatch);
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
			if (!_isInitialized) return AUUpdateState.getStateName(AUUpdateState.UNINITIALIZED);
			return AUUpdateState.getStateName(_updaterHSM.getUpdateState());
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
			return AUVersionUtils.getApplicationVersion();
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
				case AUHSMEvent.ENTER:
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
				case AUHSMEvent.ENTER:
					doInitialize();
					break;
				case AUUpdateEvent.INITIALIZED:
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
				case AUHSMEvent.ENTER:
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
				case AUHSMEvent.ENTER:
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
				case AUUpdaterHSM.EVENT_CHECK:
				case AUUpdaterHSM.EVENT_DOWNLOAD:
				case AUUpdaterHSM.EVENT_INSTALL:
					_updaterHSM.dispatch(e);
					break;
				case AUUpdateEvent.CHECK_FOR_UPDATE:
				case AUStatusUpdateEvent.UPDATE_STATUS:
				case AUUpdateEvent.DOWNLOAD_START:
				case ProgressEvent.PROGRESS:
				case AUUpdateEvent.BEFORE_INSTALL:
					onDispatchProxy(e);
					break;
				case AUStatusUpdateErrorEvent.UPDATE_ERROR:
				case AUDownloadErrorEvent.DOWNLOAD_ERROR:
				case AUStatusFileUpdateErrorEvent.FILE_UPDATE_ERROR:
				case ErrorEvent.ERROR:
					onDispatchProxy(e);
					transition(onStateReady);
					break;
				case AUStatusFileUpdateEvent.FILE_UPDATE_STATUS:
					onFileStatus(e as AUStatusFileUpdateEvent);
					break;
				case AUUpdateEvent.DOWNLOAD_COMPLETE:
					onDownloadComplete(e as AUUpdateEvent);
					break;
				case AUUpdaterHSM.EVENT_INSTALL_TRIGGER:
					doInstall();
					break;
				case AUUpdaterHSM.EVENT_FILE_INSTALL_TRIGGER:
					doFileInstall();
			}
		}
		
		
		protected function onStateCancelled(e:Event):void
		{
			if (e.type != AUHSMEvent.ENTER) return;
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
		
		
		protected function onDownloadComplete(e:AUUpdateEvent):void
		{
			_state.descriptor.previousVersion = AUVersionUtils.getApplicationVersion();
			_state.descriptor.currentVersion = _updaterHSM.descriptor.version;
			_state.descriptor.storage = File.applicationStorageDirectory;
			_state.saveToStorage();
			onDispatchProxy(e);
		}
		
		
		protected function onFileStatus(e:AUStatusFileUpdateEvent):void
		{
			if (e.available)
			{
				_state.descriptor.previousVersion = AUVersionUtils.getApplicationVersion();
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
				Log.warn("The application cannot be updated (state file). " + err.message, this);
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
			Log.debug("Initialized.", this);
			dispatch(new AUUpdateEvent(AUUpdateEvent.INITIALIZED));
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
			_uiWrapper = new AUUpdateUIWrapper();
			_uiWrapper.applicationUpdater = this;
			_uiWrapper.updateUIClass = _updateUIClass;
			_uiWrapper.addEventListener(Event.COMPLETE, onUICreated);
			_uiWrapper.addEventListener(ErrorEvent.ERROR, onUICreated);
			_uiWrapper.create();
		}
		
		
		protected function doInstall():void
		{
			Log.debug("doInstall() ...", this);
			var updateFile:File = AUFileUtils.getLocalUpdateFile();
			if (!updateFile.exists)
			{
				// Update file
				_state.resetUpdateData();
				_state.saveToStorage();
				_updaterHSM.cancel();
				throw new Error("Missing update file at install time.", AUConstants.ERROR_APPLICATION_UPDATE_NO_FILE);
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
				Log.warn(msg, this);
				_state.resetUpdateData();
				_state.saveToStorage();
				_updaterHSM.cancel();
				throw new Error(msg, AUConstants.ERROR_APPLICATION_UPDATE);
			}
		}
		
		
		protected function doFileInstall():void
		{
			Log.debug("doFileInstall() ...", this);
			var updateFile:File = _updaterHSM.airFile;
			if (!updateFile.exists)
			{
				_state.resetUpdateData();
				_state.saveToStorage();
				_updaterHSM.cancel();
				throw new Error("Missing update file at install time.", AUConstants.ERROR_APPLICATION_UPDATE_NO_FILE);
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
				Log.warn(msg, this);
				_state.resetUpdateData();
				_state.saveToStorage();
				_updaterHSM.cancel();
				throw new Error(msg, AUConstants.ERROR_APPLICATION_UPDATE);
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
				if (_state.descriptor.currentVersion == AUVersionUtils.getApplicationVersion())
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
				else if (_state.descriptor.previousVersion == AUVersionUtils.getApplicationVersion())
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
				if (_state.descriptor.previousVersion == AUVersionUtils.getApplicationVersion())
				{
					var updateFile:File = AUFileUtils.getLocalUpdateFile();
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
						Log.warn("The application cannot be updated when launched from ADL. " + e.message, this);
						_state.resetUpdateData();
						_state.saveToStorage();
					}
				} 
				// possible when user postponed an update and the manually installed the new version
				else if (_state.descriptor.currentVersion == AUVersionUtils.getApplicationVersion())
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
				var daysToComplete:Number = Math.floor(millisecondsToCheck / AUConstants.DAY_IN_MILLISECONDS) + 1;
				if (millisecondsToCheck > AUConstants.DAY_IN_MILLISECONDS)
				{
					millisecondsToCheck = AUConstants.DAY_IN_MILLISECONDS;
				}
				_timer.delay = millisecondsToCheck;
				_timer.repeatCount = daysToComplete;
			}
			_timer.start();
		}
		
		
		private function doUpdate(file:File, version:String):void
		{
			Log.debug("Approaching update install ... \"" + file.nativePath + "\" (" + version + ")", this);
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
