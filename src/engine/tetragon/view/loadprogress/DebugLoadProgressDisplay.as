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
package tetragon.view.loadprogress
{
	import com.hexagonstar.util.filter.createOutlineFilter;

	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	
	/**
	 * A load progress display that displays extensive loading information.
	 * 
	 * @see tetragon.view.loadprogress.LoadProgressDisplay
	 * @see tetragon.view.loadprogress.BasicLoadProgressDisplay
	 */
	public class DebugLoadProgressDisplay extends LoadProgressDisplay
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _tf:TextField;
		/** @private */
		protected var _text:String;
		/** @private */
		protected var _backBuffer:String;
		/** @private */
		protected var _currentFilePath:String;
		/** @private */
		protected var _percentage:Number;
		/** @private */
		protected var _sAll:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @return true
		 */
		override public function get waitForUserInput():Boolean
		{
			return true;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		override protected function onReset():void
		{
			_text = "";
			_backBuffer = "";
			_sAll = "";
			_currentFilePath = null;
			_percentage = 0;
		}
		
		
		override protected function onUpdate():void
		{
			if (allComplete) return;
			if (progress)
			{
				_percentage = progress.ratioPercentage;
				_sAll = createProgressBar(_percentage) + " All ... " + _percentage + "%";
				if (_percentage < 100)
				{
					var s1:String = createProgressBar(progress.file.percentLoaded) + " loading \""
						+ progress.file.path + "\" ... " + int(progress.file.percentLoaded) + "%";
					var s2:String = s1 + "\n" + _sAll;
					
					if (progress.file.percentLoaded == 100)
					{
						_backBuffer += s1 + "\n";
						_text = _backBuffer + _sAll;
					}
					else
					{
						_text = _backBuffer + s2;
					}
				}
			}
			else if (allFailed)
			{
				_percentage = 100;
			}
			
			if (_percentage == 100) complete();
			
			_tf.text = "Loading screen \"" + screen.id + "\" (" + screen.resourceCount
				+ " resources) ...\n\n" + _text;
			_tf.scrollV = _tf.maxScrollV;
		}
		
		
		override protected function onComplete():void
		{
			if (allFailed)
			{
				_text = "ALL RESOURCES FAILED LOADING. SEE CONSOLE FOR DETAILS!\n\n";
			}
			else if (!allLoaded)
			{
				_text = _backBuffer + _sAll + "\n\nSOME RESOURCES FAILED LOADING. SEE CONSOLE FOR DETAILS!\n\nAll loading completed. ";
			}
			else
			{
				_text = _backBuffer + _sAll + "\n\nAll loading completed. ";
			}
			if (waitForUserInput)
			{
				_text += "Press mouse to continue.";
				screenManager.mouseSignal.addOnce(onMouseClick);
			}
		}
		
		
		/**
		 * @private
		 */
		private function onMouseClick(type:String, e:MouseEvent):void
		{
			userInputSignal.dispatch();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		override protected function setup():void
		{
			var format:TextFormat = new TextFormat("Terminalscope", 16, 0xFFFFFF);
			var filter:GlowFilter = createOutlineFilter(int(format.size));
			
			_tf = new TextField();
			_tf.antiAliasType = AntiAliasType.NORMAL;
			_tf.gridFitType = GridFitType.PIXEL;
			_tf.multiline = true;
			_tf.wordWrap = true;
			_tf.embedFonts = true;
			_tf.focusRect = false;
			_tf.selectable = false;
			_tf.width = (screenManager.screenWidth / screenManager.screenScale) - 20;
			_tf.height = (screenManager.screenHeight / screenManager.screenScale) - 20;
			//_tf.border = true;
			//_tf.borderColor = 0xFFFFFF;
			_tf.defaultTextFormat = format;
			_tf.filters = [filter];
			_tf.x = 10;
			_tf.y = 10;
			
			addChild(_tf);
		}
		
		
		private function createProgressBar(percentage:uint):String
		{
			var p:uint = percentage / 10;
			var s:String = "";
			for (var i:uint = 0; i < 10; i++)
			{
				if (i <= p) s += "\u2020";
				else s+= ".";
			}
			return "[" + s + "]";
		}
	}
}
