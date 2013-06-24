package tetragon.env.update.airupdater.events
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	
	/**
	 * A StatusUpdateFileErrorEvent is dispatched when a call to the <code>checkForUpdate()</code> method of a ApplicationUpdater object encounters an error
	 * while downloading or parsing the update descriptor
	 */
	public class StatusFileUpdateErrorEvent extends ErrorEvent
	{
		/**
		 * The <code>StatusUpdateErrorEvent.UPDATE_ERROR</code> constant defines the value of the  
		 * <code>type</code> property of the event object for a <code>statusUpdateError</code> event.
		 */
		public static const FILE_UPDATE_ERROR:String = "fileUpdateError";


		public function StatusFileUpdateErrorEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, text:String = "", id:int = 0)
		{
			super(type, bubbles, cancelable, text, id);
		}


		/**
		 * @inheritDoc
		 */
		override public function clone():Event
		{
			return new StatusFileUpdateErrorEvent(type, bubbles, cancelable, text, errorID);
		}


		/**
		 * @inheritDoc
		 */
		override public function toString():String
		{
			return "[StatusFileUpdateErrorEvent (type=" + type + " text=" + text + " id=" + errorID + ")]";
		}
	}
}