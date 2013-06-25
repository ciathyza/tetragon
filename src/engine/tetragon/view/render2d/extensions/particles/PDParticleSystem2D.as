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
	import tetragon.core.types.ARGB;
	import tetragon.util.color.colorARGBToHex;
	import tetragon.util.geom.degToRad;
	import tetragon.view.render2d.textures.Texture2D;

	import flash.display3D.Context3DBlendFactor;


	public class PDParticleSystem2D extends ParticleSystem2D
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		// private const EMITTER_TYPE_GRAVITY:int = 0;
		private const EMITTER_TYPE_RADIAL:int = 1;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		// emitter configuration                            // .pex element name
		private var _emitterType:int;
		// emitterType
		private var _emitterXVariance:Number;
		// sourcePositionVariance x
		private var _emitterYVariance:Number;
		// sourcePositionVariance y
		
		// particle configuration
		private var _maxNumParticles:int;
		// maxParticles
		private var _lifespan:Number;
		// particleLifeSpan
		private var _lifespanVariance:Number;
		// particleLifeSpanVariance
		private var _startSize:Number;
		// startParticleSize
		private var _startSizeVariance:Number;
		// startParticleSizeVariance
		private var _endSize:Number;
		// finishParticleSize
		private var _endSizeVariance:Number;
		// finishParticleSizeVariance
		private var _emitAngle:Number;
		// angle
		private var _emitAngleVariance:Number;
		// angleVariance
		private var _startRotation:Number;
		// rotationStart
		private var _startRotationVariance:Number;
		// rotationStartVariance
		private var _endRotation:Number;
		// rotationEnd
		private var _endRotationVariance:Number;
		// rotationEndVariance
		
		// gravity configuration
		private var _speed:Number;
		// speed
		private var _speedVariance:Number;
		// speedVariance
		private var _gravityX:Number;
		// gravity x
		private var _gravityY:Number;
		// gravity y
		private var _radialAcceleration:Number;
		// radialAcceleration
		private var _radialAccelerationVariance:Number;
		// radialAccelerationVariance
		private var _tangentialAcceleration:Number;
		// tangentialAcceleration
		private var _tangentialAccelerationVariance:Number;
		// tangentialAccelerationVariance
		
		// radial configuration
		private var _maxRadius:Number;
		// maxRadius
		private var _maxRadiusVariance:Number;
		// maxRadiusVariance
		private var _minRadius:Number;
		// minRadius
		private var _rotatePerSecond:Number;
		// rotatePerSecond
		private var _rotatePerSecondVariance:Number;
		// rotatePerSecondVariance
		// color configuration
		private var _startColor:ARGB;
		// startColor
		private var _startColorVariance:ARGB;
		// startColorVariance
		private var _endColor:ARGB;
		// finishColor
		private var _endColorVariance:ARGB; 	// finishColorVariance
		
		
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @param config
		 * @param texture
		 */
		public function PDParticleSystem2D(config:XML, texture:Texture2D)
		{
			parseConfig(config);

			var emissionRate:Number = _maxNumParticles / _lifespan;
			super(texture, emissionRate, _maxNumParticles, _maxNumParticles, _blendFactorSource,
				_blendFactorDestination);
			
			_premultipliedAlpha = false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get emitterType():int
		{
			return _emitterType;
		}
		public function set emitterType(v:int):void
		{
			_emitterType = v;
		}


		public function get emitterXVariance():Number
		{
			return _emitterXVariance;
		}
		public function set emitterXVariance(v:Number):void
		{
			_emitterXVariance = v;
		}


		public function get emitterYVariance():Number
		{
			return _emitterYVariance;
		}
		public function set emitterYVariance(v:Number):void
		{
			_emitterYVariance = v;
		}


		public function get maxNumParticles():int
		{
			return _maxNumParticles;
		}
		public function set maxNumParticles(v:int):void
		{
			maxCapacity = v;
			_maxNumParticles = maxCapacity;
			updateEmissionRate();
		}


		public function get lifespan():Number
		{
			return _lifespan;
		}
		public function set lifespan(v:Number):void
		{
			_lifespan = Math.max(0.01, v);
			updateEmissionRate();
		}


		public function get lifespanVariance():Number
		{
			return _lifespanVariance;
		}
		public function set lifespanVariance(v:Number):void
		{
			_lifespanVariance = v;
		}


		public function get startSize():Number
		{
			return _startSize;
		}
		public function set startSize(v:Number):void
		{
			_startSize = v;
		}


		public function get startSizeVariance():Number
		{
			return _startSizeVariance;
		}
		public function set startSizeVariance(v:Number):void
		{
			_startSizeVariance = v;
		}


		public function get endSize():Number
		{
			return _endSize;
		}
		public function set endSize(v:Number):void
		{
			_endSize = v;
		}


		public function get endSizeVariance():Number
		{
			return _endSizeVariance;
		}
		public function set endSizeVariance(v:Number):void
		{
			_endSizeVariance = v;
		}


		public function get emitAngle():Number
		{
			return _emitAngle;
		}
		public function set emitAngle(v:Number):void
		{
			_emitAngle = v;
		}


		public function get emitAngleVariance():Number
		{
			return _emitAngleVariance;
		}
		public function set emitAngleVariance(v:Number):void
		{
			_emitAngleVariance = v;
		}


		public function get startRotation():Number
		{
			return _startRotation;
		}
		public function set startRotation(v:Number):void
		{
			_startRotation = v;
		}


		public function get startRotationVariance():Number
		{
			return _startRotationVariance;
		}
		public function set startRotationVariance(v:Number):void
		{
			_startRotationVariance = v;
		}


		public function get endRotation():Number
		{
			return _endRotation;
		}
		public function set endRotation(v:Number):void
		{
			_endRotation = v;
		}


		public function get endRotationVariance():Number
		{
			return _endRotationVariance;
		}
		public function set endRotationVariance(v:Number):void
		{
			_endRotationVariance = v;
		}


		public function get speed():Number
		{
			return _speed;
		}
		public function set speed(v:Number):void
		{
			_speed = v;
		}


		public function get speedVariance():Number
		{
			return _speedVariance;
		}
		public function set speedVariance(v:Number):void
		{
			_speedVariance = v;
		}


		public function get gravityX():Number
		{
			return _gravityX;
		}
		public function set gravityX(v:Number):void
		{
			_gravityX = v;
		}


		public function get gravityY():Number
		{
			return _gravityY;
		}
		public function set gravityY(v:Number):void
		{
			_gravityY = v;
		}


		public function get radialAcceleration():Number
		{
			return _radialAcceleration;
		}
		public function set radialAcceleration(v:Number):void
		{
			_radialAcceleration = v;
		}


		public function get radialAccelerationVariance():Number
		{
			return _radialAccelerationVariance;
		}
		public function set radialAccelerationVariance(v:Number):void
		{
			_radialAccelerationVariance = v;
		}


		public function get tangentialAcceleration():Number
		{
			return _tangentialAcceleration;
		}
		public function set tangentialAcceleration(v:Number):void
		{
			_tangentialAcceleration = v;
		}


		public function get tangentialAccelerationVariance():Number
		{
			return _tangentialAccelerationVariance;
		}
		public function set tangentialAccelerationVariance(v:Number):void
		{
			_tangentialAccelerationVariance = v;
		}
		
		
		public function get maxRadius():Number
		{
			return _maxRadius;
		}
		public function set maxRadius(v:Number):void
		{
			_maxRadius = v;
		}


		public function get maxRadiusVariance():Number
		{
			return _maxRadiusVariance;
		}
		public function set maxRadiusVariance(v:Number):void
		{
			_maxRadiusVariance = v;
		}


		public function get minRadius():Number
		{
			return _minRadius;
		}
		public function set minRadius(v:Number):void
		{
			_minRadius = v;
		}


		public function get rotatePerSecond():Number
		{
			return _rotatePerSecond;
		}
		public function set rotatePerSecond(v:Number):void
		{
			_rotatePerSecond = v;
		}


		public function get rotatePerSecondVariance():Number
		{
			return _rotatePerSecondVariance;
		}
		public function set rotatePerSecondVariance(v:Number):void
		{
			_rotatePerSecondVariance = v;
		}


		public function get startColor():ARGB
		{
			return _startColor;
		}
		public function set startColor(v:ARGB):void
		{
			_startColor = v;
		}


		public function get startColorVariance():ARGB
		{
			return _startColorVariance;
		}
		public function set startColorVariance(v:ARGB):void
		{
			_startColorVariance = v;
		}


		public function get endColor():ARGB
		{
			return _endColor;
		}
		public function set endColor(v:ARGB):void
		{
			_endColor = v;
		}


		public function get endColorVariance():ARGB
		{
			return _endColorVariance;
		}
		public function set endColorVariance(v:ARGB):void
		{
			_endColorVariance = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected override function createParticle():Particle2D
		{
			return new PDParticle2D();
		}
		
		
		/**
		 * @private
		 */
		protected override function initParticle(aParticle:Particle2D):void
		{
			var particle:PDParticle2D = aParticle as PDParticle2D;

			// for performance reasons, the random variances are calculated inline instead
			// of calling a function

			var lifespan:Number = _lifespan + _lifespanVariance * (Math.random() * 2.0 - 1.0);
			if (lifespan <= 0.0) return;

			particle.currentTime = 0.0;
			particle.totalTime = lifespan;

			particle.x = _emitterX + _emitterXVariance * (Math.random() * 2.0 - 1.0);
			particle.y = _emitterY + _emitterYVariance * (Math.random() * 2.0 - 1.0);
			particle.startX = _emitterX;
			particle.startY = _emitterY;

			var angle:Number = _emitAngle + _emitAngleVariance * (Math.random() * 2.0 - 1.0);
			var speed:Number = _speed + _speedVariance * (Math.random() * 2.0 - 1.0);
			particle.velocityX = speed * Math.cos(angle);
			particle.velocityY = speed * Math.sin(angle);

			particle.emitRadius = _maxRadius + _maxRadiusVariance * (Math.random() * 2.0 - 1.0);
			particle.emitRadiusDelta = _maxRadius / lifespan;
			particle.emitRotation = _emitAngle + _emitAngleVariance * (Math.random() * 2.0 - 1.0);
			particle.emitRotationDelta = _rotatePerSecond + _rotatePerSecondVariance * (Math.random() * 2.0 - 1.0);
			particle.radialAcceleration = _radialAcceleration + _radialAccelerationVariance * (Math.random() * 2.0 - 1.0);
			particle.tangentialAcceleration = _tangentialAcceleration + _tangentialAccelerationVariance * (Math.random() * 2.0 - 1.0);

			var startSize:Number = _startSize + _startSizeVariance * (Math.random() * 2.0 - 1.0);
			var endSize:Number = _endSize + _endSizeVariance * (Math.random() * 2.0 - 1.0);
			if (startSize < 0.1) startSize = 0.1;
			if (endSize < 0.1) endSize = 0.1;
			particle.scale = startSize / texture.width;
			particle.scaleDelta = ((endSize - startSize) / lifespan) / texture.width;

			// colors
			var startColor:ARGB = particle.colorARGB;
			var colorDelta:ARGB = particle.colorARGBDelta;

			startColor.r = _startColor.r;
			startColor.g = _startColor.g;
			startColor.b = _startColor.b;
			startColor.a = _startColor.a;

			if (_startColorVariance.r != 0) startColor.r += _startColorVariance.r * (Math.random() * 2.0 - 1.0);
			if (_startColorVariance.g != 0) startColor.g += _startColorVariance.g * (Math.random() * 2.0 - 1.0);
			if (_startColorVariance.b != 0) startColor.b += _startColorVariance.b * (Math.random() * 2.0 - 1.0);
			if (_startColorVariance.a != 0) startColor.a += _startColorVariance.a * (Math.random() * 2.0 - 1.0);

			var endColorRed:Number = _endColor.r;
			var endColorGreen:Number = _endColor.g;
			var endColorBlue:Number = _endColor.b;
			var endColorAlpha:Number = _endColor.a;

			if (_endColorVariance.r != 0) endColorRed += _endColorVariance.r * (Math.random() * 2.0 - 1.0);
			if (_endColorVariance.g != 0) endColorGreen += _endColorVariance.g * (Math.random() * 2.0 - 1.0);
			if (_endColorVariance.b != 0) endColorBlue += _endColorVariance.b * (Math.random() * 2.0 - 1.0);
			if (_endColorVariance.a != 0) endColorAlpha += _endColorVariance.a * (Math.random() * 2.0 - 1.0);

			colorDelta.r = (endColorRed - startColor.r) / lifespan;
			colorDelta.g = (endColorGreen - startColor.g) / lifespan;
			colorDelta.b = (endColorBlue - startColor.b) / lifespan;
			colorDelta.a = (endColorAlpha - startColor.a) / lifespan;

			// rotation
			var startRotation:Number = _startRotation + _startRotationVariance * (Math.random() * 2.0 - 1.0);
			var endRotation:Number = _endRotation + _endRotationVariance * (Math.random() * 2.0 - 1.0);

			particle.rotation = startRotation;
			particle.rotationDelta = (endRotation - startRotation) / lifespan;
		}
		
		
		/**
		 * @private
		 */
		protected override function advanceParticle(aParticle:Particle2D, passedTime:Number):void
		{
			var particle:PDParticle2D = aParticle as PDParticle2D;

			var restTime:Number = particle.totalTime - particle.currentTime;
			passedTime = restTime > passedTime ? passedTime : restTime;
			particle.currentTime += passedTime;

			if (_emitterType == EMITTER_TYPE_RADIAL)
			{
				particle.emitRotation += particle.emitRotationDelta * passedTime;
				particle.emitRadius -= particle.emitRadiusDelta * passedTime;
				particle.x = _emitterX - Math.cos(particle.emitRotation) * particle.emitRadius;
				particle.y = _emitterY - Math.sin(particle.emitRotation) * particle.emitRadius;

				if (particle.emitRadius < _minRadius)
					particle.currentTime = particle.totalTime;
			}
			else
			{
				var distanceX:Number = particle.x - particle.startX;
				var distanceY:Number = particle.y - particle.startY;
				var distanceScalar:Number = Math.sqrt(distanceX * distanceX + distanceY * distanceY);
				if (distanceScalar < 0.01) distanceScalar = 0.01;

				var radialX:Number = distanceX / distanceScalar;
				var radialY:Number = distanceY / distanceScalar;
				var tangentialX:Number = radialX;
				var tangentialY:Number = radialY;

				radialX *= particle.radialAcceleration;
				radialY *= particle.radialAcceleration;

				var newY:Number = tangentialX;
				tangentialX = -tangentialY * particle.tangentialAcceleration;
				tangentialY = newY * particle.tangentialAcceleration;

				particle.velocityX += passedTime * (_gravityX + radialX + tangentialX);
				particle.velocityY += passedTime * (_gravityY + radialY + tangentialY);
				particle.x += particle.velocityX * passedTime;
				particle.y += particle.velocityY * passedTime;
			}

			particle.scale += particle.scaleDelta * passedTime;
			particle.rotation += particle.rotationDelta * passedTime;

			particle.colorARGB.r += particle.colorARGBDelta.r * passedTime;
			particle.colorARGB.g += particle.colorARGBDelta.g * passedTime;
			particle.colorARGB.b += particle.colorARGBDelta.b * passedTime;
			particle.colorARGB.a += particle.colorARGBDelta.a * passedTime;

			particle.color = colorARGBToHex(particle.colorARGB);
			particle.alpha = particle.colorARGB.a;
		}
		
		
		/**
		 * @private
		 */
		private function updateEmissionRate():void
		{
			emissionRate = _maxNumParticles / _lifespan;
		}
		
		
		/**
		 * @private
		 */
		private function parseConfig(config:XML):void
		{
			_emitterXVariance = parseFloat(config.sourcePositionVariance.attribute("x"));
			_emitterYVariance = parseFloat(config.sourcePositionVariance.attribute("y"));
			_gravityX = parseFloat(config.gravity.attribute("x"));
			_gravityY = parseFloat(config.gravity.attribute("y"));
			_emitterType = getIntValue(config.emitterType);
			_maxNumParticles = getIntValue(config.maxParticles);
			_lifespan = Math.max(0.01, getFloatValue(config.particleLifeSpan));
			_lifespanVariance = getFloatValue(config.particleLifespanVariance);
			_startSize = getFloatValue(config.startParticleSize);
			_startSizeVariance = getFloatValue(config.startParticleSizeVariance);
			_endSize = getFloatValue(config.finishParticleSize);
			_endSizeVariance = getFloatValue(config.FinishParticleSizeVariance);
			_emitAngle = degToRad(getFloatValue(config.angle));
			_emitAngleVariance = degToRad(getFloatValue(config.angleVariance));
			_startRotation = degToRad(getFloatValue(config.rotationStart));
			_startRotationVariance = degToRad(getFloatValue(config.rotationStartVariance));
			_endRotation = degToRad(getFloatValue(config.rotationEnd));
			_endRotationVariance = degToRad(getFloatValue(config.rotationEndVariance));
			_speed = getFloatValue(config.speed);
			_speedVariance = getFloatValue(config.speedVariance);
			_radialAcceleration = getFloatValue(config.radialAcceleration);
			_radialAccelerationVariance = getFloatValue(config.radialAccelVariance);
			_tangentialAcceleration = getFloatValue(config.tangentialAcceleration);
			_tangentialAccelerationVariance = getFloatValue(config.tangentialAccelVariance);
			_maxRadius = getFloatValue(config.maxRadius);
			_maxRadiusVariance = getFloatValue(config.maxRadiusVariance);
			_minRadius = getFloatValue(config.minRadius);
			_rotatePerSecond = degToRad(getFloatValue(config.rotatePerSecond));
			_rotatePerSecondVariance = degToRad(getFloatValue(config.rotatePerSecondVariance));
			_startColor = getColor(config.startColor);
			_startColorVariance = getColor(config.startColorVariance);
			_endColor = getColor(config.finishColor);
			_endColorVariance = getColor(config.finishColorVariance);
			_blendFactorSource = getBlendFunc(config.blendFuncSource);
			_blendFactorDestination = getBlendFunc(config.blendFuncDestination);

			function getIntValue(element:XMLList):int
			{
				return parseInt(element.attribute("value"));
			}

			function getFloatValue(element:XMLList):Number
			{
				return parseFloat(element.attribute("value"));
			}

			function getColor(element:XMLList):ARGB
			{
				var color:ARGB = new ARGB();
				color.r = parseFloat(element.attribute("red"));
				color.g = parseFloat(element.attribute("green"));
				color.b = parseFloat(element.attribute("blue"));
				color.a = parseFloat(element.attribute("alpha"));
				return color;
			}

			function getBlendFunc(element:XMLList):String
			{
				var value:int = getIntValue(element);
				switch (value)
				{
					case 0:
						return Context3DBlendFactor.ZERO;
						break;
					case 1:
						return Context3DBlendFactor.ONE;
						break;
					case 0x300:
						return Context3DBlendFactor.SOURCE_COLOR;
						break;
					case 0x301:
						return Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR;
						break;
					case 0x302:
						return Context3DBlendFactor.SOURCE_ALPHA;
						break;
					case 0x303:
						return Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
						break;
					case 0x304:
						return Context3DBlendFactor.DESTINATION_ALPHA;
						break;
					case 0x305:
						return Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA;
						break;
					case 0x306:
						return Context3DBlendFactor.DESTINATION_COLOR;
						break;
					case 0x307:
						return Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR;
						break;
					default:
						throw new ArgumentError("unsupported blending function: " + value);
				}
			}
		}
	}
}
