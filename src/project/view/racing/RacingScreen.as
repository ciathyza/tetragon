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
	import tetragon.input.KeyMode;
	import tetragon.util.display.centerChild;
	import tetragon.view.Screen;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	
	/**
	 * @author Hexagon
	 */
	public class RacingScreen extends Screen
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const ID:String = "racingScreen";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _atlas:SpriteAtlas;
		private var _renderBuffer:RenderBuffer;
		private var _bufferBitmap:Bitmap;
		private var _sprites:Sprites;
		
		private var _bufferWidth:int = 640;
		private var _bufferHeight:int = 480;
		
		private var _resolution:Number = 1;					// scaling factor to provide resolution independence (computed)
		
		private var _skySpeed:Number = 0.001;				// background sky layer scroll speed when going around curve (or up hill)
		private var _hillSpeed:Number = 0.002;				// background hill layer scroll speed when going around curve (or up hill)
		private var _treeSpeed:Number = 0.003;				// background tree layer scroll speed when going around curve (or up hill)
		
		private var _skyOffset:int = 0;						// current sky scroll offset
		private var _hillOffset:int = 0;					// current hill scroll offset
		private var _treeOffset:int = 0;					// current tree scroll offset
		
		private var _playerX:Number = 0;					// player x offset from center of road (-1 to 1 to stay independent of roadWidth)
		private var _playerY:Number = 0;
		private var _playerZ:Number;						// player relative z distance from camera (computed)
		
		private var _isAccelerate:Boolean;
		private var _isBrake:Boolean;
		private var _isSteerLeft:Boolean;
		private var _isSteerRight:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
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
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function get unload():Boolean
		{
			return true;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
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
		private function onKeyDown(key:String):void
		{
			switch (key)
			{
				case "u": _isAccelerate = true; break;
				case "d": _isBrake = true; break;
				case "l": _isSteerLeft = true; break;
				case "r": _isSteerRight = true; break;
			}
		}
		
		
		/**
		 * @private
		 */
		private function onKeyUp(key:String):void
		{
			switch (key)
			{
				case "u": _isAccelerate = false; break;
				case "d": _isBrake = false; break;
				case "l": _isSteerLeft = false; break;
				case "r": _isSteerRight = false; break;
			}
		}
		
		
		/**
		 * @private
		 */
		private function onTick():void
		{
		}
		
		
		/**
		 * @private
		 */
		private function onRender(ticks:uint, ms:uint, fps:uint):void
		{
			_renderBuffer.clear();
			
			renderBackground();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
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
			
			resourceManager.process("spriteAtlas");
			_atlas = getResource("spriteAtlas");
			
			prepareSprites();
			
			_renderBuffer = new RenderBuffer(_bufferWidth, _bufferHeight, false, 0x333333);
			_bufferBitmap = new Bitmap(_renderBuffer);
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
			addChild(_bufferBitmap);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addListeners():void
		{
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
			main.statsMonitor.toggle();
			main.gameLoop.start();
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
			centerChild(_bufferBitmap);
		}
		
		
		/**
		 * @private
		 */
		private function prepareSprites():void
		{
			_sprites = new Sprites();
			_sprites.BG_SKY = _atlas.getSprite("bg_sky");
			_sprites.BG_HILLS = _atlas.getSprite("bg_hills");
			_sprites.BG_TREES = _atlas.getSprite("bg_trees");
			_sprites.BILLBOARD01 = _atlas.getSprite("sprite_billboard01");
			_sprites.BILLBOARD02 = _atlas.getSprite("sprite_billboard02");
			_sprites.BILLBOARD03 = _atlas.getSprite("sprite_billboard03");
			_sprites.BILLBOARD04 = _atlas.getSprite("sprite_billboard04");
			_sprites.BILLBOARD05 = _atlas.getSprite("sprite_billboard05");
			_sprites.BILLBOARD06 = _atlas.getSprite("sprite_billboard06");
			_sprites.BILLBOARD07 = _atlas.getSprite("sprite_billboard07");
			_sprites.BILLBOARD08 = _atlas.getSprite("sprite_billboard08");
			_sprites.BILLBOARD09 = _atlas.getSprite("sprite_billboard09");
			_sprites.BOULDER1 = _atlas.getSprite("sprite_boulder1");
			_sprites.BOULDER2 = _atlas.getSprite("sprite_boulder2");
			_sprites.BOULDER3 = _atlas.getSprite("sprite_boulder3");
			_sprites.BUSH1 = _atlas.getSprite("sprite_bush1");
			_sprites.BUSH2 = _atlas.getSprite("sprite_bush2");
			_sprites.CACTUS = _atlas.getSprite("sprite_cactus");
			_sprites.TREE1 = _atlas.getSprite("sprite_tree1");
			_sprites.TREE2 = _atlas.getSprite("sprite_tree2");
			_sprites.PALM_TREE = _atlas.getSprite("sprite_palm_tree");
			_sprites.DEAD_TREE1 = _atlas.getSprite("sprite_dead_tree1");
			_sprites.DEAD_TREE2 = _atlas.getSprite("sprite_dead_tree2");
			_sprites.STUMP = _atlas.getSprite("sprite_stump");
			_sprites.COLUMN = _atlas.getSprite("sprite_column");
			_sprites.CAR01 = _atlas.getSprite("sprite_car01");
			_sprites.CAR02 = _atlas.getSprite("sprite_car02");
			_sprites.CAR03 = _atlas.getSprite("sprite_car03");
			_sprites.CAR04 = _atlas.getSprite("sprite_car04");
			_sprites.SEMI = _atlas.getSprite("sprite_semi");
			_sprites.TRUCK = _atlas.getSprite("sprite_truck");
			_sprites.PLAYER_STRAIGHT = _atlas.getSprite("sprite_player_straight");
			_sprites.PLAYER_LEFT = _atlas.getSprite("sprite_player_left");
			_sprites.PLAYER_RIGHT = _atlas.getSprite("sprite_player_right");
			_sprites.PLAYER_UPHILL_STRAIGHT = _atlas.getSprite("sprite_player_uphill_straight");
			_sprites.PLAYER_UPHILL_LEFT = _atlas.getSprite("sprite_player_uphill_left");
			_sprites.PLAYER_UPHILL_RIGHT = _atlas.getSprite("sprite_player_uphill_right");
			_sprites.init();
		}
		
		
		/**
		 * @private
		 */
		private function renderBackground():void
		{
			renderBackgroundLayer(_sprites.BG_SKY, _skyOffset, _resolution * _skySpeed * _playerY);
			renderBackgroundLayer(_sprites.BG_HILLS, _hillOffset, _resolution * _hillSpeed * _playerY);
			renderBackgroundLayer(_sprites.BG_TREES, _treeOffset, _resolution * _treeSpeed * _playerY);
		}
		
		
		private function renderBackgroundLayer(sprite:BitmapData, rotation:Number = 0.0,
			offset:Number = 0.0):void
		{
			var imageW:Number = sprite.width / 2;
			var imageH:Number = sprite.height;
			var sourceX:Number = 0 + Math.floor(sprite.width * rotation);
			var sourceY:Number = 0;
			var sourceW:Number = Math.min(imageW, 0 + sprite.width - sourceX);
			var sourceH:Number = imageH;
			var destX:Number = 0;
			var destY:Number = offset;
			var destW:Number = Math.floor(width * (sourceW / imageW));
			var destH:Number = height;
			
			//ctx.drawImage(atlas, sourceX, sourceY, sourceW, sourceH, destX, destY, destW, destH);
			_renderBuffer.draw(sprite);
			
			if (sourceW < imageW)
			{
				//ctx.drawImage(atlas, layer.x, sourceY, imageW - sourceW, sourceH, destW - 1, destY, width - destW, destH);
			}
		}
	}
}
