package tetragon.env.update.au.descriptors
{
	import tetragon.env.update.au.utils.AUConstants;

	
	/**
	 * UpdateDescriptor class.
	 */
	public class AUUpdateDescriptor
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const NAMESPACE_UPDATE_1_0:Namespace = new Namespace("http://ns.adobe.com/air/framework/update/description/1.0");
		public static const NAMESPACE_UPDATE_2_5:Namespace = new Namespace("http://ns.adobe.com/air/framework/update/description/2.5");
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _xml:XML;
		private var _defaultNS:Namespace;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function AUUpdateDescriptor(xml:XML)
		{
			_xml = xml;
			_defaultNS = xml.namespace();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines if the given namespace refers to the current version of update descriptor
		 */
		public static function isKnownVersion(ns:Namespace):Boolean
		{
			if (!ns) return false;
			switch (ns.uri)
			{
				case NAMESPACE_UPDATE_1_0.uri:
				case NAMESPACE_UPDATE_2_5.uri:
					return true;
				default:
					return false;
			}
			return false;
		}
		
		
		public function isCompatibleWithAppDescriptor(appHasVersionNumber:Boolean):Boolean
		{
			default xml namespace = _defaultNS;
			var updateHasVersionNumber:Boolean = _xml.versionNumber != undefined;
			return updateHasVersionNumber == appHasVersionNumber;
		}
		
		
		public function getXML():XML
		{
			return _xml;
		}
		
		
		public function validate():void
		{
			default xml namespace = _defaultNS;
			if (!isKnownVersion(_defaultNS))
			{
				fail("Unknown update descriptor namespace.", AUConstants.ERROR_UPDATE_UNKNOWN);
			}
			if (_xml.versionNumber != undefined)
			{
				if (version == "")
				{
					fail("Update versionNumber must have a non-empty value.", AUConstants.ERROR_VERSION_MISSING);
				}
				if (!(/^[0-9]{1,3}(\.[0-9]{1,3}){0,2}$/.test(version)))
				{
					fail("Update versionNumber contains an invalid value.", AUConstants.ERROR_VERSION_INVALID);
				}
			}
			else
			{
				if (version == "")
				{
					fail("Update version must have a non-empty value.", AUConstants.ERROR_VERSION_MISSING);
				}
			}
			
			if (url == "")
			{
				fail("Update URL must have a non-empty value.", AUConstants.ERROR_URL_MISSING);
			}
			
			if (!validateLocalizedText(_xml.description, _defaultNS))
			{
				fail("Illegal values for localized update/description.", AUConstants.ERROR_DESCRIPTION_INVALID);
			}
		}
		
		
		/**
		 * Retrieve the localized text from the given XML element (passed in as an
		 * XMLList object). Returns appropriate text child based on current system
		 * language. Returns first text child if no text language matches system
		 * language. 
		 * Assumes xml element is of the following form:
		 *	<xmlelement>
		 *		<text xml:lang="xx">xxx</text>
		 *		...
		 *	</xmlelement>
		 */
		public static function getLocalizedText(elem:XMLList, ns:Namespace):Array
		{
			var xmlNS:Namespace = new Namespace("http://www.w3.org/XML/1998/namespace");
			var result:Array = [];
			
			// See if element contains simple content.
			if (elem.hasSimpleContent())
			{
				result = [["", elem.toString()]];
			}
			else
			{
				// Gather all the languages from the text children.
				var elemChildren:XMLList = XMLList(elem.ns::text);
				for each (var child:XML in elemChildren)
				{
					result.push([child.@xmlNS::lang.toString(), XMLList(child[0]).toString()]);
				}
			}
			return result;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get version():String
		{
			default xml namespace = _defaultNS;
			return (_xml.version != undefined) ? _xml.version.toString() : _xml.versionNumber.toString();
		}
		
		public function get versionLabel():String
		{
			default xml namespace = _defaultNS;
			if (_xml.version != undefined) return _xml.version.toString();
			return (_xml.versionLabel != undefined) ? _xml.versionLabel.toString() : _xml.versionNumber.toString();
		}
		
		public function get url():String
		{
			default xml namespace = _defaultNS;
			return _xml.url.toString();
		}
		
		public function get description():Array
		{
			default xml namespace = _defaultNS;
			return AUUpdateDescriptor.getLocalizedText(_xml.description, _defaultNS);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function validateLocalizedText(elem:XMLList, ns:Namespace):Boolean
		{
			var xmlNS:Namespace = new Namespace("http://www.w3.org/XML/1998/namespace");
			
			// See if element contains simple content
			if (elem.hasSimpleContent()) return true;

			// XMLList contains more than one element - ie. there is more than one
			// <name> or <description> element. This is invalid.
			if (elem.length() > 1) return false;
			
			// Iterate through all children of the element
			var elemChildren:XMLList = elem.*;
			for each (var child:XML in elemChildren)
			{
				// If any element doesn't have a name.
				if (child.name() == null) return false;
				
				// If any element is not <text>, it's not valid.
				if (child.name()["localName"] != "text") return false;
				
				// If any <text> element does not contain "xml:lang" attribute, it's not valid.
				if (XMLList(child.@xmlNS::lang).length() == 0) return false;
				
				// If any <text> element contains more than simple content, it's not valid.
				if (!child.hasSimpleContent()) return false;
			}
			return true;
		}
		
		
		private function fail(message:String, errorID:int = 0, throwError:Boolean = true):void
		{
			if (throwError)
			{
				throw new Error("UpdateDescriptor: " + message, errorID);
			}
		}
	}
}
