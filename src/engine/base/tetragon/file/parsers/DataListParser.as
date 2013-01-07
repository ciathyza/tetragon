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
package tetragon.file.parsers
{
	import tetragon.data.DataList;
	import tetragon.debug.Log;
	import tetragon.file.resource.ResourceIndex;
	import tetragon.file.resource.loaders.XMLResourceLoader;

	import com.hexagonstar.types.KeyValuePair;
	
	
	/**
	 * Parser for data list objects.
	 */
	public class DataListParser extends DataObjectParser implements IFileDataParser
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function parse(loader:XMLResourceLoader, model:*):void
		{
			_xml = loader.xml;
			var index:ResourceIndex = model;
			var p:XML;
			var pair:KeyValuePair;
			
			/* Loop through all lists in data file. */
			for each (var l:XML in _xml.list)
			{
				/* Get the current list's ID. */
				var id:String = extractString(l, "@id");
				
				/* Only parse the list(s) that we want! */
				if (!loader.hasResourceID(id)) continue;
				
				Log.debug("Parsing list data for " + id + " ...", this);
				
				/* Create new data list object. */
				var list:DataList = new DataList(id);
				
				/* Parse the list's items. */
				for each (var i:XML in l.item)
				{
					/* Create new data list item object. */
					var itemID:String = extractString(i, "@id");
					list.createItem(itemID);
					
					/* Parse the item's properties. */
					for each (p in i.properties.children())
					{
						pair = parseProperty(p);
						pair = checkReferencedID(pair.key, pair.value);
						list.mapProperty(itemID, pair.key, pair.value);
					}
					
					/* Parse the item's sets. */
					for each (var s:XML in i.sets.children())
					{
						/* Create new dataset object. */
						var setID:String = s.name();
						list.createSet(itemID, setID);
						
						/* Parse through all the set's properties. */
						for each (p in s.children())
						{
							pair = parseProperty(p);
							pair = checkReferencedID(pair.key, pair.value);
							list.mapSetProperty(itemID, setID, pair.key, pair.value);
						}
					}
				}
				
				/* add the parsed list to the resource index. */
				index.addDataResource(list);
			}
			
			dispose();
		}
	}
}
