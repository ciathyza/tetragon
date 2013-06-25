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
package tetragon.util.tween.plugins
{
	import tetragon.util.tween.Tween;
	import tetragon.util.tween.TweenVO;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;


	/**
	 * Normally, all transformations (scale, rotation, and position) are based on the
	 * DisplayObject's registration point (most often its upper left corner), but
	 * TransformAroundPoint allows you to define ANY point around which 2D transformations
	 * will occur during the tween. For example, you may have a dynamically-loaded image
	 * that you want to scale from its center or rotate around a particular point on the
	 * stage. <br/>
	 * <br/>
	 * 
	 * If you define an x or y value in the transformAroundPoint object, it will
	 * correspond to the custom registration point which makes it easy to position (as
	 * opposed to having to figure out where the original registration point should tween
	 * to). If you prefer to define the x/y in relation to the original registration
	 * point, do so outside the transformAroundPoint object, like: <br />
	 * <br />
	 * <code>
	 * 
	 * Tween.to(mc, 3, {x:50, y:40, transformAroundPoint:{point:new Point(200, 300), scale:0.5,
	 * rotation:30}});<br /><br /></code>
	 * 
	 * To define the <code>point</code> according to the target's local coordinates (as
	 * though it is inside the target), simply pass <code>pointIsLocal:true</code> in the
	 * transformAroundPoint object, like:<br />
	 * <br />
	 * <code>
	 * 
	 * Tween.to(mc, 3, {transformAroundPoint:{point:new Point(200, 300), pointIsLocal:true,
	 * scale:0.5, rotation:30}});<br /><br /></code>
	 * 
	 * TransformAroundPointPlugin is a <a href="http://www.greensock.com/club/">Club
	 * GreenSock</a> membership benefit. You must have a valid membership to use this
	 * class without violating the terms of use. Visit <a
	 * href="http://www.greensock.com/club/">http://www.greensock.com/club/</a> to sign up
	 * or get more details. <br />
	 * <br />
	 * 
	 * <b>USAGE:</b><br />
	 * <br />
	 * <code>
	 * 		import com.greensock.Tween; <br />
	 * 		import com.greensock.plugins.TweenPlugin; <br />
	 * 		import com.greensock.plugins.TransformAroundPointPlugin; <br />
	 * 		TweenPlugin.activate([TransformAroundPointPlugin]); // activation is permanent
	 * 		in the SWF, so this line only needs to be run once.<br /><br />
	 * 		Tween.to(mc, 1, {transformAroundPoint:{point:new Point(100, 300), scaleX:2,
	 * 		scaleY:1.5, rotation:150}}); <br /><br />
	 * </code>
	 */
	public class TransformAroundPointPlugin extends TweenPlugin
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private **/
		private static var _classInitialized:Boolean;
		/** @private **/
		protected var _target:DisplayObject;
		/** @private **/
		protected var _local:Point;
		/** @private **/
		protected var _point:Point;
		/** @private **/
		protected var _shortRotation:ShortRotationPlugin;
		/** @private **/
		protected var _proxy:DisplayObject;
		/** @private **/
		protected var _proxySizeData:Object;
		/** @private **/
		protected var _useAddElement:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public function TransformAroundPointPlugin()
		{
			propertyName = "transformAroundPoint";
			overwriteProperties = ["x", "y"];
			// so that the x/y tweens occur BEFORE the transformAroundPoint is applied
			priority = -1;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function onInitTween(target:Object, value:*, tween:Tween):Boolean
		{
			if (!(value['point'] is Point))
			{
				return false;
			}
			
			var pt:Point = value['point'];
			_target = target as DisplayObject;
			
			if (value['pointIsLocal'] == true)
			{
				_local = pt.clone();
				_point = _target.parent.globalToLocal(_target.localToGlobal(_local));
			}
			else
			{
				_point = pt.clone();
				_local = _target.globalToLocal(_target.parent.localToGlobal(_point));
			}
			
			if (!_classInitialized) _classInitialized = true;
			
			if ((!isNaN(value['width']) || !isNaN(value['height'])) && _target.parent != null)
			{
				var m:Matrix = _target.transform.matrix;
				var point:Point = _target.parent.globalToLocal(_target.localToGlobal(new Point(100, 100)));
				_target.width *= 2;
				
				if (point.x == _target.parent.globalToLocal(_target.localToGlobal(new Point(100, 100))).x)
				{
					// checks to see if the width change also alters where the 100,100 point is
					// in the parent, essentially telling us whether or not the width change also
					// effectively changed the scale, but we can't just check the scaleX because
					// rotation would affect it and there are some inconsistencies in the way
					// Adobe's classes/components work.
					_proxy = _target;
					_target.rotation = 0;
					_proxySizeData = {};
					
					if (!isNaN(value['width']))
					{
						addTween(_proxySizeData, "width", _target.width * 0.5, value['width'], "width");
						// Components that alter their width without scaling will treat their
						// width/height setters as though they were applied without any rotation,
						// so we must handle these separately. If we just allow the width/height
						// tweens to affect the Sprite and copy those values over to the _proxy,
						// it won't behave properly.
					}
					if (!isNaN(value['height']))
					{
						addTween(_proxySizeData, "height", _target.height, value['height'], "height");
					}
					
					var b:Rectangle = _target.getBounds(_target);
					var s:Sprite = new Sprite();
					var container:Sprite = new Sprite();
					
					container.addChild(s);
					container.visible = false;
					
					_useAddElement = _proxy.parent.hasOwnProperty("addElement");
					if (_useAddElement)
					{
						Object(_proxy.parent)['addElement'](container);
					}
					else
					{
						_proxy.parent.addChild(container);
					}
					
					_target = s;
					
					s.graphics.beginFill(0x0000FF, 0.4);
					s.graphics.drawRect(b.x, b.y, b.width, b.height);
					s.graphics.endFill();
					
					_proxy.width /= 2;
					
					// we must reset the width even though we're applying the transform.matrix
					// after this because some components don't flow the transform.matrix values
					// through to the width value (bug/inconsistency in Adobe's stuff).
					s.transform.matrix = _target.transform.matrix = m;
				}
				else
				{
					_target.width /= 2;
					// we must reset the width even though we're applying the transform.matrix
					// after this because some components don't flow the transform.matrix values
					// through to the width value (bug/inconsistency in Adobe's stuff).
					_target.transform.matrix = m;
				}
			}
			
			var p:String, short:ShortRotationPlugin, sp:String;
			for (p in value)
			{
				if (p == "point" || p == "pointIsLocal")
				{
					// ignore - we already set it above
				}
				else if (p == "shortRotation")
				{
					_shortRotation = new ShortRotationPlugin();
					_shortRotation.onInitTween(_target, value[p], tween);
					addTween(_shortRotation, "changeFactor", 0, 1, "shortRotation");
					for (sp in value[p])
					{
						overwriteProperties[overwriteProperties.length] = sp;
					}
				}
				else if (p == "x" || p == "y")
				{
					addTween(_point, p, _point[p], value[p], p);
				}
				else if (p == "scale")
				{
					addTween(_target, "scaleX", _target.scaleX, value['scale'], "scaleX");
					addTween(_target, "scaleY", _target.scaleY, value['scale'], "scaleY");
					overwriteProperties[overwriteProperties.length] = "scaleX";
					overwriteProperties[overwriteProperties.length] = "scaleY";
				}
				else if ((p == "width" || p == "height") && _proxy != null)
				{
					// let the proxy handle width/height
				}
				else
				{
					addTween(_target, p, _target[p], value[p], p);
					overwriteProperties[overwriteProperties.length] = p;
				}
			}

			if (tween != null)
			{
				var enumerables:Object = tween.vars;
				if ("x" in enumerables || "y" in enumerables)
				{
					// if the tween is supposed to affect x and y based on the original
					// registration point, we need to make special adjustments here...
					var endX:Number, endY:Number;
					
					if ("x" in enumerables)
					{
						endX = (typeof(enumerables['x']) == "number")
							 ? enumerables['x']
							 : _target.x + Number(enumerables['x']);
					}
					if ("y" in enumerables)
					{
						endY = (typeof(enumerables['y']) == "number")
							? enumerables['y']
							: _target.y + Number(enumerables['y']);
					}
					tween.killVars({x:true, y:true}, false);
					
					// we're taking over.
					changeFactor = 1;
					if (!isNaN(endX))
					{
						addTween(_point, "x", _point.x, _point.x + (endX - _target.x), "x");
					}
					if (!isNaN(endY))
					{
						addTween(_point, "y", _point.y, _point.y + (endY - _target.y), "y");
					}
					changeFactor = 0;
				}
			}

			return true;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function killProperties(lookup:Object):void
		{
			if (_shortRotation)
			{
				_shortRotation.killProperties(lookup);
				if (_shortRotation.overwriteProperties.length == 0)
				{
					lookup['shortRotation'] = true;
				}
			}
			super.killProperties(lookup);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function set changeFactor(v:Number):void
		{
			if (_proxy != null && _proxy.parent != null)
			{
				if (_useAddElement)
				{
					Object(_proxy.parent)['addElement'](_target.parent);
				}
				else
				{
					_proxy.parent.addChild(_target.parent);
				}
			}
			
			var val:Number, x:Number, y:Number;
			
			if (_target.parent)
			{
				var p:Point;
				var pt:TweenVO;
				var i:int = _tweens.length;
				
				if (roundProperties)
				{
					while (--i > -1)
					{
						pt = _tweens[i];
						val = pt.start + (pt.change * v);
						// 4 times as fast as Math.round()
						pt.target[pt.property] = (val > 0) ? int(val + 0.5) : int(val - 0.5);
					}
					p = _target.parent.globalToLocal(_target.localToGlobal(_local));
					x = _target.x + _point.x - p.x;
					y = _target.y + _point.y - p.y;
					// 4 times as fast as Math.round()
					_target.x = (x > 0) ? int(x + 0.5) : int(x - 0.5);
					// 4 times as fast as Math.round()
					_target.y = (y > 0) ? int(y + 0.5) : int(y - 0.5);
				}
				else
				{
					while (--i > -1)
					{
						pt = _tweens[i];
						pt.target[pt.property] = pt.start + (pt.change * v);
					}
					p = _target.parent.globalToLocal(_target.localToGlobal(_local));
					_target.x += _point.x - p.x;
					_target.y += _point.y - p.y;
				}
			}
			
			_changeFactor = v;
			
			if (_proxy != null && _proxy.parent != null)
			{
				var r:Number = _target.rotation;
				_proxy.rotation = _target.rotation = 0;
				
				if (_proxySizeData['width'] != undefined)
				{
					_proxy.width = _target.width = _proxySizeData['width'];
				}
				if (_proxySizeData['height'] != undefined)
				{
					_proxy.height = _target.height = _proxySizeData['height'];
				}
				_proxy.rotation = _target.rotation = r;

				p = _target.parent.globalToLocal(_target.localToGlobal(_local));
				x = _target.x + _point.x - p.x;
				y = _target.y + _point.y - p.y;
				if (roundProperties)
				{
					// 4 times as fast as Math.round()
					_proxy.x = (x > 0) ? int(x + 0.5) : int(x - 0.5);
					// 4 times as fast as Math.round()
					_proxy.y = (y > 0) ? int(y + 0.5) : int(y - 0.5);
				}
				else
				{
					_proxy.x = x;
					_proxy.y = y;
				}
				if (_useAddElement)
				{
					Object(_proxy.parent)['removeElement'](_target.parent);
				}
				else
				{
					_proxy.parent.removeChild(_target.parent);
				}
			}
		}
	}
}
