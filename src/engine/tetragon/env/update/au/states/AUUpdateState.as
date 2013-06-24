package tetragon.env.update.au.states
{
	public final class AUUpdateState
	{
		private static const STATES:Array = 
		[
			"UNINITIALIZED",
			"INITIALIZING",
			"READY",
			"BEFORE_CHECKING",
			"CHECKING",
			"AVAILABLE",
			"DOWNLOADING",
			"DOWNLOADED",
			"INSTALLING",
			"PENDING_INSTALLING"
		];
		
		public static const UNINITIALIZED:int		= 0;
		public static const INITIALIZING:int		= 1;
		public static const READY:int				= 2;
		public static const BEFORE_CHECKING:int		= 3;
		public static const CHECKING:int			= 4;
		public static const AVAILABLE:int			= 5;
		public static const DOWNLOADING:int			= 6;
		public static const DOWNLOADED:int			= 7;
		public static const INSTALLING:int			= 8;
		public static const PENDING_INSTALLING:int	= 9;
		
		
		public static function getStateName(state:int):String
		{
			if (state >= 0 && state < STATES.length) return STATES[state];
			return "INVALID_STATE: " + state;
		}
	}
}
