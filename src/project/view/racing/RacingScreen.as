/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * Tetragon : Game Engine for multi-platform ActionScript projects.
 * http://www.tetragonengine.com/
 * Copyright (c) The respective Copyright Holder (see LICENSE).
 * 
 * Permission is hereby granted, to any person obtaining a copy of this software
 * and associated documentation files (the "Software") under the rules defined in
 * the license found at http://www.tetragonengine.com/license/ or the LICENSE
 * file included within this distribution.
 * 
 * The above copyright notice and this permission notice must be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND. THE COPYRIGHT
 * HOLDER AND ITS LICENSORS DISCLAIM ALL WARRANTIES AND CONDITIONS, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO ANY IMPLIED WARRANTIES AND CONDITIONS OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT, AND ANY
 * WARRANTIES AND CONDITIONS ARISING OUT OF COURSE OF DEALING OR USAGE OF TRADE.
 * NO ADVICE OR INFORMATION, WHETHER ORAL OR WRITTEN, OBTAINED FROM THE COPYRIGHT
 * HOLDER OR ELSEWHERE WILL CREATE ANY WARRANTY OR CONDITION NOT EXPRESSLY STATED
 * IN THIS AGREEMENT.
 */
package view.racing
{
	import tetragon.data.atlas.Atlas;
	import tetragon.input.KeyMode;
	import tetragon.systems.racetrack.RacetrackSystem;
	import tetragon.util.display.centerChild;
	import tetragon.view.Screen;
	import tetragon.view.render.scroll.ParallaxLayer;
	import tetragon.view.render2d.core.Render2D;
	import tetragon.view.render2d.display.Quad2D;
	import tetragon.view.render2d.events.Event2D;

	import flash.display.Bitmap;
	
	
	/**
	 * @author Hexagon
	 */
	public class RacingScreen extends Screen
	{
		// -----------------------------------------------------------------------------------------
		// Constants
		// -----------------------------------------------------------------------------------------
		
		public static const ID:String = "racingScreen";
		
		
		// -----------------------------------------------------------------------------------------
		// Properties
		// -----------------------------------------------------------------------------------------
		
		private var _useRender2D:Boolean = false;
		private var _render2D:Render2D;
		private var _view:RacingView;
		
		private var _atlas:Atlas;
		
		private var _racetrackSystem:RacetrackSystem;
		private var _renderBitmap:Bitmap;
		private var _bgLayer1:ParallaxLayer;
		private var _bgLayer2:ParallaxLayer;
		private var _bgLayer3:ParallaxLayer;
		
		
		// -----------------------------------------------------------------------------------------
		// Signals
		// -----------------------------------------------------------------------------------------
		
		
		// -----------------------------------------------------------------------------------------
		// Public Methods
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function start():void
		{
			super.start();
			main.gameLoop.start();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function update():void
		{
			super.update();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function reset():void
		{
			super.reset();
			if (_racetrackSystem) _racetrackSystem.reset();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function stop():void
		{
			super.stop();
			main.gameLoop.stop();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
			if (_racetrackSystem) _racetrackSystem.dispose();
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Accessors
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function get unload():Boolean
		{
			return true;
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Callback Handlers
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function onStageResize():void
		{
			super.onStageResize();
		}
		
		
		/**
		 * @private
		 */
		private function onContext3DCreated(e:Event2D):void
		{
			/* Texture can only be processed after we have a Context3D! */
			resourceManager.process("textureAtlas");
			_atlas = getResource("textureAtlas");
			_racetrackSystem = new RacetrackSystem(1024, 640, _atlas, _useRender2D);
			_racetrackSystem.init();
			reset();
			main.gameLoop.start();
		}
		
		
		/**
		 * @private
		 */
		private function onRoot2DCreated(e:Event2D):void
		{
		}
		
		
		/**
		 * @private
		 */
		private function onTick():void
		{
			_racetrackSystem.tick();
		}
		
		
		/**
		 * @private
		 */
		private function onRender(ticks:uint, ms:uint, fps:uint):void
		{
			_racetrackSystem.render();
		}
		
		
		/**
		 * @private
		 */
		private function onKeyDown(key:String):void
		{
			switch (key)
			{
				case "u":
					_racetrackSystem.isAccelerating = true;
					break;
				case "d":
					_racetrackSystem.isBraking = true;
					break;
				case "l":
					_racetrackSystem.isSteeringLeft = true;
					break;
				case "r":
					_racetrackSystem.isSteeringRight = true;
					break;
			}
		}
		
		
		/**
		 * @private
		 */
		private function onKeyUp(key:String):void
		{
			switch (key)
			{
				case "u":
					_racetrackSystem.isAccelerating = false;
					break;
				case "d":
					_racetrackSystem.isBraking = false;
					break;
				case "l":
					_racetrackSystem.isSteeringLeft = false;
					break;
				case "r":
					_racetrackSystem.isSteeringRight = false;
					break;
			}
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Private Methods
		// -----------------------------------------------------------------------------------------
		/**
		 * @inheritDoc
		 */
		override protected function setup():void
		{
			super.setup();
		}


		/**
		 * @inheritDoc
		 */
		override protected function registerResources():void
		{
			registerResource("spriteAtlas");
			registerResource("textureAtlas");
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			main.keyInputManager.assign("CURSORUP", KeyMode.DOWN, onKeyDown, "u");
			main.keyInputManager.assign("CURSORDOWN", KeyMode.DOWN, onKeyDown, "d");
			main.keyInputManager.assign("CURSORLEFT", KeyMode.DOWN, onKeyDown, "l");
			main.keyInputManager.assign("CURSORRIGHT", KeyMode.DOWN, onKeyDown, "r");
			main.keyInputManager.assign("CURSORUP", KeyMode.UP, onKeyUp, "u");
			main.keyInputManager.assign("CURSORDOWN", KeyMode.UP, onKeyUp, "d");
			main.keyInputManager.assign("CURSORLEFT", KeyMode.UP, onKeyUp, "l");
			main.keyInputManager.assign("CURSORRIGHT", KeyMode.UP, onKeyUp, "r");
			
			if (!_useRender2D)
			{
				resourceManager.process("spriteAtlas");
				
				_atlas = getResource("spriteAtlas");
				
				_bgLayer1 = new ParallaxLayer(_atlas.getImage("bg_sky", 2.0), 2);
				_bgLayer2 = new ParallaxLayer(_atlas.getImage("bg_hills", 2.0), 3);
				_bgLayer3 = new ParallaxLayer(_atlas.getImage("bg_trees", 2.0), 4);
				
				_racetrackSystem = new RacetrackSystem(1024, 640, _atlas, _useRender2D);
				_racetrackSystem.backgroundLayers = [_bgLayer1, _bgLayer2, _bgLayer3];
				
				_renderBitmap = _racetrackSystem.renderBitmap;
			}
			else
			{
				_view = new RacingView();
				_view.background = new Quad2D(10, 10, 0xFF00FF);
				_render2D = new Render2D(_view);
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerChildren():void
		{
		}


		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void
		{
			if (_renderBitmap) addChild(_renderBitmap);
		}


		/**
		 * @inheritDoc
		 */
		override protected function addListeners():void
		{
			if (_render2D)
			{
				_render2D.addEventListener(Event2D.CONTEXT3D_CREATE, onContext3DCreated);
				_render2D.addEventListener(Event2D.ROOT_CREATED, onRoot2DCreated);
			}
			main.gameLoop.tickSignal.add(onTick);
			main.gameLoop.renderSignal.add(onRender);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function removeListeners():void
		{
			if (_render2D)
			{
				_render2D.removeEventListener(Event2D.CONTEXT3D_CREATE, onContext3DCreated);
				_render2D.removeEventListener(Event2D.ROOT_CREATED, onRoot2DCreated);
			}
			main.gameLoop.tickSignal.remove(onTick);
			main.gameLoop.renderSignal.remove(onRender);
		}


		/**
		 * @inheritDoc
		 */
		override protected function executeBeforeStart():void
		{
			reset();
			main.statsMonitor.toggle();
		}


		/**
		 * @inheritDoc
		 */
		override protected function updateDisplayText():void
		{
		}


		/**
		 * @inheritDoc
		 */
		override protected function layoutChildren():void
		{
			centerChild(_renderBitmap);
		}
	}
}
