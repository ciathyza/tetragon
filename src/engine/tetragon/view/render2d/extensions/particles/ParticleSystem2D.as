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
package tetragon.view.render2d.extensions.particles
{
	import tetragon.view.render2d.animation.IAnimatable2D;
	import tetragon.view.render2d.core.RenderSupport2D;
	import tetragon.view.render2d.core.VertexData2D;
	import tetragon.view.render2d.display.DisplayObject2D;
	import tetragon.view.render2d.events.Event2D;
	import tetragon.view.render2d.textures.Texture2D;

	import com.hexagonstar.util.agal.AGALMiniAssembler;
	import com.hexagonstar.util.geom.MatrixUtil;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;


	/** Dispatched when emission of particles is finished. */
	[Event(name="complete", type="tetragon.view.render2d.events.Event2D")]
	
	
	/**
	 * ParticleSystem2D class.
	 */
	public class ParticleSystem2D extends DisplayObject2D implements IAnimatable2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _texture:Texture2D;
		private var _particles:Vector.<Particle2D>;
		private var _frameTime:Number;
		private var _program:Program3D;
		private var _vertexData:VertexData2D;
		private var _vertexBuffer:VertexBuffer3D;
		private var _indices:Vector.<uint>;
		private var _indexBuffer:IndexBuffer3D;
		private var _numParticles:int;
		private var _maxCapacity:int;
		private var _emissionRate:Number; // emitted particles per second
		private var _emissionTime:Number;
		
		protected var _emitterX:Number;
		protected var _emitterY:Number;
		protected var _premultipliedAlpha:Boolean;
		protected var _blendFactorSource:String;
		protected var _blendFactorDestination:String;
		
		/** Helper objects. */
		private static var _helperMatrix:Matrix = new Matrix();
		private static var _helperPoint:Point = new Point();
		private static var _renderAlpha:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0];
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @param texture
		 * @param emissionRate
		 * @param initialCapacity
		 * @param maxCapacity
		 * @param blendFactorSource
		 * @param blendFactorDest
		 */
		public function ParticleSystem2D(texture:Texture2D, emissionRate:Number,
			initialCapacity:int = 128, maxCapacity:int = 8192, blendFactorSource:String = null,
			blendFactorDest:String = null)
		{
			if (!texture) throw new ArgumentError("texture must not be null");

			_texture = texture;
			_premultipliedAlpha = texture.premultipliedAlpha;
			_particles = new Vector.<Particle2D>(0, false);
			_vertexData = new VertexData2D(0);
			_indices = new <uint>[];
			_emissionRate = emissionRate;
			_emissionTime = 0.0;
			_frameTime = 0.0;
			_emitterX = _emitterY = 0;
			_maxCapacity = Math.min(8192, maxCapacity);

			_blendFactorDestination = blendFactorDest || Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			_blendFactorSource = blendFactorSource || (_premultipliedAlpha ? Context3DBlendFactor.ONE : Context3DBlendFactor.SOURCE_ALPHA);

			createProgram();
			raiseCapacity(initialCapacity);

			// handle a lost device context
			render2D.stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated,
				false, 0, true);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public override function dispose():void
		{
			render2D.stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			if (_vertexBuffer) _vertexBuffer.dispose();
			if (_indexBuffer) _indexBuffer.dispose();
			if (_program) _program.dispose();
			super.dispose();
		}
		
		
		/** Starts the emitter for a certain time. @default infinite time */
		public function start(duration:Number = Number.MAX_VALUE):void
		{
			if (_emissionRate != 0)
				_emissionTime = duration;
		}


		/** Stops emitting and optionally removes all existing particles. 
		 *  The remaining particles will keep animating until they die. */
		public function stop(clearParticles:Boolean = false):void
		{
			_emissionTime = 0.0;
			if (clearParticles) _numParticles = 0;
		}


		/** Returns an empty rectangle at the particle system's position. Calculating the
		 *  actual bounds would be too expensive. */
		public override function getBounds(targetSpace:DisplayObject2D, resultRect:Rectangle = null):Rectangle
		{
			if (resultRect == null) resultRect = new Rectangle();

			getTransformationMatrix(targetSpace, _helperMatrix);
			MatrixUtil.transformCoords(_helperMatrix, 0, 0, _helperPoint);

			resultRect.x = _helperPoint.x;
			resultRect.y = _helperPoint.y;
			resultRect.width = resultRect.height = 0;

			return resultRect;
		}


		public function advanceTime(passedTime:Number):void
		{
			var particleIndex:int = 0;
			var particle:Particle2D;

			// advance existing particles

			while (particleIndex < _numParticles)
			{
				particle = _particles[particleIndex] as Particle2D;

				if (particle.currentTime < particle.totalTime)
				{
					advanceParticle(particle, passedTime);
					++particleIndex;
				}
				else
				{
					if (particleIndex != _numParticles - 1)
					{
						var nextParticle:Particle2D = _particles[int(_numParticles - 1)] as Particle2D;
						_particles[int(_numParticles - 1)] = particle;
						_particles[particleIndex] = nextParticle;
					}

					--_numParticles;

					if (_numParticles == 0 && _emissionTime == 0)
						dispatchEvent(new Event2D(Event2D.COMPLETE));
				}
			}

			// create and advance new particles
			if (_emissionTime > 0)
			{
				var timeBetweenParticles:Number = 1.0 / _emissionRate;
				_frameTime += passedTime;

				while (_frameTime > 0)
				{
					if (_numParticles < _maxCapacity)
					{
						if (_numParticles == capacity)
							raiseCapacity(capacity);

						particle = _particles[int(_numParticles++)] as Particle2D;
						initParticle(particle);
						advanceParticle(particle, _frameTime);
					}

					_frameTime -= timeBetweenParticles;
				}

				if (_emissionTime != Number.MAX_VALUE)
					_emissionTime = Math.max(0.0, _emissionTime - passedTime);
			}

			// update vertex data
			var vertexID:int = 0;
			var color:uint;
			var alpha:Number;
			var rotation:Number;
			var x:Number, y:Number;
			var xOffset:Number, yOffset:Number;
			var textureWidth:Number = _texture.width;
			var textureHeight:Number = _texture.height;

			for (var i:int = 0; i < _numParticles; ++i)
			{
				vertexID = i << 2;
				particle = _particles[i] as Particle2D;
				color = particle.color;
				alpha = particle.alpha;
				rotation = particle.rotation;
				x = particle.x;
				y = particle.y;
				xOffset = textureWidth * particle.scale >> 1;
				yOffset = textureHeight * particle.scale >> 1;

				for (var j:int = 0; j < 4; ++j)
				{
					_vertexData.setColor(vertexID + j, color);
					_vertexData.setAlpha(vertexID + j, alpha);
				}

				if (rotation)
				{
					var cos:Number = Math.cos(rotation);
					var sin:Number = Math.sin(rotation);
					var cosX:Number = cos * xOffset;
					var cosY:Number = cos * yOffset;
					var sinX:Number = sin * xOffset;
					var sinY:Number = sin * yOffset;

					_vertexData.setPosition(vertexID, x - cosX + sinY, y - sinX - cosY);
					_vertexData.setPosition(vertexID + 1, x + cosX + sinY, y + sinX - cosY);
					_vertexData.setPosition(vertexID + 2, x - cosX - sinY, y - sinX + cosY);
					_vertexData.setPosition(vertexID + 3, x + cosX - sinY, y + sinX + cosY);
				}
				else
				{
					// optimization for rotation == 0
					_vertexData.setPosition(vertexID, x - xOffset, y - yOffset);
					_vertexData.setPosition(vertexID + 1, x + xOffset, y - yOffset);
					_vertexData.setPosition(vertexID + 2, x - xOffset, y + yOffset);
					_vertexData.setPosition(vertexID + 3, x + xOffset, y + yOffset);
				}
			}
		}


		public override function render(support:RenderSupport2D, alpha:Number):void
		{
			if (_numParticles == 0) return;

			// always call this method when you write custom rendering code!
			// it causes all previously batched quads/images to render.
			support.finishQuadBatch();

			// make this call to keep the statistics display in sync.
			// to play it safe, it's done in a backwards-compatible way here.
			if (support.hasOwnProperty("raiseDrawCount"))
				support.raiseDrawCount();

			alpha *= this.alpha;

			var context:Context3D = RenderSupport2D.context3D;
			var pma:Boolean = texture.premultipliedAlpha;

			_renderAlpha[0] = _renderAlpha[1] = _renderAlpha[2] = pma ? alpha : 1.0;
			_renderAlpha[3] = alpha;

			_vertexBuffer.uploadFromVector(_vertexData.rawData, 0, _numParticles * 4);
			_indexBuffer.uploadFromVector(_indices, 0, _numParticles * 6);

			context.setBlendFactors(_blendFactorSource, _blendFactorDestination);
			context.setTextureAt(0, _texture.base);

			context.setProgram(_program);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, support.mvpMatrix3D, true);
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, _renderAlpha, 1);
			context.setVertexBufferAt(0, _vertexBuffer, VertexData2D.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			context.setVertexBufferAt(1, _vertexBuffer, VertexData2D.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
			context.setVertexBufferAt(2, _vertexBuffer, VertexData2D.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);

			context.drawTriangles(_indexBuffer, 0, _numParticles * 2);

			context.setTextureAt(0, null);
			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
			context.setVertexBufferAt(2, null);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get isEmitting():Boolean
		{
			return _emissionTime > 0 && _emissionRate > 0;
		}


		public function get capacity():int
		{
			return _vertexData.numVertices / 4;
		}


		public function get numParticles():int
		{
			return _numParticles;
		}


		public function get maxCapacity():int
		{
			return _maxCapacity;
		}
		public function set maxCapacity(v:int):void
		{
			_maxCapacity = Math.min(8192, v);
		}


		public function get emissionRate():Number
		{
			return _emissionRate;
		}
		public function set emissionRate(v:Number):void
		{
			_emissionRate = v;
		}


		public function get emitterX():Number
		{
			return _emitterX;
		}
		public function set emitterX(v:Number):void
		{
			_emitterX = v;
		}


		public function get emitterY():Number
		{
			return _emitterY;
		}
		public function set emitterY(v:Number):void
		{
			_emitterY = v;
		}


		public function get blendFactorSource():String
		{
			return _blendFactorSource;
		}
		public function set blendFactorSource(v:String):void
		{
			_blendFactorSource = v;
		}


		public function get blendFactorDestination():String
		{
			return _blendFactorDestination;
		}
		public function set blendFactorDestination(v:String):void
		{
			_blendFactorDestination = v;
		}


		public function get texture():Texture2D
		{
			return _texture;
		}
		public function set texture(v:Texture2D):void
		{
			_texture = v;
			createProgram();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onContextCreated(e:Object):void
		{
			createProgram();
			raiseCapacity(0);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function createParticle():Particle2D
		{
			return new Particle2D();
		}


		/**
		 * @private
		 */
		protected function initParticle(particle:Particle2D):void
		{
			particle.x = _emitterX;
			particle.y = _emitterY;
			particle.currentTime = 0;
			particle.totalTime = 1;
			particle.color = Math.random() * 0xffffff;
		}


		/**
		 * @private
		 */
		protected function advanceParticle(particle:Particle2D, passedTime:Number):void
		{
			particle.y += passedTime * 250;
			particle.alpha = 1.0 - particle.currentTime / particle.totalTime;
			particle.scale = 1.0 - particle.alpha;
			particle.currentTime += passedTime;
		}


		/**
		 * @private
		 */
		private function raiseCapacity(byAmount:int):void
		{
			var oldCapacity:int = capacity;
			var newCapacity:int = Math.min(_maxCapacity, capacity + byAmount);
			var context:Context3D = RenderSupport2D.context3D;

			var baseVertexData:VertexData2D = new VertexData2D(4);
			baseVertexData.setTexCoords(0, 0.0, 0.0);
			baseVertexData.setTexCoords(1, 1.0, 0.0);
			baseVertexData.setTexCoords(2, 0.0, 1.0);
			baseVertexData.setTexCoords(3, 1.0, 1.0);
			_texture.adjustVertexData(baseVertexData, 0, 4);

			_particles.fixed = false;
			_indices.fixed = false;

			for (var i:int = oldCapacity; i < newCapacity; ++i)
			{
				var numVertices:int = i * 4;
				var numIndices:int = i * 6;

				_particles[i] = createParticle();
				_vertexData.append(baseVertexData);

				_indices[    numIndices   ] = numVertices;
				_indices[int(numIndices + 1)] = numVertices + 1;
				_indices[int(numIndices + 2)] = numVertices + 2;
				_indices[int(numIndices + 3)] = numVertices + 1;
				_indices[int(numIndices + 4)] = numVertices + 3;
				_indices[int(numIndices + 5)] = numVertices + 2;
			}

			_particles.fixed = true;
			_indices.fixed = true;

			// upload data to vertex and index buffers

			if (_vertexBuffer) _vertexBuffer.dispose();
			if (_indexBuffer) _indexBuffer.dispose();

			_vertexBuffer = context.createVertexBuffer(newCapacity * 4, VertexData2D.ELEMENTS_PER_VERTEX);
			_vertexBuffer.uploadFromVector(_vertexData.rawData, 0, newCapacity * 4);

			_indexBuffer = context.createIndexBuffer(newCapacity * 6);
			_indexBuffer.uploadFromVector(_indices, 0, newCapacity * 6);
		}
		
		
		/**
		 * @private
		 */
		private function createProgram():void
		{
			var mipmap:Boolean = _texture.mipMapping;
			var textureFormat:String = _texture.format;
			var context:Context3D = RenderSupport2D.context3D;

			if (_program) _program.dispose();

			// create vertex and fragment programs from assembly.

			var textureOptions:String = "2d, clamp, linear, " + (mipmap ? "mipnearest" : "mipnone");

			if (textureFormat == Context3DTextureFormat.COMPRESSED)
				textureOptions += ", dxt1";
			else if (textureFormat == "compressedAlpha")
				textureOptions += ", dxt5";

			var vertexProgramCode:String = "m44 op, va0, vc0 \n" + // 4x4 matrix transform to output clipspace 
			"mul v0, va1, vc4 \n" + // multiply color with alpha and pass to fragment program 
			"mov v1, va2      \n";
			// pass texture coordinates to fragment program

			var fragmentProgramCode:String = "tex ft1, v1, fs0 <" + textureOptions + "> \n" + // sample texture 0 
			"mul oc, ft1, v0";
			// multiply color with texel color

			var vertexProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexProgramAssembler.assemble(Context3DProgramType.VERTEX, vertexProgramCode);

			var fragmentProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentProgramAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentProgramCode);

			_program = context.createProgram();
			_program.upload(vertexProgramAssembler.agalcode, fragmentProgramAssembler.agalcode);
		}
	}
}
