package tetragon.env.update.au.net
{
	import tetragon.debug.Log;
	import tetragon.env.update.au.events.AUDownloadErrorEvent;
	import tetragon.env.update.au.events.AUUpdateEvent;
	import tetragon.env.update.au.utils.AUConstants;

	import flash.errors.EOFError;
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	
	/**
	 * Dispatched in case of error
	 * @eventType air.update.events.DownloadErrorEvent
	 */
	[Event(name="downloadError", type="tetragon.env.update.au.events.AUDownloadErrorEvent")]
	
	/**
	 * Dispatched during downloading 
	 * @eventType flash.events.ProgressEvent.PROGRESS
	 */
	[Event(name="progress", type="flash.events.ProgressEvent")]
	
	/**
	 * Dispatched when download has finished. Typical usage is to close the downloading window
	 * @eventType air.update.events.UpdateEvent.DOWNLOAD_COMPLETE
	 */
	[Event(name="downloadComplete", type="tetragon.env.update.au.events.AUUpdateEvent")]
	
	[Event(name="downloadStart", type="tetragon.env.update.au.events.AUUpdateEvent")]
	
	
	/**
	 * FileDownloader class.
	 */
	public class AUFileDownloader extends EventDispatcher
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		private static const ACCEPTABLE_STATUSES:Array =
		[
		    0,
      		200,    // 200 OK
      		//202,  // 203 Accepted
      		//204,  // 204 No content
      		//205,  // 205 Reset Content -- eh, why not?
      		//206,  // 206 Partial Content (in response to req with Range header)

      		// NOT:
      		//   201 Created -- seems not to be repeatable by definition
      		//   203 Non-Authoritative Information -- returned by intermediate proxy
      		//   3xx redirection -- Because I don't want to ignore SHOULD clauses of RFC 2616, section 10
      		//   4xx client errors -- Ditto and also to keep server admins from going crazy
	      	//   5xx server errors -- Not particularly indicative of server health
   		];
   		
   		//-----------------------------------------------------------------------------------------
   		// Properties
   		//-----------------------------------------------------------------------------------------
   		
		private var _fileURL:URLRequest;
		private var _downloadedFile:File;
		private var _urlStream:URLStream;
		private var _fileStream:FileStream;
		private var _isInError:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function AUFileDownloader(url:URLRequest, file:File):void
		{
			_fileURL = url;
			_fileURL.useCache = false;
			_downloadedFile = file;
			
			_urlStream = new URLStream();
			_urlStream.addEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			_urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadError);
			_urlStream.addEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
			_urlStream.addEventListener(Event.OPEN, onDownloadOpen);
			_urlStream.addEventListener(Event.COMPLETE, onDownloadComplete);
			_urlStream.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onDownloadResponseStatus);
		}
		
		
		public function download():void
		{
			_urlStream.load(_fileURL);
		}
		
		
		public function cancel():void
		{
			try
			{
				if (_urlStream && _urlStream.connected) _urlStream.close();
				disposeFileStream();
				if (_downloadedFile && _downloadedFile.exists) _downloadedFile.deleteFile();
			}
			catch(err:Error)
			{
				Log.warn("Error during canceling the download - " + err.message, this);
			}
		}
		
		
		public function inProgress():Boolean
		{
			return _urlStream.connected;
		}
		
		
		/**
		 * Disposes the class.
		 */
		public function dispose():void
		{
			disposeURLStream();
			disposeFileStream();
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		override public function toString():String
		{
			return "FileDownloader";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onDownloadResponseStatus(e:HTTPStatusEvent):void
		{
			if (!isHTTPStatusAcceptable(e.status))
			{
				dispatchErrorEvent("Invalid HTTP status code: " + e.status,
					AUConstants.ERROR_INVALID_HTTP_STATUS, e.status);
			}
		}
		
		
		private function onDownloadError(e:ErrorEvent):void
		{
			if (e is IOErrorEvent)
				dispatchErrorEvent(e.text, AUConstants.ERROR_IO_DOWNLOAD, e.errorID);
			else if (e is SecurityErrorEvent)
				dispatchErrorEvent(e.text, AUConstants.ERROR_SECURITY, e.errorID);
		}
		
		
		private function onDownloadOpen(e:Event):void
		{
			Log.debug("Opening file on disk ...", this);
			_fileStream = new FileStream();
			try
			{
				_fileStream.open(_downloadedFile, FileMode.WRITE);
			}
			catch(err:Error)
			{
				Log.warn("Error opening file on disk - " + err.message, this);
				_isInError = true;
				dispatchErrorEvent(err.message, AUConstants.ERROR_IO_FILE, err.errorID);
				return;
			}
			dispatchEvent(new AUUpdateEvent(AUUpdateEvent.DOWNLOAD_START, false, false));
		}
		
		
		private function onDownloadProgress(e:ProgressEvent):void
		{
			if (!_isInError)
			{
				saveBytes();
				dispatchEvent(e);
			}
		}
		
		
		private function onDownloadComplete(e:Event):void
		{
			// empty the buffer
			while (_urlStream && _urlStream.bytesAvailable)
			{
				saveBytes();
			}
			if (_urlStream && _urlStream.connected) disposeURLStream();
			disposeFileStream();
			if (!_isInError)
			{
				setTimeout(function():void
				{
					dispatchEvent(new AUUpdateEvent(AUUpdateEvent.DOWNLOAD_COMPLETE));
				}, 1000);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function saveBytes():void
		{
			if (!_fileStream || !_urlStream || !_urlStream.connected) return;
			try
			{
				var bytes:ByteArray = new ByteArray();
				_urlStream.readBytes(bytes, 0, _urlStream.bytesAvailable);
				_fileStream.writeBytes(bytes);
			}
			catch(err1:EOFError)
			{
				_isInError = true;
				Log.warn("EOFError - " + err1, this);
				dispatchErrorEvent(err1.message, AUConstants.ERROR_EOF_DOWNLOAD, err1.errorID);
			}
			catch(err2:IOError)
			{
				_isInError = true;
				Log.warn("IOError - " + err2, this);
				dispatchErrorEvent(err2.message, AUConstants.ERROR_IO_FILE, err2.errorID);
			}
		}
		
		
		private function dispatchErrorEvent(eventText:String, errorID:int = 0,
			subErrorID:int = 0):void
		{
			_isInError = true;
			if (_urlStream && _urlStream.connected) disposeURLStream();
			dispatchEvent(new AUDownloadErrorEvent(AUDownloadErrorEvent.DOWNLOAD_ERROR,
				false, true, eventText, errorID, subErrorID));
		}
		
		
		private function disposeURLStream():void
		{
			if (!_urlStream) return;
			_urlStream.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			_urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadError);
			_urlStream.removeEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
			_urlStream.removeEventListener(Event.OPEN, onDownloadOpen);
			_urlStream.removeEventListener(Event.COMPLETE, onDownloadComplete);
			_urlStream.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onDownloadResponseStatus);
			_urlStream = null;
		}
		
		
		private function disposeFileStream():void
		{
			if (!_fileStream) return;
			_fileStream.close();
			_fileStream = null;
		}
		
		
		private static function isHTTPStatusAcceptable(httpStatus:int):Boolean
		{
			// not in the acceptable status array
			if (ACCEPTABLE_STATUSES.indexOf(httpStatus) == -1) return false;
			return true;
		}
	}
}
