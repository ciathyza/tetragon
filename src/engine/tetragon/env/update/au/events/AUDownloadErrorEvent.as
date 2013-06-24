package tetragon.env.update.au.events
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	
	/**
	 * A DownloadErrorEvent is dispatched when an error happens while downloading
	 * the update file.
	 */
	public class AUDownloadErrorEvent extends ErrorEvent
	{
		/**
		 * The <code>DownloadErrorEvent.DOWNLOAD_ERROR</code> constant defines the value of the  
		 * <code>type</code> property of the event object for a <code>downloadError</code> event.
		 */
		public static const DOWNLOAD_ERROR:String = "downloadError";


		/**
		 * Creates an DownloadError object to pass to event listeners 
		 */
		public function AUDownloadErrorEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, text:String = "", id:int = 0, subErrorID:int = 0)
		{
			super(type, bubbles, cancelable, text, id);
			this.subErrorID = subErrorID;
		}


		/**
		 * @inheritDoc
		 */
		override public function clone():Event
		{
			return new AUDownloadErrorEvent(type, bubbles, cancelable, text, errorID, subErrorID);
		}


		/**
		 * @inheritDoc
		 */
		override public function toString():String
		{
			return "[DownloadErrorEvent (type=" + type + " text=" + text + " id=" + errorID + " subErrorID=" + subErrorID + ")]";
		}


		public var subErrorID:int = 0;
	}
}
