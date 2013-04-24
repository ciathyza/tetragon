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
package tetragon.view.render2d.display
{
	import tetragon.Main;
	import tetragon.data.Registry;
	import tetragon.data.Settings;
	import tetragon.file.resource.ResourceIndex;
	import tetragon.view.IView;
	import tetragon.view.render2d.core.RenderSupport2D;
	import tetragon.view.render2d.events.Event2D;
	
	
	/**
	 * View2D class
	 *
	 * @author hexagon
	 */
	public class View2D extends DisplayObjectContainer2D implements IView
	{
		// -----------------------------------------------------------------------------------------
		// Properties
		// -----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _background:Rect2D;
		
		/** @private */
		private static var _main:Main;
		/** @private */
		private static var _resourceIndex:ResourceIndex;
		
		
		// -----------------------------------------------------------------------------------------
		// Constructor
		// -----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function View2D()
		{
			super();
			setup();
			addEventListener(Event2D.ADDED_TO_STAGE, onAddedToStage);
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Public Methods
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public override function render(support:RenderSupport2D, alpha:Number):void
		{
			executeBeforeRender();
			
			/* Render background, which should not be part of the child collection. */
			if (_background)
			{
				support.pushMatrix();
				support.transformMatrix(_background);
				_background.render(support, alpha);
				support.popMatrix();
			}
			
			super.render(support, alpha);
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Accessors
		// -----------------------------------------------------------------------------------------
		
		public function get background():Rect2D
		{
			return _background;
		}
		public function set background(v:Rect2D):void
		{
			if (v == _background) return;
			_background = v;
			updateBackground();
		}
		
		
		protected static function get main():Main
		{
			if (!_main) _main = Main.instance;
			return _main;
		}
		
		
		protected function get registry():Registry
		{
			return main.registry;
		}
		
		
		protected function get settings():Settings
		{
			return registry.settings;
		}
		
		
		protected static function get resourceIndex():ResourceIndex
		{
			if (!_resourceIndex) _resourceIndex = main.resourceManager.resourceIndex;
			return _resourceIndex;
		}
		
		
		protected function get stageWidth():int
		{
			return main.stage.stageWidth;
		}
		
		
		protected function get stageHeight():int
		{
			return main.stage.stageHeight;
		}
		
		
		protected function get refWidth():int
		{
			return main.appInfo.referenceWidth;
		}
		
		
		protected function get refHeight():int
		{
			return main.appInfo.referenceHeight;
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Callback Handlers
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function onAddedToStage(e:Event2D):void
		{
			removeEventListener(Event2D.ADDED_TO_STAGE, onAddedToStage);
			updateBackground();
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Private Methods
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function setup():void
		{
		}
		
		
		/**
		 * Executed at start of the render loop for the view.
		 */
		protected function executeBeforeRender():void
		{
		}
		
		
		/**
		 * @private
		 */
		private function updateBackground():void
		{
			if (!_background || !stage) return;
			_background.width = width;
			_background.height = height;
		}
		
		
		/**
		 * @private
		 */
		protected static function getResource(resourceID:String):*
		{
			return resourceIndex.getResourceContent(resourceID);
		}
	}
}
