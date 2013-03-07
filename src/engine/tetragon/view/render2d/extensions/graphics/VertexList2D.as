package tetragon.view.render2d.extensions.graphics
{
	public final class VertexList2D
	{
		public var vertex:Vector.<Number>;
		public var next:VertexList2D;
		public var prev:VertexList2D;
		public var index:int;
		public var head:VertexList2D;

		private static var nodePool:Vector.<VertexList2D> = new Vector.<VertexList2D>();
		private static var nodePoolLength:int = 0;
		

		public function VertexList2D()
		{
		}


		static public function insertAfter(nodeA:VertexList2D, nodeB:VertexList2D):VertexList2D
		{
			var temp:VertexList2D = nodeA.next;
			nodeA.next = nodeB;
			nodeB.next = temp;
			nodeB.prev = nodeA;
			nodeB.head = nodeA.head;

			return nodeB;
		}


		static public function clone(vertexList:VertexList2D):VertexList2D
		{
			var newHead:VertexList2D;

			var currentNode:VertexList2D = vertexList.head;
			var currentClonedNode:VertexList2D;
			do
			{
				var newClonedNode:VertexList2D;
				if ( newHead == null )
				{
					newClonedNode = newHead = getNode();
				}
				else
				{
					newClonedNode = getNode();
				}

				newClonedNode.head = newHead;
				newClonedNode.index = currentNode.index;
				newClonedNode.vertex = currentNode.vertex;
				newClonedNode.prev = currentClonedNode;

				if ( currentClonedNode )
				{
					currentClonedNode.next = newClonedNode;
				}
				currentClonedNode = newClonedNode;

				currentNode = currentNode.next;
			}
			while ( currentNode != currentNode.head );

			currentClonedNode.next = newHead;
			newHead.prev = currentClonedNode;

			return newHead;
		}


		static public function reverse(vertexList:VertexList2D):void
		{
			var node:VertexList2D = vertexList.head;
			do
			{
				var temp:VertexList2D = node.next;
				node.next = node.prev;
				node.prev = temp;

				node = temp;
			}
			while ( node != vertexList.head );
		}


		static public function dispose(node:VertexList2D):void
		{
			while ( node && node.head )
			{
				releaseNode(node);
				var temp:VertexList2D = node.next;
				node.next = null;
				node.prev = null;
				node.head = null;
				node.vertex = null;

				node = node.next;
			}
		}
		
		
		static public function getNode():VertexList2D
		{
			if ( nodePoolLength > 0 )
			{
				nodePoolLength--;
				return nodePool.pop();
			}
			return new VertexList2D();
		}


		static public function releaseNode(node:VertexList2D):void
		{
			node.prev = node.next = node.head = null;
			node.vertex = null;
			node.index = -1;
			nodePool[nodePoolLength++] = node;
		}
	}
}
