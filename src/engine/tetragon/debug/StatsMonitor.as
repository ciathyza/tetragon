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
package tetragon.debug
{
	import lib.fonts.TerminalstatsFont;

	import tetragon.Main;
	import tetragon.core.GameLoop;
	import tetragon.data.Config;
	import tetragon.util.ui.createTextField;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	
	public class StatsMonitor extends Sprite
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private const MIN:Function = Math.min;
		/** @private */
		private const SQRT:Function = Math.sqrt;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _config:Config;
		/** @private */
		private var _stage:Stage;
		/** @private */
		private var _gameLoop:GameLoop;
		
		/** @private */
		private var _container:DisplayObjectContainer;
		/** @private */
		private var _rectangle:Rectangle;
		/** @private */
		private var _statsSection:Sprite;
		/** @private */
		private var _graphSection:Bitmap;
		/** @private */
		private var _graphBuffer:BitmapData;
		
		/** @private */
		private var _fpsTF:TextField;
		/** @private */
		private var _mem1TF:TextField;
		/** @private */
		private var _mem2TF:TextField;
		/** @private */
		private var _mem3TF:TextField;
		/** @private */
		private var _mem4TF:TextField;
		/** @private */
		private var _etc1TF:TextField;
		/** @private */
		private var _etc2TF:TextField;
		/** @private */
		private var _etc3TF:TextField;
		/** @private */
		private var _etc4TF:TextField;
		
		/** @private */
		private var _colorBg:uint;
		/** @private */
		private var _colorFPS:uint;
		/** @private */
		private var _colorMem:uint;
		/** @private */
		private var _colorMax:uint;
		/** @private */
		private var _colorPRC:uint;
		/** @private */
		private var _colorGC:uint;
		/** @private */
		private var _colorEtc1:uint;
		/** @private */
		private var _colorEtc2:uint;
		/** @private */
		private var _colorEtc3:uint;
		/** @private */
		private var _colorEtc4:uint;
		
		/** @private */
		private var _prevTime:uint;
		/** @private */
		private var _last:uint;
		/** @private */
		private var _frames:uint;
		/** @private */
		private var _statsDelay:uint;
		
		/** @private */
		private var _glFPS:uint;
		/** @private */
		private var _glTicks:uint;
		/** @private */
		private var _glRenderMS:uint;
		
		/** @private */
		private var _stageFPS:uint;
		/** @private */
		private var _stageMS:uint;
		
		/** @private */
		private var _renderFPS:uint;
		
		/** @private */
		private var _mem:Number;
		/** @private */
		private var _memMax:Number;
		/** @private */
		private var _memPRC:Number;
		/** @private */
		private var _memGC:Number;
		
		/** @private */
		private var _active:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function StatsMonitor(container:DisplayObjectContainer)
		{
			var main:Main = Main.instance;
			_container = container;
			_config = main.registry.config;
			_stage = main.stage;
			
			main.keyInputManager.assignEngineKey("toggleStatsMonitor", toggle);
			main.keyInputManager.assignEngineKey("toggleStatsMonitorPosition", togglePosition);
			
			if (_config.getBoolean(Config.STATSMONITOR_AUTO_OPEN))
			{
				setTimeout(toggle, 100);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Toggles the monitor on/off.
		 */
		public function toggle():void
		{
			if (!_active)
			{
				/* Set monitor up if we haven't done that yet! */
				if (_rectangle == null) setup();
				
				_frames = 0;
				_statsDelay = 10;
				onGameLoopFrameRateChanged(_gameLoop.frameRate);
				_glTicks = 0;
				_glRenderMS = 0;
				_last = getTimer();
				
				_gameLoop.renderSignal.add(onGameLoopRender);
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
				addEventListener(MouseEvent.CLICK, onClick);
				_stage.addEventListener(Event.RESIZE, onStageResize);
				layout();
				_container.visible = true;
				_container.addChild(this);
				_active = true;
			}
			else
			{
				_container.removeChild(this);
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				removeEventListener(MouseEvent.CLICK, onClick);
				_stage.removeEventListener(Event.RESIZE, onStageResize);
				_gameLoop.renderSignal.remove(onGameLoopRender);
				
				_active = false;
				
				/* Make console container invisible if it doesn't
				 * contain the console or fpsmonitor! */
				if (_container.numChildren == 0)
				{
					_container.visible = false;
				}
			}
		}
		
		
		/**
		 * togglePosition
		 */
		public function togglePosition():void
		{
			if (!_active) return;
			switch (_config.getString(Config.STATSMONITOR_POSITION).toLowerCase())
			{
				case "tl":
					_config.setProperty(Config.STATSMONITOR_POSITION, "TR");
					break;
				case "tr":
					_config.setProperty(Config.STATSMONITOR_POSITION, "BR");
					break;
				case "br":
					_config.setProperty(Config.STATSMONITOR_POSITION, "BL");
					break;
				case "bl":
					_config.setProperty(Config.STATSMONITOR_POSITION, "TL");
			}
			layout();
		}
		
		
		/**
		 * Sets the gameloop for integration into the stats monitor.
		 * @private
		 */
		public function setGameLoop(gameLoop:GameLoop):void
		{
			_gameLoop = gameLoop;
			_gameLoop.frameRateChangedSignal.add(onGameLoopFrameRateChanged);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onEnterFrame(e:Event):void
		{
			++_frames;
			var time:uint = getTimer();
			var delta:uint = time - _last;
			if (delta >= 50)
			{
				_stageFPS = (_frames / delta * 1000);
				_frames = 0;
				_last = time;
				_stageMS = time - _prevTime;
				updateGraphSection();
				updateStatsSection();
			}
			_prevTime = time;
		}
		
		
		/**
		 * @private
		 */
		private function onGameLoopRender(ticks:uint, ms:uint, fps:uint):void
		{
			_glTicks = ticks;
			_glRenderMS = ms;
			_renderFPS = fps;
		}
		
		
		/**
		 * @private
		 */
		private function onGameLoopFrameRateChanged(frameRate:Number):void
		{
			_glFPS = frameRate == int(frameRate) ? frameRate : int(frameRate + 1);
		}
		
		
		/**
		 * @private
		 */
		private function onClick(e:MouseEvent):void
		{
			(mouseY / height > .5) ? --_stage.frameRate : ++_stage.frameRate;
		}
		
		
		/**
		 * @private
		 */
		private function onStageResize(e:Event):void
		{
			layout();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function setup():void
		{
			Font.registerFont(TerminalstatsFont);
			focusRect = false;
			
			_mem = 0;
			_memMax = 0;
			_memPRC = 0;
			_memGC = 0;
			
			var a:Array = _config.getArray(Config.STATSMONITOR_COLORS);
			if (a)
			{
				_colorBg = uint("0x" + a[0]);
				_colorFPS = uint("0x" + a[1]);
				_colorMem = uint("0x" + a[2]);
				_colorMax = uint("0x" + a[3]);
				_colorPRC = uint("0x" + a[4]);
				_colorGC = uint("0x" + a[5]);
				_colorEtc1 = uint("0x" + a[6]);
				_colorEtc2 = uint("0x" + a[7]);
				_colorEtc3 = uint("0x" + a[8]);
				_colorEtc4 = uint("0x" + a[9]);
			}
			else
			{
				_colorBg = 0x0F0F0F;
				_colorFPS = 0xFFFFFF;
				_colorMem = 0xFFCC00;
				_colorMax = 0xFF6600;
				_colorPRC = 0x787878;
				_colorGC = 0xA2A268;
				_colorEtc1 = 0xFFFFD4;
				_colorEtc2 = 0x55D4FF;
				_colorEtc3 = 0x016A97;
				_colorEtc4 = 0xFF55AA;
			}
			
			createStatsSection();
			createGraphSection();
		}
		
		
		/**
		 * @private
		 */
		private function createStatsSection():void
		{
			_statsSection = new Sprite();
			_statsSection.graphics.beginFill(_colorBg);
			_statsSection.graphics.drawRect(0, 0, 240, 46);
			_statsSection.graphics.endFill();
			
			_fpsTF = createTextField(142, 24, new TextFormat("Terminalstats", 32, _colorFPS));
			_fpsTF.antiAliasType = AntiAliasType.NORMAL;
			_fpsTF.x = 2;
			_fpsTF.y = 0;
			
			_mem1TF = createTextField(71, 14, new TextFormat("Terminalstats", 16, _colorMem));
			_mem1TF.antiAliasType = AntiAliasType.NORMAL;
			_mem1TF.x = 2;
			_mem1TF.y = 20;
			
			_mem2TF = createTextField(71, 14, new TextFormat("Terminalstats", 16, _colorMax));
			_mem2TF.antiAliasType = AntiAliasType.NORMAL;
			_mem2TF.x = 2;
			_mem2TF.y = 30;
			
			_mem3TF = createTextField(71, 14, new TextFormat("Terminalstats", 16, _colorPRC));
			_mem3TF.antiAliasType = AntiAliasType.NORMAL;
			_mem3TF.x = 73;
			_mem3TF.y = 20;
			
			_mem4TF = createTextField(71, 14, new TextFormat("Terminalstats", 16, _colorGC));
			_mem4TF.antiAliasType = AntiAliasType.NORMAL;
			_mem4TF.x = 73;
			_mem4TF.y = 30;
			
			_etc1TF = createTextField(92, 14, new TextFormat("Terminalstats", 16, _colorEtc1));
			_etc1TF.antiAliasType = AntiAliasType.NORMAL;
			_etc1TF.x = 146;
			_etc1TF.y = 0;
			
			_etc2TF = createTextField(92, 14, new TextFormat("Terminalstats", 16, _colorEtc2));
			_etc2TF.antiAliasType = AntiAliasType.NORMAL;
			_etc2TF.x = 146;
			_etc2TF.y = 10;
			
			_etc3TF = createTextField(92, 14, new TextFormat("Terminalstats", 16, _colorEtc3));
			_etc3TF.antiAliasType = AntiAliasType.NORMAL;
			_etc3TF.x = 146;
			_etc3TF.y = 20;
			
			_etc4TF = createTextField(92, 14, new TextFormat("Terminalstats", 16, _colorEtc4));
			_etc4TF.antiAliasType = AntiAliasType.NORMAL;
			_etc4TF.x = 146;
			_etc4TF.y = 30;
			
			_statsSection.addChild(_fpsTF);
			_statsSection.addChild(_mem1TF);
			_statsSection.addChild(_mem2TF);
			_statsSection.addChild(_mem3TF);
			_statsSection.addChild(_mem4TF);
			_statsSection.addChild(_etc1TF);
			_statsSection.addChild(_etc2TF);
			_statsSection.addChild(_etc3TF);
			_statsSection.addChild(_etc4TF);
			addChild(_statsSection);
		}
		
		
		/**
		 * @private
		 */
		private function createGraphSection():void
		{
			_rectangle = new Rectangle(240 - 1, 0, 1, 46);
			_graphBuffer = new BitmapData(240, 46, false, _colorBg);
			_graphSection = new Bitmap(_graphBuffer, PixelSnapping.ALWAYS, false);
			_graphSection.y = 46;
			addChild(_graphSection);
		}
		
		
		/**
		 * @private
		 */
		private function updateGraphSection():void
		{
			_mem = System.totalMemoryNumber * 0.000000954;
			_memMax = _memMax > _mem ? _memMax : _mem;
			_memPRC = System.privateMemory * 0.000000954;
			_memGC = System.freeMemory * 0.000000954;
			
			_graphBuffer.lock();
			_graphBuffer.scroll(-1, 0);
			_graphBuffer.fillRect(_rectangle, _colorBg);
			_graphBuffer.setPixel(240 - 1, 46 - (MIN(46, SQRT(SQRT(_memPRC * 5000))) - 2), _colorPRC);
			_graphBuffer.setPixel(240 - 1, 46 - (MIN(46, SQRT(SQRT(_memGC * 5000))) - 2), _colorGC);
			_graphBuffer.setPixel(240 - 1, 46 - (MIN(46, SQRT(SQRT(_memMax * 5000))) - 2), _colorMax);
			_graphBuffer.setPixel(240 - 1, 46 - (MIN(46, SQRT(SQRT(_mem * 5000))) - 2), _colorMem);
			_graphBuffer.setPixel(240 - 1, 46 - (_glRenderMS >> 1), _colorEtc3);
			_graphBuffer.setPixel(240 - 1, 46 - (_stageMS >> 1), _colorEtc2);
			_graphBuffer.setPixel(240 - 1, 46 - MIN(46, (_stageFPS / _stage.frameRate) * 46), _colorFPS);
			_graphBuffer.unlock();
		}
		
		
		/**
		 * @private
		 */
		private function updateStatsSection():void
		{
			if (_statsDelay++ < 10) return;
			_statsDelay = 0;
			
			_fpsTF.text = "FPS:" + _stageFPS + "/" + _stage.frameRate;
			_mem1TF.text = "MEM:" + _mem.toFixed(2);
			_mem2TF.text = "MAX:" + _memMax.toFixed(2);
			_mem3TF.text = "PRC:" + _memPRC.toFixed(2);
			_mem4TF.text = "GC: " + _memGC.toFixed(2);
			_etc1TF.text = "GLFPS: " + _renderFPS + "/" + _glFPS;
			_etc2TF.text = "MS:    " + _stageMS;
			_etc3TF.text = "RENDER:" + _glRenderMS;
			_etc4TF.text = "TICKS: " + _glTicks;
		}
		
		
		/**
		 * Positions the FPSMonitor according to the config variable 'fpsMonitorPosition'.
		 * @private
		 */
		private function layout():void
		{
			switch (_config.getString(Config.STATSMONITOR_POSITION).toLowerCase())
			{
				case "tl":
					x = 0;
					y = 0;
					break;
				case "bl":
					x = 0;
					y = _stage.stageHeight - height;
					break;
				case "br":
					x = _stage.stageWidth - 240;
					y = _stage.stageHeight - height;
					break;
				default:
					x = _stage.stageWidth - 240;
					y = 0;
			}
		}
		
		
		/**
		 * @private
		 */
		//private function hex2css(color:uint):String
		//{
		//	return "#" + color.toString(16);
		//}
	}
}
