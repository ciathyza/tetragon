package tetragon.env.update.au.core
{
	import tetragon.debug.Log;
	import tetragon.env.update.au.descriptors.AUStateDescriptor;
	import tetragon.env.update.au.utils.AUConstants;
	import tetragon.env.update.au.utils.AUFileUtils;

	import flash.filesystem.File;
	
	
	public class AUUpdaterState
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _descriptor:AUStateDescriptor;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function resetUpdateData():void
		{
			descriptor.currentVersion = "";
			descriptor.previousVersion = "";
			descriptor.storage = null;
			AUFileUtils.deleteFile(AUFileUtils.getLocalUpdateFile());
			AUFileUtils.deleteFile(AUFileUtils.getLocalDescriptorFile());
			descriptor.updaterLaunched = false;
		}
		
		
		public function removePreviousStorageData(previousStorage:File):void
		{
			if (!previousStorage || !previousStorage.exists) return;
			
			var file:File = previousStorage.resolvePath(AUConstants.UPDATER_FOLDER + "/" + AUConstants.STATE_FILE);
			AUFileUtils.deleteFile(file);
			file = previousStorage.resolvePath(AUConstants.UPDATER_FOLDER + "/" + AUConstants.UPDATE_LOCAL_FILE);
			AUFileUtils.deleteFile(file);
			file = previousStorage.resolvePath(AUConstants.UPDATER_FOLDER + "/" + AUConstants.DESCRIPTOR_LOCAL_FILE);
			AUFileUtils.deleteFile(file);
			file = previousStorage.resolvePath(AUConstants.UPDATER_FOLDER);
			AUFileUtils.deleteFolder(file);
		}
		
		
		public function addFailedUpdate(version:String):void
		{
			descriptor.addFailedUpdate(version);
		}
		
		
		public function removeAllFailedUpdates():void
		{
			descriptor.removeAllFailedUpdates();
		}
		
		
		public function saveToDocuments():void
		{
			var documentsFile:File = AUFileUtils.getDocumentsStateFile();
			AUFileUtils.saveXMLToFile(_descriptor.getXML(), documentsFile);
		}
		
		
		public function saveToStorage():void
		{
			var storageFile:File = AUFileUtils.getStorageStateFile();
			AUFileUtils.saveXMLToFile(_descriptor.getXML(), storageFile);
		}
		
		
		public function load():void
		{
			var xml:XML;
			var storageFile:File = AUFileUtils.getStorageStateFile();
			var documentsFile:File = AUFileUtils.getDocumentsStateFile();

			if (!storageFile.exists)
			{
				// try documents folder
				// file doesn't exists in documents
				if (!documentsFile.exists)
				{
					// create a default state
					_descriptor = AUStateDescriptor.defaultState();
					saveToStorage();
				}
				else
				{
					// read the state from the documents folder
					try
					{
						xml = AUFileUtils.readXMLFromFile(documentsFile);
						_descriptor = new AUStateDescriptor(xml);
						_descriptor.validate();
						saveToStorage();
					}
					catch (err:Error)
					{
						Log.warn("Invalid state (1) - " + err.message, this);
						_descriptor = AUStateDescriptor.defaultState();
						saveToStorage();
					}
				}
			}
			else
			{
				// try to read from storage
				try
				{
					xml = AUFileUtils.readXMLFromFile(storageFile);
					_descriptor = new AUStateDescriptor(xml);
					_descriptor.validate();
				}
				catch (err:Error)
				{
					Log.warn("Invalid state (2) - " + err.message, this);
					_descriptor = AUStateDescriptor.defaultState();
					saveToStorage();
				}
			}
			
			// if the update file is missing
			// someone tampered.
			var updateFile:File = AUFileUtils.getLocalUpdateFile();
			if (descriptor.currentVersion && !updateFile.exists && !descriptor.updaterLaunched)
			{
				Log.warn("Missing update file!", this);
				_descriptor = AUStateDescriptor.defaultState();
				saveToStorage();
			}
			AUFileUtils.deleteFile(documentsFile);
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "UpdaterState";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get descriptor():AUStateDescriptor
		{
			return _descriptor;
		}
	}
}
