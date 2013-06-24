package tetragon.env.update.airupdater.core
{
	import tetragon.env.update.airupdater.descriptors.StateDescriptor;
	import tetragon.env.update.airupdater.utils.Constants;
	import tetragon.env.update.airupdater.utils.FileUtils;

	import com.hexagonstar.util.debug.HLog;

	import flash.filesystem.File;
	
	
	public class UpdaterState
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _descriptor:StateDescriptor;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function resetUpdateData():void
		{
			descriptor.currentVersion = "";
			descriptor.previousVersion = "";
			descriptor.storage = null;
			FileUtils.deleteFile(FileUtils.getLocalUpdateFile());
			FileUtils.deleteFile(FileUtils.getLocalDescriptorFile());
			descriptor.updaterLaunched = false;
		}
		
		
		public function removePreviousStorageData(previousStorage:File):void
		{
			if (!previousStorage || !previousStorage.exists) return;
			
			var file:File = previousStorage.resolvePath(Constants.UPDATER_FOLDER + "/" + Constants.STATE_FILE);
			FileUtils.deleteFile(file);
			file = previousStorage.resolvePath(Constants.UPDATER_FOLDER + "/" + Constants.UPDATE_LOCAL_FILE);
			FileUtils.deleteFile(file);
			file = previousStorage.resolvePath(Constants.UPDATER_FOLDER + "/" + Constants.DESCRIPTOR_LOCAL_FILE);
			FileUtils.deleteFile(file);
			file = previousStorage.resolvePath(Constants.UPDATER_FOLDER);
			FileUtils.deleteFolder(file);
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
			var documentsFile:File = FileUtils.getDocumentsStateFile();
			FileUtils.saveXMLToFile(_descriptor.getXML(), documentsFile);
		}
		
		
		public function saveToStorage():void
		{
			var storageFile:File = FileUtils.getStorageStateFile();
			FileUtils.saveXMLToFile(_descriptor.getXML(), storageFile);
		}
		
		
		public function load():void
		{
			var xml:XML;
			var storageFile:File = FileUtils.getStorageStateFile();
			var documentsFile:File = FileUtils.getDocumentsStateFile();

			if (!storageFile.exists)
			{
				// try documents folder
				// file doesn't exists in documents
				if (!documentsFile.exists)
				{
					// create a default state
					_descriptor = StateDescriptor.defaultState();
					saveToStorage();
				}
				else
				{
					// read the state from the documents folder
					try
					{
						xml = FileUtils.readXMLFromFile(documentsFile);
						_descriptor = new StateDescriptor(xml);
						_descriptor.validate();
						saveToStorage();
					}
					catch(err:Error)
					{
						HLog.warn(toString() + ": Invalid state (1) - " + err.message);
						_descriptor = StateDescriptor.defaultState();
						saveToStorage();
					}
				}
			}
			else
			{
				// try to read from storage
				try
				{
					xml = FileUtils.readXMLFromFile(storageFile);
					_descriptor = new StateDescriptor(xml);
					_descriptor.validate();
				}
				catch(err:Error)
				{
					HLog.warn(toString() + ": Invalid state (2) - " + err.message);
					_descriptor = StateDescriptor.defaultState();
					saveToStorage();
				}
			}
			
			// if the update file is missing
			// someone tampered.
			var updateFile:File = FileUtils.getLocalUpdateFile();
			if (descriptor.currentVersion && !updateFile.exists && !descriptor.updaterLaunched)
			{
				HLog.warn(toString() + ": Missing update file!");
				_descriptor = StateDescriptor.defaultState();
				saveToStorage();
			}
			FileUtils.deleteFile(documentsFile);
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
		
		public function get descriptor():StateDescriptor
		{
			return _descriptor;
		}
	}
}
