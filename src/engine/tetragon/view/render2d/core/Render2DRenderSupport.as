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
	import flash.display3D.Context3DBlendFactor;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import tetragon.view.render2d.core.events.Event2D;

	
	
	/**
	 * A class that contains helper methods simplifying Stage3D rendering.
	 * 
	 * <p>A Direct2DRenderSupport instance is passed to any "render" method of display
	 * objects. It allows manipulation of the current transformation matrix (similar to
	 * the matrix manipulation methods of OpenGL 1.x) and other helper methods.</p>
	 */
	public final class Render2DRenderSupport
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _projectionMatrix:Matrix3D;
		/** @private */
		private var _modelViewMatrix:Matrix3D;
		/** @private */
		private var _mvpMatrix:Matrix3D;
		/** @private */
		private var _matrixStack:Vector.<Matrix3D>;
		/** @private */
		private var _matrixStackSize:int;
		/** @private */
		private var _quadBatches:Vector.<QuadBatch2D>;
		/** @private */
		private var _currentQuadBatchID:int;
		
		/* Helper object. */
		
		/** @private */
		private static var _matrixCoords:Vector.<Number> = new Vector.<Number>(16, true);
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new RenderSupport object with an empty matrix stack.
		 */
		public function Render2DRenderSupport()
		{
			_projectionMatrix = new Matrix3D();
			_modelViewMatrix = new Matrix3D();
			_mvpMatrix = new Matrix3D();
			_matrixStack = new <Matrix3D>[];
			
			_matrixStackSize = 0;
			_currentQuadBatchID = 0;
			
			_quadBatches = new <QuadBatch2D>[new QuadBatch2D()];
			
			loadIdentity();
			setOrthographicProjection(400, 300);
			
			Render2D.current.addEventListener(Event2D.CONTEXT3D_CREATE, onContextCreated);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes all quad batches.
		 */
		public function dispose():void
		{
			for each (var qb:QuadBatch2D in _quadBatches)
			{
				qb.dispose();
			}
			Render2D.current.removeEventListener(Event2D.CONTEXT3D_CREATE, onContextCreated);
		}
		
		
		/**
		 * Sets up the projection matrix for ortographic 2D rendering.
		 * 
		 * @param width
		 * @param height
		 * @param near
		 * @param far
		 */
		public function setOrthographicProjection(width:Number, height:Number, near:Number = -1.0,
			far:Number = 1.0):void
		{
			_matrixCoords[0] = 2.0 / width;
			_matrixCoords[1] = _matrixCoords[2] = _matrixCoords[3] = _matrixCoords[4] = 0.0;
			_matrixCoords[5] = -2.0 / height;
			_matrixCoords[6] = _matrixCoords[7] = _matrixCoords[8] = _matrixCoords[9] = 0.0;
			_matrixCoords[10] = -2.0 / (far - near);
			_matrixCoords[11] = 0.0;
			_matrixCoords[12] = -1.0;
			_matrixCoords[13] = 1.0;
			_matrixCoords[14] = -(far + near) / (far - near);
			_matrixCoords[15] = 1.0;
			
			_projectionMatrix.copyRawDataFrom(_matrixCoords);
		}
		
		
		/**
		 * Changes the modelview matrix to the identity matrix.
		 */
		public function loadIdentity():void
		{
			_modelViewMatrix.identity();
		}
		
		
		/**
		 * Prepends a translation to the modelview matrix.
		 * 
		 * @param dx
		 * @param dy
		 * @param dz
		 */
		public function translateMatrix(dx:Number, dy:Number, dz:Number = 0):void
		{
			_modelViewMatrix.prependTranslation(dx, dy, dz);
		}
		
		
		/**
		 * Prepends a rotation (angle in radians) to the modelview matrix.
		 * 
		 * @param angle
		 * @param axis
		 */
		public function rotateMatrix(angle:Number, axis:Vector3D = null):void
		{
			_modelViewMatrix.prependRotation(angle / Math.PI * 180.0, axis == null
				? Vector3D.Z_AXIS : axis);
		}
		
		
		/**
		 * Prepends an incremental scale change to the modelview matrix.
		 * 
		 * @param sx
		 * @param sy
		 * @param sz
		 */
		public function scaleMatrix(sx:Number, sy:Number, sz:Number = 1.0):void
		{
			_modelViewMatrix.prependScale(sx, sy, sz);
		}
		
		
		/**
		 * Prepends translation, scale and rotation of an object to the modelview matrix.
		 * 
		 * @param object
		 */
		public function transformMatrix(object:DisplayObject2D):void
		{
			transformMatrixForObject(_modelViewMatrix, object);
		}
		
		
		/**
		 * Pushes the current modelview matrix to a stack from which it can be restored later.
		 */
		public function pushMatrix():void
		{
			if (_matrixStack.length < _matrixStackSize + 1) _matrixStack.push(new Matrix3D());
			_matrixStack[_matrixStackSize++].copyFrom(_modelViewMatrix);
		}
		
		
		/**
		 * Restores the modelview matrix that was last pushed to the stack.
		 */
		public function popMatrix():void
		{
			_modelViewMatrix.copyFrom(_matrixStack[--_matrixStackSize]);
		}
		
		
		/**
		 * Empties the matrix stack, resets the modelview matrix to the identity matrix.
		 */
		public function resetMatrix():void
		{
			_matrixStackSize = 0;
			loadIdentity();
		}


		/* optimized quad rendering */
		
		/**
		 * Adds a quad to the current batch of unrendered quads. If there is a state
		 * change, all previous quads are rendered at once, and the batch is reset.
		 * 
		 * @param quad
		 * @param alpha
		 * @param texture
		 * @param smoothing
		 */
		public function batchQuad(quad:Quad2D, alpha:Number, texture:Texture2D = null,
			smoothing:String = null):void
		{
			if (currentQuadBatch.isStateChange(quad, texture, smoothing)) finishQuadBatch();
			currentQuadBatch.addQuad(quad, alpha, texture, smoothing, _modelViewMatrix);
		}
		
		
		/**
		 * Renders the current quad batch and resets it.
		 */
		public function finishQuadBatch():void
		{
			currentQuadBatch.syncBuffers();
			currentQuadBatch.render(_projectionMatrix);
			currentQuadBatch.reset();
			++_currentQuadBatchID;
			if (_quadBatches.length <= _currentQuadBatchID) _quadBatches.push(new QuadBatch2D());
		}
		
		
		/**
		 * Resets the matrix stack and the quad batch index.
		 */
		public function nextFrame():void
		{
			resetMatrix();
			_currentQuadBatchID = 0;
		}
		
		
		/**
		 * Prepends translation, scale and rotation of an object to a custom matrix.
		 * 
		 * @param matrix
		 * @param object
		 */
		public static function transformMatrixForObject(matrix:Matrix3D,
			object:DisplayObject2D):void
		{
			var x:Number = object.x;
			var y:Number = object.y;
			var r:Number = object.rotation;
			var sx:Number = object.scaleX;
			var sy:Number = object.scaleY;
			var px:Number = object.pivotX;
			var py:Number = object.pivotY;
			
			if (x != 0 || y != 0) matrix.prependTranslation(x, y, 0.0);
			if (r != 0) matrix.prependRotation(r / Math.PI * 180.0, Vector3D.Z_AXIS);
			if (sx != 1 || sy != 1) matrix.prependScale(sx, sy, 1.0);
			if (px != 0 || py != 0) matrix.prependTranslation(-px, -py, 0.0);
		}
		
		
		/**
		 * Sets up the default blending factors, depending on the premultiplied alpha status.
		 * 
		 * @param premultipliedAlpha
		 */
		public static function setDefaultBlendFactors(premultipliedAlpha:Boolean):void
		{
			var df:String = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			var sf:String = premultipliedAlpha ? Context3DBlendFactor.ONE : Context3DBlendFactor.SOURCE_ALPHA;
			Render2D.context.setBlendFactors(sf, df);
		}
		
		
		/**
		 * Clears the render context with a certain color and alpha value.
		 * 
		 * @param rgb
		 * @param alpha
		 */
		public static function clear(rgb:uint = 0, alpha:Number = 0.0):void
		{
			Render2D.context.clear(((rgb >> 16) & 0xff) / 255.0, ((rgb >> 8) & 0xff) / 255.0,
				(rgb & 0xff) / 255.0, alpha);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Calculates the product of modelview and projection matrix. CAUTION: Don't save
		 * a reference to this object! Each call returns the same instance.
		 */
		public function get mvpMatrix():Matrix3D
		{
			_mvpMatrix.identity();
			_mvpMatrix.append(_modelViewMatrix);
			_mvpMatrix.append(_projectionMatrix);
			return _mvpMatrix;
		}
		
		
		/**
		 * @private
		 */
		private function get currentQuadBatch():QuadBatch2D
		{
			return _quadBatches[_currentQuadBatchID];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onContextCreated(e:Event2D):void
		{
			_quadBatches = new <QuadBatch2D>[new QuadBatch2D()];
		}
	}
}
