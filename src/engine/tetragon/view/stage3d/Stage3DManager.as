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
package tetragon.view.stage3d
{
	import tetragon.debug.Log;

	import flash.display.Stage;
	
	
	/**
	 * The Stage3DManager handles management for Stage3D objects. Stage3D objects should
	 * not be requested directly, but are exposed by a Stage3DProxy.
	 */
	public class Stage3DManager
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _stage:Stage;
		private var _stageProxies:Vector.<Stage3DProxy>;
		private var _numStageProxies:uint = 0;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new Stage3DManager class.
		 * 
		 * @param stage The Stage object that contains the Stage3D objects to be managed.
		 */
		public function Stage3DManager(stage:Stage)
		{
			_stage = stage;
			if (!_stageProxies)
			{
				_stageProxies = new Vector.<Stage3DProxy>(_stage.stage3Ds.length, true);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Requests the Stage3DProxy for the given index.
		 * 
		 * @param index The index of the requested Stage3D.
		 * @param forceSoftware Whether to force software mode even if hardware
		 *            acceleration is available.
		 * @return The Stage3DProxy for the given index.
		 */
		public function getStage3DProxy(index:uint, forceSoftware:Boolean = false):Stage3DProxy
		{
			if (!_stageProxies[index])
			{
				_numStageProxies++;
				_stageProxies[index] = new Stage3DProxy(index, _stage.stage3Ds[index], this,
					forceSoftware);
			}
			return _stageProxies[index];
		}
		
		
		/**
		 * Get the next available stage3DProxy. An error is thrown if there are no
		 * Stage3DProxies available
		 * 
		 * @param forceSoftware Whether to force software mode even if hardware
		 *            acceleration is available.
		 * @return The allocated stage3DProxy
		 */
		public function getFreeStage3DProxy(forceSoftware:Boolean = false):Stage3DProxy
		{
			var i:uint;
			var len:uint = _stageProxies.length;
			
			while (i < len)
			{
				if (!_stageProxies[i])
				{
					getStage3DProxy(i, forceSoftware);
					_stageProxies[i].width = _stage.stageWidth;
					_stageProxies[i].height = _stage.stageHeight;
					return _stageProxies[i];
				}
				++i;
			}
			
			Log.fatal("getFreeStage3DProxy:: Too many Stage3D instances used!", this);
			return null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Checks if a new stage3DProxy can be created and managed by the class.
		 */
		public function get hasFreeStage3DProxy():Boolean
		{
			return _numStageProxies < _stageProxies.length ? true : false;
		}
		
		
		/**
		 * Returns the amount of stage3DProxy objects that can be created and managed by the class.
		 */
		public function get numProxySlotsFree():uint
		{
			return _stageProxies.length - _numStageProxies;
		}


		/**
		 * Returns the amount of Stage3DProxy objects currently managed by the class.
		 */
		public function get numProxySlotsUsed():uint
		{
			return _numStageProxies;
		}


		/**
		 * Returns the maximum amount of Stage3DProxy objects that can be managed by the class.
		 */
		public function get numProxySlotsTotal():uint
		{
			return _stageProxies.length;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Internal
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Removes a Stage3DProxy from the manager.
		 * @private
		 * 
		 * @param stage3DProxy
		 */
		internal function removeStage3DProxy(stage3DProxy:Stage3DProxy):void
		{
			_numStageProxies--;
			_stageProxies[stage3DProxy.stage3DIndex] = null;
		}
	}
}
