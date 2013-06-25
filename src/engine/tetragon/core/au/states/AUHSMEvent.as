package tetragon.core.au.states
{
	import flash.events.Event;
	
	
	public class AUHSMEvent extends Event
	{
		public static const ENTER:String = "enter";
		public static const EXIT:String = "exit";


		public function AUHSMEvent(type:String)
		{
			super(type);
		}
	}
}
