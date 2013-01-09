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
	import com.hexagonstar.constants.TextureSmoothing;
	import com.hexagonstar.exception.MissingContext3DException;
	import com.hexagonstar.util.agal.AGAL;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	import flash.utils.getQualifiedClassName;
	
	
	/**
	 * Optimizes rendering of a number of quads with an identical state.
	 * 
	 * <p>
	 * The majority of all rendered objects in Starling are quads. In fact, all the
	 * default leaf nodes of Starling are quads. The rendering of those quads can be
	 * accelerated by a big factor if all quads with an identical state (i.e. same
	 * texture, same smoothing and mipmapping settings) are sent to the GPU in just one
	 * call. That's what the QuadBatch class can do.
	 * </p>
	 */
	public final class QuadBatch2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _numQuads:int;
		/** @private */
		private var _currentTexture:Texture2D;
		/** @private */
		private var _currentSmoothing:String;
		/** @private */
		private var _vertexData:VertexData2D;
		/** @private */
		private var _vertexBuffer:VertexBuffer3D;
		/** @private */
		private var _indexData:Vector.<uint>;
		/** @private */
		private var _indexBuffer:IndexBuffer3D;
		
		/* Helper object. */
		
		/** @private */
		private static var _renderAlpha:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0];
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/** Creates a new QuadBatch instance with empty batch data. */
		public function QuadBatch2D()
		{
			_vertexData = new VertexData2D(0, true);
			_indexData = new <uint>[];
			_numQuads = 0;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes vertex- and index-buffer.
		 */
		public function dispose():void
		{
			if (_vertexBuffer) _vertexBuffer.dispose();
			if (_indexBuffer) _indexBuffer.dispose();
		}
		
		
		/**
		 * Uploads the raw data of all batched quads to the vertex buffer.
		 */
		public function syncBuffers():void
		{
			// as 3rd parameter, we could also use '_numQuads * 4', but on some GPU hardware (iOS!),
			// this is slower than updating the complete buffer.
			if (_vertexBuffer)
			{
				_vertexBuffer.uploadFromVector(_vertexData.rawData, 0, _vertexData.numVertices);
			}
		}
		
		
		/**
		 * Renders the current batch. Don't forget to call 'syncBuffers' before rendering.
		 * 
		 * @param projectionMatrix
		 * @param alpha
		 */
		public function render(projectionMatrix:Matrix3D, alpha:Number = 1.0):void
		{
			if (_numQuads == 0) return;
			
			var pma:Boolean = _vertexData.premultipliedAlpha;
			var c:Context3D = Render2D.context;
			var dynamicAlpha:Boolean = alpha != 1.0;
			
			var program:String = _currentTexture
				? getImageProgramName(dynamicAlpha, _currentTexture.mipMapping, _currentTexture.repeat, _currentSmoothing)
				: getQuadProgramName(dynamicAlpha);
			
			Render2DRenderSupport.setDefaultBlendFactors(pma);
			registerPrograms();
			
			c.setProgram(Render2D.current.getProgram(program));
			c.setVertexBufferAt(0, _vertexBuffer, VertexData2D.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_3);
			c.setVertexBufferAt(1, _vertexBuffer, VertexData2D.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
			c.setProgramConstantsFromMatrix(AGAL.VERTEX, 0, projectionMatrix, true);
			
			if (dynamicAlpha)
			{
				_renderAlpha[0] = _renderAlpha[1] = _renderAlpha[2] = pma ? alpha : 1.0;
				_renderAlpha[3] = alpha;
				c.setProgramConstantsFromVector(AGAL.FRAGMENT, 0, _renderAlpha, 1);
			}
			if (_currentTexture)
			{
				c.setTextureAt(0, _currentTexture.base);
				c.setVertexBufferAt(2, _vertexBuffer, VertexData2D.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			}
			
			c.drawTriangles(_indexBuffer, 0, _numQuads * 2);
			
			if (_currentTexture)
			{
				c.setTextureAt(0, null);
				c.setVertexBufferAt(2, null);
			}
			
			c.setVertexBufferAt(1, null);
			c.setVertexBufferAt(0, null);
		}
		
		
		/**
		 * Resets the batch. The vertex- and index-buffers remain their size, so that they
		 * can be reused quickly.
		 */
		public function reset():void
		{
			_numQuads = 0;
			_currentTexture = null;
			_currentSmoothing = null;
		}
		
		
		/**
		 * Adds a quad to the current batch. Before adding a quad, you should check for a
		 * state change (with the 'isStateChange' method) and, in case of a change, render
		 * the batch.
		 * 
		 * @param quad
		 * @param alpha
		 * @param texture
		 * @param smoothing
		 * @param modelViewMatrix
		 */
		public function addQuad(quad:Quad2D, alpha:Number, texture:Texture2D, smoothing:String,
			modelViewMatrix:Matrix3D):void
		{
			if (_numQuads + 1 > _vertexData.numVertices / 4) expand();
			if (_numQuads == 0)
			{
				_currentTexture = texture;
				_currentSmoothing = smoothing;
				_vertexData.setPremultipliedAlpha(texture ? texture.premultipliedAlpha : true, false);
			}
			
			var vertexID:int = _numQuads * 4;
			quad.copyVertexDataTo(_vertexData, vertexID);
			alpha *= quad.alpha;
			if (alpha != 1.0) _vertexData.scaleAlpha(vertexID, alpha, 4);
			_vertexData.transformVertex(vertexID, modelViewMatrix, 4);
			++_numQuads;
		}
		
		
		/**
		 * Indicates if a quad can be added to the batch without causing a state change. A
		 * state change occurs if the quad uses a different base texture or has a
		 * different 'smoothing' or 'repeat' setting.
		 * 
		 * @param quad
		 * @param texture
		 * @param smoothing
		 * @return true or false.
		 */
		public function isStateChange(quad:Quad2D, texture:Texture2D, smoothing:String):Boolean
		{
			if (_numQuads == 0) return false;
			else if (_numQuads == 8192) return true; // maximum buffer size
			else if (!_currentTexture && !texture) return false;
			else if (_currentTexture && texture) return _currentTexture.base != texture.base || _currentTexture.repeat != texture.repeat || _currentSmoothing != smoothing;
			else return true;
		}
		
		
		/* compilation (for flattened sprites) */
		
		/**
		 * Analyses a container object that is made up exclusively of quads (or other
		 * containers) and creates a vector of QuadBatch objects representing the
		 * container. This can be used to render the container very efficiently. The
		 * 'flatten'-method of the Sprite class uses this method internally.
		 * 
		 * @param container
		 * @param quadBatches
		 */
		public static function compile(container:DisplayObjectContainer2D,
			quadBatches:Vector.<QuadBatch2D>):void
		{
			compileObject(container, quadBatches, -1, new Matrix3D());
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function expand():void
		{
			var oldCapacity:int = _vertexData.numVertices / 4;
			var newCapacity:int = oldCapacity == 0 ? 16 : oldCapacity * 2;
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
			
			if (_vertexBuffer) _vertexBuffer.dispose();
			if (_indexBuffer) _indexBuffer.dispose();
			
			var context:Context3D = Render2D.context;
			if (!context) throw new MissingContext3DException("QuadBatch2D: context is null!");
			
			_vertexBuffer = context.createVertexBuffer(newCapacity * 4, VertexData2D.ELEMENTS_PER_VERTEX);
			_vertexBuffer.uploadFromVector(_vertexData.rawData, 0, newCapacity * 4);
			_indexBuffer = context.createIndexBuffer(newCapacity * 6);
			_indexBuffer.uploadFromVector(_indexData, 0, newCapacity * 6);
		}
		
		
		/**
		 * @private
		 * 
		 * @param object
		 * @param quadBatches
		 * @param quadBatchID
		 * @param transformationMatrix
		 * @param alpha
		 * @return int
		 */
		private static function compileObject(object:DisplayObject2D,
			quadBatches:Vector.<QuadBatch2D>, quadBatchID:int, transformationMatrix:Matrix3D,
			alpha:Number = 1.0):int
		{
			var i:int;
			var isRootObject:Boolean = false;
			
			if (quadBatchID == -1)
			{
				isRootObject = true;
				quadBatchID = 0;
				if (quadBatches.length == 0) quadBatches.push(new QuadBatch2D());
				else quadBatches[0].reset();
			}
			else if (object.alpha == 0.0 || !object.visible)
			{
				return quadBatchID; // ignore transparent objects, except root.
			}
			
			if (object is DisplayObjectContainer2D)
			{
				var container:DisplayObjectContainer2D = object as DisplayObjectContainer2D;
				var numChildren:int = container.numChildren;
				var childMatrix:Matrix3D = new Matrix3D();
				
				for (i = 0; i < numChildren; ++i)
				{
					var child:DisplayObject2D = container.getChildAt(i);
					childMatrix.copyFrom(transformationMatrix);
					Render2DRenderSupport.transformMatrixForObject(childMatrix, child);
					quadBatchID = compileObject(child, quadBatches, quadBatchID, childMatrix, alpha * child.alpha);
				}
			}
			else if (object is Quad2D)
			{
				var quad:Quad2D = object as Quad2D;
				var image:Image2D = quad as Image2D;
				var texture:Texture2D = image ? image.texture : null;
				var smoothing:String = image ? image.smoothing : null;
				var quadBatch:QuadBatch2D = quadBatches[quadBatchID];
				
				if (quadBatch.isStateChange(quad, texture, smoothing))
				{
					quadBatch.syncBuffers();
					quadBatchID++;
					if (quadBatches.length <= quadBatchID) quadBatches.push(new QuadBatch2D());
					quadBatch = quadBatches[quadBatchID];
					quadBatch.reset();
				}
				
				quadBatch.addQuad(quad, alpha, texture, smoothing, transformationMatrix);
			}
			else
			{
				throw new Error("Unsupported display object: " + getQualifiedClassName(object));
			}
			
			if (isRootObject)
			{
				quadBatches[quadBatchID].syncBuffers();
				for (i = quadBatches.length - 1; i > quadBatchID; --i)
				{
					quadBatches[i].dispose();
					delete quadBatches[i];
				}
			}
			
			return quadBatchID;
		}


		/* program management */
		
		/**
		 * @private
		 */
		private static function registerPrograms():void
		{
			var t:Render2D = Render2D.current; // Get target.
			if (t.hasProgram(getQuadProgramName(true))) return; // already registered
			
			// create vertex and fragment programs from assembly
			var vasm:AGAL = new AGAL();
			var fasm:AGAL = new AGAL();
			var vcode:String;
			var fcode:String;
			
			// Loop through dynamicAlpha. Each combination of alpha/repeat/mipmap/smoothing
			// has its own fragment shader.
			for each (var da:Boolean in [true, false])
			{
				// Quad:
				vcode =
					"m44 op, va0, vc0  \n" +		// 4x4 matrix transform to output clipspace 
					"mov v0, va1       \n";			// pass color to fragment program
				
				fcode = da
					? "mul ft0, v0, fc0  \n" +		// multiply alpha (fc0) by color (v0) 
					  "mov oc, ft0       \n"		// output color
					: "mov oc, v0        \n";		// output color
				
				vasm.assemble(AGAL.VERTEX, vcode);
				fasm.assemble(AGAL.FRAGMENT, fcode);
				
				t.registerProgram(getQuadProgramName(da), vasm.agalcode, fasm.agalcode);
				
				// Image:
				vasm.assemble(AGAL.VERTEX,
					"m44 op, va0, vc0  \n" +		// 4x4 matrix transform to output clipspace 
					"mov v0, va1       \n" +		// pass color to fragment program 
					"mov v1, va2       \n");		// pass texture coordinates to fragment program
				
				fcode = da
					? "tex ft1, v1, fs0 <???>  \n" +	// sample texture 0 
					  "mul ft2, ft1, v0        \n" +	// multiply color with texel color 
					  "mul oc, ft2, fc0        \n"		// multiply color with alpha
					: "tex ft1, v1, fs0 <???>  \n" +	// sample texture 0 
					  "mul oc, ft1, v0         \n";		// multiply color with texel color
				
				// smoothingTypes:
				var st:Array = [TextureSmoothing.NONE, TextureSmoothing.BILINEAR, TextureSmoothing.TRILINEAR];
				
				// loop through repeat, mipmap and smoothing:
				for each (var r:Boolean in [true, false])
				{
					for each (var m:Boolean in [true, false])
					{
						for each (var s:String in st)
						{
							var options:Array = ["2d", r ? "repeat" : "clamp"];

							if (s == TextureSmoothing.NONE)
							{
								options.push("nearest", m ? "mipnearest" : "mipnone");
							}
							else if (s == TextureSmoothing.BILINEAR)
							{
								options.push("linear", m ? "mipnearest" : "mipnone");
							}
							else
							{
								options.push("linear", m ? "miplinear" : "mipnone");
							}
							
							fasm.assemble(AGAL.FRAGMENT, fcode.replace("???", options.join()));
							t.registerProgram(getImageProgramName(da, m, r, s), vasm.agalcode, fasm.agalcode);
						}
					}
				}
			}
		}
		
		
		/**
		 * @private
		 * 
		 * @param dynamicAlpha
		 */
		private static function getQuadProgramName(dynamicAlpha:Boolean):String
		{
			return dynamicAlpha ? "QB_q*" : "QB_q'";
		}
		
		
		/**
		 * @private
		 * 
		 * @param dynamicAlpha
		 * @param mipMap
		 * @param repeat
		 * @param smoothing
		 * @return String
		 */
		private static function getImageProgramName(dynamicAlpha:Boolean, mipMap:Boolean = true,
			repeat:Boolean = false, smoothing:String = "bilinear"):String
		{
			// this method is designed to return most quickly when called with
			// the default parameters (no-repeat, mipmap, bilinear)
			var name:String = dynamicAlpha ? "QB_i*" : "QB_i'";
			if (!mipMap) name += "N";
			if (repeat) name += "R";
			if (smoothing != TextureSmoothing.BILINEAR) name += smoothing.charAt(0);
			return name;
		}
	}
}
