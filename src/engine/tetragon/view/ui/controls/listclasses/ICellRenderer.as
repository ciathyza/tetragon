/*
 * hexagonlib - Multi-Purpose ActionScript 3 Library.
 *       __    __
 *    __/  \__/  \__    __
 *   /  \__/HEXAGON \__/  \
 *   \__/  \__/  LIBRARY _/
 *            \__/  \__/
 *
 * Licensed under the MIT License
 * 
 * Copyright (c) 2007-2008 Sascha Balkau / Hexagon Star Softworks
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package tetragon.view.ui.controls.listclasses 
{
	/**
	 * The ICellRenderer interface provides the methods and properties that a cell
	 * renderer requires. All user defined cell renderers should implement this interface.
	 * All user defined cell renderers must extend either the UIComponent class or a
	 * subclass of the UIComponent class.
	 *
	 * @see CellRenderer
	 */	
	public interface ICellRenderer 
	{		
		/**
		 * @private
		 */
		function set y(v:Number):void;

		
		/**
		 * @private
		 */
		function set x(v:Number):void;
		
		
		/**
		 * Gets or sets the list properties that are applied to the cell--for example,
		 * the <code>index</code> and <code>selected</code> values. These list properties
		 * are automatically updated after the cell is invalidated.
		 */
		function get listData():ListData;
		function set listData(v:ListData):void;
		
		
		/**
		 * Gets or sets an Object that represents the data that is associated with a
		 * component. When this value is set, the component data is stored and the
		 * containing component is invalidated. The invalidated component is then
		 * automatically redrawn. <p>The data property represents an object containing the
		 * item in the DataProvider that the cell represents. Typically, the data property
		 * contains standard properties, depending on the component type. In CellRenderer in
		 * a List or ComboBox component the data contains a label, icon, and data
		 * properties; a TileList: a label and a source property; a DataGrid cell contains
		 * values for each column. The data property can also contain user-specified data
		 * relevant to the specific cell. Users can extend a CellRenderer for a component to
		 * utilize different properties of the data in the rendering of the cell.</p>
		 * <p>Additionally, the <code>labelField</code>, <code>labelFunction</code>,
		 * <code>iconField</code>, <code>iconFunction</code>, <code>sourceField</code>, and
		 * <code>sourceFunction</code> elements can be used to specify which properties are
		 * used to draw the label, icon, and source respectively.</p>
		 */
		function get data():Object;
		function set data(v:Object):void;
		
		
		/**
		 * Gets or sets a Boolean value that indicates whether the
		 * current cell is selected. A value of <code>true</code> indicates
		 * that the current cell is selected; a value of <code>false</code> 
		 * indicates that it is not.
		 */
		function get selected():Boolean;
		function set selected(v:Boolean):void;
		
		
		/**
		 * Sets the size of the data according to the pixel values specified by
		 * the <code>width</code> and <code>height</code> parameters.
		 *
		 * @param width The width to display the cell renderer at, in pixels.
		 * @param height The height to display the cell renderer at, in pixels.
		 */
		function setSize(width:Number, height:Number):void;
		
		
		/**
		 * Sets the current cell to a specific mouse state.  This method 
		 * is necessary for the DataGrid to set the mouse state on an entire
		 * row when the user interacts with a single cell.
		 *
		 * @param state A string that specifies a mouse state, such as "up" or "over". 
		 */
		function setMouseState(state:String):void;
	}
}
