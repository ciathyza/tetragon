package tetragon.env.update.airupdater.ui
{
	import flash.display.Sprite;
	
	
	/**
	 * Abstract base UpdateUI class.
	 */
	public class UpdateUI extends Sprite
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------		
		
		public static const STATUS_AVAILABLE:String		= "statusAvailable";
		public static const STATUS_DOWNLOADING:String	= "statusDownloading";
		public static const STATUS_INSTALL:String		= "statusInstall";
		public static const STATUS_ERROR:String			= "statusError";
		
		public static const EVENT_CHECK_UPDATE:String	= "eventCheckUpdate";
		public static const EVENT_INSTALL_UPDATE:String	= "eventInstallUpdate";
		public static const EVENT_DOWNLOAD_UPDATE:String= "eventDownloadUpdate";
		public static const EVENT_CANCEL_UPDATE:String	= "eventCancelUpdate";
		public static const EVENT_INSTALL_LATER:String	= "eventInstallLater";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _uiContainer:Sprite;
		
		protected var _currentState:String;
		
		protected var _currentVersion:String = "";
		protected var _updateVersion:String = "";
		protected var _updateDescription:String = "";
		protected var _applicationName:String = "";
		protected var _errorText:String;
		protected var _progress:int = 0;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function UpdateUI()
		{
			super();
			setup();
			_uiContainer = new Sprite();
			addChild(_uiContainer);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function updateProgress(progress:int):void
		{
			_progress = progress;
		}
		
		
		public function dispose():void
		{
			removeUIListeners();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function set currentState(v:String):void
		{
			if (v == _currentState) return;
			_currentState = v;
			switchUIState();
		}
		public function set currentVersion(v:String):void
		{
			_currentVersion = v;
		}
		public function set upateVersion(v:String):void
		{
			_updateVersion = v;
		}
		public function set applicationName(v:String):void
		{
			_applicationName = v;
		}
		public function set description(v:String):void
		{
			_updateDescription = v;
		}
		public function set errorText(v:String):void
		{
			_errorText = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		protected function setup():void
		{
			/* Abstract method! */
		}
		
		
		protected function switchUIState():void
		{
			while(_uiContainer.numChildren > 0)
			{
				_uiContainer.removeChildAt(0);
			}
			removeUIListeners();
			switch (_currentState)
			{
				case STATUS_AVAILABLE:
					createUpdateAvailableState();
					break;
				case STATUS_DOWNLOADING:
					createUpdateDownloadState();
					break;
				case STATUS_INSTALL:
					createUpdateInstallState();
					break;
				case STATUS_ERROR:
					createUpdateErrorState();
					break;
			}
		}
		
		
		protected function createUpdateAvailableState():void
		{
			/* Abstract method! */
		}
		
		
		protected function createUpdateDownloadState():void
		{
			/* Abstract method! */
		}
		
		
		protected function createUpdateInstallState():void
		{
			/* Abstract method! */
		}
		
		
		protected function createUpdateErrorState():void
		{
			/* Abstract method! */
		}
		
		
		protected function removeUIListeners():void
		{
			/* Abstract method! */
		}
	}
}
