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
package tetragon.entity.systems
{
	import tetragon.entity.EntitySystem;
	import tetragon.entity.IEntity;
	import tetragon.entity.IEntitySystem;
	import tetragon.entity.components.GraphicsComponent;
	import tetragon.entity.components.Spacial2DComponent;
	import tetragon.view.render.RenderBuffer;

	import com.hexagonstar.util.debug.Debug;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	
	
	/**
	 * A very basic render system that simply renders entities that are made up of
	 * a graphics- and a spacial 2D component.
	 */
	public class BasicRenderSystem extends EntitySystem implements IEntitySystem
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _renderBuffer:RenderBuffer;
		/** @private */
		private var _matrix:Matrix;
		/** @private */
		private var _changedCount:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function register():void
		{
		}
		
		
		public function start():void
		{
			obtainEntities();
			if (!entities) return;
			_renderBuffer = main.renderBufferManager.getBuffer("buffer");
			_matrix = new Matrix();
			_changedCount = entities.length;
			renderSignal.add(onRender);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function stop():void
		{
			renderSignal.remove(onRender);
		}
		
		
		public function dispose():void
		{
			stop();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get componentClasses():Array
		{
			return [GraphicsComponent, Spacial2DComponent];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onRender():void
		{
			if (!_renderBuffer) return;
			
			//renderBuffer.lock();
			if (_changedCount > 0) _renderBuffer.clear();
			
			for each (var e:IEntity in entities)
			{
				var graphics:GraphicsComponent = e.getComponent(GraphicsComponent);
				var spacial:Spacial2DComponent = e.getComponent(Spacial2DComponent);
				
				if (spacial.changed || graphics.changed)
				{
					_changedCount++;
				}
				
				if (_changedCount < 1) return;
				
				if (!graphics.graphic)
				{
					var bd:BitmapData = main.resourceManager.resourceIndex.getResourceContent(graphics.graphicID);
					graphics.graphic = new Bitmap(bd);
				}
				
				if (graphics.graphic)
				{
					_matrix.identity();
					_matrix.translate(spacial.position.x, spacial.position.y);
					_matrix.rotate(spacial.rotation);
					_renderBuffer.draw(graphics.graphic, _matrix);
					
					graphics.changed = false;
					spacial.changed = false;
					_changedCount = 0;
				}
				
				Debug.trace("Rendering " + e.id + ", graphicID: " + graphics.graphicID + ", x: " + spacial.position.x + ", y: " + spacial.position.y + ", rotation: " + spacial.rotation);
			}
			
			//renderBuffer.unlock();
		}
	}
}
