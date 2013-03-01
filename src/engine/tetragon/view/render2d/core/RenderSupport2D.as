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
	import tetragon.view.render2d.display.BlendMode2D;
	import tetragon.view.render2d.display.DisplayObject2D;
	import tetragon.view.render2d.display.Quad2D;
	import tetragon.view.render2d.display.QuadBatch2D;
	import tetragon.view.render2d.textures.Texture2D;

	import com.hexagonstar.exception.MissingContext3DException;
	import com.hexagonstar.util.agal.AGALMiniAssembler;
	import com.hexagonstar.util.color.ColorUtil;
	import com.hexagonstar.util.geom.MatrixUtil;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	/**
	 * A class that contains helper methods simplifying Stage3D rendering. A RenderSupport
	 * instance is passed to any "render" method of display objects. It allows
	 * manipulation of the current transformation matrix (similar to the matrix
	 * manipulation methods of OpenGL 1.x) and other helper methods.
	 */
	public class RenderSupport2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _projectionMatrix:Matrix;
		/** @private */
		private var _modelViewMatrix:Matrix;
		/** @private */
		private var _mvpMatrix:Matrix;
		/** @private */
		private var _mvpMatrix3D:Matrix3D;
		/** @private */
		private var _matrixStack:Vector.<Matrix>;
		/** @private */
		private var _renderTarget:Texture2D;
		/** @private */
		private var _scissorRectangle:Rectangle;
		/** @private */
		private var _quadBatches:Vector.<QuadBatch2D>;
		
		/** @private */
		private var _matrixStackSize:int;
		/** @private */
		private var _drawCount:int;
		/** @private */
		private var _backBufferWidth:int;
		/** @private */
		private var _backBufferHeight:int;
		/** @private */
		private var _currentQuadBatchID:int;
		/** @private */
		private var _blendMode:String;
		
		/** @private */
		private static var _point:Point;
		/** @private */
		private static var _rectangle:Rectangle;
		/** @private */
		private static var _agal:AGALMiniAssembler;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new RenderSupport object with an empty matrix stack.
		 */
		public function RenderSupport2D()
		{
			if (!_point) _point = new Point();
			if (!_rectangle) _rectangle = new Rectangle();
			
			_projectionMatrix = new Matrix();
			_modelViewMatrix = new Matrix();
			_mvpMatrix = new Matrix();
			_mvpMatrix3D = new Matrix3D();
			_matrixStack = new <Matrix>[];
			
			_matrixStackSize = 0;
			_drawCount = 0;
			_currentQuadBatchID = 0;
			_renderTarget = null;
			
			_blendMode = BlendMode2D.NORMAL;
			_scissorRectangle = new Rectangle();
			_quadBatches = new <QuadBatch2D>[new QuadBatch2D()];
			
			loadIdentity();
			setOrthographicProjection(0, 0, 400, 300);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes all quad batches.
		 */
		public function dispose():void
		{
			for each (var quadBatch:QuadBatch2D in _quadBatches)
			{
				quadBatch.dispose();
			}
		}
		
		
		/**
		 * Changes the modelview matrix to the identity matrix.
		 */
		public function loadIdentity():void
		{
			_modelViewMatrix.identity();
		}
		
		
		/**
		 * Sets up the projection matrix for ortographic 2D rendering.
		 * 
		 * @param x
		 * @param y
		 * @param w
		 * @param h
		 */
		public function setOrthographicProjection(x:Number, y:Number, w:Number, h:Number):void
		{
			_projectionMatrix.setTo(2.0 / w, 0, 0, -2.0 / h, -(2 * x + w) / w, (2 * y + h) / h);
		}


		/**
		 * Prepends a translation to the modelview matrix.
		 * 
		 * @param dx
		 * @param dy
		 */
		public function translateMatrix(dx:Number, dy:Number):void
		{
			MatrixUtil.prependTranslation(_modelViewMatrix, dx, dy);
		}
		
		
		/**
		 * Prepends a rotation (angle in radians) to the modelview matrix.
		 * 
		 * @param angle
		 */
		public function rotateMatrix(angle:Number):void
		{
			MatrixUtil.prependRotation(_modelViewMatrix, angle);
		}
		
		
		/**
		 * Prepends an incremental scale change to the modelview matrix.
		 * 
		 * @param sx
		 * @param sy
		 */
		public function scaleMatrix(sx:Number, sy:Number):void
		{
			MatrixUtil.prependScale(_modelViewMatrix, sx, sy);
		}
		
		
		/**
		 * Prepends a matrix to the modelview matrix by multiplying it another matrix.
		 * 
		 * @param matrix
		 */
		public function prependMatrix(matrix:Matrix):void
		{
			MatrixUtil.prependMatrix(_modelViewMatrix, matrix);
		}
		
		
		/**
		 * Prepends translation, scale and rotation of an object to the modelview matrix.
		 * 
		 * @param object
		 */
		public function transformMatrix(object:DisplayObject2D):void
		{
			MatrixUtil.prependMatrix(_modelViewMatrix, object.transformationMatrix);
		}
		
		
		/**
		 * Pushes the current modelview matrix to a stack from which it can be restored
		 * later.
		 */
		public function pushMatrix():void
		{
			if (_matrixStack.length < _matrixStackSize + 1)
			{
				_matrixStack.push(new Matrix());
			}
			_matrixStack[int(_matrixStackSize++)].copyFrom(_modelViewMatrix);
		}
		
		
		/**
		 * Restores the modelview matrix that was last pushed to the stack.
		 */
		public function popMatrix():void
		{
			_modelViewMatrix.copyFrom(_matrixStack[int(--_matrixStackSize)]);
		}
		
		
		/**
		 * Empties the matrix stack, resets the modelview matrix to the identity matrix.
		 */
		public function resetMatrix():void
		{
			_matrixStackSize = 0;
			loadIdentity();
		}
		
		
		/**
		 * Activates the current blend mode on the active rendering context.
		 * 
		 * @param premultipliedAlpha
		 */
		public function applyBlendMode(premultipliedAlpha:Boolean):void
		{
			setBlendFactors(premultipliedAlpha, _blendMode);
		}
		
		
		/**
		 * Configures the back buffer on the current context3D. By using this method, Render2D
		 * can store the size of the back buffer and utilize this information in other methods
		 * (e.g. the scissor rectangle property). Back buffer width and height can later be
		 * accessed using the properties with the same name.
		 * 
		 * @param w
		 * @param h
		 * @param antiAlias
		 * @param enableDepthAndStencil
		 */
		public function configureBackBuffer(w:int, h:int, antiAlias:int,
			enableDepthAndStencil:Boolean):void
		{
			_backBufferWidth = w;
			_backBufferHeight = h;
			Render2D.context.configureBackBuffer(w, h, antiAlias, enableDepthAndStencil);
		}
		
		
		/**
		 * Adds a quad to the current batch of unrendered quads. If there is a state
		 * change, all previous quads are rendered at once, and the batch is reset.
		 * 
		 * @param quad
		 * @param parentAlpha
		 * @param texture
		 * @param smoothing
		 */
		public function batchQuad(quad:Quad2D, parentAlpha:Number, texture:Texture2D = null,
			smoothing:String = null):void
		{
			if (_quadBatches[_currentQuadBatchID].isStateChange(quad.tinted, parentAlpha,
				texture, smoothing, _blendMode))
			{
				finishQuadBatch();
			}
			_quadBatches[_currentQuadBatchID].addQuad(quad, parentAlpha, texture, smoothing,
				_modelViewMatrix, _blendMode);
		}
		
		
		/**
		 * Renders the current quad batch and resets it.
		 */
		public function finishQuadBatch():void
		{
			var currentBatch:QuadBatch2D = _quadBatches[_currentQuadBatchID];
			if (currentBatch.numQuads != 0)
			{
				currentBatch.renderCustom(_projectionMatrix);
				currentBatch.reset();
				++_currentQuadBatchID;
				++_drawCount;
				if (_quadBatches.length <= _currentQuadBatchID)
				{
					_quadBatches.push(new QuadBatch2D());
				}
			}
		}
		
		
		/**
		 * Resets matrix stack, blend mode, quad batch index, and draw count.
		 */
		public function nextFrame():void
		{
			resetMatrix();
			_blendMode = BlendMode2D.NORMAL;
			_currentQuadBatchID = 0;
			_drawCount = 0;
		}
		
		
		/**
		 * Clears the render context with a certain color and alpha value.
		 * 
		 * @param rgb
		 * @param alpha
		 */
		public function clear(rgb:uint = 0, alpha:Number = 0.0):void
		{
			RenderSupport2D.clear(rgb, alpha);
		}
		
		
		/**
		 * Raises the draw count by a specific value. Call this method in custom render
		 * methods to keep the statistics display in sync.
		 */
		public function raiseDrawCount(value:uint = 1):void
		{
			_drawCount += value;
		}
		
		
		/**
		 * Prepends translation, scale and rotation of an object to a custom matrix.
		 * 
		 * @param matrix
		 * @param object
		 */
		public static function transformMatrixForObject(matrix:Matrix, object:DisplayObject2D):void
		{
			MatrixUtil.prependMatrix(matrix, object.transformationMatrix);
		}
		
		
		/**
		 * Assembles fragment- and vertex-shaders, passed as Strings, to a Program3D. If
		 * you pass a 'resultProgram', it will be uploaded to that program; otherwise, a
		 * new program will be created on the current Stage3D context.
		 * 
		 * @param vertexShader
		 * @param fragmentShader
		 * @param resultProgram
		 */
		public static function assembleAgal(vertexShader:String, fragmentShader:String,
			resultProgram:Program3D = null):Program3D
		{
			if (!resultProgram)
			{
				var context:Context3D = Render2D.context;
				if (!context) throw new MissingContext3DException();
				resultProgram = context.createProgram();
			}
			
			resultProgram.upload(agal.assemble(Context3DProgramType.VERTEX, vertexShader),
				agal.assemble(Context3DProgramType.FRAGMENT, fragmentShader));
			return resultProgram;
		}
		
		
		/**
		 * Deprecated. Call 'setBlendFactors' instead.
		 */
		public static function setDefaultBlendFactors(premultipliedAlpha:Boolean):void
		{
			setBlendFactors(premultipliedAlpha);
		}
		
		
		/**
		 * Sets up the blending factors that correspond with a certain blend mode.
		 * 
		 * @param premultipliedAlpha
		 * @param blendMode
		 */
		public static function setBlendFactors(premultipliedAlpha:Boolean,
			blendMode:String = "normal"):void
		{
			var blendFactors:Array = BlendMode2D.getBlendFactors(blendMode, premultipliedAlpha);
			Render2D.context.setBlendFactors(blendFactors[0], blendFactors[1]);
		}
		
		
		/**
		 * Clears the render context with a certain color and alpha value.
		 * 
		 * @param rgb
		 * @param alpha
		 */
		public static function clear(rgb:uint = 0, alpha:Number = 0.0):void
		{
			Render2D.context.clear(ColorUtil.getRed(rgb) / 255.0,
				ColorUtil.getGreen(rgb) / 255.0,
				ColorUtil.getBlue(rgb) / 255.0, alpha);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Calculates the product of modelview and projection matrix. CAUTION: Don't save
		 * a reference to this object! Each call returns the same instance.
		 */
		public function get mvpMatrix():Matrix
		{
			_mvpMatrix.copyFrom(_modelViewMatrix);
			_mvpMatrix.concat(_projectionMatrix);
			return _mvpMatrix;
		}
		
		
		/**
		 * Calculates the product of modelview and projection matrix and saves it in a 3D
		 * matrix. CAUTION: Don't save a reference to this object! Each call returns the
		 * same instance.
		 */
		public function get mvpMatrix3D():Matrix3D
		{
			return MatrixUtil.convertTo3D(mvpMatrix, _mvpMatrix3D);
		}
		
		
		/**
		 * Returns the current modelview matrix. CAUTION: not a copy -- use with care!
		 */
		public function get modelViewMatrix():Matrix
		{
			return _modelViewMatrix;
		}
		
		
		/**
		 * Returns the current projection matrix. CAUTION: not a copy -- use with care!
		 */
		public function get projectionMatrix():Matrix
		{
			return _projectionMatrix;
		}
		
		
		/**
		 * The blend mode to be used on rendering. To apply the factor, you have to
		 * manually call 'applyBlendMode' (because the actual blend factors depend on the
		 * PMA mode).
		 */
		public function get blendMode():String
		{
			return _blendMode;
		}
		public function set blendMode(v:String):void
		{
			if (v != BlendMode2D.AUTO) _blendMode = v;
		}
		
		
		/**
		 * The texture that is currently being rendered into, or 'null' to render into the
		 * back buffer. If you set a new target, it is immediately activated.
		 */
		public function get renderTarget():Texture2D
		{
			return _renderTarget;
		}
		public function set renderTarget(v:Texture2D):void
		{
			_renderTarget = v;
			if (v) Render2D.context.setRenderToTexture(v.base);
			else Render2D.context.setRenderToBackBuffer();
		}
		
		
		/**
		 * The width of the back buffer, as it was configured in the last call to
		 * 'RenderSupport2D.configureBackBuffer()'. Beware: changing this value does not
		 * actually resize the back buffer; the setter should only be used to inform
		 * Render2D about the size of a back buffer it can't control (shared context
		 * situations).
		 */
		public function get backBufferWidth():int
		{
			return _backBufferWidth;
		}
		public function set backBufferWidth(v:int):void
		{
			_backBufferWidth = v;
		}
		
		
		/**
		 * The height of the back buffer, as it was configured in the last call to
		 * 'RenderSupport2D.configureBackBuffer()'. Beware: changing this value does not
		 * actually resize the back buffer; the setter should only be used to inform
		 * Render2D about the size of a back buffer it can't control (shared context
		 * situations).
		 */
		public function get backBufferHeight():int
		{
			return _backBufferHeight;
		}
		public function set backBufferHeight(v:int):void
		{
			_backBufferHeight = v;
		}


		/**
		 * The scissor rectangle can be used to limit rendering in the current render
		 * target to a certain area. This method expects the rectangle in stage
		 * coordinates (different to the context3D method with the same name, which
		 * expects pixels). Pass <code>null</code> to turn off scissoring. CAUTION: not a
		 * copy -- use with care!
		 */
		public function get scissorRectangle():Rectangle
		{
			return _scissorRectangle.isEmpty() ? null : _scissorRectangle;
		}
		public function set scissorRectangle(v:Rectangle):void
		{
			if (v)
			{
				_scissorRectangle.setTo(v.x, v.y, v.width, v.height);
				var w:int = _renderTarget ? _renderTarget.root.nativeWidth : _backBufferWidth;
				var h:int = _renderTarget ? _renderTarget.root.nativeHeight : _backBufferHeight;
				MatrixUtil.transformCoords(_projectionMatrix, v.x, v.y, _point);
				_rectangle.x = Math.max(0, ( _point.x + 1) / 2) * w;
				_rectangle.y = Math.max(0, (-_point.y + 1) / 2) * h;
				MatrixUtil.transformCoords(_projectionMatrix, v.right, v.bottom, _point);
				_rectangle.right = Math.min(1, ( _point.x + 1) / 2) * w;
				_rectangle.bottom = Math.min(1, (-_point.y + 1) / 2) * h;
				Render2D.context.setScissorRectangle(_rectangle);
			}
			else
			{
				_scissorRectangle.setEmpty();
				Render2D.context.setScissorRectangle(null);
			}
		}
		
		
		/**
		 * Indicates the number of stage3D draw calls made by the Render2D system.
		 */
		public function get drawCount():int
		{
			return _drawCount;
		}
		
		
		static public function get agal():AGALMiniAssembler
		{
			if (!_agal) _agal = new AGALMiniAssembler();
			return _agal;
		}
	}
}
