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
	import tetragon.view.render2d.core.RenderSupport2D;
	import tetragon.view.render2d.core.VertexData2D;
	import tetragon.view.render2d.events.Event2D;
	import tetragon.view.render2d.filters.FragmentFilter2D;
	import tetragon.view.render2d.filters.FragmentFilterMode2D;
	import tetragon.view.render2d.textures.Texture2D;
	import tetragon.view.render2d.textures.TextureSmoothing2D;

	import com.hexagonstar.util.agal.AGALMiniAssembler;

	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	
	/**
	 * 	Optimizes rendering of a number of quads with an identical state.
	 * 
	 *  <p>The majority of all rendered objects in Render2D are quads. In fact, all the default
	 *  leaf nodes of Render2D are quads (the Image and Quad classes). The rendering of those 
	 *  quads can be accelerated by a big factor if all quads with an identical state are sent 
	 *  to the GPU in just one call. That's what the QuadBatch class can do.</p>
	 *  
	 *  <p>The 'flatten' method of the Sprite class uses this class internally to optimize its 
	 *  rendering performance. In most situations, it is recommended to stick with flattened
	 *  sprites, because they are easier to use. Sometimes, however, it makes sense
	 *  to use the QuadBatch class directly: e.g. you can add one quad multiple times to 
	 *  a quad batch, whereas you can only add it once to a sprite. Furthermore, this class
	 *  does not dispatch <code>ADDED</code> or <code>ADDED_TO_STAGE</code> events when a quad
	 *  is added, which makes it more lightweight.</p>
	 *  
	 *  <p>One QuadBatch object is bound to a specific render state. The first object you add to a 
	 *  batch will decide on the QuadBatch's state, that is: its texture, its settings for 
	 *  smoothing and blending, and if it's tinted (colored vertices and/or transparency). 
	 *  When you reset the batch, it will accept a new state on the next added quad.</p> 
	 *  
	 *  <p>The class extends DisplayObject, but you can use it even without adding it to the
	 *  display tree. Just call the 'renderCustom' method from within another render method,
	 *  and pass appropriate values for transformation matrix, alpha and blend mode.</p>
	 *
	 *  @see Sprite  
	 */
	public class QuadBatch2D extends DisplayObject2D
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		private static const QUAD_PROGRAM_NAME:String = "QB_q";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _numQuads:int;
		private var _syncRequired:Boolean;
		private var _tinted:Boolean;
		private var _texture:Texture2D;
		private var _smoothing:String;
		private var _vertexData:VertexData2D;
		private var _vertexBuffer:VertexBuffer3D;
		private var _indexData:Vector.<uint>;
		private var _indexBuffer:IndexBuffer3D;
		
		/** Helper objects. */
		private static var _helperMatrix:Matrix = new Matrix();
		private static var _renderAlpha:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0];
		private static var _renderMatrix:Matrix3D = new Matrix3D();
		private static var _programNameCache:Dictionary = new Dictionary();
		private static var _rawData:Vector.<Number> = new <Number>[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new QuadBatch instance with empty batch data.
		 */
		public function QuadBatch2D()
		{
			_vertexData = new VertexData2D(0, true);
			_indexData = new <uint>[];
			_numQuads = 0;
			_tinted = false;
			_syncRequired = false;

			// Handle lost context. We use the conventional event here (not the one from Render2D)
			// so we're able to create a weak event listener; this avoids memory leaks when people
			// forget to call "dispose" on the QuadBatch.
			render2D.stage3D.addEventListener(Event2D.CONTEXT3D_CREATE, onContextCreated,
				false, 0, true);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes vertex- and index-buffer.
		 */
		public override function dispose():void
		{
			render2D.stage3D.removeEventListener(Event2D.CONTEXT3D_CREATE, onContextCreated);
			if (_vertexBuffer) _vertexBuffer.dispose();
			if (_indexBuffer) _indexBuffer.dispose();
			super.dispose();
		}
		
		
		/**
		 * Creates a duplicate of the QuadBatch object.
		 */
		public function clone():QuadBatch2D
		{
			var clone:QuadBatch2D = new QuadBatch2D();
			clone._vertexData = _vertexData.clone(0, _numQuads * 4);
			clone._indexData = _indexData.slice(0, _numQuads * 6);
			clone._numQuads = _numQuads;
			clone._tinted = _tinted;
			clone._texture = _texture;
			clone._smoothing = _smoothing;
			clone._syncRequired = true;
			clone.blendMode = blendMode;
			clone.alpha = alpha;
			return clone;
		}
		
		
		/**
		 * Renders the current batch with custom settings for model-view-projection matrix, alpha 
		 * and blend mode. This makes it possible to render batches that are not part of the 
		 * display list.
		 * 
		 * @param mvpMatrix
		 * @param parentAlpha
		 * @param blendMode
		 */
		public function renderCustom(mvpMatrix:Matrix, parentAlpha:Number = 1.0,
			blendMode:String = null):void
		{
			if (_numQuads == 0) return;
			if (_syncRequired) syncBuffers();
			
			var pma:Boolean = _vertexData.premultipliedAlpha;
			var tinted:Boolean = _tinted || (parentAlpha != 1.0);
			
			_renderAlpha[0] = _renderAlpha[1] = _renderAlpha[2] = pma ? parentAlpha : 1.0;
			_renderAlpha[3] = parentAlpha;
			
			/* Inlined Matrix convertTo3D for better speed. */
			_rawData[0] = mvpMatrix.a;
			_rawData[1] = mvpMatrix.b;
			_rawData[4] = mvpMatrix.c;
			_rawData[5] = mvpMatrix.d;
			_rawData[12] = mvpMatrix.tx;
			_rawData[13] = mvpMatrix.ty;
			_renderMatrix.copyRawDataFrom(_rawData);
			
			/* Inlined RenderSupport2D.setBlendFactors. */
			var bf:Array = BlendMode2D.getBlendFactors(blendMode ? blendMode : this.blendMode, pma);
			context3D.setBlendFactors(bf[0], bf[1]);
			
			context3D.setProgram(render2D.getProgram(_texture ? getImageProgramName(tinted, _texture.mipMapping, _texture.repeat, _texture.format, _smoothing) : QUAD_PROGRAM_NAME));
			context3D.setProgramConstantsFromVector("vertex", 0, _renderAlpha, 1);
			context3D.setProgramConstantsFromMatrix("vertex", 1, _renderMatrix, true);
			context3D.setVertexBufferAt(0, _vertexBuffer, 0, "float2");
			
			if (!_texture || tinted)
			{
				context3D.setVertexBufferAt(1, _vertexBuffer, 2, "float4");
			}
			if (_texture)
			{
				context3D.setTextureAt(0, _texture.base);
				context3D.setVertexBufferAt(2, _vertexBuffer, 6, "float2");
			}
			
			context3D.drawTriangles(_indexBuffer, 0, _numQuads * 2);
			
			if (_texture)
			{
				context3D.setTextureAt(0, null);
				context3D.setVertexBufferAt(2, null);
			}
			
			context3D.setVertexBufferAt(1, null);
			context3D.setVertexBufferAt(0, null);
		}
		
		
		/**
		 * Resets the batch. The vertex- and index-buffers remain their size, so that they
		 * can be reused quickly.
		 */
		public function reset():void
		{
			_numQuads = 0;
			_texture = null;
			_smoothing = null;
			_syncRequired = true;
		}


		/**
		 * Adds an image to the batch. This method internally calls 'addQuad' with the correct
		 * parameters for 'texture' and 'smoothing'.
		 * 
		 * @param image
		 * @param parentAlpha
		 * @param modelViewMatrix
		 * @param blendMode
		 */
		public function addImage(image:Image2D, parentAlpha:Number = 1.0,
			modelViewMatrix:Matrix = null, blendMode:String = null):void
		{
			addQuad(image, parentAlpha, image.texture, image.smoothing, modelViewMatrix, blendMode);
		}
		
		
		/**
		 * Adds a quad to the batch. The first quad determines the state of the batch,
		 * i.e. the values for texture, smoothing and blendmode. When you add additional quads,  
		 * make sure they share that state (e.g. with the 'isStageChange' method), or reset
		 * the batch.
		 * 
		 * @param quad
		 * @param parentAlpha
		 * @param texture
		 * @param smoothing
		 * @param modelViewMatrix
		 * @param blendMode
		 */
		public function addQuad(quad:IQuad2D, parentAlpha:Number = 1.0, texture:Texture2D = null,
			smoothing:String = null, modelViewMatrix:Matrix = null, blendMode:String = null):void
		{
			if (!modelViewMatrix) modelViewMatrix = quad.transformationMatrix;
			
			var alpha:Number = parentAlpha * quad.alpha;
			var vertexID:int = _numQuads * 4;
			
			if (_numQuads + 1 > _vertexData.numVertices / 4)
			{
				expand();
			}
			
			if (_numQuads == 0)
			{
				this.blendMode = blendMode ? blendMode : quad.blendMode;
				_texture = texture;
				_tinted = texture ? (quad.tinted || parentAlpha != 1.0) : false;
				_smoothing = smoothing;
				_vertexData.setPremultipliedAlpha(quad.premultipliedAlpha);
			}
			
			quad.copyVertexDataTo(_vertexData, vertexID);
			_vertexData.transformVertex(vertexID, modelViewMatrix, 4);
			
			if (alpha != 1.0)
			{
				_vertexData.scaleAlpha(vertexID, alpha, 4);
			}
			
			_syncRequired = true;
			_numQuads++;			
		}
		
		
		/**
		 * @param quadBatch
		 * @param parentAlpha
		 * @param modelViewMatrix
		 * @param blendMode
		 */
		public function addQuadBatch(quadBatch:QuadBatch2D, parentAlpha:Number = 1.0,
			modelViewMatrix:Matrix = null, blendMode:String = null):void
		{
			if (!modelViewMatrix) modelViewMatrix = quadBatch.transformationMatrix;
			
			var tinted:Boolean = quadBatch._tinted || parentAlpha != 1.0;
			var alpha:Number = parentAlpha * quadBatch.alpha;
			var vertexID:int = _numQuads * 4;
			var numQuads:int = quadBatch.numQuads;
			
			if (_numQuads + numQuads > capacity)
			{
				expand(_numQuads + numQuads);
			}
			if (_numQuads == 0)
			{
				this.blendMode = blendMode ? blendMode : quadBatch.blendMode;
				_texture = quadBatch._texture;
				_tinted = tinted;
				_smoothing = quadBatch._smoothing;
				_vertexData.setPremultipliedAlpha(quadBatch._vertexData.premultipliedAlpha, false);
			}
			
			quadBatch._vertexData.copyTo(_vertexData, vertexID, 0, numQuads * 4);
			_vertexData.transformVertex(vertexID, modelViewMatrix, numQuads * 4);
			
			if (alpha != 1.0)
			{
				_vertexData.scaleAlpha(vertexID, alpha, numQuads * 4);
			}
			
			_syncRequired = true;
			_numQuads += numQuads;
		}
		
		
		/**
		 * Indicates if specific quads can be added to the batch without causing a state change. 
		 * A state change occurs if the quad uses a different base texture, has a different 
		 * 'tinted', 'smoothing', 'repeat' or 'blendMode' setting, or if the batch is full
		 * (one batch can contain up to 8192 quads).
		 * 
		 * @param tinted
		 * @param parentAlpha
		 * @param texture
		 * @param smoothing
		 * @param blendMode
		 * @param numQuads
		 */
		public function isStateChange(tinted:Boolean, parentAlpha:Number, texture:Texture2D,
			smoothing:String, blendMode:String, numQuads:int = 1):Boolean
		{
			if (_numQuads == 0) return false;
			else if (_numQuads + numQuads > 8192) return true; // maximum buffer size
			else if (!_texture && !texture) return false;
			else if (_texture && texture)
			{
				return _texture.base != texture.base
					|| _texture.repeat != texture.repeat
					|| _smoothing != smoothing
					|| _tinted != (tinted || parentAlpha != 1.0)
					|| this.blendMode != blendMode;
			}
			else return true;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function getBounds(targetSpace:DisplayObject2D,
			resultRect:Rectangle = null):Rectangle
		{
			if (!resultRect) resultRect = new Rectangle();
			var m:Matrix = targetSpace == this
				? null
				: getTransformationMatrix(targetSpace, _helperMatrix);
			return _vertexData.getBounds(m, 0, _numQuads * 4, resultRect);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function render(support:RenderSupport2D, parentAlpha:Number):void
		{
			if (_numQuads)
			{
				support.finishQuadBatch();
				support.raiseDrawCount();
				renderCustom(support.mvpMatrix, alpha * parentAlpha, support.blendMode);
			}
		}
		
		
		/**
		 * Analyses an object that is made up exclusively of quads (or other containers)
		 * and creates a vector of QuadBatch objects representing it. This can be
		 * used to render the container very efficiently. The 'flatten'-method of the Sprite 
		 * class uses this method internally.
		 */
		public static function compile(object:DisplayObject2D, quadBatches:Vector.<QuadBatch2D>):void
		{
			compileObject(object, quadBatches, -1, new Matrix());
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get numQuads():int
		{
			return _numQuads;
		}


		public function get tinted():Boolean
		{
			return _tinted;
		}


		public function get texture():Texture2D
		{
			return _texture;
		}


		public function get smoothing():String
		{
			return _smoothing;
		}


		private function get capacity():int
		{
			return _vertexData.numVertices / 4;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onContextCreated(e:Object):void
		{
			/* Tentative fix for Error #3694! Check that the context isn't disposed before
			 * it get's accessed again! */
			if (RenderSupport2D.context3D && RenderSupport2D.context3D.driverInfo != "Disposed")
			{
				createBuffers();
				registerPrograms();
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function expand(newCapacity:int = -1):void
		{
			var oldCapacity:int = capacity;
			
			if (newCapacity < 0) newCapacity = oldCapacity * 2;
			if (newCapacity == 0) newCapacity = 16;
			if (newCapacity <= oldCapacity) return;
			
			_vertexData.numVertices = newCapacity * 4;
			
			for (var i:int = oldCapacity; i < newCapacity; ++i)
			{
				_indexData[int(i * 6)] = i * 4;
				_indexData[int(i * 6 + 1)] = i * 4 + 1;
				_indexData[int(i * 6 + 2)] = i * 4 + 2;
				_indexData[int(i * 6 + 3)] = i * 4 + 1;
				_indexData[int(i * 6 + 4)] = i * 4 + 3;
				_indexData[int(i * 6 + 5)] = i * 4 + 2;
			}
			
			createBuffers();
			registerPrograms();
		}


		/**
		 * @private
		 */
		private function createBuffers():void
		{
			var numVertices:int = _vertexData.numVertices;
			var numIndices:int = _indexData.length;
			
			if (_vertexBuffer) _vertexBuffer.dispose();
			if (_indexBuffer) _indexBuffer.dispose();
			if (numVertices == 0) return;
			
			_vertexBuffer = context3D.createVertexBuffer(numVertices, 8);
			_vertexBuffer.uploadFromVector(_vertexData.rawData, 0, numVertices);
			
			_indexBuffer = context3D.createIndexBuffer(numIndices);
			_indexBuffer.uploadFromVector(_indexData, 0, numIndices);
			
			_syncRequired = false;
		}
		
		
		/**
		 * Uploads the raw data of all batched quads to the vertex buffer.
		 */
		private function syncBuffers():void
		{
			if (!_vertexBuffer)
			{
				createBuffers();
				return;
			}
			
			// as 3rd parameter, we could also use '_numQuads * 4', but on some GPU hardware
			// (iOS!), this is slower than updating the complete buffer.
			_vertexBuffer.uploadFromVector(_vertexData.rawData, 0, _vertexData.numVertices);
			_syncRequired = false;
		}
		
		
		/**
		 * @private
		 */
		private static function compileObject(object:DisplayObject2D,
			quadBatches:Vector.<QuadBatch2D>, quadBatchID:int, transformationMatrix:Matrix,
			alpha:Number = 1.0, blendMode:String = null, ignoreCurrentFilter:Boolean = false):int
		{
			var i:int;
			var quadBatch:QuadBatch2D;
			var isRootObject:Boolean = false;
			var objectAlpha:Number = object.alpha;

			var container:DisplayObjectContainer2D = object as DisplayObjectContainer2D;
			var quad:Rect2D = object as Rect2D;
			var batch:QuadBatch2D = object as QuadBatch2D;
			var filter:FragmentFilter2D = object.filter;

			if (quadBatchID == -1)
			{
				isRootObject = true;
				quadBatchID = 0;
				objectAlpha = 1.0;
				blendMode = object.blendMode;
				if (quadBatches.length == 0) quadBatches.push(new QuadBatch2D());
				else quadBatches[0].reset();
			}

			if (filter && !ignoreCurrentFilter)
			{
				if (filter.mode == FragmentFilterMode2D.ABOVE)
				{
					quadBatchID = compileObject(object, quadBatches, quadBatchID, transformationMatrix, alpha, blendMode, true);
				}

				quadBatchID = compileObject(filter.compile(object), quadBatches, quadBatchID, transformationMatrix, alpha, blendMode);

				if (filter.mode == FragmentFilterMode2D.BELOW)
				{
					quadBatchID = compileObject(object, quadBatches, quadBatchID, transformationMatrix, alpha, blendMode, true);
				}
			}
			else if (container)
			{
				var numChildren:int = container.numChildren;
				var childMatrix:Matrix = new Matrix();

				for (i = 0; i < numChildren; ++i)
				{
					var child:DisplayObject2D = container.getChildAt(i);
					var childVisible:Boolean = child.alpha != 0.0 && child.visible && child.scaleX != 0.0 && child.scaleY != 0.0;
					if (childVisible)
					{
						var childBlendMode:String = child.blendMode == BlendMode2D.AUTO ? blendMode : child.blendMode;
						childMatrix.copyFrom(transformationMatrix);
						RenderSupport2D.transformMatrixForObject(childMatrix, child);
						quadBatchID = compileObject(child, quadBatches, quadBatchID, childMatrix, alpha * objectAlpha, childBlendMode);
					}
				}
			}
			else if (quad || batch)
			{
				var texture:Texture2D;
				var smoothing:String;
				var tinted:Boolean;
				var numQuads:int;

				if (quad)
				{
					var image:Image2D = quad as Image2D;
					texture = image ? image.texture : null;
					smoothing = image ? image.smoothing : null;
					tinted = quad.tinted;
					numQuads = 1;
				}
				else
				{
					texture = batch._texture;
					smoothing = batch._smoothing;
					tinted = batch._tinted;
					numQuads = batch._numQuads;
				}

				quadBatch = quadBatches[quadBatchID];

				if (quadBatch.isStateChange(tinted, alpha * objectAlpha, texture, smoothing, blendMode, numQuads))
				{
					quadBatchID++;
					if (quadBatches.length <= quadBatchID) quadBatches.push(new QuadBatch2D());
					quadBatch = quadBatches[quadBatchID];
					quadBatch.reset();
				}

				if (quad)
					quadBatch.addQuad(quad, alpha, texture, smoothing, transformationMatrix, blendMode);
				else
					quadBatch.addQuadBatch(batch, alpha, transformationMatrix, blendMode);
			}
			else
			{
				throw new Error("Unsupported display object: " + getQualifiedClassName(object));
			}

			if (isRootObject)
			{
				// remove unused batches
				for (i = quadBatches.length - 1; i > quadBatchID; --i)
				{
					(quadBatches.pop() as QuadBatch2D).dispose();
				}
			}

			return quadBatchID;
		}
		
		
		/**
		 * @private
		 */
		private static function registerPrograms():void
		{
			if (render2D.hasProgram(QUAD_PROGRAM_NAME)) return; // already registered
			
			var agal:AGALMiniAssembler = RenderSupport2D.agal;
			
			// this is the input data we'll pass to the shaders:
			//
			// va0 -> position
			// va1 -> color
			// va2 -> texCoords
			// vc0 -> alpha
			// vc1 -> mvpMatrix
			// fs0 -> texture

			// Quad:
			var vertexASM:String =
				"m44 op, va0, vc1 \n" +	// 4x4 matrix transform to output clipspace 
				"mul v0, va1, vc0 \n";	// multiply alpha (vc0) with color (va1)

			var fragmentASM:String =
				"mov oc, v0       \n";	// output color
			
			render2D.registerProgram(QUAD_PROGRAM_NAME,
				agal.assemble(Context3DProgramType.VERTEX, vertexASM),
				agal.assemble(Context3DProgramType.FRAGMENT, fragmentASM));
			
			// Image:
			// Each combination of tinted/repeat/mipmap/smoothing has its own fragment shader.
			for each (var tinted:Boolean in [true, false])
			{
				vertexASM = tinted
					? "m44 op, va0, vc1 \n" +	// 4x4 matrix transform to output clipspace 
					  "mul v0, va1, vc0 \n" +	// multiply alpha (vc0) with color (va1) 
					  "mov v1, va2      \n"		// pass texture coordinates to fragment program
					: "m44 op, va0, vc1 \n" +	// 4x4 matrix transform to output clipspace 
					  "mov v1, va2      \n";	// pass texture coordinates to fragment program
				
				fragmentASM = tinted
					? "tex ft1,  v1, fs0 <???> \n" +	// sample texture 0 
					  "mul  oc, ft1,  v0       \n"		// multiply color with texel color
					: "tex  oc,  v1, fs0 <???> \n";		// sample texture 0
				
				var smoothingTypes:Array =
				[
					TextureSmoothing2D.NONE,
					TextureSmoothing2D.BILINEAR,
					TextureSmoothing2D.TRILINEAR
				];

				var formats:Array =
				[
					Context3DTextureFormat.BGRA,
					Context3DTextureFormat.COMPRESSED,
					Context3DTextureFormat.COMPRESSED_ALPHA
				];
				
				for each (var repeat:Boolean in [true, false])
				{
					for each (var mipmap:Boolean in [true, false])
					{
						for each (var smoothing:String in smoothingTypes)
						{
							for each (var format:String in formats)
							{
								var options:Array = ["2d", repeat ? "repeat" : "clamp"];

								if (format == Context3DTextureFormat.COMPRESSED)
									options.push("dxt1");
								else if (format == Context3DTextureFormat.COMPRESSED_ALPHA)
									options.push("dxt5");
								
								if (smoothing == TextureSmoothing2D.NONE)
									options.push("nearest", mipmap ? "mipnearest" : "mipnone");
								else if (smoothing == TextureSmoothing2D.BILINEAR)
									options.push("linear", mipmap ? "mipnearest" : "mipnone");
								else
									options.push("linear", mipmap ? "miplinear" : "mipnone");
								
								render2D.registerProgram(getImageProgramName(tinted, mipmap, repeat,
									format, smoothing), agal.assemble(Context3DProgramType.VERTEX,
										vertexASM), agal.assemble(Context3DProgramType.FRAGMENT,
										fragmentASM.replace("???", options.join())));
							}
						}
					}
				}
			}
		}
		
		
		/**
		 * @private
		 */
		private static function getImageProgramName(tinted:Boolean, mipMap:Boolean = true,
			repeat:Boolean = false, format:String = "bgra", smoothing:String = "bilinear"):String
		{
			var bitField:uint = 0;
			
			if (tinted) bitField |= 1;
			if (mipMap) bitField |= 1 << 1;
			if (repeat) bitField |= 1 << 2;
			
			if (smoothing == "none") bitField |= 1 << 3;
			else if (smoothing == "trilinear") bitField |= 1 << 4;
			
			if (format == "compressed") bitField |= 1 << 5;
			else if (format == "compressedAlpha") bitField |= 1 << 6;
			
			var name:String = _programNameCache[bitField];
			if (name == null)
			{
				name = "QB_i." + bitField.toString(16);
				_programNameCache[bitField] = name;
			}
			
			return name;
		}
	}
}
