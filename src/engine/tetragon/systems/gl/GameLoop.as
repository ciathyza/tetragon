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
package tetragon.systems.gl
{
	import tetragon.Main;
	import tetragon.core.signals.Signal;
	import tetragon.systems.ISystem;
	import tetragon.view.stage3d.Stage3DProxy;

	import flash.events.Event;
	import flash.utils.getTimer;
	
	
	/**
	 * A system that executes the main game loop by dispatching a tick and a render signal.
	 */
	public final class GameLoop implements ISystem
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Total number of milliseconds elapsed since game start.
		 * @private
		 */
		private var _total:uint;
		
		/**
		 * Total number of milliseconds elapsed since last update loop.
		 * Counts down as we step through the game loop.
		 * @private
		 */
		private var _accumulator:int;
		
		/**
		 * Milliseconds of time per step of the game loop.  FlashEvent.g. 60 fps = 16ms.
		 * @private
		 */
		private var _step:Number;
		
		/**
		 * Framerate of the Flash player (NOT the game loop). Default = 30.
		 * @private
		 */
		private var _stageFrameRate:uint;
		
		/**
		 * Max allowable accumulation (see _accumulator).
		 * Should always (and automatically) be set to roughly 2x the flash player framerate.
		 * @private
		 */
		private var _maxAccumulation:uint;
		
		/**
		 * Reference to Main.
		 * @private
		 */
		private var _main:Main;
		
		/**
		 * Reference to Stage3DProxy.
		 * @private
		 */
		private var _stage3DProxy:Stage3DProxy;
		
		/** @private */
		private var _renders:uint;
		/** @private */
		private var _renderLast:uint;
		/** @private */
		private var _renderFPS:uint;
		/** @private */
		private var _started:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _tickSignal:TickSignal;
		/** @private */
		private var _renderSignal:RenderSignal;
		/** @private */
		private var _frameRateChangedSignal:Signal;
		/** @private */
		private var _enterFrameSignal:Signal;
		/** @private */
		private var _exitFrameSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function GameLoop()
		{
			_main = Main.instance;
			
			init();
			start();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function init():void
		{
			stageFrameRate = frameRate = _main.contextView.stage.frameRate;
			_accumulator = _step;
			_total = 0;
		}
		
		
		public function start():void
		{
			if (_started) return;
			_started = true;
			_main.contextView.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		
		public function stop():void
		{
			if (!_started) return;
			_started = false;
			_main.contextView.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		
		/**
		 * Sets the used Stage3DProxy object if it becomes available. The engine sets
		 * this internally!
		 * 
		 * @private
		 */
		public function setStage3DProxy(stage3DProxy:Stage3DProxy):void
		{
			_stage3DProxy = stage3DProxy;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			stop();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function toString():String
		{
			return "GameLoop";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * How many times you want the game to update each second. More updates usually
		 * means better collisions and smoother motion. NOTE: This is NOT the same thing
		 * as the Flash Player framerate!
		 */
		public function get frameRate():Number
		{
			return 1000 / _step;
		}
		public function set frameRate(v:Number):void
		{
			if (isNaN(v)) return;
			v = v < 5 ? 5 : v > 200 ? 200 : v;
			_step = 1000 / v;
			if (_maxAccumulation < _step) _maxAccumulation = _step;
			if (_frameRateChangedSignal) _frameRateChangedSignal.dispatch(frameRate);
		}
		
		
		public function get stageFrameRate():Number
		{
			return _main.contextView.stage.frameRate;
		}
		public function set stageFrameRate(v:Number):void
		{
			if (isNaN(v)) return;
			_stageFrameRate = v;
			_main.contextView.stage.frameRate = _stageFrameRate;
			_maxAccumulation = 2000 / _stageFrameRate - 1;
			if (_maxAccumulation < _step) _maxAccumulation = _step;
		}
		
		
		/**
		 * The milliseconds for one frame.
		 */
		public function get step():Number
		{
			return _step;
		}
		
		
		public function get renderFPS():uint
		{
			return _renderFPS;
		}
		
		
		public function get tickSignal():TickSignal
		{
			if (!_tickSignal) _tickSignal = new TickSignal();
			return _tickSignal;
		}
		
		
		public function get renderSignal():RenderSignal
		{
			if (!_renderSignal) _renderSignal = new RenderSignal();
			return _renderSignal;
		}
		
		
		public function get enterFrameSignal():Signal
		{
			if (!_enterFrameSignal) _enterFrameSignal = new Signal();
			return _enterFrameSignal;
		}
		
		
		public function get exitFrameSignal():Signal
		{
			if (!_exitFrameSignal) _exitFrameSignal = new Signal();
			return _exitFrameSignal;
		}
		
		
		public function get frameRateChangedSignal():Signal
		{
			if (!_frameRateChangedSignal) _frameRateChangedSignal = new Signal();
			return _frameRateChangedSignal;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onEnterFrame(e:Event):void
		{
			if (_stage3DProxy) _stage3DProxy.clear();
			if (_enterFrameSignal) _enterFrameSignal.dispatch();
			
			var time:uint = getTimer();
			var ms:uint = time - _total;
			var ticks:uint = 0;
			_total = time;
			
			_accumulator += ms;
			if (_accumulator > _maxAccumulation)
			{
				_accumulator = _maxAccumulation;
			}
			while (_accumulator >= _step)
			{
				++ticks;
				if (_tickSignal) _tickSignal.dispatch();
				_accumulator -= _step;
			}
			
			/* Calculate render FPS. */
			++_renders;
			time = getTimer();
			var delta:uint = time - _renderLast;
			if (delta >= 50)
			{
				_renderFPS = (_renders / delta * 1000);
				_renders = 0;
				_renderLast = time;
			}
			
			if (_renderSignal) _renderSignal.dispatch(ticks, ms, _renderFPS);
			if (_stage3DProxy) _stage3DProxy.present();
			if (_exitFrameSignal) _exitFrameSignal.dispatch();
		}
	}
}
