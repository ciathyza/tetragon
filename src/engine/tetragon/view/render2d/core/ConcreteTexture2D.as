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
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.utils.ByteArray;
	import tetragon.view.render2d.core.events.Event2D;


	
	
	/**
	 * A ConcreteTexture2D wraps a Stage3D texture object, storing the properties of the
	 * texture.
	 */
	public class ConcreteTexture2D extends Texture2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _base:TextureBase;
		/** @private */
		private var _data:Object;
		
		/** @private */
		private var _width:int;
		/** @private */
		private var _height:int;
		
		/** @private */
		private var _mipMapping:Boolean;
		/** @private */
		private var _pma:Boolean;
		/** @private */
		private var _ort:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a ConcreteTexture2D object from a TextureBase, storing information about
		 * size, mip-mapping, and if the channels contain premultiplied alpha values.
		 * 
		 * @param base
		 * @param width
		 * @param height
		 * @param mipMapping
		 * @param premultipliedAlpha
		 * @param optimizedForRenderTexture
		 */
		public function ConcreteTexture2D(base:TextureBase, width:int, height:int,
			mipMapping:Boolean, premultipliedAlpha:Boolean,
			optimizedForRenderTexture:Boolean = false)
		{
			_base = base;
			_width = width;
			_height = height;
			_mipMapping = mipMapping;
			_pma = premultipliedAlpha;
			_ort = optimizedForRenderTexture;
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
			restoreOnLostContext(null);
			/* removes event listener & data reference */
			super.dispose();
		}
		
		
		/**
		 * Instructs this instance to restore its base texture when the context is lost.
		 * 'data' can be either BitmapData or a ByteArray with ATF data.
		 * 
		 * @param data
		 */
		public function restoreOnLostContext(data:Object):void
		{
			if (!_data && data)
				Render2D.current.addEventListener(Event2D.CONTEXT3D_CREATE, onContext3DCreated);
			if (!data)
				Render2D.current.removeEventListener(Event2D.CONTEXT3D_CREATE, onContext3DCreated);
			_data = data;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Indicates if the base texture was optimized for being used in a render texture.
		 */
		public function get optimizedForRenderTexture():Boolean
		{
			return _ort;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function get base():TextureBase
		{
			return _base;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function get width():Number
		{
			return _width;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function get height():Number
		{
			return _height;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function get mipMapping():Boolean
		{
			return _mipMapping;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function get premultipliedAlpha():Boolean
		{
			return _pma;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onContext3DCreated(e:Event2D):void
		{
			var c:Context3D = Render2D.context;
			var bd:BitmapData = _data as BitmapData;
			var b:ByteArray = _data as ByteArray;
			var t:Texture;
			
			if (bd)
			{
				t = c.createTexture(_width, _height, Context3DTextureFormat.BGRA, _ort);
				Texture2D.uploadBitmapData(t, bd, _mipMapping);
			}
			else if (b)
			{
				var format:String = b[6] == 2 ? Context3DTextureFormat.COMPRESSED : Context3DTextureFormat.BGRA;
				t = c.createTexture(_width, _height, format, _ort);
				Texture2D.uploadAtfData(t, b);
			}

			_base = t;
		}
	}
}
