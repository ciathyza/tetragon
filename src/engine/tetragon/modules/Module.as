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
package tetragon.modules
{
	import tetragon.Main;
	import tetragon.data.Registry;
	import tetragon.util.reflection.getClassName;

	import flash.display.Stage;
	
	
	/**
	 * Abstract base class for tetragon modules. You can extend this class when
	 * creating new tetragon modules, in addition to implementing the IModule interface.
	 */
	public class Module implements IModule
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _main:Main;
		/** @private */
		private var _id:String;
		/** @private */
		private var _priority:int;
		/** @private */
		private var _initParams:Object;
		/** @private */
		private var _started:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function Module()
		{
			_main = Main.instance;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function init():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function start():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function stop():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function toString():String
		{
			return getClassName(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function get moduleInfo():IModuleInfo
		{
			return null;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get id():String
		{
			return _id;
		}
		public function set id(v:String):void
		{
			if (_id != null) return;
			_id = v;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get priority():int
		{
			return _priority;
		}
		public function set priority(v:int):void
		{
			_priority = v;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get initParams():Object
		{
			return _initParams;
		}
		public function set initParams(v:Object):void
		{
			_initParams = v;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get autoStart():Boolean
		{
			return true;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get started():Boolean
		{
			return _started;
		}
		public function set started(v:Boolean):void
		{
			_started = v;
		}
		
		
		/**
		 * Reference to Main for use in sub classes.
		 */
		protected function get main():Main
		{
			return _main;
		}
		
		
		/**
		 * Reference to the registry main for use in sub classes.
		 * 
		 * @private
		 */
		protected function get registry():Registry
		{
			return _main.registry;
		}
		
		
		/**
		 * Reference to the main stage for use in sub classes.
		 * 
		 * @private
		 */
		protected function get stage():Stage
		{
			return _main.stage;
		}
	}
}
