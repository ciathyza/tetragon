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
	import tetragon.view.ui.controls.LabelButton;

	import flash.events.MouseEvent;

	[Style(name="upSkin", type="Class")]
	[Style(name="downSkin", type="Class")]
	[Style(name="overSkin", type="Class")]
	[Style(name="disabledSkin", type="Class")]
	[Style(name="selectedDisabledSkin", type="Class")]
	[Style(name="selectedUpSkin", type="Class")]
	[Style(name="selectedDownSkin", type="Class")]
	[Style(name="selectedOverSkin", type="Class")]
	[Style(name="textFormat", type="flash.text.TextFormat")]
	[Style(name="disabledTextFormat", type="flash.text.TextFormat")]
	[Style(name="textPadding", type="Number", format="Length")]

	
	/**
	 * The CellRenderer class defines methods and properties for list-based components
	 * to use to manipulate and display custom cell content in each of their rows. A
	 * customized cell can contain text, an existing component such as a CheckBox, or
	 * any class that you create. The list-based components that use this class include
	 * the List, DataGrid, TileList, and ComboBox components.
	 * 
	 * @see ICellRenderer
	 */
	public class CellRenderer extends LabelButton implements ICellRenderer
	{
		////////////////////////////////////////////////////////////////////////////////////////
		// Properties                                                                         //
		////////////////////////////////////////////////////////////////////////////////////////
		
		protected var _listData:ListData;
		protected var _data:Object;
		
		private static var defaultStyles:Object =
		{
			upSkin:					"CellRendererUpSkin",
			downSkin:				"CellRendererDownSkin",
			overSkin:				"CellRendererOverSkin",
			disabledSkin:			"CellRendererDisabledSkin",
			selectedDisabledSkin:	"CellRendererSelectedDisabledSkin",
			selectedUpSkin:			"CellRendererSelectedUpSkin",
			selectedDownSkin:		"CellRendererSelectedDownSkin",
			selectedOverSkin:		"CellRendererSelectedOverSkin",
			textFormat:				null,
			disabledTextFormat:		null,
			embedFonts:				null,
			textPadding:			5
		};
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Public Methods                                                                     //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Creates a new CellRenderer instance.
		 */
		public function CellRenderer():void
		{
			super();
			
			toggle = true;
			focusEnabled = false;
		}
		
		
		/**
		 * Specifies the dimensions at which the data should be rendered. These dimensions
		 * affect both the data and the cell that contains it; the cell renderer uses them
		 * to ensure that the data fits the cell and does not bleed into adjacent cells.
		 * 
		 * @param width The width of the object, in pixels.
		 * @param height The height of the object, in pixels.
		 */
		override public function setSize(width:Number, height:Number):void
		{
			super.setSize(width, height);
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Getters & Setters                                                                  //
		////////////////////////////////////////////////////////////////////////////////////////
		
		public static function get styleDefinition():Object
		{
			return defaultStyles;
		}
		
		
		public function get listData():ListData
		{
			return _listData;
		}
		public function set listData(v:ListData):void
		{
			_listData = v;
			label = _listData.label;
			setStyle("icon", _listData.icon);
		}
		
		
		public function get data():Object
		{
			return _data;
		}
		public function set data(v:Object):void
		{
			_data = v;
		}
		
		
		override public function get selected():Boolean
		{
			return super.selected;
		}
		override public function set selected(v:Boolean):void
		{
			super.selected = v;
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Event Handlers                                                                     //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * @private
		 */
		override protected function onToggleSelected(e:MouseEvent):void
		{
			/* don't set selected or dispatch change event. */
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Private Methods                                                                    //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * @private
		 */
		override protected function drawLayout():void
		{
			var textPadding:Number = Number(getStyleValue("textPadding"));
			var textFieldX:Number = 0;
			
			/* Align icon */
			if (_icon != null)
			{
				_icon.x = textPadding;
				_icon.y = Math.round((height - _icon.height) >> 1);
				textFieldX = _icon.width + textPadding;
			}
			
			/* Align text */
			if (label.length > 0)
			{
				_tf.visible = true;
				var textWidth:Number = Math.max(0, width - textFieldX - textPadding * 2);
				_tf.width = textWidth;
				_tf.height = _tf.textHeight + 4;
				_tf.x = textFieldX + textPadding;
				_tf.y = Math.round((height - _tf.height) >> 1);
			}
			else
			{
				_tf.visible = false;
			}
			
			/* Size background */
			_bg.width = width;
			_bg.height = height;
		}
	}
}
