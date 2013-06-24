package tetragon.env.update.airupdater.ui
{
	import tetragon.env.update.airupdater.ApplicationUpdater;
	import tetragon.env.update.airupdater.events.DownloadErrorEvent;
	import tetragon.env.update.airupdater.events.UpdateEvent;

	import com.hexagonstar.util.debug.HLog;
	import com.hexagonstar.util.display.StageReference;

	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.geom.Rectangle;
	
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	
	
	public class UpdateUIWrapper extends EventDispatcher
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _updater:ApplicationUpdater;
		private var _updateUIClass:Class;
		private var _updateUI:UpdateUI;
		private var _uiWindow:NativeWindow;
		private var _isInitialized:Boolean;
		private var _isExiting:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function UpdateUIWrapper()
		{
			watchOpenedWindows();
			
			/* add listener to Exiting to handle Cmd-Q on MacOSX add biggest priority in
			 * order to close the window before a CLOSING event gets sent because of the
			 * recommended way of handling the exiting event
			 * http://livedocs.adobe.com/flex/3/html/app_launch_1.html#1036875 */
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting,
				false, int.MAX_VALUE);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function create():void
		{
			if (!_updateUIClass)
			{
				fail("No updateUIClass was assigned.");
				return;
			}
			var obj:Object = new _updateUIClass();
			if (obj is UpdateUI)
			{
				_updateUI = UpdateUI(obj);
				_updateUI.addEventListener(UpdateUI.EVENT_CHECK_UPDATE, onUICheckUpdate);
				_updateUI.addEventListener(UpdateUI.EVENT_CANCEL_UPDATE, onUICancelUpdate);
				_updateUI.addEventListener(UpdateUI.EVENT_DOWNLOAD_UPDATE, onUIDownloadUpdate);
				_updateUI.addEventListener(UpdateUI.EVENT_INSTALL_UPDATE, onUIInstallUpdate);
				_updateUI.addEventListener(UpdateUI.EVENT_INSTALL_LATER, onUIInstallLater);
				_isInitialized = true;
				dispatchEvent(new Event(Event.COMPLETE));
			}
			else
			{
				fail("updateUIClass needs to extend UpdateUI.");
			}
		}
		
		
		public function showWindow():void
		{
			if (!_updateUI) return;
			
			_isExiting = false;
			
			var options:NativeWindowInitOptions = new NativeWindowInitOptions();
			options.systemChrome = NativeWindowSystemChrome.STANDARD;
			options.type = NativeWindowType.NORMAL;
			options.maximizable = false;
			options.minimizable = false;
			options.resizable = false;
			
			_uiWindow = new NativeWindow(options);
			_uiWindow.visible = false;
			_uiWindow.addEventListener(Event.CLOSING, function(e:Event):void
			{
				// if not exiting, do not actually close the window
				if (!_isExiting) e.preventDefault();
				else _uiWindow = null;
				// cancel anyway if the window was about to be closed
				// except when in PENDING_INSTALLING state
				if (_updater.currentState != "PENDING_INSTALLING")
				{
					_updater.cancelUpdate();
				}
			});
			
			_uiWindow.stage.align = StageAlign.TOP_LEFT;
			_uiWindow.stage.scaleMode = StageScaleMode.NO_SCALE;
			_uiWindow.title = "Update";
			// uiWindow.alwaysInFront = true;
			var w:int = _updateUI.width;
			var h:int = _updateUI.height;
			var p:NativeWindow = StageReference.stage.nativeWindow;
			_uiWindow.bounds = new Rectangle(int(p.x + (p.width * 0.5) - (w * 0.5)), int(p.y + (p.height * 0.5) - (h * 0.5)), w, h);
			_updateUI.currentState = UpdateUI.STATUS_AVAILABLE;
			
			_uiWindow.stage.addChild(_updateUI);
			_uiWindow.visible = true;
			_uiWindow.orderToFront();
		}
		
		
		public function closeWindow():void
		{
			if (_uiWindow != null && !_uiWindow.closed)
			{
				_uiWindow.close();
				_uiWindow = null;
			}
		}
		
		
		/**
		 * Disposes the class.
		 */
		public function dispose():void
		{
			NativeApplication.nativeApplication.removeEventListener(Event.EXITING, onExiting);
			if (_updater)
			{
				_updater.removeEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
				_updater.removeEventListener(UpdateEvent.DOWNLOAD_COMPLETE, onDownloadComplete);
				_updater.removeEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, onDownloadError);
				_updater.removeEventListener(ErrorEvent.ERROR, onUpdateError);
			}
			if (_updateUI)
			{
				_updateUI.removeEventListener(UpdateUI.EVENT_CHECK_UPDATE, onUICheckUpdate);
				_updateUI.removeEventListener(UpdateUI.EVENT_CANCEL_UPDATE, onUICancelUpdate);
				_updateUI.removeEventListener(UpdateUI.EVENT_DOWNLOAD_UPDATE, onUIDownloadUpdate);
				_updateUI.removeEventListener(UpdateUI.EVENT_INSTALL_UPDATE, onUIInstallUpdate);
				_updateUI.removeEventListener(UpdateUI.EVENT_INSTALL_LATER, onUIInstallLater);
				_updateUI.dispose();
			}
			if (_uiWindow != null && !_uiWindow.closed)
			{
				//_uiWindow.removeEventListener(Event.CLOSE, onWindowClose);
				//_uiWindow = null;
			}
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		override public function toString():String
		{
			return "UpdateUIWrapper";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get initialized():Boolean
		{
			return _isInitialized;
		}
		
		
		public function set applicationUpdater(v:ApplicationUpdater):void
		{
			_updater = v;
			_updater.addEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
			_updater.addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, onDownloadComplete);
			_updater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, onDownloadError);
			_updater.addEventListener(ErrorEvent.ERROR, onUpdateError);
		}
		
		
		public function set updateUIClass(v:Class):void
		{
			_updateUIClass = v;
		}
		
		
		public function set currentVersion(v:String):void
		{
			if (_updateUI) _updateUI.currentVersion = v;
		}
		public function set updateVersion(v:String):void
		{
			if (_updateUI) _updateUI.upateVersion = v;
		}
		public function set applicationName(v:String):void
		{
			if (_updateUI) _updateUI.applicationName = v;
		}
		public function set description(v:String):void
		{
			if (_updateUI) _updateUI.description = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onUICheckUpdate(e:Event):void
		{
			_updater.checkNow();
		}
		
		
		private function onUIDownloadUpdate(e:Event):void
		{
			_updateUI.currentState = UpdateUI.STATUS_DOWNLOADING;
			_updater.downloadUpdate();
		}
		
		
		private function onUIInstallUpdate(e:Event):void
		{
			_updater.installUpdate();
		}
		
		
		private function onUIInstallLater(e:Event):void
		{
			_updater.installLater();
		}
		
		
		private function onUICancelUpdate(e:Event):void
		{
			_updater.cancelUpdate();
		}
		
		
		private function onDownloadProgress(e:ProgressEvent):void
		{
			_updateUI.currentState = UpdateUI.STATUS_DOWNLOADING;
			var percent:Number = (e.bytesLoaded / e.bytesTotal) * 100;
			_updateUI.updateProgress(percent);
		}
		
		
		private function onDownloadComplete(e:UpdateEvent):void
		{
			e.preventDefault();
			_updateUI.currentState = UpdateUI.STATUS_INSTALL;
		}
		
		
		private function onDownloadError(e:DownloadErrorEvent):void
		{
			e.preventDefault();
			_updateUI.errorText = e.text;
			_updateUI.currentState = UpdateUI.STATUS_ERROR;
		}
		
		
		private function onUpdateError(e:ErrorEvent):void
		{
			if (_updateUI)
			{
				_updateUI.errorText = e.text;
				_updateUI.currentState = UpdateUI.STATUS_ERROR;
			}
		}
		
		
		private function onWindowClose(e:Event):void
		{
			if (_uiWindow != null && !_uiWindow.closed
				&& NativeApplication.nativeApplication.openedWindows.length == 1)
			{
				onExiting(e);
			}
			else
			{
				watchOpenedWindows();
			}
			//if (_updater.currentState != "PENDING_INSTALLING")
			//{
			//	onUICancelUpdate(null);
			//}
		}
		
		
		private function onExiting(e:Event):void
		{
			_isExiting = true;
			closeWindow();
			dispose();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function watchOpenedWindows():void
		{
			for (var i:uint = 0; i < NativeApplication.nativeApplication.openedWindows.length; i++)
			{
				var win:NativeWindow = NativeApplication.nativeApplication.openedWindows[i];
				if (win == _uiWindow) continue;
				win.removeEventListener(Event.CLOSE, onWindowClose);
				if (!win.closed) win.addEventListener(Event.CLOSE, onWindowClose);
			}
		}
		
		
		private function fail(message:String):void
		{
			HLog.warn(toString() + ": " + message);
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
		}
	}
}
