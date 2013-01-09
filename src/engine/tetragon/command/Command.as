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
package tetragon.command
{
	import com.hexagonstar.signals.Signal;
	import com.hexagonstar.util.reflection.getClassName;

	
	/**
	 * Abstract class for command implementations. A command encapsulates code that can be
	 * instantiated and executed anywhere else in the application.
	 * 
	 * <p>Commands can either be executed without signal listening if their execution code is
	 * processed synchronous or a command can be listened to for signals that are broadcasted
	 * by the command when the it completes, an error occurs or during command progress
	 * steps.</p>
	 */
	public class Command
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _listener:ICommandListener;
		/** @private */
		protected var _aborted:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Signal
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		public var completeSignal:Signal;
		/** @private */
		public var abortSignal:Signal;
		/** @private */
		public var errorSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new Command instance.
		 */
		public function Command()
		{
			completeSignal = new Signal();
			abortSignal = new Signal();
			errorSignal = new Signal();
			_aborted = false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Executes the command. In sub-classed commands you should override this
		 * method, make a call to super.execute and then initiate all your command's
		 * execution implementation from here.
		 */ 
		public function execute():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Aborts the command's execution. Any sub-classed implementation needs
		 * to take care of abort functionality by checking the _aborted property.
		 */
		public function abort():void
		{
			_aborted = true;
		}
		
		
		/**
		 * Disposes the command.
		 */
		public function dispose():void
		{
			completeSignal.removeAll();
			abortSignal.removeAll();
			errorSignal.removeAll();
			_listener = null;
		}
		
		
		/**
		 * Returns a string representation of the command.
		 * 
		 * @return A string representation of the command.
		 */
		public function toString():String
		{
			return getClassName(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the name identifier of the command. Names are mainly used for the
		 * command to be identified when it should be able to be executed through the CLI.
		 * This is an abstract method which needs to be overidden in sub classes to
		 * give it a unique command name.
		 * 
		 * @return the name identifier of the command.
		 */
		public function get name():String
		{
			return "command";
		}
		
		
		/**
		 * Gets or sets the object that listens to signals fired by this command. This
		 * can be used as a shortcut. The listener has to implement the ICommandListener
		 * interface to be able to use this.
		 * 
		 * @return The object that listens to signals fired by this command.
		 */
		public function get listener():ICommandListener
		{
			return _listener;
		}
		public function set listener(v:ICommandListener):void
		{
			_listener = v;
		}
		
		
		/**
		 * Gets the abort state of the command.
		 */
		public function get aborted():Boolean
		{
			return _aborted;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Notifies listeners that the command has completed.
		 */
		protected function notifyComplete():void
		{
			completeSignal.dispatch(this);
		}
		
		
		/**
		 * Notifies listeners that the command was aborted.
		 */
		protected function notifyAbort():void
		{
			abortSignal.dispatch(this);
		}
		
		
		/**
		 * Notifies listeners that an error has occured while executing the command.
		 * 
		 * @param errorMsg The error message to be broadcasted with the event.
		 */
		protected function notifyError(errorMsg:String):void
		{
			errorSignal.dispatch(this, errorMsg);
		}
		
		
		/**
		 * Completes the command. This is an abstract method that needs to be overridden
		 * by subclasses. You put code here that should be executed when the command
		 * finishes, like cleaning up event listeners etc. After your code, place a call
		 * to super.complete().
		 */
		protected function complete():void
		{
			if (!_aborted) notifyComplete();
			else notifyAbort();
		}
	}
}
