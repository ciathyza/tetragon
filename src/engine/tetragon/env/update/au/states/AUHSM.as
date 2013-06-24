package tetragon.env.update.au.states
{
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	
	public class AUHSM extends EventDispatcher
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _hsmState:Function;
		private var _asyncTimer:Timer;
		private var _asyncState:Function;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function AUHSM(initialState:Function):void
		{
			_hsmState = initialState;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function init():void
		{
			try
			{
				_hsmState(new AUHSMEvent(AUHSMEvent.ENTER));
			}
			catch(err:Error)
			{
				_hsmState(new ErrorEvent(ErrorEvent.ERROR, false, false, err.message, err.errorID));
			}
		}
		
		
		public function dispatch(e:Event):void
		{
			try
			{
				_hsmState(e);
			}
			catch(err:Error)
			{
				_hsmState(new ErrorEvent(ErrorEvent.ERROR, false, false, err.message, err.errorID));
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		protected function get stateHSM():Function
		{
			return _hsmState;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		protected function onAsyncTimer(e:TimerEvent):void
		{
			transition(_asyncState);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		protected function transition(state:Function):void
		{
			// If we got here from a timer, clear it
			if (_asyncTimer)
			{
				_asyncTimer.removeEventListener(TimerEvent.TIMER, onAsyncTimer);
				_asyncTimer = null;
				_asyncState = null;
			}
			
			try
			{
				_hsmState(new AUHSMEvent(AUHSMEvent.EXIT));
				_hsmState = state;
				_hsmState(new AUHSMEvent(AUHSMEvent.ENTER));
			}
			catch(err:Error)
			{
				_hsmState(new ErrorEvent(ErrorEvent.ERROR, false, false, "Unhandled exception "
					+ err.name + ": " + err.message, err.errorID));
			}
		}
		
		
		/**
		 * Transitions asynchronously to the specified function.
		 */
		protected function transitionAsync(state:Function):void
		{
			if (_asyncTimer) throw new IllegalOperationError("Async transition already queued.");
			_asyncState = state;
			_asyncTimer = new Timer(0, 1);
			_asyncTimer.addEventListener(TimerEvent.TIMER, onAsyncTimer);
			_asyncTimer.start();
		}
	}
}
