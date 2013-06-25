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
	import tetragon.Main;
	import tetragon.core.types.KeyValuePair;
	import tetragon.debug.Log;
	import tetragon.entity.EntityDefinition;
	import tetragon.entity.EntityFamily;
	import tetragon.entity.EntityManager;
	import tetragon.file.resource.ResourceIndex;
	import tetragon.file.resource.loaders.XMLResourceLoader;
	
	
	/**
	 * A data parser that parses entity data and creates entity definitions from it.
	 */
	public class EntityDataParser extends DataObjectParser implements IFileDataParser
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _entityManager:EntityManager;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function EntityDataParser()
		{
			super();
			_entityManager = Main.instance.entityManager;
		}
		
		
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
			
			/* Loop through all items in data file. */
			for each (var x:XML in _xml.entity)
			{
				/* Get the current item's ID. */
				var id:String = extractString(x, "@id");
				
				/* Only parse the item(s) that we want! */
				if (!loader.hasResourceID(id)) continue;
				
				Log.debug("Parsing entity data for " + id + " ...", this);
				
				/* Create a new entity definition for the data item. */
				var ed:EntityDefinition = new EntityDefinition(id);
				
				/* Loop through the item's component definitions. */
				for each (var c:XML in x.components.component)
				{
					var isRefList:Boolean = extractBoolean(c, "@refList");
					var cClassID:String = extractString(c, "@classID");
					var cClass:Class = classRegistry.getEntityComponentClass(cClassID);
					
					if (cClass)
					{
						/* Create map that maps all properties and values of the component. */
						var componentProperties:Object;
						var p:XML;
						var pair:KeyValuePair;
						
						/* If the component is a ref list, map all refs of it. */
						if (isRefList)
						{
							var refs:Object = {};
							var refCount:uint = 0;
							
							/* Loop through all refs. */
							for each (var r:XML in c.ref)
							{
								var refID:String = extractString(r, "@id");
								/* Create a reference definition for the entity ref. */
								var rd:EntityDefinition = new EntityDefinition(refID);
								
								/* Loop through all components of the ref. */
								for each (var rc:XML in r.component)
								{
									var rcClassID:String = extractString(rc, "@classID");
									var rcClass:Class = classRegistry.getEntityComponentClass(rcClassID);
									
									if (rcClass)
									{
										/* Map all properties found in the ref's component definition. */
										componentProperties = {};
										for each (p in rc.children())
										{
											pair = parseProperty(p);
											pair = checkReferencedID(pair.key, pair.value);
											if (pair.value == null || pair.value == "")
											{
												componentProperties[pair.key] = null;
											}
											else
											{
												componentProperties[pair.key] = pair.value;
											}
										}
										
										/* Add ref component mapping to reference definition. */
										rd.addComponentMapping(rcClassID, componentProperties);
									}
									else
									{
										error("No component class mapped for the classID \""
											+ rcClassID + "\" for ref " + refID + " in item with ID \"" + id + "\".");
									}
								}
								
								/* Store reference definition in temporary map. */
								refs[refID] = rd;
								++refCount;
							}
							
							/* Store map that contains a key/value pair with the refs mappings
							 * as a component mapping in the current entity definition. */
							pair = new KeyValuePair("refs", refs);
							componentProperties = {refs: pair.value};
							ed.addComponentMapping(cClassID, componentProperties);
							
							Log.debug("Parsed " + refCount + " references in " + id + ".", this);
						}
						/* Component is not a ref list, proceed as normal. */
						else
						{
							/* Map all properties found in the component definition. */
							componentProperties = {};
							for each (p in c.children())
							{
								pair = parseProperty(p);
								pair = checkReferencedID(pair.key, pair.value);
								if (pair.value == null || pair.value == "")
								{
									componentProperties[pair.key] = null;
								}
								else
								{
									componentProperties[pair.key] = pair.value;
								}
							}
							
							/* Add component property map to entity definition. */
							ed.addComponentMapping(cClassID, componentProperties);
						}
					}
					else
					{
						error("No component class mapped for the classID \""
							+ cClassID + "\" for item with ID \"" + id + "\".");
					}
				}
				
				/* Set entity family signature for entity. */
				ed.familySignature = EntityFamily.getComponentSignatureFor(ed.componentMappings);
				
				/* Create and map new entity family. */
				_entityManager.mapEntityFamily(new EntityFamily(ed.familySignature));
				
				/* Store entity definition in resource index. */
				index.addDataResource(ed);
			}
			
			dispose();
		}
	}
}
