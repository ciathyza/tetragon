package tetragon.env.update.au.core
{
	import tetragon.env.update.au.utils.AUConstants;

	import flash.utils.ByteArray;
	
	
	/**
	 * AIRUnpackager class.
	 */
	public class AUAIRUnpackager extends AUUCFUnpackager
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _descriptorXML:XML;
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get descriptorXML():XML
		{
			return _descriptorXML;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		override protected function doDone():void
		{
			if (_descriptorXML == null)
			{
				fail("META-INF/AIR/application.xml must exist in the AIR file.",
					AUConstants.ERROR_AIR_MISSING_APPLICATION_XML);
			}
		}
		
		
		override protected function doFile(fileNumber:uint, path:String, data:ByteArray):Boolean
		{
			if (fileNumber == 0) return true;
			if (fileNumber == 1 && path != "META-INF/AIR/application.xml")
			{
				fail("META-INF/AIR/application.xml must be the second file in an AIR file.",
					AUConstants.ERROR_AIR_MISSING_APPLICATION_XML);
			}
			_descriptorXML = new XML(data.toString());
			// stop after the second file
			return false;
		}
	}
}
