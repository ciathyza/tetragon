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
package view.away3d
{
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.SphereGeometry;
	import away3d.utils.Cast;

	import tetragon.view.obsolete.Screen;

	import flash.display.BitmapData;
	import flash.geom.Vector3D;
	
	
	/**
	 * @author Hexagon
	 */
	public class Away3DTestScreen extends Screen
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const ID:String = "away3DTestScreen";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _view:View3D;
		private var _sphere:Mesh;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function start():void
		{
			super.start();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function update():void
		{
			super.update();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function reset():void
		{
			super.reset();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function stop():void
		{
			super.stop();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines whether the screen will unload all it's loaded resources once it is
		 * closed. You can override this getter and return false for screens where you don't
		 * want resources to be unloaded, .e.g. for a dedicated resource preload screen.
		 * 
		 * @default true
		 */
		override protected function get unload():Boolean
		{
			return true;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Invoked whenever the display stage is resized. By default this method calls the
		 * layoutChildren() method of the screen class. You can override it to replace
		 * this handler with custom code or to disabled it.
		 */
		override protected function onStageResize():void
		{
			super.onStageResize();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initializes the screen. Called right after instantiation. If you override this
		 * method you must call <code>super.init()</code> in your overriden method.
		 */
		override protected function setup():void
		{
			super.setup();
		}
		
		
		/**
		 * Registers resources for loading that are required for the screen.
		 * 
		 * <p>This is an abstract method. Override this method in your screen sub-class and
		 * register as many resources as you need for the screen. The resources are being
		 * preloaded before the screen is opened by the screen manager.</p>
		 * 
		 * @see tetragon.view.Screen#registerResource()
		 * 
		 * @example
		 * <pre>
		 *     registerResource("resource1");
		 *     registerResource("resource2");
		 * </pre>
		 */
		override protected function registerResources():void
		{
			registerResource("marsmap");
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			_view = new View3D();
			
			//_view.camera.z = -600;
			//_view.camera.y = 500;
			_view.camera.lookAt(new Vector3D());
			
			var b:BitmapData = resourceIndex.getImage("marsmap");
			
			_sphere = new Mesh(new SphereGeometry(800, 64, 64), new TextureMaterial(Cast.bitmapTexture(b)));
			_sphere.rotationZ = 90;
			_sphere.y = -800;
			_sphere.z = -800;
			
			_view.scene.addChild(_sphere);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerChildren():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void
		{
			addChild(_view);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addListeners():void
		{
			main.gameLoop.renderSignal.add(onRender);
		}


		private function onRender(ticks:uint, ms:uint, renderFPS:uint):void
		{
			_sphere.rotationY += 0.1;
			_view.render();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function removeListeners():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function executeBeforeStart():void
		{
			main.statsMonitor.toggle();
			main.gameLoop.start();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function updateDisplayText():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function layoutChildren():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function enableChildren():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function disableChildren():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function pauseChildren():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function unpauseChildren():void
		{
		}
	}
}
