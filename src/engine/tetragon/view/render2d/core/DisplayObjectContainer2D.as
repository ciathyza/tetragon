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
package tetragon.view.render2d.core
{
	import com.hexagonstar.exception.AbstractClassException;
	import com.hexagonstar.util.geom.transform2DCoords;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	import tetragon.view.render2d.core.events.Event2D;


	
	
	/**
	 * A DisplayObjectContainer represents a collection of display objects. It is the base
	 * class of all display objects that act as a container for other objects. By
	 * maintaining an ordered list of children, it defines the back-to-front positioning
	 * of the children within the display tree.
	 * 
	 * <p>
	 * A container does not a have size in itself. The width and height properties
	 * represent the extents of its children. Changing those properties will scale all
	 * children accordingly.
	 * </p>
	 * 
	 * <p>
	 * As this is an abstract class, you can't instantiate it directly, but have to use a
	 * subclass instead. The most lightweight container class is "Sprite".
	 * </p>
	 * 
	 * <strong>Adding and removing children</strong>
	 * 
	 * <p>
	 * The class defines methods that allow you to add or remove children. When you add a
	 * child, it will be added at the frontmost position, possibly occluding a child that
	 * was added before. You can access the children via an index. The first child will
	 * have index 0, the second child index 1, etc.
	 * </p>
	 * 
	 * Adding and removing objects from a container triggers non-bubbling events.
	 * 
	 * <ul>
	 * <li><code>Event.ADDED</code>: the object was added to a parent.</li>
	 * <li><code>Event.ADDED_TO_STAGE</code>: the object was added to a parent that is
	 * connected to the stage, thus becoming visible now.</li>
	 * <li><code>Event.REMOVED</code>: the object was removed from a parent.</li>
	 * <li><code>Event.REMOVED_FROM_STAGE</code>: the object was removed from a parent
	 * that is connected to the stage, thus becoming invisible now.</li>
	 * </ul>
	 * 
	 * Especially the <code>ADDED_TO_STAGE</code> event is very helpful, as it allows you
	 * to automatically execute some logic (e.g. start an animation) when an object is
	 * rendered the first time.
	 * 
	 * @see Sprite2D
	 * @see DisplayObject2D
	 */
	public class DisplayObjectContainer2D extends DisplayObject2D
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _children:Vector.<DisplayObject2D>;
		
		/* Helper objects. */
		
		/** @private */
		private static var _helperMatrix:Matrix = new Matrix();
		/** @private */
		private static var _helperPoint:Point = new Point();
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public function DisplayObjectContainer2D()
		{
			if (getQualifiedClassName(this) == "starling.display::DisplayObjectContainer")
			{
				throw new AbstractClassException(this);
			}
			_children = new <DisplayObject2D>[];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes the resources of all children.
		 */
		public override function dispose():void
		{
			var len:uint = _children.length;
			for (var i:uint = 0; i < len; ++i)
			{
				_children[i].dispose();
			}
			super.dispose();
		}
		
		
		/**
		 * Adds a child to the container. It will be at the frontmost position.
		 * 
		 * @param child
		 */
		public function addChild(child:DisplayObject2D):void
		{
			addChildAt(child, numChildren);
		}
		
		
		/**
		 * Adds a child to the container at a certain index.
		 * 
		 * @param child
		 * @param index
		 */
		public function addChildAt(child:DisplayObject2D, index:int):void
		{
			if (index >= 0 && index <= numChildren)
			{
				child.removeFromParent();
				_children.splice(index, 0, child);
				child.setParent(this);
				child.dispatchEvent(new Event2D(Event2D.ADDED, true));
				if (stage) child.dispatchEventOnChildren(new Event2D(Event2D.ADDED_TO_STAGE));
				return;
			}
			throw new RangeError("Invalid child index");
		}
		
		
		/**
		 * Removes a child from the container. If the object is not a child, nothing
		 * happens. If requested, the child will be disposed right away.
		 * 
		 * @param child
		 * @param dispose
		 */
		public function removeChild(child:DisplayObject2D, dispose:Boolean = false):void
		{
			var i:int = getChildIndex(child);
			if (i != -1) removeChildAt(i, dispose);
		}
		
		
		/**
		 * Removes a child at a certain index. Children above the child will move down. If
		 * requested, the child will be disposed right away.
		 * 
		 * @param index
		 * @param dispose
		 */
		public function removeChildAt(index:int, dispose:Boolean = false):void
		{
			if (index >= 0 && index < numChildren)
			{
				var c:DisplayObject2D = _children[index];
				c.dispatchEvent(new Event2D(Event2D.REMOVED, true));
				if (stage) c.dispatchEventOnChildren(new Event2D(Event2D.REMOVED_FROM_STAGE));
				c.setParent(null);
				_children.splice(index, 1);
				if (dispose) c.dispose();
				return;
			}
			throw new RangeError("Invalid child index");
		}
		
		
		/**
		 * Removes a range of children from the container (endIndex included). If no
		 * arguments are given, all children will be removed.
		 * 
		 * @param beginIndex
		 * @param endIndex
		 * @param dispose
		 */
		public function removeChildren(beginIndex:int = 0, endIndex:int = -1, dispose:Boolean = false):void
		{
			if (endIndex < 0 || endIndex >= numChildren) endIndex = numChildren - 1;
			for (var i:int = beginIndex; i <= endIndex; ++i)
			{
				removeChildAt(beginIndex, dispose);
			}
		}
		
		
		/**
		 * Returns a child object at a certain index.
		 * 
		 * @param index
		 * @return DisplayObject2D
		 */
		public function getChildAt(index:int):DisplayObject2D
		{
			if (index >= 0 && index < numChildren) return _children[index];
			else throw new RangeError("Invalid child index");
		}
		
		
		/**
		 * Returns a child object with a certain name (non-recursively).
		 * 
		 * @param name
		 * @return DisplayObject2D
		 */
		public function getChildByName(name:String):DisplayObject2D
		{
			var len:uint = _children.length;
			for (var i:uint = 0; i < len; ++i)
			{
				if (_children[i].name == name) return _children[i];
			}
			return null;
		}
		
		
		/**
		 * Returns the index of a child within the container, or "-1" if it is not found.
		 * 
		 * @param child
		 * @return int
		 */
		public function getChildIndex(child:DisplayObject2D):int
		{
			return _children.indexOf(child);
		}
		
		
		/**
		 * Moves a child to a certain index. Children at and after the replaced position move up.
		 * 
		 * @param child
		 * @param index
		 */
		public function setChildIndex(child:DisplayObject2D, index:int):void
		{
			var oldIndex:int = getChildIndex(child);
			if (oldIndex == -1) throw new ArgumentError("Not a child of this container");
			_children.splice(oldIndex, 1);
			_children.splice(index, 0, child);
		}
		
		
		/**
		 * Swaps the indices of two children.
		 * 
		 * @param child1
		 * @param child2
		 */
		public function swapChildren(child1:DisplayObject2D, child2:DisplayObject2D):void
		{
			var i1:int = getChildIndex(child1);
			var i2:int = getChildIndex(child2);
			if (i1 == -1 || i2 == -1)
			{
				throw new ArgumentError("Not a child of this container");
			}
			swapChildrenAt(i1, i2);
		}
		
		
		/**
		 * Swaps the indexes of two children.
		 * 
		 * @param index1
		 * @param index2
		 */
		public function swapChildrenAt(index1:int, index2:int):void
		{
			var c1:DisplayObject2D = getChildAt(index1);
			var c2:DisplayObject2D = getChildAt(index2);
			_children[index1] = c2;
			_children[index2] = c1;
		}
		
		
		/**
		 * Sorts the children according to a given function (that works just like the sort
		 * function of the Vector class).
		 * 
		 * @param compareFunction
		 */
		public function sortChildren(compareFunction:Function):void
		{
			_children = _children.sort(compareFunction);
		}
		
		
		/**
		 * Determines if a certain object is a child of the container (recursively).
		 * 
		 * @param child
		 * @return true or false
		 */
		public function contains(child:DisplayObject2D):Boolean
		{
			if (child == this) return true;
			var len:uint = _children.length;
			for (var i:uint = 0; i < len; ++i)
			{
				var c:DisplayObject2D = _children[i];
				var con:DisplayObjectContainer2D = c as DisplayObjectContainer2D;
				if (con && con.contains(child)) return true;
				else if (c == child) return true;
			}
			return false;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function getBounds(targetSpace:DisplayObject2D,
			resultRect:Rectangle = null):Rectangle
		{
			if (!resultRect) resultRect = new Rectangle();
			
			var numChildren:uint = _children.length;
			if (numChildren == 0)
			{
				getTransformationMatrix(targetSpace, _helperMatrix);
				transform2DCoords(_helperMatrix, 0.0, 0.0, _helperPoint);
				resultRect.x = _helperPoint.x;
				resultRect.y = _helperPoint.y;
				resultRect.width = resultRect.height = 0;
				return resultRect;
			}
			else if (numChildren == 1)
			{
				return _children[0].getBounds(targetSpace, resultRect);
			}
			else
			{
				var minX:Number = Number.MAX_VALUE, maxX:Number = -Number.MAX_VALUE;
				var minY:Number = Number.MAX_VALUE, maxY:Number = -Number.MAX_VALUE;
				
				for (var i:uint = 0; i < numChildren; ++i)
				{
					_children[i].getBounds(targetSpace, resultRect);
					minX = minX < resultRect.x ? minX : resultRect.x;
					maxX = maxX > resultRect.right ? maxX : resultRect.right;
					minY = minY < resultRect.y ? minY : resultRect.y;
					maxY = maxY > resultRect.bottom ? maxY : resultRect.bottom;
				}
				
				resultRect.x = minX;
				resultRect.y = minY;
				resultRect.width = maxX - minX;
				resultRect.height = maxY - minY;

				return resultRect;
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function hitTest(localPoint:Point, forTouch:Boolean = false):DisplayObject2D
		{
			if (forTouch && (!visible || !touchable)) return null;
			
			var localX:Number = localPoint.x;
			var localY:Number = localPoint.y;
			var len:int = _children.length;
			
			for (var i:int = len - 1; i >= 0; --i) // front to back!
			{
				var child:DisplayObject2D = _children[i];
				getTransformationMatrix(child, _helperMatrix);
				transform2DCoords(_helperMatrix, localX, localY, _helperPoint);
				var target:DisplayObject2D = child.hitTest(_helperPoint, forTouch);
				if (target) return target;
			}
			
			return null;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function renderWithSupport(support:Render2DRenderSupport, alpha:Number):void
		{
			alpha *= this.alpha;
			var len:uint = _children.length;

			for (var i:uint = 0; i < len; ++i)
			{
				var c:DisplayObject2D = _children[i];
				if (c.alpha != 0.0 && c.visible && c.scaleX != 0.0 && c.scaleY != 0.0)
				{
					support.pushMatrix();
					support.transformMatrix(c);
					c.renderWithSupport(support, alpha);
					support.popMatrix();
				}
			}
		}
		
		
		/**
		 * Dispatches an event on all children (recursively). The event must not bubble.
		 * 
		 * @param event
		 */
		public function broadcastEvent(event:Event2D):void
		{
			if (event.bubbles)
			{
				throw new ArgumentError("Broadcast of bubbling events is prohibited");
			}
			dispatchEventOnChildren(event);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The number of children of this container.
		 */
		public function get numChildren():uint
		{
			return _children.length;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 * 
		 * @param e
		 */
		internal override function dispatchEventOnChildren(e:Event2D):void
		{
			// the event listeners might modify the display tree, which could make the loop crash.
			// thus, we collect them in a list and iterate over that list instead.
			var listeners:Vector.<DisplayObject2D> = new <DisplayObject2D>[];
			getChildEventListeners(this, e.type, listeners);
			var len:uint = listeners.length;
			for (var i:uint = 0; i < len; ++i)
			{
				listeners[i].dispatchEvent(e);
			}
		}
		
		
		/**
		 * @private
		 * 
		 * @param object
		 * @param eventType
		 * @param listeners
		 */
		private function getChildEventListeners(object:DisplayObject2D, eventType:String,
			listeners:Vector.<DisplayObject2D>):void
		{
			var container:DisplayObjectContainer2D = object as DisplayObjectContainer2D;
			if (object.hasEventListener(eventType)) listeners.push(object);
			
			if (container)
			{
				var children:Vector.<DisplayObject2D> = container._children;
				var len:uint = children.length;
				for (var i:uint = 0; i < len; ++i)
				{
					getChildEventListeners(children[i], eventType, listeners);
				}
			}
		}
	}
}
