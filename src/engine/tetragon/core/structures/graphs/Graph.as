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
package tetragon.core.structures.graphs
{
	import tetragon.core.structures.IIterator;
	
	
	public class Graph
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The graph's nodes.
		 */
		public var nodes:Vector.<GraphNode>;
		
		/** @private */
		private var _nodeCount:int;
		/** @private */
		private var _maxSize:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates an empty graph.
		 * 
		 * @param size The total number of nodes the graph can hold.
		 */
		public function Graph(size:int)
		{
			_maxSize = size;
			clear();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Query Operations
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The number of nodes the graph can store.
		 */
		public function get maxSize():int
		{
			return _maxSize;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get size():int
		{
			return _nodeCount;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function isEmpty():Boolean
		{
			return _nodeCount == 0;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function contains(data:*):Boolean
		{
			for (var i:int = 0; i < _nodeCount; i++)
			{
				var n:GraphNode = nodes[i];
				if (n && n.data == data) return true;
			}
			return false;
		}
		
		
		/**
		 * Finds an arc pointing to the node at the 'from' index to the node at the
		 * 'to' index.
		 * 
		 * @param from The originating graph node index.
		 * @param to The ending graph node index.
		 * @return A GraphArc object or null if it doesn't exist.
		 */
		public function getArc(from:int, to:int):GraphArc
		{
			var fn:GraphNode = nodes[from];
			var tn:GraphNode = nodes[to];
			if (fn && tn) return fn.getArc(tn);
			return null;
		}
		
		
		/**
		 * Performs an iterative depth-first traversal starting at a given node.
		 * 
		 * @example The following code shows an example callback function.
		 * The graph traversal runs until the value '5' is found in the data
		 * property of a node instance.
		 * 
		 * @example
		 * <pre>
		 * var visitNode:Function = function(node:GraphNode):Boolean
		 * {
		 *     if (node.data == 5)
		 *         return false; // terminate traversal
		 *     return true;
		 * }
		 * myGraph.depthFirst(graph.nodes[0], visitNode);
		 * </pre>
		 * 
		 * @param node  The graph node at which the traversal starts.
		 * @param visit A callback function which is invoked every time a node
		 *              is visited. The visited node is accessible through
		 *              the function's first argument. You can terminate the
		 *              traversal by returning false in the callback function.
		 */
		public function depthFirst(node:GraphNode, visit:Function):void
		{
			if (!node) return;
			
			var stack:Vector.<GraphNode> = new Vector.<GraphNode>();
			var arcs:Vector.<GraphArc>;
			var c:int = 1, k:int, i:int;
			var n:GraphNode;
			
			stack.push(node);
			
			while (c > 0)
			{
				n = stack[--c];
				if (n.marked) continue;
				n.marked = true;
				visit(n);
				k = n.numArcs, arcs = n.arcs;
				
				for (i = 0; i < k; i++)
				{
					stack[c++] = arcs[i].node;
				}
			}
		}
		
		
		/**
		 * Performs a breadth-first traversal starting at a given node.
		 * 
		 * @example The following code shows an example callback function.
		 * The graph traversal runs until the value '5' is found in the data
		 * property of a node instance.
		 * 
		 * @example
		 * <pre>
		 * var visitNode:Function = function(node:GraphNode):Boolean
		 * {
		 *     if (node.data == 5)
		 *         return false; // terminate traversal
		 *     return true;
		 * }
		 * myGraph.breadthFirst(graph.nodes[0], visitNode);
		 * </pre>
		 * 
		 * @param node  The graph node at which the traversal starts.
		 * @param visit A callback function which is invoked every time a node
		 *              is visited. The visited node is accessible through
		 *              the function's first argument. You can terminate the
		 *              traversal by returning false in the callback function.
		 */
		public function breadthFirst(node:GraphNode, visit:Function):void
		{
			if (!node) return;
			
			var queue:Vector.<GraphNode> = new Vector.<GraphNode>(0x10000);
			var divisor:int = 0x10000 - 1;
			var front:int = 0;
			var c:int = 1, k:int, i:int;
			var arcs:Vector.<GraphArc>;
			var v:GraphNode;
			var w:GraphNode;

			queue[0] = node;
			node.marked = true;

			while (c > 0)
			{
				v = queue[front];
				if (!visit(v)) return;
				arcs = v.arcs, k = v.numArcs;
				
				for (i = 0; i < k; i++)
				{
					w = arcs[i].node;
					if (w.marked) continue;
					w.marked = true;
					queue[int((c++ + front) & divisor)] = w;
				}
				
				if (++front == 0x10000) front = 0;
				c--;
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get iterator():IIterator
		{
			return new GraphIterator(this);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function toArray():Array
		{
			var a:Array = [];
			for (var i:int = 0, j:int = 0; i < _nodeCount; i++)
			{
				var n:GraphNode = nodes[i];
				if (n) a[j++] = n.data;
			}
			return a;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Modification Operations
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds a node at a given index to the graph.
		 * 
		 * @param data The data to store in the node.
		 * @param index The index the node is stored at.
		 * 
		 * @return True if a node was added, otherwise false.
		 */
		public function addNode(data:*, index:int):Boolean
		{
			if (nodes[index]) return false;

			nodes[index] = new GraphNode(data);
			_nodeCount++;
			return true;
		}
		
		
		/**
		 * Removes a node from the graph at a given index.
		 * 
		 * @param index The node's index.
		 * @return True if removal was successful, otherwise false.
		 */
		public function removeNode(index:int):Boolean
		{
			var node:GraphNode = nodes[index];
			if (node == null) return false;
			
			for (var i:int = 0; i < _maxSize; i++)
			{
				var n:GraphNode = nodes[i];
				if (n && n.getArc(node))
				{
					removeArc(i, index);
					break;
				}
			}
			
			nodes[i] = null;
			_nodeCount--;
			return true;
		}
		
		
		/**
		 * Adds an arc pointing to the node located at the 'from' index to the node at
		 * the 'to' index.
		 * 
		 * @param from The originating graph node index.
		 * @param to The ending graph node index.
		 * @param weight The arc's weight.
		 * @return True if the arc was added, otherwise false.
		 */
		public function addArc(from:int, to:int, weight:int = 1):Boolean
		{
			var fn:GraphNode = nodes[from];
			var tn:GraphNode = nodes[to];
			if (fn && tn)
			{
				if (fn.getArc(tn)) return false;
				fn.addArc(tn, weight);
				return true;
			}
			return false;
		}
		
		
		/**
		 * Removes an arc pointing to the node located at the 'from' index to the node
		 * at the 'to' index.
		 * 
		 * @param from The originating graph node index.
		 * @param to The ending graph node index.
		 * @return True if the arc was removed, otherwise false.
		 */
		public function removeArc(from:int, to:int):Boolean
		{
			var fn:GraphNode = nodes[from];
			var tn:GraphNode = nodes[to];
			if (fn && tn)
			{
				fn.removeArc(tn);
				return true;
			}
			return false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Bulk Operations
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Marks are used to keep track of the nodes that have been visited during a
		 * depth-first or breadth-first traversal. You must call this method to clear
		 * all markers before starting a new traversal.
		 */
		public function clearMarks():void
		{
			for (var i:int = 0; i < _maxSize; i++)
			{
				var node:GraphNode = nodes[i];
				if (node) node.marked = false;
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function clear():void
		{
			nodes = new Vector.<GraphNode>(_maxSize, true);
			_nodeCount = 0;
		}
	}
}


// ------------------------------------------------------------------------------------------------

import tetragon.core.exception.UnsupportedOperationException;
import tetragon.core.structures.IIterator;
import tetragon.core.structures.graphs.Graph;
import tetragon.core.structures.graphs.GraphNode;


/**
 * @private
 */
final class GraphIterator implements IIterator
{
	private var _nodes:Vector.<GraphNode>;
	private var _cursor:int;
	private var _size:int;
	
	public function GraphIterator(graph:Graph)
	{
		_nodes = graph.nodes;
		_size = graph.maxSize;
	}
	
	public function reset():void
	{
		_cursor = 0;
	}
	
	public function remove():*
	{
		// TODO Add remove operation to GraphIterator!
		throw new UnsupportedOperationException("[GraphIterator] removing is not supported yet.");
		return null;
	}
	
	public function get hasNext():Boolean
	{
		return _cursor < _size;
	}
	
	public function get next():*
	{
		if (_cursor < _size)
		{
			var item:* = _nodes[_cursor];
			if (item)
			{
				_cursor++;
				return item;
			}
			while (_cursor < _size)
			{
				item = _nodes[_cursor++];
				if (item) return item;
			}
		}
		return null;
	}
	
	public function get data():*
	{
		var n:GraphNode = _nodes[_cursor];
		if (n) return n.data;
	}
	
	public function set data(obj:*):void
	{
		var n:GraphNode = _nodes[_cursor];
		if (n) n.data = obj;
	}
}
