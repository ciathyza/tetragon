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
package tetragon.setup
{
	import tetragon.data.sprite.SpriteAtlas;
	import tetragon.data.sprite.SpriteSet;
	import tetragon.data.sprite.SpriteSheet;
	import tetragon.entity.components.*;
	import tetragon.file.parsers.*;
	import tetragon.file.resource.processors.*;
	import tetragon.modules.app.Game2DModule;
	
	
	/**
	 * Setup class for Tetragon "Game2D" Extra.
	 */
	public class Game2DExtraSetup extends Setup
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function startupInitial():void
		{
			complete(INITIAL);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function startupPostConfig():void
		{
			complete(POST_CONFIG);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function startupPostSettings():void
		{
			complete(POST_SETTINGS);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function startupFinal():void
		{
			complete(FINAL);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function shutdown():void
		{
			complete(SHUTDOWN);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get name():String
		{
			return "game2DExtra";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function registerModules():void
		{
			registrar.registerModule(Game2DModule.defaultID, Game2DModule);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerThemes():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerCLICommands():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerResourceFileTypes():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerComplexTypes():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerDataTypes():void
		{
			registrar.registerDataType(SpriteAtlas.SPRITE_ATLAS, SpriteAtlasDataParser);
			registrar.registerDataType(SpriteSheet.SPRITE_SHEET, SpriteSheetDataParser);
			registrar.registerDataType(SpriteSet.SPRITE_SET, SpriteSetDataParser);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerResourceProcessors():void
		{
			registrar.registerResourceProcessor(SpriteAtlas.SPRITE_ATLAS, SpriteAtlasProcessor);
			registrar.registerResourceProcessor(SpriteSheet.SPRITE_SHEET, SpriteSheetProcessor);
			registrar.registerResourceProcessor(SpriteSet.SPRITE_SET, SpriteSetProcessor);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerEntitySystems():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerEntityComponents():void
		{
			registrar.registerEntityComponent("actor2DRefComponent", Actor2DRefComponent);
			registrar.registerEntityComponent("cell2DComponent", Cell2DComponent);
			registrar.registerEntityComponent("cell2DInteriorDataComponent", Cell2DInteriorDataComponent);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerStates():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerScreens():void
		{
		}
	}
}
