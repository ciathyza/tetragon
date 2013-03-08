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
	import tetragon.view.render2d.core.VertexData2D;

	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	
	/**
	 * Interface for simple, polygonal display objects that have four vertices.
	 * 
	 * @author Hexagon
	 */
	public interface IQuad2D
	{
		/**
		 * @inheritDoc
		 */
		function getBounds(targetSpace:DisplayObject2D, resultRect:Rectangle = null):Rectangle;
		
		
		/**
		 * Returns the color of a vertex at a certain index.
		 * 
		 * @param vertexID
		 */
		function getVertexColor(vertexID:int):uint;
		
		
		/**
		 * Sets the color of a vertex at a certain index.
		 * 
		 * @param vertexID
		 * @param color
		 */
		function setVertexColor(vertexID:int, color:uint):void;
		
		
		/**
		 * Returns the alpha value of a vertex at a certain index.
		 * 
		 * @param vertexID
		 */
		function getVertexAlpha(vertexID:int):Number;
		
		
		/**
		 * Sets the alpha value of a vertex at a certain index.
		 * 
		 * @param vertexID
		 * @param alpha
		 */
		function setVertexAlpha(vertexID:int, alpha:Number):void;
		
		
		/**
		 * Copies the raw vertex data to a VertexData instance.
		 * 
		 * @param targetData
		 * @param targetVertexID
		 */
		function copyVertexDataTo(targetData:VertexData2D, targetVertexID:int = 0):void;
		
		
		/**
		 * @inheritDoc
		 */
		function render(support:RenderSupport2D, parentAlpha:Number):void;
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the color of the quad, or of vertex 0 if vertices have different colors.
		 */
		function get color():uint;
		
		/**
		 * Sets the colors of all vertices to a certain value.
		 */
		function set color(v:uint):void;
		
		
		function get transformationMatrix():Matrix;
		function get blendMode():String;
		
		/**
		 * @inheritDoc
		 */
		function get alpha():Number;
		function set alpha(v:Number):void;
		
		
		/**
		 * Returns true if the quad (or any of its vertices) is non-white or non-opaque.
		 */
		function get tinted():Boolean;
	}
}
