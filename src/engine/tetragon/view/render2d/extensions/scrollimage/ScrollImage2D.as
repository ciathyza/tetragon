/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * Tetragon : Game Engine for multi-platform ActionScript projects.
 * http://www.tetragonengine.com/
 * Copyright (c) The respective Copyright Holder (see LICENSE).
 * 
 * Permission is hereby granted, to any person obtaining a copy of this software
 * and associated documentation files (the "Software") under the rules defined in
 * the license found at http://www.tetragonengine.com/license/ or the LICENSE
 * file included within this distribution.
 * 
 * The above copyright notice and this permission notice must be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND. THE COPYRIGHT
 * HOLDER AND ITS LICENSORS DISCLAIM ALL WARRANTIES AND CONDITIONS, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO ANY IMPLIED WARRANTIES AND CONDITIONS OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT, AND ANY
 * WARRANTIES AND CONDITIONS ARISING OUT OF COURSE OF DEALING OR USAGE OF TRADE.
 * NO ADVICE OR INFORMATION, WHETHER ORAL OR WRITTEN, OBTAINED FROM THE COPYRIGHT
 * HOLDER OR ELSEWHERE WILL CREATE ANY WARRANTY OR CONDITION NOT EXPRESSLY STATED
 * IN THIS AGREEMENT.
 */
