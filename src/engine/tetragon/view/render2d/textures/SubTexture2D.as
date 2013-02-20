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
	import tetragon.view.render2d.core.VertexData2D;

	import flash.display3D.textures.TextureBase;
	import flash.geom.Point;
	import flash.geom.Rectangle;


	/**
	 * A SubTexture represents a section of another texture. This is achieved solely by 
	 * manipulation of texture coordinates, making the class very efficient. 
	 *
	 * <p><em>Note that it is OK to create subtextures of subtextures.</em></p>
	 */
	public class SubTexture2D extends Texture2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _parent:Texture2D;
		private var _clipping:Rectangle;
		private var _rootClipping:Rectangle;
		private var _ownsParent:Boolean;
		
		/** Helper object. */
		private static var _texCoords:Point = new Point();
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new subtexture containing the specified region (in points) of a parent 
		 * texture. If 'ownsParent' is true, the parent texture will be disposed automatically
		 * when the subtexture is disposed.
		 * 
		 * @param parentTexture
		 * @param region
		 * @param ownsParent
		 */
		public function SubTexture2D(parentTexture:Texture2D, region:Rectangle,
			ownsParent:Boolean = false)
		{
			_parent = parentTexture;
			_ownsParent = ownsParent;
			
			setClipping(!region
				? new Rectangle(0, 0, 1, 1)
				: new Rectangle(region.x / parentTexture.width, region.y / parentTexture.height,
					region.width / parentTexture.width, region.height / parentTexture.height)
			);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes the parent texture if this texture owns it.
		 */
		public override function dispose():void
		{
			if (_ownsParent) _parent.dispose();
			super.dispose();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function adjustVertexData(vertexData:VertexData2D, vertexID:int,
			count:int):void
		{
			super.adjustVertexData(vertexData, vertexID, count);
			
			var clipX:Number = _rootClipping.x;
			var clipY:Number = _rootClipping.y;
			var clipWidth:Number = _rootClipping.width;
			var clipHeight:Number = _rootClipping.height;
			var endIndex:int = vertexID + count;
			
			for (var i:int = vertexID; i < endIndex; ++i)
			{
				vertexData.getTexCoords(i, _texCoords);
				vertexData.setTexCoords(i, clipX + _texCoords.x * clipWidth,
					clipY + _texCoords.y * clipHeight);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/** The texture which the subtexture is based on. */
		public function get parent():Texture2D
		{
			return _parent;
		}
		
		
		/** Indicates if the parent texture is disposed when this object is disposed. */
		public function get ownsParent():Boolean
		{
			return _ownsParent;
		}
		
		
		/** The clipping rectangle, which is the region provided on initialization 
		 *  scaled into [0.0, 1.0]. */
		public function get clipping():Rectangle
		{
			return _clipping.clone();
		}
		
		
		/** @inheritDoc */
		public override function get base():TextureBase
		{
			return _parent.base;
		}
		
		
		/** @inheritDoc */
		public override function get root():ConcreteTexture2D
		{
			return _parent.root;
		}


		/** @inheritDoc */
		public override function get format():String
		{
			return _parent.format;
		}


		/** @inheritDoc */
		public override function get width():Number
		{
			return _parent.width * _clipping.width;
		}


		/** @inheritDoc */
		public override function get height():Number
		{
			return _parent.height * _clipping.height;
		}


		/** @inheritDoc */
		public override function get nativeWidth():Number
		{
			return _parent.nativeWidth * _clipping.width;
		}


		/** @inheritDoc */
		public override function get nativeHeight():Number
		{
			return _parent.nativeHeight * _clipping.height;
		}


		/** @inheritDoc */
		public override function get mipMapping():Boolean
		{
			return _parent.mipMapping;
		}


		/** @inheritDoc */
		public override function get premultipliedAlpha():Boolean
		{
			return _parent.premultipliedAlpha;
		}


		/** @inheritDoc */
		public override function get scale():Number
		{
			return _parent.scale;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function setClipping(value:Rectangle):void
		{
			_clipping = value;
			_rootClipping = value.clone();

			var parentTexture:SubTexture2D = _parent as SubTexture2D;
			while (parentTexture)
			{
				var parentClipping:Rectangle = parentTexture._clipping;
				_rootClipping.x = parentClipping.x + _rootClipping.x * parentClipping.width;
				_rootClipping.y = parentClipping.y + _rootClipping.y * parentClipping.height;
				_rootClipping.width *= parentClipping.width;
				_rootClipping.height *= parentClipping.height;
				parentTexture = parentTexture._parent as SubTexture2D;
			}
		}
	}
}
