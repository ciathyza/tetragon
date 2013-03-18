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
package tetragon.view.render2d.textures
{
	import tetragon.view.render2d.core.RenderSupport2D;
	import tetragon.view.render2d.display.DisplayObject2D;
	import tetragon.view.render2d.display.Image2D;

	import com.hexagonstar.util.math.nextPowerOfTwo;

	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	
	/**
	 * A RenderTexture is a dynamic texture onto which you can draw any display object.
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
	 * To erase parts of a render texture, you can use any display object like a "rubber"
	 * by setting its blending mode to "BlendMode.ERASE".
	 * </p>
	 * 
	 * <p>
	 * Beware that render textures can't be restored when the Render2D's render context is
	 * lost.
	 * </p>
	 */
	public class RenderTexture2D extends SubTexture2D
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		private const PMA:Boolean = true;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _activeTexture:Texture2D;
		private var _bufferTexture:Texture2D;
		private var _helperImage:Image2D;
		private var _drawingBundled:Boolean;
		private var _bufferReady:Boolean;
		private var _support:RenderSupport2D;
		
		/** helper object */
		private static var _scissorRect:Rectangle = new Rectangle();
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
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
		 * @param scale
		 */
		public function RenderTexture2D(width:int, height:int, persistent:Boolean = true,
			scale:Number = -1.0)
		{
			if (scale <= 0.0) scale = render2D.contentScaleFactor;
			
			var nativeWidth:int = nextPowerOfTwo(width * scale);
			var nativeHeight:int = nextPowerOfTwo(height * scale);
			_activeTexture = Texture2D.empty(width, height, PMA, true, scale);
			
			super(_activeTexture, new Rectangle(0, 0, width, height), true);
			
			_support = new RenderSupport2D();
			_support.setOrthographicProjection(0, 0, nativeWidth / scale, nativeHeight / scale);
			
			if (persistent)
			{
				_bufferTexture = Texture2D.empty(width, height, PMA, true, scale);
				_helperImage = new Image2D(_bufferTexture);
				_helperImage.smoothing = TextureSmoothing2D.NONE; // solves some antialias-issues
			}
		}
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public override function dispose():void
		{
			_support.dispose();
			if (isPersistent)
			{
				_bufferTexture.dispose();
				_helperImage.dispose();
			}
			super.dispose();
		}
		
		
		/**
		 * Draws an object into the texture. Note that any filters on the object will
		 * currently be ignored.
		 * 
		 * @param object The object to draw.
		 * @param matrix If 'matrix' is null, the object will be drawn adhering its
		 *            properties for position, scale, and rotation. If it is not null, the
		 *            object will be drawn in the orientation depicted by the matrix.
		 * @param alpha The object's alpha value will be multiplied with this value.
		 * @param antiAliasing This parameter is currently ignored by Stage3D.
		 */
		public function draw(object:DisplayObject2D, matrix:Matrix = null, alpha:Number = 1.0,
			antiAliasing:int = 0):void
		{
			if (!object) return;
			
			if (_drawingBundled) render();
			else drawBundled(render, antiAliasing);
			
			function render():void
			{
				_support.loadIdentity();
				_support.blendMode = object.blendMode;
				if (matrix) _support.prependMatrix(matrix);
				else _support.transformMatrix(object);
				object.render(_support, alpha);
			}
		}
		
		
		/**
		 * The same as draw() but with some additional features like a clipRect.
		 */
		public function drawImage(object:Image2D, matrix:Matrix = null,
			clipRect:Rectangle = null, alpha:Number = 1.0, antiAliasing:int = 0):void
		{
			if (!object) return;
			
			if (_drawingBundled) render();
			else drawBundled(render, antiAliasing);
			
			function render():void
			{
				_support.loadIdentity();
				_support.blendMode = object.blendMode;
				if (matrix) _support.prependMatrix(matrix);
				else _support.transformMatrix(object);
				object.clipRect = clipRect;
				object.render(_support, alpha);
			}
		}
		
		
		/**
		 * Bundles several calls to <code>draw</code> together in a block. This avoids buffer 
		 * switches and allows you to draw multiple objects into a non-persistent texture.
		 * 
		 * @param drawingBlock
		 * @param antiAliasing
		 */
		public function drawBundled(drawingBlock:Function, antiAliasing:int = 0):void
		{
			// persistent drawing uses double buffering, as Molehill forces us to call 'clear'
			// on every render target once per update.
			
			// switch buffers
			if (isPersistent)
			{
				var tmpTexture:Texture2D = _activeTexture;
				_activeTexture = _bufferTexture;
				_bufferTexture = tmpTexture;
				_helperImage.texture = _bufferTexture;
			}
			
			// limit drawing to relevant area
			_scissorRect.setTo(0, 0, _activeTexture.nativeWidth, _activeTexture.nativeHeight);
			
			_support.scissorRectangle = _scissorRect;
			_support.renderTarget = _activeTexture;
			_support.clear();
			
			// draw buffer
			if (isPersistent && _bufferReady) _helperImage.render(_support, 1.0);
			else _bufferReady = true;
			
			try
			{
				_drawingBundled = true;
				// draw new objects
				if (drawingBlock != null) drawingBlock();
			}
			finally
			{
				_drawingBundled = false;
				_support.finishQuadBatch();
				_support.nextFrame();
				_support.renderTarget = null;
				_support.scissorRectangle = null;
			}
		}
		
		
		/**
		 * Clears the texture (restoring full transparency).
		 */
		public function clear():void
		{
			_support.renderTarget = _activeTexture;
			_support.clear();
			_support.renderTarget = null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/** Indicates if the texture is persistent over multiple draw calls. */
		public function get isPersistent():Boolean
		{
			return _bufferTexture != null;
		}
		
		
		/** @inheritDoc */
		public override function get base():TextureBase
		{
			return _activeTexture.base;
		}
		
		
		/** @inheritDoc */
		public override function get root():ConcreteTexture2D
		{
			return _activeTexture.root;
		}
	}
}
