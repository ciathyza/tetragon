package tetragon.core.au.descriptors
{
	import tetragon.core.au.utils.AUConstants;

	
	/**
	 * ConfigurationDescriptor class.
	 */
	public class AUConfigurationDescriptor
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const NAMESPACE_CONFIGURATION_1_0:Namespace =
			new Namespace("http://ns.adobe.com/air/framework/update/configuration/1.0");
		
		public static const DIALOG_CHECK_FOR_UPDATE:String	= "checkforupdate";
		public static const DIALOG_DOWNLOAD_UPDATE:String	= "downloadupdate";
		public static const DIALOG_DOWNLOAD_PROGRESS:String	= "downloadprogress";
		public static const DIALOG_INSTALL_UPDATE:String	= "installupdate";
		public static const DIALOG_FILE_UPDATE:String		= "fileupdate";
		public static const DIALOG_UNEXPECTED_ERROR:String	= "unexpectederror";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _xml:XML;
		private var _defaultNS:Namespace;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function AUConfigurationDescriptor(xml:XML)
		{
			_xml = xml;
			_defaultNS = xml.namespace();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function validate():void
		{
			default xml namespace = _defaultNS;
			if (!isThisVersion(_defaultNS))
			{
				fail("Unknown configuration version.", AUConstants.ERROR_CONFIGURATION_UNKNOWN);
			}
			if (url == "")
			{
				fail("Configuration URL must have a non-empty value.", AUConstants.ERROR_URL_MISSING);
			}
			if (!validateInterval(_xml.delay.toString()))
			{
				fail("Illegal value \"" + _xml.delay.toString() + "\" for configuration/delay.",
					AUConstants.ERROR_DELAY_INVALID);
			}
			if (!validateDefaultUI(_xml.defaultUI))
			{
				fail("Illegal values for configuration/defaultUI.", AUConstants.ERROR_DEFAULTUI_INVALID);
			}
		}
		
		
		/**
		 * Determines if the given namespace refers to the current version of
		 * configuration descriptor.
		 */
		public static function isThisVersion(ns:Namespace):Boolean
		{
			return ns && ns.uri == NAMESPACE_CONFIGURATION_1_0.uri;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get checkInterval():Number
		{
			default xml namespace = _defaultNS;
			return convertInterval(_xml.delay.toString());
		}
		
		
		public function get url():String
		{
			default xml namespace = _defaultNS;
			return _xml.url.toString();
		}
		
		
		public function get defaultUI():Array
		{
			var dialogs:Array = new Array();
			for each (var elem:XML in _xml.defaultUI.*)
			{
				var dlg:Object =
				{
					"name": elem.@name,
					"visible": stringToBoolean(elem.@visible)
				};
				dialogs.push(dlg);
			}
			return dialogs;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function convertInterval(intervalString:String):Number
		{
			var result:Number = -1;
			if (intervalString.length > 0) result = Number(intervalString);
			return result;
		}
		
		
		private function validateInterval(intervalString:String):Boolean
		{
			var result:Boolean = false;
			if (intervalString.length > 0)
			{
				try
				{
					var intervalNumber:Number = Number(intervalString);
					if (intervalNumber >= 0) result = true;
				}
				catch(err:Error)
				{
					fail("validateInterval: Couldn't get result.", 0, false);
					result = false;
				}
			}
			else
			{
				result = true;
			}
			return result;
		}
		
		
		private function validateDefaultUI(elem:XMLList):Boolean
		{
			// XMLList contains more than one element - ie. there is more than one
			// <name> or <description> element. This is invalid.
			if (elem.length() > 1) return false;

			// Iterate through all children of the element.
			var elemChildren:XMLList = elem.*;
			for each (var child:XML in elemChildren)
			{
				// If any element doesn't have a name.
				if (child.name() == null) return false;
				// If any element is not <text>, it's not valid
				if (child.name()["localName"] != "dialog") return false;
				
				// If any <dialog> element does not contain "name" attribute, it's not valid.
				var s:String = String(child.@name).toLowerCase();
				var a:Array =
				[
					DIALOG_CHECK_FOR_UPDATE,
					DIALOG_DOWNLOAD_UPDATE,
					DIALOG_DOWNLOAD_PROGRESS,
					DIALOG_INSTALL_UPDATE,
					DIALOG_FILE_UPDATE,
					DIALOG_UNEXPECTED_ERROR
				];
				if (a.indexOf(s) == -1) return false;
				
				// If any <dialog> element does not contain "visible" attribute with "true"
				// or "false", it's not valid.
				s = child.@visible;
				a = ["true", "false"];
				if (a.indexOf(s) == -1) return false;
				
				// If any <dialog> element contains content, it's not valid.
				if (child.hasComplexContent()) return false;
			}
			return true;
		}
		
		
		private function stringToBoolean(str:String):Boolean
		{
			switch (str.toLowerCase())
			{
				case "true":
				case "1":
					return true;
				case "":
				case "false":
				case "0":
					return false;
			}
			return false;
		}
		
		
		private function fail(message:String, errorID:int = 0, throwError:Boolean = true):void
		{
			if (throwError)
			{
				throw new Error("ConfigurationDescriptor: " + message, errorID);
			}
		}
	}
}
