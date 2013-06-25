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
	import tetragon.Main;
	import tetragon.core.signals.Signal;
	import tetragon.util.reflection.getClassName;
	
	
	/**
	 * Abstract base class for state classes.
	 * 
	 * <p>States are used to organize the execution of the application into several
	 * 'abstract' areas. For example in a game the intro, main menu, gameplay and hi-score
	 * display could be categorized as states. A state often represents a screen but it is
	 * not a requirement that a state represents a single screen. A state could also span
	 * over several screens or might not be related to any screen at all. On the other
	 * hand several states could also share the same screen.</p>
	 */
	public class State
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private static var _main:Main;
		/** @private */
		private var _id:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _enteredSignal:Signal;
		/** @private */
		private var _exitedSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function State(id:String)
		{
			_id = id;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Enters the state. This method initiates loading of any resources that are
		 * registered in the <code>registerResources()</code> method of the state.
		 * 
		 * <p>You normally don't call this method manually. Instead the state manager
		 * calls it automatically when the state is requested to be entered.</p>
		 */
		public function enter():void
		{
			/* Abstract method! */
			entered();
		}
		
		
		/**
		 * Updates the state. You normally don't call this method manually. Instead the
		 * state manager calls it automatically on the current state when the
		 * <code>updateState()</code> method in the screen manager is called.
		 * 
		 * <p>This is an abstract method. You can override this method in your state
		 * sub-class if your state class requires the updating of any child objects.</p>
		 */
		public function update():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Exits the state. This method will stop the state if it's started, then removes
		 * any listeners, unloads it's resources if necessary and disposes the state
		 * afterwards. You normally don't call this method manually. Instead the state
		 * manager calls it automatically when the state is requested to be exited.
		 */
		public function exit():void
		{
			/* Abstract method! */
			exited();
		}
		
		
		/**
		 * Returns a String representation of the state.
		 * 
		 * @return A String representation of the state.
		 */
		public function toString():String
		{
			return getClassName(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * ID of the state.
		 */
		public function get id():String
		{
			return _id;
		}
		
		
		/**
		 * Signal that is dispatched after the state has been entered.
		 * @private
		 */
		internal function get enteredSignal():Signal
		{
			if (!_enteredSignal) _enteredSignal = new Signal();
			return _enteredSignal;
		}
		
		
		/**
		 * Signal that is dispatched after the state has been exited.
		 * @private
		 */
		internal function get exitedSignal():Signal
		{
			if (!_exitedSignal) _exitedSignal = new Signal();
			return _exitedSignal;
		}
		
		
		/**
		 * A reference to Main for quick access in subclasses.
		 * 
		 * @see tetragon.Main
		 */
		protected static function get main():Main
		{
			if (!_main) _main = Main.instance;
			return _main;
		}
		
		
		/**
		 * A reference to the state manager for quick access in subclasses.
		 * 
		 * @see tetragon.state.StateManager
		 */
		protected static function get stateManager():StateManager
		{
			return main.stateManager;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Call this method at the end of your overriden enter method.
		 * @private
		 */
		protected function entered():void
		{
			if (!_enteredSignal) return;
			_enteredSignal.dispatch(this);
		}
		
		
		/**
		 * Call this method at the end of your overriden exit method.
		 * @private
		 */
		protected function exited():void
		{
			if (!_exitedSignal) return;
			_exitedSignal.dispatch(this);
		}
	}
}
