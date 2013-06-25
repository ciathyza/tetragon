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
package tetragon.core.signals
{
	/**
	 * The SignalBindingList class represents an immutable list of SignalBinding objects.
	 */
	public final class SignalBindingList
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Represents an empty list. Used as the list terminator.
		 */
		public static const NIL:SignalBindingList = new SignalBindingList(null, null);
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		// Although those variables are not const, they would be if AS3 would handle it correctly.
		public var head:ISignalBinding;
		public var tail:SignalBindingList;
		public var nonEmpty:Boolean = false;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates and returns a new SignalBindingList object.
		 * 
		 * <p>A user never has to create a SignalBindingList manually. Use the
		 * <code>NIL</code> element to represent an empty list.
		 * <code>NIL.prepend(value)</code> would create a list containing
		 * <code>value</code>.</p>
		 * 
		 * @param head The head of the list.
		 * @param tail The tail of the list.
		 */
		public function SignalBindingList(head:ISignalBinding, tail:SignalBindingList = null)
		{
			if (!head && !tail)
			{
				if (NIL)
				{
					Signal.fail("SignalBindingList", "Parameters head and tail are null. Use"
						+ " the NIL element instead.", ArgumentError);
				}
				// this is the NIL element as per definition
				nonEmpty = false;
				return;
			}
			
			this.head = head;
			this.tail = tail || NIL;
			nonEmpty = true;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Prepends a binding to this list.
		 * 
		 * @param binding The item to be prepended.
		 * @return A list consisting of binding followed by all elements of this list.
		 */
		public function prepend(binding:ISignalBinding):SignalBindingList
		{
			return new SignalBindingList(binding, this);
		}
		
		
		/**
		 * Appends a binding to this list. Note: appending is O(n). Where possible,
		 * prepend which is O(1). In some cases, many list items must be cloned to avoid
		 * changing existing lists.
		 * 
		 * @param binding The item to be appended.
		 * @return A list consisting of all elements of this list followed by binding.
		 */
		public function append(binding:ISignalBinding):SignalBindingList
		{
			if (!binding) return this;
			if (!nonEmpty) return new SignalBindingList(binding);
			// Special case: just one binding.
			if (tail == NIL) return new SignalBindingList(binding).prepend(head);
			
			const wholeClone:SignalBindingList = new SignalBindingList(head);
			var subClone:SignalBindingList = wholeClone;
			var current:SignalBindingList = tail;
			
			while (current.nonEmpty)
			{
				subClone = subClone.tail = new SignalBindingList(current.head);
				current = current.tail;
			}
			// Append the new binding last.
			subClone.tail = new SignalBindingList(binding);
			return wholeClone;
		}
		
		
		public function insertWithPriority(binding:ISignalBinding):SignalBindingList
		{
			if (!nonEmpty) return new SignalBindingList(binding);

			const priority:int = binding.priority;
			// Special case: new binding has the highest priority.
			if (priority > this.head.priority) return prepend(binding);

			var q:SignalBindingList = null;
			const wholeClone:SignalBindingList = new SignalBindingList(head);
			var subClone:SignalBindingList = wholeClone;
			var current:SignalBindingList = tail;
			
			// Find a binding with lower priority and go in front of it.
			while (current.nonEmpty)
			{
				if (priority > current.head.priority)
				{
					const newTail:SignalBindingList = current.prepend(binding);
					return new SignalBindingList(head, newTail);
				}
				
				subClone = subClone.tail = new SignalBindingList(current.head);
				current = current.tail;
			}
			
			// Binding has lowest priority.
			subClone.tail = new SignalBindingList(binding);
			return wholeClone;
		}
		
		
		public function filterNot(listener:Function):SignalBindingList
		{
			if (!nonEmpty || listener == null) return this;
			if (listener == head.listener) return tail;
			
			// The first item wasn't a match so the filtered list will contain it.
			const wholeClone:SignalBindingList = new SignalBindingList(head);
			var subClone:SignalBindingList = wholeClone;
			var current:SignalBindingList = tail;
			
			while (current.nonEmpty)
			{
				if (current.head.listener == listener)
				{
					// Splice out the current head.
					subClone.tail = current.tail;
					return wholeClone;
				}
				
				subClone = subClone.tail = new SignalBindingList(current.head);
				current = current.tail;
			}
			
			// The listener was not found so this list is unchanged.
			return this;
		}
		
		
		public function contains(listener:Function):Boolean
		{
			if (!nonEmpty) return false;
			var p:SignalBindingList = this;
			while (p.nonEmpty)
			{
				if (p.head.listener == listener) return true;
				p = p.tail;
			}
			return false;
		}
		
		
		public function find(listener:Function):ISignalBinding
		{
			if (!nonEmpty) return null;
			var p:SignalBindingList = this;
			while (p.nonEmpty)
			{
				if (p.head.listener == listener) return p.head;
				p = p.tail;
			}
			return null;
		}
		
		
		public function toString():String
		{
			var buffer:String = '';
			var p:SignalBindingList = this;
			while (p.nonEmpty)
			{
				buffer += p.head + " -> ";
				p = p.tail;
			}
			buffer += "NIL";
			return "[List " + buffer + "]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The number of bindings in the list.
		 */
		public function get length():uint
		{
			if (!nonEmpty) return 0;
			if (tail == NIL) return 1;

			// We could cache the length, but it would make methods like filterNot
			// unnecessarily complicated.
			// Instead we assume that O(n) is okay since the length property is used in rare
			// cases.
			// We could also cache the length lazy, but that is a waste of another 8b per list
			// node (at least).
			
			var result:uint = 0;
			var p:SignalBindingList = this;
			
			while (p.nonEmpty)
			{
				++result;
				p = p.tail;
			}
			
			return result;
		}
	}
}
