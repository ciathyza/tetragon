package tetragon.env.update.au.descriptors
{
	import flash.display.NativeWindowSystemChrome;
	import flash.geom.Point;
	
	
	/**
	 * Class for accessing the contents of an application descriptor. This
	 * class provides access to the entire descriptor but only for the this
	 * version of the runtime; if you want to access descriptors for other
	 * versions, see InstalledApplication.
	 *
	 * After instantiating, call the validate methods to ensure you have a 
	 * valid file. Results of accessor methods/properties are undefined if 
	 * validate() fails.
	 */
	public class AUApplicationDescriptor
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/** 
		 * Iterate property names to get the corresponding names of the app
		 * descriptor elements. Associated property values are the width and
		 * height of the corresponding image.
		 */
		public static const ICON_IMAGES:Object =
		{
			image16x16: 16,
			image32x32: 32,
			image48x48: 48,
			image128x128: 128
		};
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _xml:XML;
		private var _defaultNS:Namespace;
		private var _name:String;
		private var _description:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function AUApplicationDescriptor(xml:XML)
		{
			_xml = xml;
			_defaultNS = _xml.namespace();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------		
		
		/**
		 * Returns the package path to the 16x16 icon image, if any. The icon paths are 
		 * the values inside the <icon> block:
		 *   ...
		 *   <icon>
		 *     <image16x16>path/to/16x16.gif</image16x16>
		 *     <image32x32>path/to/32x32.png</image32x32>
		 *     ...
		 *   </icon>
		 *   ...
		 */
		public function getIcon(size:String):String
		{
			default xml namespace = _defaultNS;
			return _xml.icon.elements(new QName(_defaultNS, size)).toString();
		}
		
		
		public function hasCustomUpdateUI():Boolean
		{
			default xml namespace = _defaultNS;
			return stringToBooleanDefFalse(_xml.customUpdateUI.toString());
		}
		
		
		public function validate():void
		{
			default xml namespace = _defaultNS;
			if (filename == "") fail("Application filename must have a non-empty value.");
			
			// check for the 2.5 change (versionNumber instead of version).
			if (_xml.versionNumber != undefined)
			{
				if (version == "") fail("versionNumber must have a non-empty value.");
				
				// version has to be of format <0-999>.<0-999>.<0-999>
				if (!(/^[0-9]{1,3}(\.[0-9]{1,3}){0,2}$/.test(version) ))
				{
					fail("versionNumber contains an invalid value.");
				}
			}
			else
			{
				if (version == "")
				{
					fail("version must have a non-empty value.");
				}
			}
			
			// The application cannot begin with a ' ' (space), have any of these characters:
			// *"/:<>?\|, and end with a . (dot) or ' ' (space).
			if (!(/^([^\*\"\/:<>\?\\\|\. ]|[^\*\"\/:<>\?\\\| ][^\*\"\/:<>\?\\\|]*[^\*\"\/:<>\?\\\|\. ])$/.test(filename)))
			{
				fail("invalid application filename");
			}
			if (_xml.initialWindow.content.toString() == "")
			{
				fail("initialWindow/content must have a non-empty value.");
			}

			// The install and program menu folders cannot begin with a / (forward-slash) or a ' ' (space),
			// have any of these characters: *":<>?\|, and end with a . (dot) or ' ' (space)
			if ((installFolder != "") && !(/^([^\*\"\/:<>\?\\\|\. ]|[^\*\"\/:<>\?\\\| ][^\*\":<>\?\\\|]*[^\*\":<>\?\\\|\. ])$/.test(installFolder)))
			{
				fail("invalid install folder");
			}
			if ((programMenuFolder != "") && !(/^([^\*\"\/:<>\?\\\|\. ]|[^\*\"\/:<>\?\\\| ][^\*\":<>\?\\\|]*[^\*\":<>\?\\\|\. ])$/.test(programMenuFolder)))
			{
				fail("invalid program menu folder");
			}
			if (["", NativeWindowSystemChrome.NONE, NativeWindowSystemChrome.STANDARD].indexOf(_xml.initialWindow.systemChrome.toString()) == -1)
			{
				fail("Illegal value \"" + _xml.initialWindow.systemChrome.toString()
					+ "\" for application/initialWindow/systemChrome.");
			}
			if (["", "true", "false", "1", "0"].indexOf(_xml.initialWindow.transparent.toString()) == -1 )
			{
				fail("Illegal value \"" + _xml.initialWindow.transparent.toString()
					+ "\" for application/initialWindow/transparent.");
			}
			if (["", "true", "false", "1", "0"].indexOf(_xml.initialWindow.visible.toString()) == -1 )
			{
				fail("Illegal value \"" + _xml.initialWindow.visible.toString()
					+ "\" for application/initialWindow/visible.");
			}
			if (["", "true", "false", "1", "0"].indexOf(_xml.initialWindow.minimizable.toString()) == -1 )
			{
				fail("Illegal value \"" + _xml.initialWindow.minimizable.toString()
					+ "\" for application/initialWindow/minimizable.");
			}
			if (["", "true", "false", "1", "0"].indexOf(_xml.initialWindow.maximizable.toString()) == -1 )
			{
				fail("Illegal value \"" + _xml.initialWindow.maximizable.toString()
					+ "\" for application/initialWindow/maximizable.");
			}
			if (["", "true", "false", "1", "0"].indexOf(_xml.initialWindow.resizable.toString()) == -1 )
			{
				fail("Illegal value \"" + _xml.initialWindow.resizable.toString()
					+ "\" for application/initialWindow/resizeable.");
			}
			if (["", "true", "false", "1", "0"].indexOf(_xml.initialWindow.closeable.toString()) == -1 )
			{
				fail("Illegal value \"" + _xml.initialWindow.closeable.toString()
					+ "\" for application/initialWindow/closeable.");
			}
			if (initialWindowTransparent && (initialWindowSystemChrome != NativeWindowSystemChrome.NONE))
			{
				fail("Illegal window settings. Transparent windows are only supported when"
					+ " systemChrome is set to \"none\".");
			}
			if (!validateDimension(_xml.initialWindow.width.toString()))
			{
				fail("Illegal value \"" + _xml.initialWindow.width.toString()
					+ "\" for application/initialWindow/width.");
			}
			if (!validateDimension(_xml.initialWindow.height.toString()))
			{
				fail("Illegal value \"" + _xml.initialWindow.height.toString()
					+ "\" for application/initialWindow/height.");
			}
			if (!validateLocation(_xml.initialWindow.x.toString()))
			{
				fail("Illegal value \"" + _xml.initialWindow.x.toString()
					+ "\" for application/initialWindow/x.");
			}
			if (!validateLocation(_xml.initialWindow.y.toString()))
			{
				fail("Illegal value \"" + _xml.initialWindow.y.toString()
					+ "\" for application/initialWindow/y.");
			}
			if (!validateDimensionPair(_xml.initialWindow.minSize.toString()))
			{
				fail("Illegal value \"" + _xml.initialWindow.minSize.toString()
					+ "\" for application/initialWindow/minSize.");
			}
			if (!validateDimensionPair(_xml.initialWindow.maxSize.toString()))
			{
				fail("Illegal value \"" + _xml.initialWindow.maxSize.toString()
					+ "\" for application/initialWindow/maxSize.");
			}
			if (!validateLocalizedText(XMLList(_xml.name), _defaultNS))
			{
				fail("Illegal values for application/name.");
			}
			if (!validateLocalizedText(_xml.description, _defaultNS))
			{
				fail("Illegal values for application/description.");
			}

			// This pattern matches the set of characters permitted in Uniform Type Identifiers, as
			// defined in the Carbon Data Management Guide (see http://developer.apple.com). It is
			// additionally limited to 212 characters so that it can be concatenated with the pub id
			// and used as a filename.
			if (!( /^[A-Za-z0-9\-\.]{1,212}$/.test(id)))
			{
				fail("Invalid application identifier.");
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get namespace():Namespace
		{
			default xml namespace = _defaultNS;
			return _xml.namespace();
		}
		
		
		public function get minimumPatchLevel():int
		{
			default xml namespace = _defaultNS;
			return _xml.@minimumPatchLevel;
		}
		
		
		public function get id():String
		{
			default xml namespace = _defaultNS;
			return _xml.id.toString();
		}
		
		
		public function get version():String
		{
			default xml namespace = _defaultNS;
			// until 2.5 we had version, after 2.5 we had versionNumber
			if (_xml.version == undefined && _xml.versionNumber == undefined)
			{
				fail("cannot get version (backwards incompatible application namespace change?)");
			}
			if (_xml.version == undefined) return _xml.versionNumber.toString();
			return _xml.version.toString();
		}
		
		
		public function get versionLabel():String
		{
			// default xml namespace = m_defaultNs;
			// until 2.5 we had version, after 2.5 we had versionNumber
			if (_xml.nsversion == undefined && _xml.versionNumber == undefined)
			{
				fail("cannot get version (backwards incompatible application namespace change?)");
			}
			if (_xml.version != undefined) return _xml.version.toString();
			return (_xml.versionLabel == undefined)
				? _xml.versionNumber.toString()
				: _xml.versionLabel.toString();
		}
		
		
		public function get filename():String
		{
			default xml namespace = _defaultNS;
			return _xml.filename.toString();
		}
		
		
		/**
		 * Name defaults to filename if not specified
		 */
		public function get name():String
		{
			default xml namespace = _defaultNS;
			return (_name == "" ? filename : _name);
		}
		
		
		public function get description():String
		{
			return _description;
		}
		
		
		public function get copyright():String
		{
			default xml namespace = _defaultNS;
			return _xml.copyright.toString();
		}
		
		
		public function get initialWindowContent():String
		{
			default xml namespace = _defaultNS;
			return _xml.initialWindow.content;
		}
		
		
		/**
		 * Defaults to name of application
		 */
		public function get initialWindowTitle():String
		{
			default xml namespace = _defaultNS;
			var result:String = _xml.initialWindow.title.toString();
			if (result == "") result = name;
			return result;
		}
		
		
		/**
		 * Defaults to STANDARD
		 */
		public function get initialWindowSystemChrome():String
		{
			default xml namespace = _defaultNS;
			var systemChromeString:String = _xml.initialWindow.systemChrome.toString();
			var result:String = NativeWindowSystemChrome.STANDARD;
			switch (systemChromeString)
			{
				// accept valid entries
				case NativeWindowSystemChrome.STANDARD:
				case NativeWindowSystemChrome.NONE:
					result = systemChromeString;
			}
			return result;
		}
		
		
		public function get fileTypes():XMLList
		{
			default xml namespace = _defaultNS;
			return _xml.fileTypes.elements();
		}
		
		
		public function get initialWindowTransparent():Boolean
		{
			default xml namespace = _defaultNS;
			return stringToBooleanDefFalse(_xml.initialWindow.transparent.toString());
		}
		
		
		public function get initialWindowVisible():Boolean
		{
			default xml namespace = _defaultNS;
			return stringToBooleanDefFalse(_xml.initialWindow.visible.toString());
		}
		
		
		public function get initialWindowMinimizable():Boolean
		{
			default xml namespace = _defaultNS;
			return stringToBooleanDefTrue(_xml.initialWindow.minimizable.toString());
		}
		
		
		public function get initialWindowMaximizable():Boolean
		{
			default xml namespace = _defaultNS;
			return stringToBooleanDefTrue(_xml.initialWindow.maximizable.toString());
		}
		
		
		public function get initialWindowResizable():Boolean
		{
			default xml namespace = _defaultNS;
			return stringToBooleanDefTrue(_xml.initialWindow.resizable.toString());
		}
		
		
		public function get initialWindowCloseable():Boolean
		{
			default xml namespace = _defaultNS;
			return stringToBooleanDefTrue(_xml.initialWindow.closeable.toString());
		}
		
		
		public function get initialWindowWidth():Number
		{
			default xml namespace = _defaultNS;
			return convertDimension(_xml.initialWindow.width.toString());
		}
		
		
		public function get initialWindowHeight():Number
		{
			default xml namespace = _defaultNS;
			return convertDimension(_xml.initialWindow.height.toString());
		}
		
		
		public function get initialWindowX():Number
		{
			default xml namespace = _defaultNS;
			return convertLocation(_xml.initialWindow.x.toString());
		}
		
		
		public function get initialWindowY():Number
		{
			default xml namespace = _defaultNS;
			return convertLocation(_xml.initialWindow.y.toString());
		}
		
		
		public function get initialWindowMinSize():Point
		{
			default xml namespace = _defaultNS;
			return convertDimensionPoint(_xml.initialWindow.minSize.toString());
		}
		
		
		public function get initialWindowMaxSize():Point
		{
			default xml namespace = _defaultNS;
			return convertDimensionPoint(_xml.initialWindow.maxSize.toString());
		}
		
		
		public function get installFolder():String
		{
			default xml namespace = _defaultNS;
			return _xml.installFolder.toString();
		}
		
		
		public function get programMenuFolder():String
		{
			default xml namespace = _defaultNS;
			return _xml.programMenuFolder.toString();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function stringToBooleanDefTrue(str:String):Boolean
		{
			switch (str.toLowerCase())
			{
				case "":
				case "true":
				case "1":
					return true;
				case "false":
				case "0":
					return false;
			}
			return true;
		}
		
		
		private function stringToBooleanDefFalse(str:String):Boolean
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
		
		
		private function convertDimension(dimensionString:String):Number
		{
			var result:Number = -1;
			if (dimensionString.length > 0)
			{
				var dimensionUINT:uint = uint(dimensionString);
				result = Number(dimensionUINT);
			}
			return result;
		}
		
		
		private function convertLocation(locationString:String):Number
		{
			var result:Number = -1;
			if (locationString.length > 0)
			{
				var locationINT:int = int(locationString);
				result = Number(locationINT);
			}
			return result;
		}
		
		
		private function convertDimensionPoint(dimensionString:String):Point
		{
			var result:Point = null;
			if (dimensionString.length > 0)
			{
				try
				{
					var list:Array = dimensionString.split(/ +/);
					if (list.length == 2)
					{
						var x:Number = convertDimension(String(list[0]));
						var y:Number = convertDimension(String(list[1]));
						var pt:Point = new Point();
						pt.x = x;
						pt.y = y;
						result = pt;
					}
				}
				catch(err:Error)
				{
					// feh. error.  conversion failed
					fail("convertDimensionPoint: Couldn't get result.", false);
					result = null;
				}
			}
			return result;
		}
		
		
		private function validateDimension(dimensionString:String):Boolean
		{
			var result:Boolean = false;
			if (dimensionString.length > 0)
			{
				try
				{
					var dimensionNumber:Number = Number(dimensionString);
					if (dimensionNumber >= 0) result = true;
				}
				catch (err:Error)
				{
					fail("validateDimension: Couldn't get result.", false);
					result = false;
				}
			}
			else
			{
				result = true;
			}
			return result;
		}
		
		
		private function validateDimensionPair(inputString:String):Boolean
		{
			var result:Boolean = false;
			if (inputString.length > 0)
			{
				var pt:Point = convertDimensionPoint(inputString);
				if ((pt != null) && (pt.x != -1) && (pt.y != -1)) result = true;
			}
			else
			{
				result = true;
			}
			return result;
		}
		
		
		private function validateLocation(inputString:String):Boolean
		{
			var result:Boolean = false;
			if (inputString.length > 0)
			{
				try
				{
					var dimensionNumber:Number = Number(inputString);
					if (!isNaN(dimensionNumber)) result = true;
				}
				catch(err:Error)
				{
					fail("validateLocation: Couldn't get result.", false);
					result = false;
				}
			}
			else
			{
				result = true;
			}
			return result;
		}
		
		
		private function validateLocalizedText(elem:XMLList, ns:Namespace):Boolean
		{
			var xmlNS:Namespace = new Namespace("http://www.w3.org/XML/1998/namespace");

			// See if element contains simple content.
			if (elem.hasSimpleContent()) return true;

			// XMLList contains more than one element - ie. there is more than one
			// <name> or <description> element. This is invalid.
			if (elem.length() > 1) return false;
			
			// Iterate through all children of the element.
			var elemChildren:XMLList = elem.*;
			for each (var child:XML in elemChildren)
			{
				// If any element is not <text>, it's not valid.
				if (child.name() == null || child.name()["localName"] != "text") return false;

				// If any <text> element does not contain "xml:lang" attribute, it's not valid.
				if (XMLList(child.@xmlNS::lang).length() == 0) return false;

				// If any <text> element contains more than simple content, it's not valid.
				if (!child.hasSimpleContent()) return false;
			}
			return true;
		}
		
		
		private function fail(message:String, throwError:Boolean = true):void
		{
			if (throwError)
			{
				throw new Error("ApplicationDescriptor: " + message);
			}
		}
	}
}
