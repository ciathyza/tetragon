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
	import tetragon.data.sprite.SpriteAtlas;
	import tetragon.data.texture.TextureAtlas;
	import tetragon.input.KeyMode;
	import tetragon.util.display.centerChild;
	import tetragon.view.Screen;
	import tetragon.view.render.racetrack.RaceTrackRenderer;
	import tetragon.view.render.scroll.ParallaxLayer;
	import tetragon.view.render2d.core.Render2D;
	import tetragon.view.render2d.display.Quad2D;
	import tetragon.view.render2d.display.View2D;
	import tetragon.view.render2d.events.Event2D;

	import com.hexagonstar.util.debug.Debug;

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
		
		private var _render2D:Render2D;
		private var _view2D:View2D;
		
		private var _raceTrackRenderer:RaceTrackRenderer;
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
			_raceTrackRenderer.reset();
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
			_raceTrackRenderer.dispose();
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
			main.gameLoop.start();
		}
		
		
		/**
		 * @private
		 */
		private function onRoot2DCreated(e:Event2D):void
		{
			Debug.trace("Root2D Created!");
		}
		
		
		/**
		 * @private
		 */
		private function onTick():void
		{
			//_raceTrackRenderer.tick();
		}
		
		
		/**
		 * @private
		 */
		private function onRender(ticks:uint, ms:uint, fps:uint):void
		{
			//_raceTrackRenderer.render();
			//_hwRenderBuffer.render();
		}
		
		
		/**
		 * @private
		 */
		private function onKeyDown(key:String):void
		{
			switch (key)
			{
				case "u":
					_raceTrackRenderer.isAccelerating = true;
					break;
				case "d":
					_raceTrackRenderer.isBraking = true;
					break;
				case "l":
					_raceTrackRenderer.isSteeringLeft = true;
					break;
				case "r":
					_raceTrackRenderer.isSteeringRight = true;
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
					_raceTrackRenderer.isAccelerating = false;
					break;
				case "d":
					_raceTrackRenderer.isBraking = false;
					break;
				case "l":
					_raceTrackRenderer.isSteeringLeft = false;
					break;
				case "r":
					_raceTrackRenderer.isSteeringRight = false;
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
			resourceManager.process("spriteAtlas");
			
			var spriteAtlas:SpriteAtlas = getResource("spriteAtlas");
			var textureAtlas:TextureAtlas = getResource("textureAtlas");
			
			_bgLayer1 = new ParallaxLayer(spriteAtlas.getSprite("bg_sky", 2.0), 2);
			_bgLayer2 = new ParallaxLayer(spriteAtlas.getSprite("bg_hills", 2.0), 3);
			_bgLayer3 = new ParallaxLayer(spriteAtlas.getSprite("bg_trees", 2.0), 4);
			
			_raceTrackRenderer = new RaceTrackRenderer(1024, 640, spriteAtlas);
			_raceTrackRenderer.backgroundLayers = [_bgLayer1, _bgLayer2, _bgLayer3];
			
			_renderBitmap = _raceTrackRenderer.renderBitmap;
			
			main.keyInputManager.assign("CURSORUP", KeyMode.DOWN, onKeyDown, "u");
			main.keyInputManager.assign("CURSORDOWN", KeyMode.DOWN, onKeyDown, "d");
			main.keyInputManager.assign("CURSORLEFT", KeyMode.DOWN, onKeyDown, "l");
			main.keyInputManager.assign("CURSORRIGHT", KeyMode.DOWN, onKeyDown, "r");
			main.keyInputManager.assign("CURSORUP", KeyMode.UP, onKeyUp, "u");
			main.keyInputManager.assign("CURSORDOWN", KeyMode.UP, onKeyUp, "d");
			main.keyInputManager.assign("CURSORLEFT", KeyMode.UP, onKeyUp, "l");
			main.keyInputManager.assign("CURSORRIGHT", KeyMode.UP, onKeyUp, "r");
			
			_view2D = new View2D();
			_view2D.background = new Quad2D(10, 10, 0x000033);
			_render2D = new Render2D(_view2D);
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
			//addChild(_renderBitmap);
		}


		/**
		 * @inheritDoc
		 */
		override protected function addListeners():void
		{
			_render2D.addEventListener(Event2D.CONTEXT3D_CREATE, onContext3DCreated);
			_render2D.addEventListener(Event2D.ROOT_CREATED, onRoot2DCreated);
			
			main.gameLoop.tickSignal.add(onTick);
			main.gameLoop.renderSignal.add(onRender);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function removeListeners():void
		{
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
