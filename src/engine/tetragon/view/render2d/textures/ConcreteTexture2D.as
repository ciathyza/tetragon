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
	import tetragon.view.render2d.events.Event2D;

	import flash.display.BitmapData;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.TextureBase;
	
	
	/**
	 * A ConcreteTexture wraps a Stage3D texture object, storing the properties of the texture.
	 */
	public class ConcreteTexture2D extends Texture2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _base:TextureBase;
		private var _format:String;
		private var _width:int;
		private var _height:int;
		private var _mipMapping:Boolean;
		private var _premultipliedAlpha:Boolean;
		private var _optimizedForRenderTexture:Boolean;
		private var _data:Object;
		private var _scale:Number;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a ConcreteTexture object from a TextureBase, storing information about size,
		 * mip-mapping, and if the channels contain premultiplied alpha values.
		 * 
		 * @param base
		 * @param format
		 * @param width
		 * @param height
		 * @param mipMapping
		 * @param premultipliedAlpha
		 * @param optimizedForRenderTexture
		 * @param scale
		 */
		public function ConcreteTexture2D(base:TextureBase, format:String, width:int, height:int,
			mipMapping:Boolean, premultipliedAlpha:Boolean,
			optimizedForRenderTexture:Boolean = false, scale:Number = 1.0)
		{
			_scale = scale <= 0.0 ? 1.0 : scale;
			_base = base;
			_format = format;
			_width = width;
			_height = height;
			_mipMapping = mipMapping;
			_premultipliedAlpha = premultipliedAlpha;
			_optimizedForRenderTexture = optimizedForRenderTexture;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes the TextureBase object.
		 */
		public override function dispose():void
		{
			if (_base) _base.dispose();
			restoreOnLostContext(null); // removes event listener & data reference
			super.dispose();
		}
		
		
		// texture backup (context lost)
		
		/**
		 * Instructs this instance to restore its base texture when the context is lost. 'data' 
		 * can be either BitmapData or a ByteArray with ATF data.
		 * 
		 * @param data
		 */
		public function restoreOnLostContext(data:Object):void
		{
			if (!_data && data)
				render2D.addEventListener(Event2D.CONTEXT3D_CREATE, onContextCreated);
			else if (!data)
				render2D.removeEventListener(Event2D.CONTEXT3D_CREATE, onContextCreated);
			_data = data;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onContextCreated(e:Event2D):void
		{
			var bitmapData:BitmapData = _data as BitmapData;
			var atfData:ATFData2D = _data as ATFData2D;
			var nativeTexture:flash.display3D.textures.Texture;
			
			if (bitmapData)
			{
				nativeTexture = context3D.createTexture(_width, _height, Context3DTextureFormat.BGRA,
					_optimizedForRenderTexture);
				Texture2D.uploadBitmapData(nativeTexture, bitmapData, _mipMapping);
			}
			else if (atfData)
			{
				nativeTexture = context3D.createTexture(atfData.width, atfData.height, atfData.format,
					_optimizedForRenderTexture);
				Texture2D.uploadATFData(nativeTexture, atfData.data);
			}
			
			_base = nativeTexture;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/** Indicates if the base texture was optimized for being used in a render texture. */
		public function get optimizedForRenderTexture():Boolean
		{
			return _optimizedForRenderTexture;
		}


		/** @inheritDoc */
		public override function get base():TextureBase
		{
			return _base;
		}


		/** @inheritDoc */
		public override function get root():ConcreteTexture2D
		{
			return this;
		}


		/** @inheritDoc */
		public override function get format():String
		{
			return _format;
		}


		/** @inheritDoc */
		public override function get width():Number
		{
			return _width / _scale;
		}


		/** @inheritDoc */
		public override function get height():Number
		{
			return _height / _scale;
		}


		/** @inheritDoc */
		public override function get nativeWidth():Number
		{
			return _width;
		}


		/** @inheritDoc */
		public override function get nativeHeight():Number
		{
			return _height;
		}


		/** The scale factor, which influences width and height properties. */
		public override function get scale():Number
		{
			return _scale;
		}


		/** @inheritDoc */
		public override function get mipMapping():Boolean
		{
			return _mipMapping;
		}


		/** @inheritDoc */
		public override function get premultipliedAlpha():Boolean
		{
			return _premultipliedAlpha;
		}
	}
}
