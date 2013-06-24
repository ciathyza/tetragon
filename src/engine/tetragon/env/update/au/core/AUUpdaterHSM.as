package tetragon.env.update.au.core
{
	import tetragon.debug.Log;
	import tetragon.env.update.au.descriptors.AUApplicationDescriptor;
	import tetragon.env.update.au.descriptors.AUUpdateDescriptor;
	import tetragon.env.update.au.events.AUDownloadErrorEvent;
	import tetragon.env.update.au.events.AUStatusFileUpdateErrorEvent;
	import tetragon.env.update.au.events.AUStatusFileUpdateEvent;
	import tetragon.env.update.au.events.AUStatusUpdateErrorEvent;
	import tetragon.env.update.au.events.AUStatusUpdateEvent;
	import tetragon.env.update.au.events.AUUpdateEvent;
	import tetragon.env.update.au.net.AUFileDownloader;
	import tetragon.env.update.au.states.AUHSM;
	import tetragon.env.update.au.states.AUHSMEvent;
	import tetragon.env.update.au.states.AUUpdateState;
	import tetragon.env.update.au.utils.AUConstants;
	import tetragon.env.update.au.utils.AUFileUtils;
	import tetragon.env.update.au.utils.AUVersionUtils;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	
	
	[Event(name="checkForUpdate", type="tetragon.env.update.au.events.AUUpdateEvent")]
	[Event(name="updateStatus", type="tetragon.env.update.au.events.AUStatusUpdateEvent")]
	[Event(name="updateError", type="tetragon.env.update.au.events.AUStatusUpdateErrorEvent")]
	[Event(name="downloadStart", type="tetragon.env.update.au.events.AUUpdateEvent")]
	
	/**
	 * Dispatched during downloading 
	 * @eventType flash.events.ProgressEvent.PROGRESS
	 */
	[Event(name="progress", type="flash.events.ProgressEvent")]
	
	/**
	 * Dispatched in case of error
	 * @eventType air.update.events.DownloadErrorEvent
	 */
	[Event(name="downloadError", type="tetragon.env.update.au.events.AUDownloadErrorEvent")]
	
	/**
	 * Dispatched when download has finished. Typical usage is to close the downloading window
	 * @eventType air.update.events.UpdateEvent.DOWNLOAD_COMPLETE
	 */
	[Event(name="downloadComplete", type="tetragon.env.update.au.events.AUUpdateEvent")]
	
	[Event(name="beforeInstall", type="tetragon.env.update.au.events.AUUpdateEvent")]
	
	
	/**
	 * UpdaterHSM class.
	 */
	public class AUUpdaterHSM extends AUHSM
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const EVENT_CHECK:String					= "updater.check";
		public static const EVENT_DOWNLOAD:String				= "updater.download";
		public static const EVENT_INSTALL:String				= "updater.install";
		public static const EVENT_INSTALL_TRIGGER:String		= "install.trigger";
		public static const EVENT_FILE_INSTALL_TRIGGER:String	= "file_install.trigger";
		public static const EVENT_STATE_CLEAR_TRIGGER:String	= "state_clear.trigger";
		public static const EVENT_ASYNC:String					= "check.async";
		public static const EVENT_FILE:String					= "check.file";
		public static const EVENT_VERIFIED:String				= "check.verified";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _downloader:AUFileDownloader;
		private var _updateURL:URLRequest;
		private var _updateFile:File;
		private var _descriptor:AUUpdateDescriptor;
		private var _applicationDescriptor:AUApplicationDescriptor;
		private var _requestedURL:String;
		private var _airFile:File;
		private var _unpackager:AUAIRUnpackager;
		private var _configuration:AUUpdaterConfiguration;
		private var _lastErrorEvent:ErrorEvent;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function AUUpdaterHSM()
		{
			super(onStateReady);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function checkAsync(url:String):void
		{
			_requestedURL = url;
			dispatch(new Event(EVENT_ASYNC));
		}
		
		
		public function installFile(file:File):void
		{
			_airFile = file;
			dispatch(new Event(EVENT_FILE));
		}
		
		
		public function cancel():void
		{
			transition(onStateCancelled);
		}
		
		
		public function getUpdateState():int
		{
			var updateState:int = -1;
			switch(stateHSM)
			{
				case onStateInitialized:
					updateState = AUUpdateState.READY;
					break;
				case onStateBeforeChecking:
					updateState = AUUpdateState.BEFORE_CHECKING;
					break;
				case onStateChecking:
					updateState = AUUpdateState.CHECKING;
					break;
				case onStateAvailable:
				case onStateAvailableFile:
					updateState = AUUpdateState.AVAILABLE;
					break;
				case onStateDownloading:
					updateState = AUUpdateState.DOWNLOADING;
					break;
				case onStateDownloaded:
					updateState = AUUpdateState.DOWNLOADED;
					break;
				case onStateInstalling:
					updateState = AUUpdateState.INSTALLING;
					break;
				case onStatePendingInstall:
					updateState = AUUpdateState.PENDING_INSTALLING;
					break;
				case onStateReady:
					updateState = AUUpdateState.READY;
			}
			return updateState;
		}
		
		
		/**
		 * Disposes the class.
		 */
		public function dispose():void
		{
			disposeDownloader();
			disposeUnpackager();
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		override public function toString():String
		{
			return "UpdaterHSM";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get configuration():AUUpdaterConfiguration
		{
			return _configuration;
		}
		public function set configuration(v:AUUpdaterConfiguration):void
		{
			_configuration = v;
		}
		
		
		public function get descriptor():AUUpdateDescriptor
		{
			return _descriptor;
		}
		
		
		public function get applicationDescriptor():AUApplicationDescriptor
		{
			return _applicationDescriptor;
		}
		
		
		public function get airFile():File
		{
			return _airFile;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		protected function onStateInitialized(e:Event):void
		{
			if (e.type != AUHSMEvent.ENTER) return;
			transition(onStateReady);
		}
		
		
		protected function onStateBeforeChecking(e:Event):void
		{
			switch(e.type)
			{
				case AUHSMEvent.ENTER:
					var ev:AUUpdateEvent = new AUUpdateEvent(AUUpdateEvent.CHECK_FOR_UPDATE, false, true);
					dispatchEvent(ev);
					if (!ev.isDefaultPrevented())
					{
						// if the event wasn't cancelled, start downloading
						transition(onStateChecking);
						return;
					}
					// event was cancelled, wait for the next event
					break;
				case EVENT_CHECK:
					transition(onStateChecking);
			}
		}
		
		
		protected function onStateChecking(e:Event):void
		{
			switch(e.type)
			{
				case AUHSMEvent.ENTER:
					_downloader = new AUFileDownloader(_updateURL, _updateFile);
					_downloader.addEventListener(AUDownloadErrorEvent.DOWNLOAD_ERROR, dispatch);
					_downloader.addEventListener(ProgressEvent.PROGRESS, dispatch);
					_downloader.addEventListener(AUUpdateEvent.DOWNLOAD_COMPLETE, dispatch);
					_downloader.download();
					break;
				case AUUpdateEvent.DOWNLOAD_START:
					// Not interested in download start, when downloading descriptor
					break;
				case ProgressEvent.PROGRESS:
					// Not interested in progress events, while downloading descriptor
					break;
				case AUDownloadErrorEvent.DOWNLOAD_ERROR:
					_lastErrorEvent = new AUStatusUpdateErrorEvent(AUStatusUpdateErrorEvent.UPDATE_ERROR, false, true, AUDownloadErrorEvent(e).text, AUDownloadErrorEvent(e).errorID, AUDownloadErrorEvent(e).subErrorID);
					transition(onStateErrored);
					break;
				case AUUpdateEvent.DOWNLOAD_COMPLETE:
					disposeDownloader();
					// update descriptor is downloaded
					// read it
					descriptorDownloaded();
			}
		}
		
		
		protected function onStateAvailable(e:Event):void
		{
			switch (e.type)
			{
				case AUHSMEvent.ENTER:
					if (dispatchEvent(new AUStatusUpdateEvent(AUStatusUpdateEvent.UPDATE_STATUS, false, true, true, descriptor.version, descriptor.description, descriptor.versionLabel)))
					{
						// if the event wasn't cancelled, start downloading
						transition(onStateDownloading);
						return;
					}
					// event was cancelled, wait for the next event
					break;
				case EVENT_DOWNLOAD:
					transition(onStateDownloading);
			}
		}
		
		
		protected function onStateDownloading(e:Event):void
		{
			switch (e.type)
			{
				case AUHSMEvent.ENTER:
					_downloader = new AUFileDownloader(_updateURL, _updateFile);
					_downloader.addEventListener(AUDownloadErrorEvent.DOWNLOAD_ERROR, dispatch);
					_downloader.addEventListener(AUUpdateEvent.DOWNLOAD_START, dispatch);
					_downloader.addEventListener(ProgressEvent.PROGRESS, dispatch);
					_downloader.addEventListener(AUUpdateEvent.DOWNLOAD_COMPLETE, dispatch);
					_downloader.download();
					break;
				case AUUpdateEvent.DOWNLOAD_START:
					dispatchEvent(e.clone());
					break;
				case ProgressEvent.PROGRESS:
					dispatchEvent(e.clone());
					break;
				case AUDownloadErrorEvent.DOWNLOAD_ERROR:
					_lastErrorEvent = ErrorEvent(e.clone());
					transition(onStateErrored);
					break;
				case AUUpdateEvent.DOWNLOAD_COMPLETE:
					disposeDownloader();
					transition(onStateDownloaded);
			}
		}


		protected function onStateDownloaded(e:Event):void
		{
			switch (e.type)
			{
				case AUHSMEvent.ENTER:
					_unpackager = new AUAIRUnpackager();
					_unpackager.addEventListener(Event.COMPLETE, dispatch);
					_unpackager.addEventListener(ErrorEvent.ERROR, dispatch);
					_unpackager.addEventListener(IOErrorEvent.IO_ERROR, dispatch);
					_unpackager.unpackageAsync(_updateFile.url);
					break;
				case ErrorEvent.ERROR:
				case IOErrorEvent.IO_ERROR:
					_unpackager.cancel();
					disposeUnpackager();
					_lastErrorEvent = new AUDownloadErrorEvent(AUDownloadErrorEvent.DOWNLOAD_ERROR, false, true, "", AUConstants.ERROR_AIR_UNPACKAGING, ErrorEvent(e).errorID);
					transition(onStateErrored);
					break;
				case Event.COMPLETE:
					_unpackager.cancel();
					var descriptor:AUApplicationDescriptor = new AUApplicationDescriptor(_unpackager.descriptorXML);
					try
					{
						descriptor.validate();
					}
					catch(err:Error)
					{
						disposeUnpackager();
						_lastErrorEvent = new AUDownloadErrorEvent(AUDownloadErrorEvent.DOWNLOAD_ERROR, false, true, err.message, AUConstants.ERROR_VALIDATE, err.errorID);
						transition(onStateErrored);
						return;
					}
					if (descriptor.id != AUVersionUtils.getApplicationID())
					{
						_lastErrorEvent = new AUDownloadErrorEvent(AUDownloadErrorEvent.DOWNLOAD_ERROR, false, true, "Different applicationID", AUConstants.ERROR_VALIDATE, AUConstants.ERROR_DIFFERENT_APPLICATION_ID);
						transition(onStateErrored);
						return;
					}
					if (_descriptor.version != descriptor.version)
					{
						_lastErrorEvent = new AUDownloadErrorEvent(AUDownloadErrorEvent.DOWNLOAD_ERROR, false, true, "Version mismatch", AUConstants.ERROR_VALIDATE, AUConstants.ERROR_VERSION_MISMATCH);
						transition(onStateErrored);
						return;
					}
					if (!isNewerVersion(AUVersionUtils.getApplicationVersion(), descriptor.version))
					{
						_lastErrorEvent = new AUDownloadErrorEvent(AUDownloadErrorEvent.DOWNLOAD_ERROR, false, true, "Not a newer version", AUConstants.ERROR_VALIDATE, AUConstants.ERROR_NOT_NEW_VERSION);
						transition(onStateErrored);
						return;
					}
					dispatch(new Event(EVENT_VERIFIED));
					break;
				case EVENT_VERIFIED:
					if (dispatchEvent(new AUUpdateEvent(AUUpdateEvent.DOWNLOAD_COMPLETE, false, true)))
					{
						// if the event wasn't cancelled, start downloading
						transition(onStateInstalling);
						return;
					}
					// event was cancelled, wait for the next event
					break;
				case EVENT_INSTALL:
					transition(onStateInstalling);
			}
		}
		
		
		protected function onStateInstalling(e:Event):void
		{
			if (e.type != AUHSMEvent.ENTER) return;
			if (!dispatchEvent(new AUUpdateEvent(AUUpdateEvent.BEFORE_INSTALL, false, true)))
			{
				// if the event was  cancelled, wait restart
				transition(onStatePendingInstall);
				return;
			}
			installUpdate();
		}
		
		
		/**
		 *  Terminal state
		 */
		protected function onStatePendingInstall(e:Event):void
		{
		}
		
		
		protected function onStateUnpackaging(e:Event):void
		{
			switch (e.type)
			{
				case AUHSMEvent.ENTER:
					_unpackager = new AUAIRUnpackager();
					_unpackager.addEventListener(Event.COMPLETE, dispatch);
					_unpackager.addEventListener(ErrorEvent.ERROR, dispatch);
					_unpackager.addEventListener(IOErrorEvent.IO_ERROR, dispatch);
					_unpackager.unpackageAsync(_airFile.url);
					break;
				case Event.COMPLETE:
					_unpackager.cancel();
					fileUnpackaged();
					disposeUnpackager();
					break;
				case ErrorEvent.ERROR:
				case IOErrorEvent.IO_ERROR:
					_unpackager.cancel();
					disposeUnpackager();
					_lastErrorEvent = new AUStatusFileUpdateErrorEvent(AUStatusFileUpdateErrorEvent.FILE_UPDATE_ERROR, false, true, "", (ErrorEvent(e).errorID));
					transition(onStateErrored);
			}
		}
		
		
		protected function onStateAvailableFile(e:Event):void
		{
			switch (e.type)
			{
				case AUHSMEvent.ENTER:
					if (dispatchEvent(new AUStatusFileUpdateEvent(AUStatusFileUpdateEvent.FILE_UPDATE_STATUS, false, true, true, _applicationDescriptor.version, _airFile.nativePath, _applicationDescriptor.versionLabel)))
					{
						// if the event wasn't cancelled, start downloading
						transition(onStateInstallingFile);
						return;
					}
					// event was cancelled, wait for the next event
					break;
				case EVENT_INSTALL:
					transition(onStateInstallingFile);
			}
		}
		
		
		protected function onStateInstallingFile(e:Event):void
		{
			if (e.type != AUHSMEvent.ENTER) return;
			installFileUpdate();
		}
		
		
		protected function onStateReady(e:Event):void
		{
			switch (e.type)
			{
				case AUHSMEvent.ENTER:
					break;
				case EVENT_ASYNC:
					_updateURL = new URLRequest(_requestedURL);
					_updateFile = AUFileUtils.getLocalDescriptorFile();
					transitionAsync(onStateBeforeChecking);
					break;
				case EVENT_FILE:
					transitionAsync(onStateUnpackaging);
			}
		}
		
		
		protected function onStateCancelled(e:Event):void
		{
			if (e.type != AUHSMEvent.ENTER) return;
			dispatchEvent(new Event(EVENT_STATE_CLEAR_TRIGGER));
			// clear everything and transition to ready
			if (_downloader)
			{
				_downloader.cancel();
				disposeDownloader();
			}
			transition(onStateReady);
		}
		
		
		protected function onStateErrored(e:Event):void
		{
			//HLog.warn(toString() + ": stateErrored: " + e.type + " lastErrorEvent: " + _lastErrorEvent);
			switch (e.type)
			{
				case AUHSMEvent.ENTER:
					var isDialogHidden:Boolean = false;
					if (_lastErrorEvent)
					{
						isDialogHidden = dispatchEvent(_lastErrorEvent);
						_lastErrorEvent = null;
					}
					dispatchEvent(new Event(EVENT_STATE_CLEAR_TRIGGER));
					// clear everything and transition to ready
					if (_downloader)
					{
						_downloader.cancel();
						disposeDownloader();
					}
					if (isDialogHidden)
					{
						transition(onStateReady);
					}
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function isNewerVersion(oldVersion:String, newVersion:String):Boolean
		{
			if (configuration) return configuration.isNewerVersionFunction(oldVersion, newVersion);
			return AUVersionUtils.isNewerVersion(oldVersion, newVersion);
		}
		
		
		private function fileUnpackaged():void
		{
			try
			{
				var xml:XML = _unpackager.descriptorXML;
				_applicationDescriptor = new AUApplicationDescriptor(xml);
				_applicationDescriptor.validate();
				
				// different applicationID
				if (AUVersionUtils.getApplicationID() != _applicationDescriptor.id)
				{
					throw new Error(toString() + ": Different applicationID.",
						AUConstants.ERROR_DIFFERENT_APPLICATION_ID);
				}
				if (!isNewerVersion(AUVersionUtils.getApplicationVersion(), _applicationDescriptor.version))
				{
					if (dispatchEvent(new AUStatusFileUpdateEvent(AUStatusFileUpdateEvent.FILE_UPDATE_STATUS, false, true, false, _applicationDescriptor.version, _airFile.nativePath, _applicationDescriptor.versionLabel)))
					{
						transition(onStateReady);
					}
					return;
				}
				transition(onStateAvailableFile);
			}
			catch(err:Error)
			{
				Log.warn("Error validating file descriptor - " + err.message, this);
				_lastErrorEvent = new AUStatusFileUpdateErrorEvent(AUStatusFileUpdateErrorEvent.FILE_UPDATE_ERROR, false, true, err.message, err.errorID);
				transition(onStateErrored);
			}
		}
		
		
		private function descriptorDownloaded():void
		{
			try
			{
				var xml:XML = AUFileUtils.readXMLFromFile(_updateFile);
				_descriptor = new AUUpdateDescriptor(xml);
				_descriptor.validate();
				
				if (!_descriptor.isCompatibleWithAppDescriptor(AUVersionUtils.applicationHasVersionNumber()))
				{
					throw new Error("Application namespace and update descriptor namespace are not compatible.", AUConstants.ERROR_INCOMPATIBLE_NAMESPACE);
				}
				if (!isNewerVersion(AUVersionUtils.getApplicationVersion(), _descriptor.version))
				{
					if (dispatchEvent(new AUStatusUpdateEvent(AUStatusUpdateEvent.UPDATE_STATUS, false, true)))
					{
						transition(onStateReady);
					}
					return;
				}
				
				// update is available
				_updateFile = AUFileUtils.getLocalUpdateFile();
				_updateURL = new URLRequest(descriptor.url);
				transition(onStateAvailable);
			}
			catch(err:Error)
			{
				Log.warn("Error loading/validating downloaded descriptor - " + err.message, this);
				_lastErrorEvent = new AUStatusUpdateErrorEvent(AUStatusUpdateErrorEvent.UPDATE_ERROR, false, false, err.message, err.errorID);
				transition(onStateErrored);
			}
		}
		
		
		private function installUpdate():void
		{
			dispatchEvent(new Event(EVENT_INSTALL_TRIGGER));
		}
		
		
		private function installFileUpdate():void
		{
			dispatchEvent(new Event(EVENT_FILE_INSTALL_TRIGGER));
		}
		
		
		private function disposeDownloader():void
		{
			if (!_downloader) return;
			_downloader.removeEventListener(AUDownloadErrorEvent.DOWNLOAD_ERROR, dispatch);
			_downloader.removeEventListener(AUUpdateEvent.DOWNLOAD_START, dispatch);
			_downloader.removeEventListener(ProgressEvent.PROGRESS, dispatch);
			_downloader.removeEventListener(AUUpdateEvent.DOWNLOAD_COMPLETE, dispatch);
			_downloader.dispose();
			_downloader = null;
		}
		
		
		private function disposeUnpackager():void
		{
			if (!_unpackager) return;
			_unpackager.removeEventListener(Event.COMPLETE, dispatch);
			_unpackager.removeEventListener(ErrorEvent.ERROR, dispatch);
			_unpackager.removeEventListener(IOErrorEvent.IO_ERROR, dispatch);
			_unpackager.dispose();
			_unpackager = null;
		}
	}
}
