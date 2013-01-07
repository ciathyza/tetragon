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
	import tetragon.data.sprite.SpriteObject;
	import tetragon.data.sprite.SpriteProperty;
	import tetragon.data.sprite.SpritePropertyDefinition;
	import tetragon.data.sprite.SpriteSequence;
	import tetragon.data.sprite.SpriteSequencePlayMode;
	import tetragon.data.sprite.SpriteSet;
	import tetragon.file.resource.ResourceIndex;
	import tetragon.file.resource.loaders.XMLResourceLoader;

	import com.hexagonstar.types.KeyValuePair;
	
	
	/**
	 * Data parser for parsing spriteset data files.
	 */
	public class SpriteSetDataParser extends DataObjectParser implements IFileDataParser
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
			var refID:String;
			var name:String;
			
			for each (var x:XML in _xml.spriteSet)
			{
				/* Get the current item's ID. */
				var id:String = extractString(x, "@id");
				
				/* Only parse the item(s) that we want! */
				if (!loader.hasResourceID(id)) continue;
				
				/* Create new SpriteSet definition. */
				var s:SpriteSet = new SpriteSet(id);
				s.spriteSheetID = extractString(x, "@spriteSheetID");
				checkReferencedID("spriteSheetID", s.spriteSheetID);
				
				/* Parse the spriteset's property definitions. */
				var propertyDefinitions:Object = {};
				for each (var p1:XML in x.propertyDefinitions.propertyDef)
				{
					var pd:SpritePropertyDefinition = new SpritePropertyDefinition();
					pd.id = extractString(p1, "@id");
					pd.name = extractString(p1, "@name");
					pd.defaultValue = extractUntyped(p1, "@defaultValue");
					propertyDefinitions[pd.id] = pd;
				}
				s.propertyDefinitions = propertyDefinitions;
				
				/* Parse the spriteset's global properties. */
				var globalProperties:Object = {};
				for each (var p2:XML in x.globalProperties.property)
				{
					/* Get property definition that is referenced by this property. */
					refID = extractString(p2, "@id");
					name = getReferencedPropertyName(refID, s);
					if (name == null) continue;
					/* Store property with key name taken from property defs. */
					var gp:SpriteProperty = new SpriteProperty(name, extractUntyped(p2, "@value"));
					globalProperties[gp.id] = gp;
				}
				s.globalProperties = globalProperties;
				
				/* Parse the spriteset's sprite objects. */
				var c:int = 0;
				var spriteObjects:Object = {};
				for each (var p3:XML in x.sprites.sprite)
				{
					var sID:String = extractString(p3, "@id");
					var sSpriteSheetID:String = extractString(p3, "@spriteSheetID");
					var sFrameID:String = extractString(p3, "@frameID");
					
					/* Parse the sprite's properties. */
					var sProperties:Object = {};
					for each (var pp:XML in p3.properties.property)
					{
						/* Get property definition that is referenced by this property. */
						refID = extractString(pp, "@id");
						name = getReferencedPropertyName(refID, s);
						if (name == null) continue;
						/* Store property with key name taken from property defs. */
						var sp:SpriteProperty = new SpriteProperty(name, extractUntyped(pp, "@value"));
						sProperties[sp.id] = sp;
					}
					
					/* Parse the sprite's sequences. */
					var sSequences:Object = {};
					var seqCount:int = 0;
					var seq:SpriteSequence;
					var seqID:String;
					var v:Vector.<String>;
					for each (var ss:XML in p3.sequences.sequence)
					{
						seqID = extractString(ss, "@id");
						seq = new SpriteSequence(seqID);
						seq.loops = extractNumber(ss, "@loops");
						seq.playMode = extractString(ss, "@playMode");
						seq.followSequence = extractString(ss, "@followSequence");
						seq.followDelay = extractNumber(ss, "@followDelay");
						
						/* Parse frame IDs that are used in the sequence. */
						var frameIDs:XMLList = ss.frameIDs;
						var pair:KeyValuePair = parseProperty(frameIDs[0]);
						if (pair.value && pair.value is Array && (pair.value as Array).length > 0)
						{
							var a:Array = pair.value;
							v = new Vector.<String>(a.length, true);
							for (var i:uint = 0; i < a.length; i++)
							{
								v[i] = a[i];
							}
							seq.frameIDs = v;
						}
						sSequences[seq.id] = seq;
						seqCount++;
					}
					
					/* If the sprite has no sequences defined but instead has a single frameID
					 * property, then the sprite gets a sequence with one frame. */
					if (seqCount == 0 && sFrameID != null)
					{
						seq = new SpriteSequence(SpriteSequence.DEFAULT_ID);
						seq.loops = 0;
						seq.playMode = SpriteSequencePlayMode.FORWARD;
						seq.followSequence = null;
						seq.followDelay = 0;
						v = new Vector.<String>(1, true);
						v[0] = sFrameID;
						seq.frameIDs = v;
						sSequences[seq.id] = seq;
						seqCount = 1;
					}
					
					var so:SpriteObject = new SpriteObject(sID, sSpriteSheetID, sProperties, sSequences, seqCount);
					spriteObjects[so.id] = so;
					c++;
				}
				s.sprites = spriteObjects;
				s.spriteCount = c;
				
				index.addDataResource(s);
			}
			
			dispose();
		}
		
		
		private function getReferencedPropertyName(refID:String, s:SpriteSet):String
		{
			var spd:SpritePropertyDefinition = s.getPropertyDefinition(refID);
			var name:String;
			if (spd) name = s.getPropertyDefinition(refID).name;
			
			if (name == null)
			{
				warn("The spriteset \"" + s.id + "\" references a property definition with ID \""
					+ refID + "\" that is not defined in the spriteset's property definitions.");
			}
			return name;
		}
	}
}
