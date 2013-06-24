package tetragon.env.update.au.events
{
	import flash.events.Event;

	public class AUStatusUpdateEvent extends AUUpdateEvent
	{
		/**
		 * The <code>StatusUpdateEvent.UPDATE_STATUS</code> constant defines the value of the  
		 * <code>type</code> property of the event object for a <code>updateStatus</code> event.
		 */
		public static const UPDATE_STATUS:String = "updateStatus";


		public function AUStatusUpdateEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, available:Boolean = false, version:String = "", details:Array = null, versionLabel:String = "")
		{
			super(type, bubbles, cancelable);
			this.available = available;
			this.version = version;
			this.details = details == null ? [] : details;
			this.versionLabel = versionLabel;
		}


		/**
		 * @inheritDoc
		 */
		override public function clone():Event
		{
			return new AUStatusUpdateEvent(type, bubbles, cancelable, available, version, details, versionLabel);
		}


		/**
		 * @inheritDoc
		 */
		override public function toString():String
		{
			return "[StatusUpdateEvent (type=" + type + " available=" + available + " version=" + version + " details=" + details + " versionLabel=" + versionLabel + " )]";
		}


		/**
		 * Indicates if an update is available. 
		 */
		public var available:Boolean = false;
		/**
		 * Indicates the version of the new update
		 */
		public var version:String = "";
		/**
		 * Indicates the versionLabel of the new update
		 */
		public var versionLabel:String = "";
		/**
		 * The text describing the new update. It may contain html tags.
		 */
		public var details:Array = [];
	}
}
