/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * Tetragon : Game Engine for multi-platform ActionScript projects.
 * http://www.tetragonengine.com/ - Copyright (C) 2012 Sascha Balkau
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
package tetragon.state
{
	import tetragon.debug.Log;

	import com.hexagonstar.util.string.TabularText;
	
	
	/**
	 * StateManager class
	 */
	public final class StateManager
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _states:Object;
		/** @private */
		private var _currentState:State;
		/** @private */
		private var _nextState:State;
		
		
		//-----------------------------------------------------------------------------------------
		// Signal
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _stateEnteredSignal:StateSignal;
		/** @private */
		private var _stateExitedSignal:StateSignal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function StateManager()
		{
			_states = {};
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Registers a state class for use with the state manager.
		 * 
		 * @param stateID
		 * @param stateClass
		 * @return true or false.
		 */
		public function registerState(stateID:String, stateClass:Class):Boolean
		{
			if (stateID == null || !stateClass) return false;
			var s:* = new stateClass(stateID);
			if (!(s is State))
			{
				Log.error("Tried to register a state that is not of type State (" + stateClass
					+ ").", this);
				return false;
			}
			_states[stateID] = s;
			return true;
		}
		
		
		/**
		 * Enters the state with the specified stateID.
		 * 
		 * @param stateID
		 */
		public function enterState(stateID:String):void
		{
			var state:State = _states[stateID];
			if (!state)
			{
				Log.error("Could not enter state with ID \"" + stateID
					+ "\" because no state with this ID has been registered.", this);
				return;
			}
			
			/* If the specified state is already entered, only update it! */
			if (_currentState == state)
			{
				updateState();
				return;
			}
			
			_nextState = state;
			exitCurrentState();
		}
		
		
		/**
		 * Updates the current state.
		 */
		public function updateState():void
		{
			if (!_currentState) return;
			Log.debug("Updating " + _currentState.toString() + ".", this);
			_currentState.update();
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "StateManager";
		}
		
		
		/**
		 * Returns a list of all registered states.
		 */
		public function dumpStateList():String
		{
			var t:TabularText = new TabularText(2, true, "  ", null, "  ", 100, ["ID", "CURRENT"]);
			for (var id:String in _states)
			{
				var state:State = _states[id];
				var current:String = _currentState == state ? "true" : "";
				t.add([id, current]);
			}
			return toString() + "\n" + t;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the currently entered state.
		 */
		public function get currentState():State
		{
			return _currentState;
		}
		
		
		/**
		 * A signal that is dispatched whenever a state has been entered.<br/>
		 * Signal parameter signature: <code>type:String, state:State</code>
		 */
		public function get stateEnteredSignal():StateSignal
		{
			if (!_stateEnteredSignal) _stateEnteredSignal = new StateSignal();
			return _stateEnteredSignal;
		}
		
		
		/**
		 * A signal that is dispatched whenever a state has been exited.<br/>
		 * Signal parameter signature: <code>type:String, state:State</code>
		 */
		public function get stateExitedSignal():StateSignal
		{
			if (!_stateExitedSignal) _stateExitedSignal = new StateSignal();
			return _stateExitedSignal;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onStateEntered(enteredState:State):void
		{
			if (!_stateEnteredSignal) return;
			_stateEnteredSignal.dispatch(StateSignal.ENTERED, enteredState);
		}
		
		
		/**
		 * @private
		 */
		private function onStateExited(exitedState:State):void
		{
			if (!_stateExitedSignal) return;
			_stateExitedSignal.dispatch(StateSignal.EXITED, exitedState);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function exitCurrentState():void
		{
			if (_currentState)
			{
				Log.debug("Exiting " + _currentState.toString() + " ...", this);
				_currentState.exitedSignal.addOnce(onStateExited);
				_currentState.exit();
			}
			else
			{
				enterNextState();
			}
		}
		
		
		/**
		 * @private
		 */
		private function enterNextState():void
		{
			if (_nextState)
			{
				_currentState = _nextState;
				_nextState = null;
				Log.debug("Entering " + _currentState.toString() + " ...", this);
				
				_currentState.enteredSignal.addOnce(onStateEntered);
				_currentState.enter();
			}
		}
	}
}
