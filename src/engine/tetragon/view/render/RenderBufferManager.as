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
package tetragon.view.render
{
	/**
	 * A class that manages render buffers. Use this class to create any render buffer
	 * that you want to use for rendering any graphical output onto a bitmap buffer,
	 * for example tilescroll views or 3D viewports. You can create and use as many
	 * render buffers as necessary.
	 */
	public final class RenderBufferManager
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _buffers:Object;
		/** @private */
		private var _bufferCount:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function RenderBufferManager()
		{
			_buffers = {};
			_bufferCount = 0;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new render buffer and returns it. If a buffer with the specified ID already
		 * exists, it is returned instead and no new buffer is created.
		 * 
		 * @param id
		 * @param width
		 * @param height
		 * @param transparent
		 * @param fillColor
		 * @return A RenderBuffer object.
		 */
		public function createBuffer(id:String, width:int, height:int, transparent:Boolean = true,
			fillColor:uint = 0x00000000):RenderBuffer
		{
			if (_buffers[id]) return _buffers[id];
			var b:RenderBuffer = new RenderBuffer(width, height, transparent, fillColor);
			_buffers[id] = b;
			_bufferCount++;
			return b;
		}
		
		
		/**
		 * Returns the render buffer of the specified ID or null.
		 */
		public function getBuffer(id:String):RenderBuffer
		{
			return _buffers[id];
		}
		
		
		/**
		 * Allows to resize an existing render buffer.
		 * 
		 * @param id
		 * @param width
		 * @param height
		 * @return true or false.
		 */
		public function resizeBuffer(id:String, width:int, height:int):Boolean
		{
			if (!_buffers[id]) return false;
			// TODO
			return false;
		}
		
		
		/**
		 * Removes and disposes an existing render buffer.
		 * 
		 * @param id The ID of the buffer to remove.
		 * @return true if the buffer was disposed and removed successfully, false if not
		 *         which only happens if no buffer with the ID was found.
		 */
		public function removeBuffer(id:String):Boolean
		{
			if (!_buffers[id]) return false;
			RenderBuffer(_buffers[id]).dispose();
			delete _buffers[id];
			_bufferCount--;
			return true;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Amount of render buffers that are currently in use.
		 */
		public function get bufferCount():int
		{
			return _bufferCount;
		}
	}
}
