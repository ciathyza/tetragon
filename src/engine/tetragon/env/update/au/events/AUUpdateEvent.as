package tetragon.env.update.au.events
{
	import flash.events.Event;

	/**
	 * A UpdateEvent is dispatched by a ApplicationUpdater object during the update process.
	 */	
	public class AUUpdateEvent extends Event
	{
		/**
		 * The <code>UpdateEvent.INITIALIZED</code> constant defines the value of the  
		 * <code>type</code> property of the event object for a <code>initialized</code> event.
		 */			
		public static const INITIALIZED:String = "initialized";
		
		/**
		 * The <code>UpdateEvent.BEFORE_INSTALL</code> constant defines the value of the  
		 * <code>type</code> property of the event object for a <code>beforeInstall</code> event.
		 */			
		public static const BEFORE_INSTALL:String = "beforeInstall";
		
		/**
		 * The <code>UpdateEvent.CHECK_FOR_UPDATE</code> constant defines the value of the  
		 * <code>type</code> property of the event object for a <code>checkForUpdate</code> event.
		 */			
		public static const CHECK_FOR_UPDATE:String = "checkForUpdate";
		
		/**
		 * The <code>UpdateEvent.DOWNLOAD_START</code> constant defines the value of the  
		 * <code>type</code> property of the event object for a <code>downloadStart</code> event.
		 */			
		public static const DOWNLOAD_START:String = "downloadStart";

		/**
		 * The <code>UpdateEvent.DOWNLOAD_COMPLETE</code> constant defines the value of the  
		 * <code>type</code> property of the event object for a <code>downloadComplete</code> event.
		 */			
		public static const DOWNLOAD_COMPLETE:String = "downloadComplete";
		
		public function AUUpdateEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		/**
	 	 * @inheritDoc
	 	 */
		override public function clone():Event
		{
			return new AUUpdateEvent(type, bubbles, cancelable);	
		}
		
		/**
	 	 * @inheritDoc
	 	 */
		override public function toString():String
		{
			return "[UpdateEvent (type=" + type + ")]";	
		}
	}
}
