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
package tetragon.view.render2d.core
{
	import com.hexagonstar.util.math.nextPowerOfTwo;

	import flash.display3D.Context3D;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Rectangle;


	/**
	 * A RenderTexture2D is a dynamic texture onto which you can draw any display object.
	 * 
	 * <p>
	 * After creating a render texture, just call the <code>drawObject</code> method to
	 * render an object directly onto the texture. The object will be drawn onto the
	 * texture at its current position, adhering its current rotation, scale and alpha
	 * properties.
	 * </p>
	 * 
	 * <p>
	 * Drawing is done very efficiently, as it is happening directly in graphics memory.
	 * After you have drawn objects onto the texture, the performance will be just like
	 * that of a normal texture - no matter how many objects you have drawn.
	 * </p>
	 * 
	 * <p>
	 * If you draw lots of objects at once, it is recommended to bundle the drawing calls
	 * in a block via the <code>drawBundled</code> method, like shown below. That will
	 * speed it up immensely, allowing you to draw hundreds of objects very quickly.
	 * </p>
	 * 
	 * <pre>
	 *  renderTexture.drawBundled(function():void
	 *  {
	 *     for (var i:int=0; i&lt;numDrawings; ++i)
	 *     {
	 *         image.rotation = (2 &#42; Math.PI / numDrawings) &#42; i;
	 *         renderTexture.draw(image);
	 *     }   
	 *  });
	 * </pre>
	 * 
	 * <p>
	 * Beware that render textures can't be restored when the Starling's render context is
	 * lost.
	 * </p>
	 */
	public class RenderTexture2D extends Texture2D
	{
		// -----------------------------------------------------------------------------------------
		// Properties
		// -----------------------------------------------------------------------------------------
		
		/** @private */
		private var _activeTexture:Texture2D;
		/** @private */
		private var _bufferTexture:Texture2D;
		/** @private */
		private var _helperImage:Image2D;
		/** @private */
		private var _drawing:Boolean;
		/** @private */
		private var _nativeWidth:int;
		/** @private */
		private var _nativeHeight:int;
		/** @private */
		private var _support:Render2DRenderSupport;
		
		
		// -----------------------------------------------------------------------------------------
		// Constructor
		// -----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new RenderTexture with a certain size. If the texture is persistent,
		 * the contents of the texture remains intact after each draw call, allowing you
		 * to use the texture just like a canvas. If it is not, it will be cleared before
		 * each draw call. Persistancy doubles the required graphics memory! Thus, if you
		 * need the texture only for one draw (or drawBundled) call, you should deactivate
		 * it.
		 * 
		 * @param width
		 * @param height
		 * @param persistent
		 */
		public function RenderTexture2D(width:int, height:int, persistent:Boolean = true)
		{
			_support = new Render2DRenderSupport();
			_nativeWidth = nextPowerOfTwo(width);
			_nativeHeight = nextPowerOfTwo(height);
			_activeTexture = Texture2D.createEmpty(width, height, 0x0, true);
			
			if (persistent)
			{
				_bufferTexture = Texture2D.createEmpty(width, height, 0x0, true);
				_helperImage = new Image2D(_bufferTexture);
			}
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Public Methods
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public override function dispose():void
		{
			_activeTexture.dispose();

			if (_bufferTexture)
			{
				_bufferTexture.dispose();
				_helperImage.dispose();
			}

			super.dispose();
		}


		/**
		 * Draws an object onto the texture, adhering its properties for position, scale,
		 * rotation and alpha.
		 * 
		 * @param object
		 * @param antiAliasing
		 */
		public function draw(object:DisplayObject2D, antiAliasing:int = 0):void
		{
			if (!object) return;
			if (_drawing) render();
			else drawBundled(render, antiAliasing);
			
			function render():void
			{
				_support.pushMatrix();
				_support.transformMatrix(object);
				object.renderWithSupport(_support, 1.0);
				_support.popMatrix();
			}
		}
		
		
		/**
		 * Bundles several calls to <code>draw</code> together in a block. This avoids
		 * buffer switches and allows you to draw multiple objects into a non-persistent
		 * texture.
		 * 
		 * @param drawingBlock
		 * @param antiAliasing
		 */
		public function drawBundled(drawingBlock:Function, antiAliasing:int = 0):void
		{
			var c:Context3D = Render2D.context;
			if (!c) throwMissingContext3DException("RenderTexture2D.drawBundled");
			
			// limit drawing to relevant area
			c.setScissorRectangle(new Rectangle(0, 0, _activeTexture.width, _activeTexture.height));
			
			// persistent drawing uses double buffering, as Molehill forces us to call 'clear'
			// on every render target once per update.
			
			// switch buffers
			if (_bufferTexture)
			{
				var tmp:Texture2D = _activeTexture;
				_activeTexture = _bufferTexture;
				_bufferTexture = tmp;
				_helperImage.texture = _bufferTexture;
			}
			
			c.setRenderToTexture(_activeTexture.base, false, antiAliasing);
			Render2DRenderSupport.setDefaultBlendFactors(true);
			Render2DRenderSupport.clear();
			
			_support.setOrthographicProjection(_nativeWidth, _nativeHeight);
			
			// draw buffer
			if (_bufferTexture) _helperImage.renderWithSupport(_support, 1.0);
			
			try
			{
				_drawing = true;
				// draw new objects
				if (drawingBlock != null) drawingBlock();
			}
			finally
			{
				_drawing = false;
				_support.finishQuadBatch();
				_support.nextFrame();
				c.setScissorRectangle(null);
				c.setRenderToBackBuffer();
			}
		}
		
		
		/**
		 * Clears the texture (restoring full transparency).
		 */
		public function clear():void
		{
			var c:Context3D = Render2D.context;
			if (!c) throwMissingContext3DException("RenderTexture2D.clear");
			c.setRenderToTexture(_activeTexture.base);
			Render2DRenderSupport.clear();
			
			if (_bufferTexture)
			{
				c.setRenderToTexture(_activeTexture.base);
				Render2DRenderSupport.clear();
			}
			
			c.setRenderToBackBuffer();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function adjustVertexData(vertexData:VertexData2D, vertexID:int,
			count:int):void
		{
			_activeTexture.adjustVertexData(vertexData, vertexID, count);
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Accessors
		// -----------------------------------------------------------------------------------------
		
		/**
		 * Indicates if the texture is persistent over multiple draw calls.
		 */
		public function get isPersistent():Boolean
		{
			return _bufferTexture != null;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function get width():Number
		{
			return _activeTexture.width;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function get height():Number
		{
			return _activeTexture.height;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function get premultipliedAlpha():Boolean
		{
			return _activeTexture.premultipliedAlpha;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function get base():TextureBase
		{
			return _activeTexture.base;
		}
	}
}
