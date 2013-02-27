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
package tetragon.view.render.buffers
{
	import tetragon.Main;
	import tetragon.debug.Log;
	import tetragon.view.stage3d.Stage3DEvent;
	import tetragon.view.stage3d.Stage3DProxy;

	import com.hexagonstar.util.agal.AGALMiniAssembler;

	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	
	
	/**
	 * HardwareRenderBuffer class
	 *
	 * @author Hexagon
	 */
	public class HardwareRenderBuffer
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _width:int;
		private var _height:int;
		
		private var _stage3DProxy:Stage3DProxy;
		private var _stage3D:Stage3D;
		private var _context:Context3D;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function HardwareRenderBuffer(width:int, height:int, color:uint = 0x000022)
		{
			_width = width;
			_height = height;
			
			_stage3DProxy = Main.instance.stage3DManager.getFreeStage3DProxy();
			_stage3DProxy.antiAlias = 0;
			_stage3DProxy.color = color;
			_stage3DProxy.width = width;
			_stage3DProxy.height = height;
			_stage3D = _stage3DProxy.stage3D;
			_stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContext3DCreated);
			_stage3DProxy.requestContext3D();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public function render():void
		{
			_stage3DProxy.clear();
			
			// vertex position to attribute register 0
			_context.setVertexBufferAt(0, vertexbuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			// color to attribute register 1
			_context.setVertexBufferAt(1, vertexbuffer, 3, Context3DVertexBufferFormat.FLOAT_3);
			// assign shader program
			_context.setProgram(program);
			var m:Matrix3D = new Matrix3D();
			//m.appendRotation(getTimer() / 40, Vector3D.Z_AXIS);
			_context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, m, true);
			_context.drawTriangles(indexbuffer);
			
			_stage3DProxy.present();
		}
		
		
		/**
		 * Disposes the class.
		 */
		public function dispose():void
		{
			_stage3DProxy.removeEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContext3DCreated);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onContext3DCreated(e:Stage3DEvent):void
		{
			_context = _stage3D.context3D;
			Log.debug("Context3D Created!", this);
			test();
		}
		
		
		protected var vertexbuffer:VertexBuffer3D;
		protected var indexbuffer:IndexBuffer3D;
		private var program:Program3D;
		
		
		private function test():void
		{
			var vertices:Vector.<Number> = Vector.<Number>([
				// x, y, z, r, g, b
				-0.3, -0.3, 0, 1, 0, 0,
				-0.3,  0.3, 0, 0, 1, 0,
				 0.3,  0.3, 0, 0, 0, 1]);
			
			// Create VertexBuffer3D. 3 vertices, of 6 Numbers each
			vertexbuffer = _context.createVertexBuffer(3, 6);
			// Upload VertexBuffer3D to GPU. Offset 0, 3 vertices
			vertexbuffer.uploadFromVector(vertices, 0, 3);
			
			var indices:Vector.<uint> = Vector.<uint>([0, 1, 2]);
			// Create IndexBuffer3D. Total of 3 indices. 1 triangle of 3 vertices
			indexbuffer = _context.createIndexBuffer(3);
			// Upload IndexBuffer3D to GPU. Offset 0, count 3
			indexbuffer.uploadFromVector(indices, 0, 3);
			
			var agal:AGALMiniAssembler = new AGALMiniAssembler();
			agal.assemble(Context3DProgramType.VERTEX,
				  "m44 op, va0, vc0\n"		// pos to clipspace
				+ "mov v0, va1       "		// copy color
			);
			
			var fragmentShaderAssembler:AGALMiniAssembler= new AGALMiniAssembler();
			fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT,
				"mov oc, v0 "
			);
			
			program = _context.createProgram();
			program.upload(agal.agalcode, fragmentShaderAssembler.agalcode);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
	}
}