package tetragon.view.render2d.extensions.scrollimage
{
	import tetragon.view.render2d.core.RenderSupport2D;
	import tetragon.view.render2d.core.VertexData2D;
	import tetragon.view.render2d.display.DisplayObject2D;
	import tetragon.view.render2d.textures.Texture2D;
	import tetragon.view.render2d.textures.TextureSmoothing2D;

	import com.hexagonstar.constants.TextureSmoothing;
	import com.hexagonstar.util.agal.AGALMiniAssembler;

	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;


	/**
	 * Display object with tile texture, may contain 16 TileTexture objects
	 * 
	 * CURRENT LIMITATIONS:
	 * - The parallax of a layer cannot be a fraction (e.g. 0.5). It must be a full number
	 * (e.g. 1, 2, 3, 4...).
	 * - Layers must have all the same size. (no texture frames are supported).
	 */
	public class ScrollImage2D extends DisplayObject2D
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		private static const MAX_LAYERS_AMOUNT:uint = 16;
		// 0,1,2,3 - transform matrix, 4 - alpha, must start from vc5
		private static const REGISTER:uint = 5;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The x offet of the tiles.
		 */
		public var tilesOffsetX:Number = 0.0;
		
		/**
		 * The y offet of the tiles.
		 */
		public var tilesOffsetY:Number = 0.0;
		
		/**
		 * The rotation of the tiles in radians.
		 */
		public var tilesRotation:Number = 0.0;
		
		/**
		 * The horizontal scale factor. '1' means no scale, negative values flip the tiles.
		 */
		public var tilesScaleX:Number = 1.0;
		
		/**
		 * The vertical scale factor. '1' means no scale, negative values flip the tiles.
		 */
		public var tilesScaleY:Number = 1.0;
		
		/**
		 * Used for uniform tile-scaling.
		 */
		private var _tilesScale:Number = 1.0;
		
		// vertex data
		private var _vertexData:VertexData2D;
		private var _vertexBuffer:VertexBuffer3D;
		
		// ShaderConstand and clipping index data
		private var _extraBuffer:VertexBuffer3D;
		private var _extraData:Vector.<Number>;
		
		// index data
		private var _indexData:Vector.<uint>;
		private var _indexBuffer:IndexBuffer3D;
		private var _texture:Texture2D;
		
		// properties
		private var _smoothing:String = TextureSmoothing2D.NONE;
		private var _baseProgram:String;
		
		private var _canvasWidth:Number;
		private var _canvasHeight:Number;
		private var _textureWidth:Number = 0.0;
		private var _textureHeight:Number = 0.0;
		private var _tempWidth:Number;
		private var _tempHeight:Number;
		private var _maxU:Number;
		private var _maxV:Number;
		private var _color:uint;
		
		private var _layers:Vector.<ScrollTile2D>;
		private var _layersMatrix:Vector.<Matrix3D>;
		private var _mainLayer:ScrollTile2D;
		private var _layerVertexData:VertexData2D;
		
		private var _mainLayerWidth:int;
		private var _mainLayerHeight:int;
		
		private var _tilesPivotX:Number = 0.0;
		private var _tilesPivotY:Number = 0.0;
		private var _textureRatio:Number;
		
		private var _syncRequired:Boolean;
		private var _useBaseTexture:Boolean;
		private var _premultipliedAlpha:Boolean;
		private var _mipMapping:Boolean;
		private var _freeze:Boolean;
		private var _parallax:Boolean = true;
		private var _parallaxOffset:Boolean = true;
		private var _parallaxScale:Boolean = true;
		
		// helper objects (to avoid temporary objects)
		private var _renderColorAlpha:Vector.<Number>;
		private var _matrix:Matrix3D;
		private static var _programNameCache:Dictionary = new Dictionary();
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates an object with tiled texture. Default without mipMapping to avoid some
		 * borders anrtefacts. Property use BaseTexture determinant using whole texture
		 * (without UV clipping) - use it for better performance special on mobile.
		 * 
		 * @param width
		 * @param height
		 * @param useBaseTexture
		 */
		public function ScrollImage2D(width:Number, height:Number, useBaseTexture:Boolean = false)
		{
			_layers = new Vector.<ScrollTile2D>();
			_layersMatrix = new Vector.<Matrix3D>();
			_renderColorAlpha = new <Number>[1.0, 1.0, 1.0, 1.0];
			_matrix = new Matrix3D();
			
			_useBaseTexture = useBaseTexture;
			// base program without tint/alpha/mipmaps and with blinear smoothing
			_baseProgram = getImageProgramName(false, _mipMapping, _smoothing);
			_canvasWidth = width;
			_canvasHeight = height;
			
			resetVertices();
			registerPrograms();
			
			color = 0xFFFFFF;
			
			// handle lost context
			render2D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Add layer on the top.
		 * @param layer
		 * @return
		 */
		public function addLayer(layer:ScrollTile2D):ScrollTile2D
		{
			return addLayerAt(layer, numLayers + 1);
		}
		
		
		/**
		 * Add layer at index.
		 * @param layer
		 * @param index
		 * @return
		 */
		public function addLayerAt(layer:ScrollTile2D, index:int):ScrollTile2D
		{
			if (index > numLayers) index = numLayers + 1;

			if (_layers.length == 0 && _layers.length < MAX_LAYERS_AMOUNT)
			{
				mainLayerSetup(layer);
			}
			else if (_texture != layer.baseTexture)
			{
				throw new Error("Layers must use this same texture.");
			}
			else if ( _layers.length >= MAX_LAYERS_AMOUNT )
			{
				throw new Error("Maximum layers amount has been reached! Max is " + MAX_LAYERS_AMOUNT);
			}

			_layers.splice(index, 0, layer);
			_layersMatrix.splice(index, 0, new Matrix3D());

			updateMesh();
			return layer;
		}


		/**
		 * Remove layer at index.
		 * @param id
		 */
		public function removeLayerAt(id:int):void
		{
			if (_layers.length && id < _layers.length)
			{
				_layers.splice(id, 1);
				_layersMatrix.splice(id, 1);
				if (_layers.length) updateMesh();
				else reset();
			}
		}


		/**
		 * Remove all layers.
		 * @param dispose
		 */
		public function removeAll(dispose:Boolean = false):void
		{
			if (dispose)
			{
				for (var i:int = 0; i < _layers.length; i++)
				{
					_layers[i].dispose();
				}
			}
			reset();
		}


		/**
		 * Return layer at index.
		 * @param layer
		 */
		public function getLayerAt(index:uint):ScrollTile2D
		{
			if (index < _layers.length) return _layers[index];
			return null;
		}
		
		
		/**
		 * Returns a rectangle that completely encloses the object as it appears in another coordinate system.
		 * @param targetSpace
		 * @param resultRect
		 * @return
		 */
		public override function getBounds(targetSpace:DisplayObject2D, resultRect:Rectangle = null):Rectangle
		{
			if (resultRect == null) resultRect = new Rectangle();
			var transformationMatrix:Matrix = getTransformationMatrix(targetSpace);
			return _vertexData.getBounds(transformationMatrix, 0, -1, resultRect);
		}
		
		
		/**
		 * Renders the object with the help of a 'support' object and with the accumulated alpha of its parent object.
		 * @param support
		 * @param alpha
		 */
		public override function render(support:RenderSupport2D, alpha:Number):void
		{
			if ( _layers.length == 0) return;
			
			support.raiseDrawCount();
			support.finishQuadBatch();
			if (_syncRequired) syncBuffers();
			support.applyBlendMode(_premultipliedAlpha);
			if (_texture) context3D.setTextureAt(0, _texture.base);
			
			// set buffers
			// position
			// UV
			// vc for color and transform registers
			// clipping
			context3D.setVertexBufferAt(0, _vertexBuffer, VertexData2D.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			context3D.setVertexBufferAt(1, _vertexBuffer, VertexData2D.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			context3D.setVertexBufferAt(2, _extraBuffer, VertexData2D.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_3);
			context3D.setVertexBufferAt(3, _extraBuffer, 3, Context3DVertexBufferFormat.FLOAT_4);
			
			// set alpha
			_renderColorAlpha[3] = this.alpha * alpha;
			
			// set object and layers data
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, support.mvpMatrix3D, true);
			context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, _renderColorAlpha, 1);
			
			var tintedlayer:Boolean = false;
			var layer:ScrollTile2D;
			
			for (var i:int = 0; i < _layers.length; i++)
			{
				layer = _layers[i];
				tintedlayer = tintedlayer || layer.color != 0xFFFFFF || layer.alpha != 1.0;
				_matrix = _freeze ? _layersMatrix[i] : calculateMatrix(layer, _layersMatrix[i]);
				context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, getColorRegister(i), layer.colorTrans, 1);
				context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, getTransRegister(i), _matrix, true);
			}
			
			// activate program (shader)
			var tinted:Boolean = (_renderColorAlpha[3] != 1.0) || color != 0xFFFFFF || tintedlayer;
			context3D.setProgram(render2D.getProgram(getImageProgramName(tinted, _mipMapping, _smoothing, _texture.format, _useBaseTexture)));
			
			// draw the object
			context3D.drawTriangles(_indexBuffer, 0, _indexData.length / 3);

			// reset buffers
			if (_texture)
			{
				context3D.setTextureAt(0, null);
			}

			context3D.setVertexBufferAt(0, null);
			context3D.setVertexBufferAt(1, null);
			context3D.setVertexBufferAt(2, null);
			context3D.setVertexBufferAt(3, null);
		}
		
		
		/**
		 * Disposes all resources of the display object.
		 */
		public override function dispose():void
		{
			render2D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			if (_vertexBuffer) _vertexBuffer.dispose();
			if (_indexBuffer) _indexBuffer.dispose();
			_layers = null;
			_layersMatrix = null;
			_texture = null;
			super.dispose();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Tint color.
		 */
		public function get color():uint
		{
			return _color;
		}
		public function set color(v:uint):void
		{
			_color = v;
			_renderColorAlpha[0] = ((_color >> 16) & 0xff) / 255.0;
			_renderColorAlpha[1] = ((_color >> 8) & 0xff) / 255.0;
			_renderColorAlpha[2] = (_color & 0xff) / 255.0;
		}
		
		
		public function get tilesScale():Number
		{
			return _tilesScale;
		}
		public function set tilesScale(v:Number):void
		{
			_tilesScale = tilesScaleX = tilesScaleY = v;
		}
		
		
		/**
		 * Canvas width in pixels.
		 */
		public function get canvasWidth():Number
		{
			return _canvasWidth;
		}
		public function set canvasWidth(v:Number):void
		{
			_canvasWidth = v;
			if (_mainLayer)
			{
				mainLayerSetup(_mainLayer);
				_syncRequired = true;
			}
		}
		
		
		/**
		 * Canvas height in pixels.
		 */
		public function get canvasHeight():Number
		{
			return _canvasHeight;
		}
		public function set canvasHeight(v:Number):void
		{
			_canvasHeight = v;
			if (_mainLayer)
			{
				mainLayerSetup(_mainLayer);
				_syncRequired = true;
			}
		}
		
		
		/**
		 * @inheritDocs
		 */
		override public function get width():Number
		{
			return numLayers == 0 ? super.width : 0;
		}
		override public function set width(v:Number):void
		{
			if (_textureWidth)
			{
				super.width = v;
				_tempWidth = 0;
			}
			else
			{
				_tempWidth = v;
			}
		}


		/**
		 * @inheritDocs
		 */
		override public function get height():Number
		{
			return numLayers == 0 ? super.height : 0;
		}
		override public function set height(v:Number):void
		{
			if (_textureHeight)
			{
				super.height = v;
				_tempHeight = 0;
			}
			else
			{
				_tempHeight = v;
			}
		}


		/**
		 * Texture used in object - from the layer on index 0.
		 */
		public function get texture():Texture2D
		{
			return _texture;
		}
		
		
		/**
		 * The x pivot for rotation and scale the tiles.
		 */
		public function get tilesPivotX():Number
		{
			return _tilesPivotX * _textureWidth;
		}
		public function set tilesPivotX(v:Number):void
		{
			_tilesPivotX = _textureWidth ? v / _textureWidth : 0;
		}


		/**
		 * The y pivot for rotation and scale the tiles.
		 */
		public function get tilesPivotY():Number
		{
			return _tilesPivotY * _textureHeight;
		}
		public function set tilesPivotY(v:Number):void
		{
			_tilesPivotY = _textureHeight ? v / _textureHeight : 0;
		}


		/**
		 * Determinate parlax for offset.
		 */
		public function get parallaxOffset():Boolean
		{
			return _parallaxOffset;
		}
		public function set parallaxOffset(v:Boolean):void
		{
			_parallaxOffset = v;
		}


		/**
		 * Determinate parlax for scale.
		 */
		public function get parallaxScale():Boolean
		{
			return _parallaxScale;
		}
		public function set parallaxScale(v:Boolean):void
		{
			_parallaxScale = v;
		}


		/**
		 * Determinate parlax for all transformations.
		 */
		public function get parallax():Boolean
		{
			return _parallax;
		}
		public function set parallax(v:Boolean):void
		{
			_parallax = v;
			parallaxOffset = v;
			parallaxScale = v;
		}


		/**
		 * Avoid all tiles transformations - for better performance matrixes are not calculate.
		 */
		public function get freeze():Boolean
		{
			return _freeze;
		}
		public function set freeze(v:Boolean):void
		{
			for (var i:int = 0; i < _layers.length; i++)
			{
				calculateMatrix(_layers[i], _layersMatrix[i]);
			}
			_freeze = v;
		}


		/**
		 * Return number of layers
		 */
		public function get numLayers():int
		{
			return _layers.length;
		}
		
		
		/**
		 * The smoothing filter that is used for the texture.
		 */
		public function get smoothing():String
		{
			return _smoothing;
		}
		public function set smoothing(v:String):void
		{
			_smoothing = v;
		}


		/**
		 * Determinate mipmapping for the texture - default set to false to avoid
		 * borders artefacts.
		 */
		public function get mipMapping():Boolean
		{
			return _mipMapping;
		}
		public function set mipMapping(v:Boolean):void
		{
			if (_texture) _mipMapping = v ? _texture.mipMapping : v;
			else _mipMapping = v;
		}
		
		
		public function get layerWidth():int
		{
			return _mainLayerWidth;
		}


		public function get layerHeight():int
		{
			return _mainLayerHeight;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Context created handler
		 * @param event
		 */
		private function onContextCreated(event:Event):void
		{
			// the old context was lost, so we create new buffers and shaders.
			createBuffers();
			registerPrograms();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Reset vertexData
		 */
		private function resetVertices():void
		{
			_vertexData = new VertexData2D(0);
			_indexData = new Vector.<uint>();
			_extraData = new Vector.<Number>();
		}
		
		
		/**
		 * Setup object property using first layer.
		 * @param layer
		 */
		private function mainLayerSetup(layer:ScrollTile2D):void
		{
			_mainLayer = layer;
			_mainLayerWidth = _mainLayer.width;
			_mainLayerHeight = _mainLayer.width;
			_texture = _mainLayer.baseTexture;
			_premultipliedAlpha = _texture.premultipliedAlpha;

			_textureWidth = _texture.width;
			_textureHeight = _texture.height;

			_textureRatio = _textureWidth / _textureHeight;

			_maxU = _canvasWidth / _textureWidth;
			_maxV = _canvasHeight / _textureHeight;

			if (_layerVertexData == null)
			{
				_layerVertexData = new VertexData2D(4);

				_layerVertexData.setPosition(0, 0, 0);
				_layerVertexData.setPosition(1, _canvasWidth, 0);
				_layerVertexData.setPosition(2, 0, _canvasHeight);
				_layerVertexData.setPosition(3, _canvasWidth, _canvasHeight);

				_layerVertexData.setTexCoords(0, 0, 0);
				_layerVertexData.setTexCoords(1, _maxU, 0);
				_layerVertexData.setTexCoords(2, 0, _maxV);
				_layerVertexData.setTexCoords(3, _maxU, _maxV);
			}
		}


		/**
		 * Update mesh
		 */
		private function updateMesh():void
		{
			if ( _mainLayer )
			{
				resetVertices();

				for (var i:int = 0; i < _layers.length; i++)
				{
					setupVertices(i, _layers[i]);
				}
				if ( _layers.length ) createBuffers();
			}
		}


		/**
		 * Reset all resources.
		 */
		private function reset():void
		{
			_layers = new Vector.<ScrollTile2D>();
			_layersMatrix = new Vector.<Matrix3D>();
			_mainLayer = null;
			_textureWidth = _textureHeight = 0;
			resetVertices();
		}
		
		
		/**
		 * Creates vertex for a layer.
		 * @param id
		 * @param layer
		 */
		private function setupVertices(id:int, layer:ScrollTile2D):void
		{
			_vertexData.append(_layerVertexData);

			_indexData[int(id * 6)] = id * 4;
			_indexData[int(id * 6 + 1)] = id * 4 + 1;
			_indexData[int(id * 6 + 2)] = id * 4 + 2;
			_indexData[int(id * 6 + 3)] = id * 4 + 1;
			_indexData[int(id * 6 + 4)] = id * 4 + 3;
			_indexData[int(id * 6 + 5)] = id * 4 + 2;

			var i:int = -1;
			while (++i < 4 )
			{
				_extraData.push(getColorRegister(id), getTransRegister(id), int(_premultipliedAlpha), layer.baseClipping.x, layer.baseClipping.y, layer.baseClipping.width, layer.baseClipping.height);
			}
		}


		/**
		 * Return next free color register number.
		 * @param id
		 * @return
		 */
		private function getColorRegister(id:uint):uint
		{
			return REGISTER + ( id * 5 );
		}


		/**
		 * Return next free transform register number.
		 * @param id
		 * @return
		 */
		private function getTransRegister(id:uint):uint
		{
			return REGISTER + ( id * 5 ) + 1;
		}


		/**
		 * Creates new vertex- and index-buffers and uploads our vertex- and index-data to those buffers.
		 */
		private function createBuffers():void
		{
			// check if width/height was set before vertex creation
			if ( _tempWidth ) width = _tempWidth;
			if ( _tempHeight ) height = _tempHeight;

			if (_vertexBuffer)
				_vertexBuffer.dispose();
			if (_indexBuffer)
				_indexBuffer.dispose();
			if (_extraBuffer)
				_extraBuffer.dispose();

			_vertexBuffer = context3D.createVertexBuffer(_vertexData.numVertices, VertexData2D.ELEMENTS_PER_VERTEX);
			_vertexBuffer.uploadFromVector(_vertexData.rawData, 0, _vertexData.numVertices);

			_extraBuffer = context3D.createVertexBuffer(_vertexData.numVertices, 7);
			_extraBuffer.uploadFromVector(_extraData, 0, _vertexData.numVertices);

			_indexBuffer = context3D.createIndexBuffer(_indexData.length);
			_indexBuffer.uploadFromVector(_indexData, 0, _indexData.length);
		}


		/**
		 * Uploads the raw data of all batched quads to the vertex buffer.
		 */
		private function syncBuffers():void
		{
			if (_vertexBuffer == null)
				createBuffers();
			else
			{
				_vertexBuffer.uploadFromVector(_vertexData.rawData, 0, _vertexData.numVertices);
				_syncRequired = false;
			}
		}


		/**
		 * Calculate matrix transform for a layer
		 * @param layer
		 * @param matrix
		 * @return
		 */
		private function calculateMatrix(layer:ScrollTile2D, matrix:Matrix3D):Matrix3D
		{
			var pOffset:Number = _parallaxOffset ? layer.parallax : 1.0;
			//var pScale:Number = _parallaxScale ? layer.parallax : 1.0;
			var pScale:Number = 1.0; // Tentative fix for scaling with parallax problem.
			var angle:Number = layer.rotation + tilesRotation;
			
			matrix.identity();
			matrix.prependTranslation(-_tilesPivotX, - _tilesPivotY, 0);
			
			// for no square ratio, scale to square
			if (_textureRatio != 1) matrix.appendScale(1, 1 / _textureRatio, 1);
			
			var xs:Number = 1 / (layer.scaleX / pScale) / tilesScaleX + 1 - pScale;
			var ys:Number = 1 / (layer.scaleY / pScale) / tilesScaleY + 1 - pScale;
			
			// Faster Math.abs
			xs = xs < 0 ? -xs : xs;
			ys = ys < 0 ? -ys : ys;
			
			matrix.appendScale(xs, ys, 1.0);
			matrix.appendRotation(- angle * 180 / Math.PI, Vector3D.Z_AXIS);
			
			// for no square ratio, unscale from square to orginal ratio
			if (_textureRatio != 1) matrix.appendScale(1, _textureRatio, 1);
			
			xs = _tilesPivotX - (layer.offsetX + tilesOffsetX) / _textureWidth * pOffset;
			ys = _tilesPivotY - (layer.offsetY + tilesOffsetY) / _textureHeight * pOffset;
			
			matrix.appendTranslation(xs, ys, 0);
			return matrix;
		}


		/**
		 * Register the programs
		 */
		private function registerPrograms():void
		{
			if (render2D.hasProgram(_baseProgram) ) return;
			// already registered

			// create vertex and fragment programs from assembly
			var agal:AGALMiniAssembler = RenderSupport2D.agal;

			var vertexProgramCode:String;
			var fragmentProgramCode:String;
			// va0 -> position
			// va1 -> UV
			// va2.x -> vc index for color
			// va2.y -> vc index for transformation
			// va2.z -> premultiplied alpha 1/0
			// va3 -> clipping
			// vc0 -> mvpMatrix (4 vectors, vc0 - vc3)
			// vc4 -> alpha and color

			// vc[va2.x] -> color and alpha for layer
			// vc[va2.y] -> matrix transform for layer

			// pass to fragment shader
			// v0 -> color
			// v1 -> uv
			// v2 -> x,y of start
			// v3 ->width, height and reciprocals
			for each (var useBase:Boolean in [true, false])
			{
				for each (var tinted:Boolean in [true, false])
				{
					vertexProgramCode = tinted ? "mov vt0, vc4 \n" + 						// store color in temp0 
					"mul vt0, vt0, vc[va2.x] \n" + 				// multiply color with alpha for layer and pass it to fragment shader 
					"pow vt1, vt0.w, va2.z \n" + 				// if mPremulitply == 0 alpha multiplayer == 1 
					"mul vt0.xyz, vt0.xyz, vt1.xxx \n" + 		// multiply color by alpha 
					"mov v0, vt0 \n" 							// pass it to fragment shader				
					: "mov v0, vc4 \n";
					// pass color to fragment shader

					vertexProgramCode += "mov vt2, va3 \n";
					// store in temp1 the tile clipping

					var clippingData:String = "mov v2, vt2 \n" +     						// pass the x and y of start 
					"mov v3.xy, vt2.zw \n" +   					// pass the width & height 
					"rcp v3.z, vt2.z \n" +   					// pass the reciprocals of width 
					"rcp v3.w, vt2.w \n";
					// pass the reciprocals of heigh

					vertexProgramCode += useBase ? '' : clippingData;
					vertexProgramCode += "m44 vt2, va1, vc[va2.y] \n" + 				// mutliply UV by transform matrix 
					"mov v1, vt2 \n" +  						// pass the uvs. 
					"m44 op, va0, vc0 \n";
					// 4x4 matrix transform to output space

					var vertexByteCode:ByteArray = agal.assemble(Context3DProgramType.VERTEX, vertexProgramCode);
					fragmentProgramCode = "mov ft0, v1 \n";
					// sotre UV`a to temp0

					var clippingUV:String = "mul ft0.xy, ft0.xy, v3.zw \n" + 			// multiply to larger number 
					"frc ft0.xy, ft0.xy \n" +					// keep the fraction of the large number 
					"mul ft0.xy, ft0.xy, v3.xy \n" + 			// multiply to smaller number 
					"add ft0.xy, ft0.xy, v2.xy \n";
					// add the start x & y of the tile

					fragmentProgramCode += useBase ? '' : clippingUV;

					fragmentProgramCode += "tex ft1, ft0, fs0 <???> \n";
					// sample texture 0

					fragmentProgramCode += tinted ? "mul oc, ft1, v0 \n"   						// multiply color with texel color and output
					: "mov oc, ft1 \n";
					// output

					var smoothingTypes:Array = [TextureSmoothing.NONE, TextureSmoothing.BILINEAR, TextureSmoothing.TRILINEAR];

					var formats:Array = [Context3DTextureFormat.BGRA, Context3DTextureFormat.COMPRESSED, "compressedAlpha"// use explicit string for compatibility
					];

					for each (var mipmap:Boolean in [true, false])
					{
						for each (var smoothing:String in smoothingTypes)
						{
							for each (var format:String in formats)
							{
								var options:Array = ["2d"];

								if (format == Context3DTextureFormat.COMPRESSED)
									options.push("dxt1");
								else if (format == "compressedAlpha")
									options.push("dxt5");

								if (smoothing == TextureSmoothing.NONE)
									options.push("nearest", mipmap ? "mipnearest" : "mipnone", "repeat");
								else if (smoothing == TextureSmoothing.BILINEAR)
									options.push("linear", mipmap ? "mipnearest" : "mipnone", "repeat");
								else
									options.push("linear", mipmap ? "miplinear" : "mipnone", "repeat");

								render2D.registerProgram(getImageProgramName(tinted, mipmap, smoothing, format, useBase),
									vertexByteCode,
									agal.assemble(Context3DProgramType.FRAGMENT, fragmentProgramCode.replace("???", options.join())));
							}
						}
					}
				}
			}
		}


		/**
		 * Return program name.
		 * @param tinted
		 * @param mipMap
		 * @param smoothing
		 * @param format
		 * @return
		 */
		private static function getImageProgramName(tinted:Boolean = false, mipMap:Boolean = false,
			smoothing:String = "bilinear", format:String = "bgra",
			useBaseTexture:Boolean = false):String
		{
			var bitField:uint = 0;
			
			if (tinted) bitField |= 1;
			if (mipMap) bitField |= 2;
			
			if (smoothing == TextureSmoothing.NONE) bitField |= 1 << 3;
			else if (smoothing == TextureSmoothing.TRILINEAR) bitField |= 1 << 4;
			
			if (format == Context3DTextureFormat.COMPRESSED) bitField |= 1 << 5;
			else if (format == Context3DTextureFormat.COMPRESSED_ALPHA) bitField |= 1 << 6;
			
			if (useBaseTexture) bitField |= 1 << 7;
			else bitField |= 1 << 8;
			
			var name:String = _programNameCache[bitField];
			if (name == null)
			{
				name = "SImage_i." + bitField.toString(16);
				_programNameCache[bitField] = name;
			}
			
			return name;
		}
	}
}
