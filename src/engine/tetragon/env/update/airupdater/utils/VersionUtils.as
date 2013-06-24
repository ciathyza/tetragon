package tetragon.env.update.airupdater.utils
{
	import flash.desktop.NativeApplication;
	
	
	public class VersionUtils
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		private static const SPECIALS:Array = ["alpha", "beta", "rc"];
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Algorithm for comparing versions
		 *   1. Every +,-,_,SPACE is replaced by DOT : 1.2+-__5 => 1.2...5
		 *   2. All sequence of DOT are replaced by one single DOT  1.2...5 => 1.2.5
		 *   3. A DOT is inserted between any DIGIT - ALPHANUMERIC: 1beta1 => 1.beta.1
		 *   4. The version is split using DOT as delimiter
		 *   5. The numbers are compared as number, the alphanumeric as string with the exception of alpha, beta and rc, where alpha < beta < rc 
		 */
		public static function isNewerVersion(currentVersion:String, newVersion:String):Boolean
		{
			var v1:String = currentVersion.replace(/[+\-_ ]/g, ".").replace(/\.(\.)+/g, ".").replace(/([^\d\.])([^\D\.])/g, "$1.$2").replace(/([^\D\.])([^\d\.])/g, "$1.$2");
			var v2:String = newVersion.replace(/[+\-_ ]/g, ".").replace(/\.(\.)+/g, ".").replace(/([^\d\.])([^\D\.])/g, "$1.$2").replace(/([^\D\.])([^\d\.])/g, "$1.$2");
			var parts1:Array = v1.split(".");
			var parts2:Array = v2.split(".");
			var minLen:int = Math.min(parts1.length, parts2.length);
			
			for (var i:int = 0; i < minLen; i++)
			{
				var p1:String = parts1[i];
				var p2:String = parts2[i];
				var isDigit1:Boolean = isDigit(p1.charAt(0));
				var isDigit2:Boolean = isDigit(p2.charAt(0));
				
				// compare numbers (greater wins)
				if (isDigit1 && isDigit2)
				{
					var n1:uint = uint(p1);
					var n2:uint = uint(p2);
					if (n2 != n1) return n2 > n1;
				}
				// compare only alphanumeric
				else if (!isDigit1 && !isDigit2)
				{
					// check specials
					var index1:int = SPECIALS.indexOf(p1.toLowerCase());
					var index2:int = SPECIALS.indexOf(p2.toLowerCase());
					// rc > beta > alpha
					if (index1 != -1 && index2 != -1)
					{
						if (index1 != index2) return index2 > index1;
					}
					else
					{
						var p1l:String = p1.toLowerCase();
						var p2l:String = p2.toLowerCase();
						if (p2l != p1l) return p2l > p1l;
					}
				}
				// digit with alphanumeric
				else
				{
					// digit > alphanumeric
					if (isDigit1) return false;
					return true;
				}
			}
			
			// they are equals
			if (parts1.length == parts2.length) return false;
			
			// if old version has more parts
			if (parts1.length > parts2.length)
			{
				// number is greater
				if (isDigit(String(parts1[minLen]).charAt(0))) return false;
				// alphanumeric is lower
				else return true;
			}
			// if new version has more parts
			// number is greater
			if (isDigit(String(parts2[minLen]).charAt(0))) return true;
			// alphanumeric is lower
			return false;
		}
		
		
		public static function getApplicationVersion():String
		{
			var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXML.namespace();
			return ((appXML.ns::version == undefined) ? (appXML.ns::versionNumber) : (appXML.ns::version));
		}


		public static function getApplicationID():String
		{
			return NativeApplication.nativeApplication.applicationID;
		}


		public static function applicationHasVersionNumber():Boolean
		{
			var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXML.namespace();
			return appXML.ns::versionNumber != undefined;
		}
		
		
		private static function isDigit(ch:String):Boolean
		{
			return ch >= "0" && ch <= "9";
		}
	}
}
