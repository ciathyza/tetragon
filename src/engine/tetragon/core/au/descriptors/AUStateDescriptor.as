package tetragon.core.au.descriptors
{
	import tetragon.core.au.utils.AUConstants;

	import flash.filesystem.File;
	
	
	/**
	 * StateDescriptor class.
	 */
	public class AUStateDescriptor
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const NAMESPACE_STATE_1_0:Namespace = new Namespace("http://ns.adobe.com/air/framework/update/state/1.0");
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _xml:XML;
		private var _defaultNS:Namespace;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function AUStateDescriptor(xml:XML)
		{
			_xml = xml;
			_defaultNS = xml.namespace();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines if the given namespace refers to the current version of state descriptor
		 */
		public static function isThisVersion(ns:Namespace):Boolean
		{
			return ns && ns.uri == NAMESPACE_STATE_1_0.uri;
		}
		
		
		/**
		 * Creates the default XML file
		 */
		public static function defaultState():AUStateDescriptor
		{
			default xml namespace = NAMESPACE_STATE_1_0;
			var initialXML:XML =
				<state>
					<lastCheck>
						{new Date()}
					</lastCheck>
				</state>;
			return new AUStateDescriptor(initialXML);
		}
		
		
		public function getXML():XML
		{
			return _xml;
		}
		
		
		public function addFailedUpdate(value:String):void
		{
			if (_xml.failed.length() == 0) _xml.failed = <failed/>;
			_xml.failed.appendChild(<version>{value}</version>);
		}
		
		
		public function removeAllFailedUpdates():void
		{
			_xml.failed = <failed />;
		}
		
		
		public function validate():void
		{
			default xml namespace = _defaultNS;
			
			if (!isThisVersion(_defaultNS))
			{
				fail("Unknown state version.", AUConstants.ERROR_STATE_UNKNOWN);
			}
			if (_xml.lastCheck.toString() == "")
			{
				fail("lastCheck must have a non-empty value.", AUConstants.ERROR_LAST_CHECK_MISSING);
			}
			if (!validateDate(_xml.lastCheck.toString()))
			{
				fail("Invalid date format for state/lastCheck.", AUConstants.ERROR_LAST_CHECK_INVALID);
			}
			if (_xml.previousVersion.toString() != "" && !validateText(_xml.previousVersion))
			{
				fail("Illegal value for state/previousVersion.", AUConstants.ERROR_PREV_VERSION_INVALID);
			}
			if (_xml.currentVersion.toString() != "" && !validateText(_xml.currentVersion))
			{
				fail("Illegal value for state/currentVersion.", AUConstants.ERROR_CURRENT_VERSION_INVALID);
			}
			if (_xml.storage.toString() != "" && (!validateText(_xml.storage) || !validateFile(_xml.storage.toString())))
			{
				fail("Illegal value for state/storage.", AUConstants.ERROR_STORAGE_INVALID);
			}
			if (["", "true", "false"].indexOf(_xml.updaterLaunched.toString()) == -1 )
			{
				fail("Illegal value \"" + _xml.updaterLaunched.toString() + "\" for state/updaterLaunched.",
					AUConstants.ERROR_LAUNCHED_INVALID);
			}
			if (!validateFailed(_xml.failed))
			{
				fail("Illegal values for state/failed.", AUConstants.ERROR_FAILED_INVALID);
			}
			
			// check if all the update data is in place
			var count:int = 0;
			if (previousVersion != "") count++;
			if (currentVersion != "") count++;
			if (storage) count++;
			
			if (count > 0 && count != 3)
			{
				fail("All state/previousVersion, state/currentVersion, state/storage,"
					+ " state/updaterLaunched  must be set.", AUConstants.ERROR_VERSIONS_INVALID);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get lastCheckDate():Date
		{
			return stringToDate(_xml.lastCheck.toString());
		}
		public function set lastCheckDate(v:Date):void
		{
			_xml.lastCheck = v.toString();
		}
		
		
		public function get currentVersion():String
		{
			return _xml.currentVersion.toString();
		}
		public function set currentVersion(v:String):void
		{
			_xml.currentVersion = v;
		}
		
		
		public function get previousVersion():String
		{
			return _xml.previousVersion.toString();
		}
		public function set previousVersion(v:String):void
		{
			_xml.previousVersion = v;
		}
		
		
		public function get storage():File
		{
			return stringToFile(_xml.storage.toString());
		}
		public function set storage(v:File):void
		{
			_xml.storage = fileToString(v);
		}
		
		
		public function get updaterLaunched():Boolean
		{
			return stringToBoolean(_xml.updaterLaunched.toString());
		}
		public function set updaterLaunched(v:Boolean):void
		{
			_xml.updaterLaunched = v.toString();
		}
		
		
		public function get failedUpdates():Array
		{
			var updates:Array = new Array();
			for each (var version:XML in _xml.failed.*)
			{
				updates.push(version);
			}
			return updates;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function validateDate(dateString:String):Boolean
		{
			var result:Boolean = false;
			try
			{
				var n:Number = Date.parse(dateString);
				if (!isNaN(n))
				{
					result = true;
				}
			}
			catch (err:Error)
			{
				fail("validateDate: Couldn't get result.", 0, false);
				result = false;
			}
			return result;
		}
		
		
		private function validateFile(fileString:String):Boolean
		{
			var result:Boolean = false;
			try
			{
				var file:File = new File(fileString);
				result = true;
			}
			catch (err:Error)
			{
				fail("validateFile: Couldn't get result.", 0, false);
				result = false;
			}
			return result;
		}
		
		
		private function validateText(elem:XMLList):Boolean
		{
			// See if element contains simple content
			if (!elem.hasSimpleContent()) return false;
			
			// XMLList contains more than one element - ie. there is more than one
			// <name> or <description> element. This is invalid.
			if (elem.length() > 1) return false;

			return true;
		}
		
		
		private function validateFailed(elem:XMLList):Boolean
		{
			// XMLList contains more than one element - ie. there is more than one
			// <name> or <description> element. This is invalid.
			if (elem.length() > 1) return false;
			
			var elemChildren:XMLList = elem.*;
			for each (var child:XML in elemChildren)
			{
				// If any element doesn't have a name.
				if (child.name() == null) return false;
				
				// If any element is not <version>, it's not valid.
				if (child.name()["localName"] != "version") return false;
				
				// If any <version> element contains more than simple content, it's not valid.
				if (!child.hasSimpleContent()) return false;
			}
			return true;
		}
		
		
		private function stringToDate(dateString:String):Date
		{
			var date:Date = null;
			if (dateString) date = new Date(dateString);
			return date;
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
		
		
		private function stringToFile(str:String):File
		{
			if (!str) return null;
			return new File(str);
		}
		
		
		private function fileToString(file:File):String
		{
			if (file && file.nativePath) return file.nativePath;
			return "";
		}
		
		
		private function fail(message:String, errorID:int = 0, throwError:Boolean = true):void
		{
			if (throwError)
			{
				throw new Error("StateDescriptor: " + message, errorID);
			}
		}
	}
}
