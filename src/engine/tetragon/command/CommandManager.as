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
	import tetragon.Main;
	
	
	/**
	 * A manager that can be used to manage command execution. You call the execute
	 * method and specify a command and any handler methods that should be notified of
	 * broadcasted command events. After the command has finished execution all it's
	 * event listeners are automatically removed. The CommandManager also makes sure
	 * that the same command is not executed more than once at the same time.
	 */
	public class CommandManager implements ICommandListener
	{
		// -----------------------------------------------------------------------------------------
		// Properties
		// -----------------------------------------------------------------------------------------
		
		/** @private */
		private var _main:Main;
		/** @private */
		private var _executingCommands:Vector.<CommandVO>;
		
		
		// -----------------------------------------------------------------------------------------
		// Constructor
		// -----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function CommandManager()
		{
			_main = Main.instance;
			_executingCommands = new Vector.<CommandVO>();
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Public Methods
		// -----------------------------------------------------------------------------------------
		
		/**
		 * Executes the specified command.
		 * 
		 * @param cmd The command to execute.
		 * @param completeHandler An optional complete handler that is called once the
		 *            command has completed.
		 * @param errorHandler An optional error handler that is called if the command
		 *            broadcasts an error event.
		 * @param abortHandler An optional abort handler that is called if the command
		 *            has been aborted.
		 * @param progressHandler An optional complete handler that is called everytime the
		 *            command broadcasts a progress event.
		 * @return true if the command is being executed successfully, false if not (e.g. if
		 *         the same command instance is already in execution).
		 */
		public function execute(cmd:CLICommand, completeHandler:Function = null,
			errorHandler:Function = null, abortHandler:Function = null,
			progressHandler:Function = null):Boolean
		{
			if (!isExecuting(cmd))
			{
				//Log.trace("Executing command: " + cmd.name, this);
				
				var c:CommandVO = new CommandVO();
				c.command = cmd;
				c.completeHandler = completeHandler;
				c.errorHandler = errorHandler;
				c.abortHandler = abortHandler;
				c.progressHandler = progressHandler;
				
				_executingCommands.push(c);
				addCommandListeners(c);
				
				cmd.main = _main;
				cmd.commandManager = this;
				
				cmd.execute();
				
				return true;
			}
			else
			{
				/* Do nothing else if specified command is currently in execution. */
				return false;
			}
		}
		
		
		/**
		 * Aborts all currently executed commands.
		 */
		public function abortAll():void
		{
			for each (var c:CommandVO in _executingCommands)
			{
				c.command.abort();
			}
		}
		
		
		/**
		 * Checks if the specified command is currently being executed.
		 */
		public function isExecuting(cmd:CLICommand):Boolean
		{
			for each (var c:CommandVO in _executingCommands)
			{
				if (cmd == c.command)
					return true;
			}
			return false;
		}
		
		
		/**
		 * Returns a String Representation of CommandManager.
		 * 
		 * @return A String Representation of CommandManager.
		 */
		public function toString():String
		{
			return "CommandManager";
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Getters & Setters
		// -----------------------------------------------------------------------------------------
		
		/**
		 * Returns the amount of commands that are currently in execution.
		 */
		public function get executingCommandCount():int
		{
			return _executingCommands.length;
		}
		
		
		/**
		 * Pauses or unpauses all currently executed commands that support being paused and
		 * unpaused.
		 */
		public function set paused(v:Boolean):void
		{
			for each (var c:CommandVO in _executingCommands)
			{
				if (c.command is PausableCommand)
				{
					PausableCommand(c.command).paused = v;
				}
			}
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Event Handlers
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 * 
		 * @param command
		 */
		public function onCommandComplete(command:Command):void
		{
			//Debug.trace(toString() + " Completed command: " + command.name);
			/* After complete remove the command from the executing commands queue */
			removeCommand(command);
		}
		
		
		/**
		 * @private
		 * 
		 * @param command
		 */
		public function onCommandAbort(command:Command):void
		{
			//Debug.trace(toString() + " Command aborted: " + command.name);
			/* After abort remove the command from the executing commands queue */
			removeCommand(command);
		}
		
		
		/**
		 * @private
		 * 
		 * @param command
		 * @param message
		 */
		public function onCommandError(command:Command, message:String):void
		{
			/* Only used for debugging! */
			//Debug.trace(toString() + " Command error: " + command.name);
		}
		
		
		/**
		 * @private
		 * 
		 * @param command
		 * @param message
		 * @param progress
		 */
		public function onCommandProgress(command:Command, message:String, progress:int):void
		{
			/* Only used for debugging! */
			// Log.debug(toString() + " Command progress: " + e.command.name);
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Private Methods
		// -----------------------------------------------------------------------------------------
		
		/**
		 * Adds signal listeners for the command in the specified commandDO. If the command's
		 * listener property has a listener object assigned this will add signal listeners to
		 * that listener object. Otherwise it will check if any of the optional signal
		 * handlers were specified with a call to CommandManager.execute() and if any of
		 * them are assigned this method adds signal listeners to these.
		 * 
		 * @private
		 * 
		 * @param cmdDO The command data object with the command that needs listeners added.
		 */
		private function addCommandListeners(cmdVO:CommandVO):void
		{
			var cmd:CLICommand = cmdVO.command;
			var l:ICommandListener = cmd.listener;

			/* If the command has a listener assigned we use it to broadcast signals
			 * to. Otherwise the command must have handler methods manually assigned. */
			if (l)
			{
				cmd.completeSignal.add(l.onCommandComplete);
				cmd.errorSignal.add(l.onCommandError);
				cmd.abortSignal.add(l.onCommandAbort);
				if (cmd is CompositeCommand)
				{
					CompositeCommand(cmd).progressSignal.add(l.onCommandProgress);
				}
			}
			else
			{
				if (cmdVO.completeHandler != null)
				{
					cmd.completeSignal.add(cmdVO.completeHandler);
				}
				if (cmdVO.errorHandler != null)
				{
					cmd.errorSignal.add(cmdVO.errorHandler);
				}
				if (cmdVO.abortHandler != null)
				{
					cmd.abortSignal.add(cmdVO.abortHandler);
				}
				if (cmdVO.progressHandler != null)
				{
					if (cmd is CompositeCommand)
					{
						CompositeCommand(cmd).progressSignal.add(cmdVO.progressHandler);
					}
				}
			}
			
			/* Add event listeners that call handlers in the command manager */
			cmd.completeSignal.add(onCommandComplete);
			cmd.errorSignal.add(onCommandError);
			cmd.abortSignal.add(onCommandAbort);
			if (cmd is CompositeCommand)
			{
				CompositeCommand(cmd).progressSignal.add(onCommandProgress);
			}
		}
		
		
		/**
		 * First tries to find the commandDO that is associated with the specified command
		 * and removes it from the executing commands queue. After that any event listeners
		 * are removed from the command.
		 * 
		 * @private
		 * 
		 * @param c The command to remove.
		 */
		private function removeCommand(c:Command):void
		{
			/* Find the commandDO that the specified command is part of and remove it */
			var cmdVO:CommandVO;
			for (var i:int = 0; i < _executingCommands.length; i++)
			{
				if (c == _executingCommands[i].command)
				{
					cmdVO = _executingCommands.splice(i, 1)[0];
					break;
				}
			}
			
			/* Remove all event listeners from the command */
			if (cmdVO)
			{
				var cmd:CLICommand = cmdVO.command;
				var l:ICommandListener = cmd.listener;
				
				if (l)
				{
					cmd.completeSignal.remove(l.onCommandComplete);
					cmd.errorSignal.remove(l.onCommandError);
					cmd.abortSignal.remove(l.onCommandAbort);
					if (cmd is CompositeCommand)
					{
						CompositeCommand(cmd).progressSignal.remove(l.onCommandProgress);
					}
				}
				
				if (cmdVO.completeHandler != null)
				{
					cmd.completeSignal.remove(cmdVO.completeHandler);
				}
				if (cmdVO.errorHandler != null)
				{
					cmd.errorSignal.remove(cmdVO.errorHandler);
				}
				if (cmdVO.abortHandler != null)
				{
					cmd.abortSignal.remove(cmdVO.abortHandler);
				}
				if (cmdVO.progressHandler != null)
				{
					if (cmd is CompositeCommand)
					{
						CompositeCommand(cmd).progressSignal.remove(cmdVO.progressHandler);
					}
				}
				
				cmd.completeSignal.remove(onCommandComplete);
				cmd.errorSignal.remove(onCommandError);
				cmd.abortSignal.remove(onCommandAbort);
				if (cmd is CompositeCommand)
				{
					CompositeCommand(cmd).progressSignal.remove(onCommandProgress);
				}
				
				cmd.dispose();
			}
			else
			{
				/* CommandVO belonging to the command was not found,
				 * something's foul here. This should never happen! */
				throw new Error(toString() + " no CommandVO found for the command!");
			}
		}
	}
}


import tetragon.command.CLICommand;

/**
 * Command Value Object
 * @private
 */
final class CommandVO
{
	public var command:CLICommand;
	public var completeHandler:Function;
	public var errorHandler:Function;
	public var abortHandler:Function;
	public var progressHandler:Function;
}
