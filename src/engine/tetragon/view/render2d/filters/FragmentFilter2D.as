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
package tetragon.view.render2d.filters
{
	import tetragon.util.geom.MatrixUtil;
	import tetragon.util.geom.RectangleUtil;
	import tetragon.util.math.nextPowerOfTwo;
	import tetragon.view.render2d.core.Render2D;
	import tetragon.view.render2d.core.RenderSupport2D;
	import tetragon.view.render2d.core.VertexData2D;
	import tetragon.view.render2d.display.BlendMode2D;
	import tetragon.view.render2d.display.DisplayObject2D;
	import tetragon.view.render2d.display.Image2D;
	import tetragon.view.render2d.display.QuadBatch2D;
	import tetragon.view.render2d.display.Stage2D;
	import tetragon.view.render2d.events.Event2D;
	import tetragon.view.render2d.textures.Texture2D;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.errors.IllegalOperationError;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;


	/** The FragmentFilter class is the base class for all filter effects in Render2D.
	 *  All other filters of this package extend this class. You can attach them to any display
	 *  object through the 'filter' property.
	 * 
	 *  <p>A fragment filter works in the following way:</p>
	 *  <ol>
	 *    <li>The object that is filtered is rendered into a texture (in stage coordinates).</li>
	 *    <li>That texture is passed to the first filter pass.</li>
	 *    <li>Each pass processes the texture using a fragment shader (and optionally a vertex 
	 *        shader) to achieve a certain effect.</li>
	 *    <li>The output of each pass is used as the input for the next pass; if it's the 
	 *        final pass, it will be rendered directly to the back buffer.</li>  
	 *  </ol>
	 * 
	 *  <p>All of this is set up by the abstract FragmentFilter class. Concrete subclasses
	 *  just need to override the protected methods 'createPrograms', 'activate' and 
	 *  (optionally) 'deactivate' to create and execute its custom shader code. Each filter
	 *  can be configured to either replace the original object, or be drawn below or above it.
	 *  This can be done through the 'mode' property, which accepts one of the Strings defined
	 *  in the 'FragmentFilterMode' class.</p>
	 * 
	 *  <p>Beware that each filter should be used only on one object at a time. Otherwise, it
	 *  will get slower and require more resources; and caching will lead to undefined
	 *  results.</p>
	 */
	public class FragmentFilter2D
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/** All filter processing is expected to be done with premultiplied alpha. */
		protected const PMA:Boolean = true;
		
		/**
		 * The standard vertex shader code. It will be used automatically if you don't create
		 * a custom vertex shader yourself.
		 */
		protected const STD_VERTEX_SHADER:String =
			"m44 op, va0, vc0 \n" +	// 4x4 matrix transform to output space 
			"mov v0, va1      \n";	// pass texture coordinates to fragment program
		
		/**
		 * The standard fragment shader code. It just forwards the texture color to the output.
		 */
		protected const STD_FRAGMENT_SHADER:String =
			"tex oc, v0, fs0 <2d, clamp, linear, mipnone>";	// just forward texture color
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		public static var render2D:Render2D;
		public static var context3D:Context3D;
		
		private var _vertexPosAtID:int = 0;
		private var _texCoordsAtID:int = 1;
		private var _baseTextureID:int = 0;
		private var _mvpConstantID:int = 0;
		private var _numPasses:int;
		private var _passTextures:Vector.<Texture2D>;
		private var _mode:String;
		private var _resolution:Number;
		private var _marginX:Number;
		private var _marginY:Number;
		private var _offsetX:Number;
		private var _offsetY:Number;
		private var _vertexData:VertexData2D;
		private var _vertexBuffer:VertexBuffer3D;
		private var _indexData:Vector.<uint>;
		private var _indexBuffer:IndexBuffer3D;
		private var _cacheRequested:Boolean;
		private var _cache:QuadBatch2D;
		
		/** helper objects. */
		private var _projMatrix:Matrix = new Matrix();
		private static var _bounds:Rectangle = new Rectangle();
		private static var _stageBounds:Rectangle = new Rectangle();
		private static var _transformationMatrix:Matrix = new Matrix();
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new Fragment filter with the specified number of passes and resolution.
		 * This constructor may only be called by the constructor of a subclass.
		 * 
		 * @param numPasses
		 * @param resolution
		 */
		public function FragmentFilter2D(numPasses:int = 1, resolution:Number = 1.0)
		{
			if (numPasses < 1) throw new ArgumentError("At least one pass is required.");
			
			_numPasses = numPasses;
			_resolution = resolution;
			
			_marginX = _marginY = 0.0;
			_offsetX = _offsetY = 0.0;
			_mode = FragmentFilterMode2D.REPLACE;
			
			_vertexData = new VertexData2D(4);
			_vertexData.setTexCoords(0, 0, 0);
			_vertexData.setTexCoords(1, 1, 0);
			_vertexData.setTexCoords(2, 0, 1);
			_vertexData.setTexCoords(3, 1, 1);
			
			_indexData = new <uint>[0, 1, 2, 1, 3, 2];
			_indexData.fixed = true;
			
			createPrograms();
			
			// Handle lost context. By using the conventional event, we can make it weak; this
			// avoids memory leaks when people forget to call "dispose" on the filter.
			render2D.stage3D.addEventListener(Event2D.CONTEXT3D_CREATE,
				onContextCreated, false, 0, true);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/** Disposes the filter (programs, buffers, textures). */
		public function dispose():void
		{
			render2D.stage3D.removeEventListener(Event2D.CONTEXT3D_CREATE, onContextCreated);
			if (_vertexBuffer) _vertexBuffer.dispose();
			if (_indexBuffer) _indexBuffer.dispose();
			disposePassTextures();
			disposeCache();
		}
		
		
		/** Applies the filter on a certain display object, rendering the output into the current 
		 *  render target. This method is called automatically by Render2D's rendering system 
		 *  for the object the filter is attached to. */
		public function render(object:DisplayObject2D, support:RenderSupport2D,
			parentAlpha:Number):void
		{
			// bottom layer
			if (mode == FragmentFilterMode2D.ABOVE)
			{
				object.render(support, parentAlpha);
			}
			// center layer
			if (_cacheRequested)
			{
				_cacheRequested = false;
				_cache = renderPasses(object, support, 1.0, true);
				disposePassTextures();
			}
			
			if (_cache) _cache.render(support, parentAlpha);
			else renderPasses(object, support, parentAlpha, false);
			
			// top layer
			if (mode == FragmentFilterMode2D.BELOW)
			{
				object.render(support, parentAlpha);
			}
		}
		
		
		/** Caches the filter output into a texture. An uncached filter is rendered in every frame;
		 *  a cached filter only once. However, if the filtered object or the filter settings
		 *  change, it has to be updated manually; to do that, call "cache" again. */
		public function cache():void
		{
			_cacheRequested = true;
			disposeCache();
		}


		/** Clears the cached output of the filter. After calling this method, the filter will
		 *  be executed once per frame again. */
		public function clearCache():void
		{
			_cacheRequested = false;
			disposeCache();
		}


		/** @private */
		public function compile(object:DisplayObject2D):QuadBatch2D
		{
			if (_cache) return _cache;
			else
			{
				var renderSupport:RenderSupport2D;
				var stage:Stage2D = object.stage;

				if (stage == null)
					throw new Error("Filtered object must be on the stage.");

				renderSupport = new RenderSupport2D();
				object.getTransformationMatrix(stage, renderSupport.modelViewMatrix);
				return renderPasses(object, renderSupport, 1.0, true);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/** Indicates if the filter is cached (via the "cache" method). */
		public function get isCached():Boolean
		{
			return (_cache != null) || _cacheRequested;
		}


		/** The resolution of the filter texture. "1" means stage resolution, "0.5" half the
		 *  stage resolution. A lower resolution saves memory and execution time (depending on 
		 *  the GPU), but results in a lower output quality. Values greater than 1 are allowed;
		 *  such values might make sense for a cached filter when it is scaled up. @default 1 */
		public function get resolution():Number
		{
			return _resolution;
		}
		public function set resolution(v:Number):void
		{
			if (v <= 0) throw new ArgumentError("Resolution must be > 0");
			else _resolution = v;
		}


		/** The filter mode, which is one of the constants defined in the "FragmentFilterMode" 
		 *  class. @default "replace" */
		public function get mode():String
		{
			return _mode;
		}
		public function set mode(v:String):void
		{
			_mode = v;
		}


		/** Use the x-offset to move the filter output to the right or left. */
		public function get offsetX():Number
		{
			return _offsetX;
		}
		public function set offsetX(v:Number):void
		{
			_offsetX = v;
		}


		/** Use the y-offset to move the filter output to the top or bottom. */
		public function get offsetY():Number
		{
			return _offsetY;
		}
		public function set offsetY(v:Number):void
		{
			_offsetY = v;
		}


		/** The x-margin will extend the size of the filter texture along the x-axis.
		 *  Useful when the filter will "grow" the rendered object. */
		protected function get marginX():Number
		{
			return _marginX;
		}
		protected function set marginX(v:Number):void
		{
			_marginX = v;
		}


		/** The y-margin will extend the size of the filter texture along the y-axis.
		 *  Useful when the filter will "grow" the rendered object. */
		protected function get marginY():Number
		{
			return _marginY;
		}
		protected function set marginY(v:Number):void
		{
			_marginY = v;
		}


		/** The number of passes the filter is applied. The "activate" and "deactivate" methods
		 *  will be called that often. */
		protected function set numPasses(v:int):void
		{
			_numPasses = v;
		}
		protected function get numPasses():int
		{
			return _numPasses;
		}


		/** The ID of the vertex buffer attribute that stores the vertex position. */
		protected final function get vertexPosAtID():int
		{
			return _vertexPosAtID;
		}
		protected final function set vertexPosAtID(v:int):void
		{
			_vertexPosAtID = v;
		}


		/** The ID of the vertex buffer attribute that stores the texture coordinates. */
		protected final function get texCoordsAtID():int
		{
			return _texCoordsAtID;
		}
		protected final function set texCoordsAtID(v:int):void
		{
			_texCoordsAtID = v;
		}


		/** The ID (sampler) of the input texture (containing the output of the previous pass). */
		protected final function get baseTextureID():int
		{
			return _baseTextureID;
		}
		protected final function set baseTextureID(v:int):void
		{
			_baseTextureID = v;
		}


		/** The ID of the first register of the modelview-projection constant (a 4x4 matrix). */
		protected final function get mvpConstantID():int
		{
			return _mvpConstantID;
		}
		protected final function set mvpConstantID(v:int):void
		{
			_mvpConstantID = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onContextCreated(event:Object):void
		{
			_vertexBuffer = null;
			_indexBuffer = null;
			_passTextures = null;
			createPrograms();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function renderPasses(object:DisplayObject2D, support:RenderSupport2D,
			parentAlpha:Number, intoCache:Boolean = false):QuadBatch2D
		{
			var cacheTexture:Texture2D = null;
			var stage:Stage2D = object.stage;
			var scale:Number = render2D.contentScaleFactor;
			
			if (!stage) throw new Error("Filtered object must be on the stage.");
			
			// the bounds of the object in stage coordinates
			calculateBounds(object, stage, !intoCache, _bounds);
			
			if (_bounds.isEmpty())
			{
				disposePassTextures();
				return intoCache ? new QuadBatch2D() : null;
			}

			updateBuffers(context3D, _bounds);
			updatePassTextures(_bounds.width, _bounds.height, _resolution * scale);

			support.finishQuadBatch();
			support.raiseDrawCount(_numPasses);
			support.pushMatrix();

			// save original projection matrix and render target
			_projMatrix.copyFrom(support.projectionMatrix);
			var previousRenderTarget:Texture2D = support.renderTarget;

			if (previousRenderTarget)
			{
				throw new IllegalOperationError("It's currently not possible to stack filters! "
					+ "This limitation will be removed in a future Stage3D version.");
			}

			if (intoCache)
			{
				cacheTexture = Texture2D.empty(_bounds.width, _bounds.height, PMA, true,
					_resolution * scale);
			}

			// draw the original object into a texture
			support.renderTarget = _passTextures[0];
			support.clear();
			support.blendMode = BlendMode2D.NORMAL;
			support.setOrthographicProjection(_bounds.x, _bounds.y, _bounds.width, _bounds.height);
			object.render(support, parentAlpha);
			support.finishQuadBatch();

			// prepare drawing of actual filter passes
			RenderSupport2D.setBlendFactors(PMA);
			support.loadIdentity();
			
			// now we'll draw in stage coordinates!
			context3D.setVertexBufferAt(_vertexPosAtID, _vertexBuffer, VertexData2D.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			context3D.setVertexBufferAt(_texCoordsAtID, _vertexBuffer, VertexData2D.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);

			// draw all passes
			for (var i:int = 0; i < _numPasses; ++i)
			{
				if (i < _numPasses - 1) // intermediate pass
				{
					// draw into pass texture
					support.renderTarget = getPassTexture(i + 1);
					support.clear();
				}
				else // final pass
				{
					if (intoCache)
					{
						// draw into cache texture
						support.renderTarget = cacheTexture;
						support.clear();
					}
					else
					{
						// draw into back buffer, at original (stage) coordinates
						support.renderTarget = previousRenderTarget;
						support.projectionMatrix.copyFrom(_projMatrix);
						// restore projection matrix
						support.translateMatrix(_offsetX, _offsetY);
						support.blendMode = object.blendMode;
						support.applyBlendMode(PMA);
					}
				}

				var passTexture:Texture2D = getPassTexture(i);

				context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _mvpConstantID, support.mvpMatrix3D, true);
				context3D.setTextureAt(_baseTextureID, passTexture.base);

				activate(i, context3D, passTexture);
				context3D.drawTriangles(_indexBuffer, 0, 2);
				deactivate(i, context3D, passTexture);
			}

			// reset shader attributes
			context3D.setVertexBufferAt(_vertexPosAtID, null);
			context3D.setVertexBufferAt(_texCoordsAtID, null);
			context3D.setTextureAt(_baseTextureID, null);

			support.popMatrix();

			if (intoCache)
			{
				// restore support settings
				support.renderTarget = previousRenderTarget;
				support.projectionMatrix.copyFrom(_projMatrix);

				// Create an image containing the cache. To have a display object that contains
				// the filter output in object coordinates, we wrap it in a QuadBatch: that way,
				// we can modify it with a transformation matrix.

				var quadBatch:QuadBatch2D = new QuadBatch2D();
				var image:Image2D = new Image2D(cacheTexture);

				stage.getTransformationMatrix(object, _transformationMatrix);
				MatrixUtil.prependTranslation(_transformationMatrix, _bounds.x + _offsetX, _bounds.y + _offsetY);
				quadBatch.addImage(image, 1.0, _transformationMatrix);

				return quadBatch;
			}
			else return null;
		}


		// helper methods
		private function updateBuffers(context:Context3D, bounds:Rectangle):void
		{
			_vertexData.setPosition(0, bounds.x, bounds.y);
			_vertexData.setPosition(1, bounds.right, bounds.y);
			_vertexData.setPosition(2, bounds.x, bounds.bottom);
			_vertexData.setPosition(3, bounds.right, bounds.bottom);

			if (_vertexBuffer == null)
			{
				_vertexBuffer = context.createVertexBuffer(4, VertexData2D.ELEMENTS_PER_VERTEX);
				_indexBuffer = context.createIndexBuffer(6);
				_indexBuffer.uploadFromVector(_indexData, 0, 6);
			}

			_vertexBuffer.uploadFromVector(_vertexData.rawData, 0, 4);
		}


		private function updatePassTextures(width:int, height:int, scale:Number):void
		{
			var numPassTextures:int = _numPasses > 1 ? 2 : 1;

			var needsUpdate:Boolean = _passTextures == null || _passTextures.length != numPassTextures || _passTextures[0].width != width || _passTextures[0].height != height;

			if (needsUpdate)
			{
				if (_passTextures)
				{
					for each (var texture:Texture2D in _passTextures)
						texture.dispose();

					_passTextures.length = numPassTextures;
				}
				else
				{
					_passTextures = new Vector.<Texture2D>(numPassTextures);
				}

				for (var i:int = 0; i < numPassTextures; ++i)
					_passTextures[i] = Texture2D.empty(width, height, PMA, true, scale);
			}
		}


		private function getPassTexture(pass:int):Texture2D
		{
			return _passTextures[pass % 2];
		}


		/** Calculates the bounds of the filter in stage coordinates, while making sure that the 
		 *  according textures will have powers of two. */
		private function calculateBounds(object:DisplayObject2D, stage:Stage2D, intersectWithStage:Boolean, resultRect:Rectangle):void
		{
			// optimize for full-screen effects
			if (object == stage || object == render2D.rootView)
				resultRect.setTo(0, 0, stage.stageWidth, stage.stageHeight);
			else
				object.getBounds(stage, resultRect);

			if (intersectWithStage)
			{
				_stageBounds.setTo(0, 0, stage.stageWidth, stage.stageHeight);
				RectangleUtil.intersect(resultRect, _stageBounds, resultRect);
			}

			if (!resultRect.isEmpty())
			{
				// the bounds are a rectangle around the object, in stage coordinates,
				// and with an optional margin. To fit into a POT-texture, it will grow towards
				// the right and bottom.
				var deltaMargin:Number = _resolution == 1.0 ? 0.0 : 1.0 / _resolution;
				// avoid hard edges
				resultRect.x -= _marginX + deltaMargin;
				resultRect.y -= _marginY + deltaMargin;
				resultRect.width += 2 * (_marginX + deltaMargin);
				resultRect.height += 2 * (_marginY + deltaMargin);
				resultRect.width = nextPowerOfTwo(resultRect.width * _resolution) / _resolution;
				resultRect.height = nextPowerOfTwo(resultRect.height * _resolution) / _resolution;
			}
		}


		private function disposePassTextures():void
		{
			for each (var texture:Texture2D in _passTextures)
				texture.dispose();

			_passTextures = null;
		}


		private function disposeCache():void
		{
			if (_cache)
			{
				if (_cache.texture) _cache.texture.dispose();
				_cache.dispose();
				_cache = null;
			}
		}


		// protected methods
		/** Subclasses must override this method and use it to create their 
		 *  fragment- and vertex-programs. */
		protected function createPrograms():void
		{
			throw new Error("Method has to be implemented in subclass!");
		}


		/** Subclasses must override this method and use it to activate their fragment- and 
		 *  to vertext-programs.
		 *  The 'activate' call directly precedes the call to 'context.drawTriangles'. Set up
		 *  the context the way your filter needs it. The following constants and attributes 
		 *  are set automatically:
		 *  
		 *  <ul><li>vertex constants 0-3: mvpMatrix (3D)</li>
		 *      <li>vertex attribute 0: vertex position (FLOAT_2)</li>
		 *      <li>vertex attribute 1: texture coordinates (FLOAT_2)</li>
		 *      <li>texture 0: input texture</li>
		 *  </ul>
		 *  
		 *  @param pass: the current render pass, starting with '0'. Multipass filters can
		 *               provide different logic for each pass.
		 *  @param context: the current context3D (the same as in Render2D.context, passed
		 *               just for convenience)
		 *  @param texture: the input texture, which is already bound to sampler 0. */
		protected function activate(pass:int, context:Context3D, texture:Texture2D):void
		{
			throw new Error("Method has to be implemented in subclass!");
		}


		/** This method is called directly after 'context.drawTriangles'. 
		 *  If you need to clean up any resources, you can do so in this method. */
		protected function deactivate(pass:int, context:Context3D, texture:Texture2D):void
		{
			// clean up resources
		}


		/**
		 * Assembles fragment- and vertex-shaders, passed as Strings, to a Program3D. 
		 * If any argument is  null, it is replaced by the class constants STD_FRAGMENT_SHADER or
		 * STD_VERTEX_SHADER, respectively.
		 * 
		 * @param fragmentShader
		 * @param vertexShader
		 * @return Program3D
		 */
		protected function assembleAgal(fragmentShader:String = null,
			vertexShader:String = null):Program3D
		{
			if (!fragmentShader) fragmentShader = STD_FRAGMENT_SHADER;
			if (!vertexShader) vertexShader = STD_VERTEX_SHADER;
			return RenderSupport2D.assembleAgal(vertexShader, fragmentShader);
		}
	}
}
