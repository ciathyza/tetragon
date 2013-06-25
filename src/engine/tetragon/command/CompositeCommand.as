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
	import tetragon.core.signals.Signal;
	
	
	/**
	 * A CompositeCommand is a composite command that consists of several single
	 * commands which are executed in sequential order.
	 */
	public class CompositeCommand extends PausableCommand implements ICommandListener
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _progress:int;
		/** @private */
		protected var _commands:Vector.<Command>;
		/** @private */
		protected var _messages:Vector.<String>;
		/** @private */
		protected var _currentCmd:Command;
		/** @private */
		protected var _currentMsg:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Signal
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		public var progressSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new CompositeCommand instance.
		 */
		public function CompositeCommand()
		{
			super();
			progressSignal = new Signal();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Executes the composite command. Abstract method. Be sure to call super.execute()
		 * first in subclassed execute methods.
		 */ 
		override public function execute():void
		{
			_paused = false;
			_progress = 0;
			_commands = new Vector.<Command>();
			_messages = new Vector.<String>();
			
			enqueueCommands();
			next();
		}
		
		
		/**
		 * Aborts the command's execution.
		 */
		override public function abort():void
		{
			super.abort();
			if (_currentCmd) _currentCmd.abort();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
			
			for (var i:int = 0; i < _commands.length; i++)
			{
				_commands[i].dispose();
			}
			
			progressSignal.removeAll();
			_currentCmd = null;
			_currentMsg = null;
			_commands = null;
			_messages = null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The name identifier of the command.
		 */
		override public function get name():String
		{
			return "compositeCommand";
		}
		
		
		/**
		 * The command's progress.
		 */
		public function get progress():int
		{
			return _progress;
		}
		
		/**
		 * The Message associated to the command's progress.
		 */
		public function get progressMessage():String
		{
			return _currentMsg;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @param command
		 * @param message
		 * @param progress
		 */
		public function onCommandProgress(command:Command, message:String, progress:int):void
		{
			/* Not used yet! */
		}
		
		
		/**
		 * @param command
		 */
		public function onCommandComplete(command:Command):void
		{
			removeCommandListeners();
			notifyProgress();
			next();
		}
		
		
		/**
		 * @param command
		 */
		public function onCommandAbort(command:Command):void
		{
			removeCommandListeners();
			notifyProgress();
			next();
		}
		
		
		/**
		 * @param command
		 * @param message
		 */
		public function onCommandError(command:Command, message:String):void
		{
			removeCommandListeners();
			notifyProgress();
			notifyError(message);
			next();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Abstract method. This is the place where you enqueue single commands.
		 */
		protected function enqueueCommands():void
		{
		}
		
		
		/**
		 * Enqueues a commandfor use in the composite command's execution sequence.
		 */
		protected function enqueue(cmd:Command, progressMsg:String = ""):void
		{
			_commands.push(cmd);
			_messages.push(progressMsg);
		}
		
		
		/**
		 * Executes the next enqueued command.
		 */
		protected function next():void
		{
			_currentMsg = _messages.shift();
			
			if (!_aborted && _commands.length > 0)
			{
				_currentCmd = _commands.shift();
				_currentCmd.completeSignal.add(onCommandComplete);
				_currentCmd.abortSignal.add(onCommandAbort);
				_currentCmd.errorSignal.add(onCommandError);
				_currentCmd.execute();
			}
			else
			{
				complete();
			}
		}
		
		
		protected function removeCommandListeners():void
		{
			_currentCmd.completeSignal.remove(onCommandComplete);
			_currentCmd.abortSignal.remove(onCommandAbort);
			_currentCmd.errorSignal.remove(onCommandError);
		}
		
		
		/**
		 * Notify listeners that the command has updated progress.
		 */
		protected function notifyProgress():void
		{
			_progress++;
			progressSignal.dispatch(this, _currentMsg, _progress);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function notifyError(errorMsg:String):void
		{
			errorSignal.dispatch(this, errorMsg, _progress);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function complete():void
		{
			super.complete();
		}
	}
}
