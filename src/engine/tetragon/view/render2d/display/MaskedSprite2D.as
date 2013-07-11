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
	import tetragon.view.render2d.textures.RenderTexture2D;

	import flash.display3D.Context3DBlendFactor;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	
	/**
	 * MaskedSprite2D
	 */
	public class MaskedSprite2D extends Sprite2D
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		protected static const MASK_MODE_NORMAL:String = "mask";
		protected static const MASK_MODE_INVERTED:String = "maskinverted";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _mask:DisplayObject2D;
		protected var _renderTexture:RenderTexture2D;
		protected var _maskRenderTexture:RenderTexture2D;
		protected var _image:Image2D;
		protected var _maskImage:Image2D;
		
		protected var _scaleFactor:Number;
		
		protected var _superRenderFlag:Boolean;
		protected var _inverted:Boolean;
		protected var _animated:Boolean;
		protected var _maskRendered:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @param mask
		 * @param scaleFactor
		 * @param animated
		 */
		public function MaskedSprite2D(mask:DisplayObject2D = null, scaleFactor:Number = -1.0,
			animated:Boolean = false)
		{
			super();

			_animated = animated;
			_scaleFactor = scaleFactor;
			
			BlendMode2D.register(MASK_MODE_NORMAL, Context3DBlendFactor.ZERO, Context3DBlendFactor.SOURCE_ALPHA);
			BlendMode2D.register(MASK_MODE_INVERTED, Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			
			// Handle lost context. By using the conventional event, we can make a weak listener.
			// This avoids memory leaks when people forget to call "dispose" on the object.
			render2D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			
			this.mask = mask;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public override function render(support:RenderSupport2D, parentAlpha:Number):void
		{
			if (_animated || (!_animated && !_maskRendered))
			{
				if (_superRenderFlag || !_mask)
				{
					super.render(support, parentAlpha);
				}
				else
				{
					if (_mask)
					{
						_maskRenderTexture.draw(_mask);
						_renderTexture.drawBundled(drawRenderTextures);
						_image.render(support, parentAlpha);
						_maskRendered = true;
					}
				}
			}
			else
			{
				_image.render(support, parentAlpha);
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			clearRenderTextures();
			render2D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			super.dispose();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get animated():Boolean
		{
			return _animated;
		}
		public function set animated(v:Boolean):void
		{
			_animated = v;
		}
		
		
		public function get inverted():Boolean
		{
			return _inverted;
		}
		public function set inverted(v:Boolean):void
		{
			_inverted = v;
			refreshRenderTextures();
		}
		
		
		public function set mask(v:DisplayObject2D):void
		{
			// clean up existing mask if there is one
			if (_mask) _mask = null;

			if (v)
			{
				_mask = v;
				if (_mask.width == 0 || _mask.height == 0)
				{
					throw new Error("Mask must have dimensions. Current dimensions are "
						+ _mask.width + "x" + _mask.height + ".");
				}
				refreshRenderTextures();
			}
			else
			{
				clearRenderTextures();
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onContextCreated(e:Object):void
		{
			refreshRenderTextures();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function clearRenderTextures():void
		{
			// clean up old render textures and images
			if (_maskRenderTexture)
			{
				_maskRenderTexture.dispose();
			}

			if (_renderTexture)
			{
				_renderTexture.dispose();
			}

			if (_image)
			{
				_image.dispose();
			}

			if (_maskImage)
			{
				_maskImage.dispose();
			}
		}
		
		
		/**
		 * @private
		 */
		protected function refreshRenderTextures():void
		{
			if (_mask)
			{
				clearRenderTextures();
				
				_maskRenderTexture = new RenderTexture2D(_mask.width, _mask.height, false, _scaleFactor);
				_renderTexture = new RenderTexture2D(_mask.width, _mask.height, false, _scaleFactor);
				
				// create image with the new render texture
				_image = new Image2D(_renderTexture);

				// create image to blit the mask onto
				_maskImage = new Image2D(_maskRenderTexture);

				// set the blending mode to MASK (ZERO, SRC_ALPHA)
				if (_inverted)
				{
					_maskImage.blendMode = MASK_MODE_INVERTED;
				}
				else
				{
					_maskImage.blendMode = MASK_MODE_NORMAL;
				}
			}
			_maskRendered = false;
		}


		/**
		 * @private
		 */
		protected function drawRenderTextures():void
		{
			// undo scaling and positioning temporarily because its already applied in this execution stack
			var matrix:Matrix = transformationMatrix.clone();

			transformationMatrix = new Matrix();
			_superRenderFlag = true;
			_renderTexture.draw(this);
			_superRenderFlag = false;

			transformationMatrix = matrix;
			_renderTexture.draw(_maskImage);
		}
	}
}
