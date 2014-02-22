package com.sclaggett.dnd
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;

	public class DragAndDrop
	{
		/***
		 * Drop effect constants.
		 **/
		
		public static const DROPEFFECT_NONE:String = "none";
		public static const DROPEFFECT_COPY:String = "copy";
		public static const DROPEFFECT_LINK:String = "link";
		public static const DROPEFFECT_MOVE:String = "move";

		/***
		 * Configuration
		 **/

		// Flag that specifies if drag and drop should be disabled on the main browser (default value is 
		// true).  This is generally desirable because the user may accidentally drop a file outside of 
		// the Flash player if it does not occupy the full browser window. The default browser behavior 
		// when this happens is to redirect away from the HTML page that contains this SWF and load the 
		// dropped file in its place, which probably wasn't what the user intended to do.
		public static function set disableMainWindow(value:Boolean):void
		{
			if (_initialized == true)
			{
				throw Error("Configuration cannot be changed after control has been initialized");
			}
			_disableMainWindow = value;
		}

		// Flag that specifies if the dropped files should be loaded by the JavaScript code, encoded and 
		// passed to the Flash player (default value is true). Set to false is the file contents are not 
		// needed to improve performance.
		public static function set enableFileTransfer(value:Boolean):void
		{
			if (_initialized == true)
			{
				throw Error("Configuration cannot be changed after control has been initialized");
			}
			_enableFileTransfer = value;
		}
		
		// Threshold number of bytes above which the file contents will not be loaded into memory and
		// passed to the Flash player (default value if 40 MB). Larger files take longer to load and
		// require more memory.
		public static function set fileTransferThreshold(value:int):void
		{
			if (_initialized == true)
			{
				throw Error("Configuration cannot be changed after control has been initialized");
			}
			_fileTransferThreshold = value;
		}
		
		// Flag that indicates if the file selection dialog of the browser will be enabled (default value
		// is true). Set to false if this functionality is not needed.
		public static function set enableFileBrowse(value:Boolean):void
		{
			if (_initialized == true)
			{
				throw Error("Configuration cannot be changed after control has been initialized");
			}
			_enableFileBrowse = value;
		}
		
		// Flag that indicates if the file upload mechanism will be enabled (default value is true). Set
		// to false if this functionality is not needed.
		public static function set enableFileUpload(value:Boolean):void
		{
			if (_initialized == true)
			{
				throw Error("Configuration cannot be changed after control has been initialized");
			}
			_enableFileUpload = value;
		}

		// Callback that will be invoked continuously when a drag operation is in progress. The function 
		// should have the following signature:
		//	function DragOverCallback(clientX:int, clientY:int):String
		// The position coodinates are relative to the upper left corner of the stage. Return one of the four
		// drop effect constants defined above to set the mouse pointer: DROPEFFECT_NONE, DROPEFFECT_COPY, 
		// DROPEFFECT_LINK, or DROPEFFECT_MOVE.
		public static function set dragOverCallback(value:Function):void
		{
			_dragOverCallback = value;
		}
		
		// Callback that will be invoked once for each file that is dropped on the Flash player. The function
		// should have the following signature:
		//	function DropFileCallback(file:DragAndDropFile, filesLoaded:int, filesTotal:int):Boolean
		// Return true if the JavaScript should cache the reference for the file for later upload to the
		// server.
		public static function set dropFileCallback(value:Function):void
		{
			_dropFileCallback = value;
		}

		/***
		 * Public functions
		 **/
		
		// Initializes the drag and drop mechanism. Returns an empty string if successful, or a description
		// of the error otherwise.
		public static function initialize():String
		{
			try
			{
				if (_initialized == true)
				{
					throw Error("Control has already been initialized");
				}

				// Inject the javascript functions into the browser.
				ExternalInterface.call(DragAndDropJS.INSERT_JS_ADD_EVENT_HANDLER);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_PREVENT_DEFAULT);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_DISABLE_MAIN_WINDOW);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_CHECK_FILE_READER);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_INITIALIZE_DRAG_AND_DROP);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_INJECT_BROWSE_INPUT);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_INJECT_UPLOAD_FORM);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_PASS_FILE_TO_FLASH);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_ON_FILE_LOADED);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_PROCESS_FILES);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_SCHEDULE_FILES);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_ON_DRAG_OVER_WINDOW);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_ON_DRAG_DROP_WINDOW);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_ON_DRAG_ENTER);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_ON_DRAG_LEAVE);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_ON_DRAG_OVER);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_ON_DROP);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_BROWSE_FOR_FILES);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_ON_FILES_SELECTED);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_ON_UPLOAD_PROGRESS);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_ON_UPLOAD_COMPLETE);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_ON_UPLOAD_ERROR);
				ExternalInterface.call(DragAndDropJS.INSERT_JS_UPLOAD_FILES);
				
				// Add callbacks so the JavaScript can invoke Actionscript code.
				ExternalInterface.addCallback(AS3_ON_DRAG_ENTER, onDragEnter);
				ExternalInterface.addCallback(AS3_ON_DRAG_OVER, onDragOver);
				ExternalInterface.addCallback(AS3_ON_DRAG_LEAVE, onDragLeave);
				ExternalInterface.addCallback(AS3_ON_DROP_START, onDropStart);
				ExternalInterface.addCallback(AS3_ON_DROP_FILE, onDropFile);
				ExternalInterface.addCallback(AS3_ON_DROP_STOP, onDropStop);
				ExternalInterface.addCallback(AS3_ON_UPLOAD_START, onUploadStart);
				ExternalInterface.addCallback(AS3_ON_UPLOAD_PROGRESS, onUploadProgress);
				ExternalInterface.addCallback(AS3_ON_UPLOAD_FILE, onUploadFile);
				ExternalInterface.addCallback(AS3_ON_UPLOAD_STOP, onUploadStop);
				ExternalInterface.addCallback(AS3_ON_UPLOAD_ERROR, onUploadError);
				
				// Disable drag and drop on the main browser window.
				var success:Boolean;
				if (_disableMainWindow == true)
				{
					success = ExternalInterface.call(DragAndDropJS.JS_DISABLE_MAIN_WINDOW);
					if (success != true)
					{
						return "Failed to disable main window";
					}
				}
				
				// Make sure the HTML5 class FileReader is supported.
				if (_enableFileTransfer == true)
				{
					success = ExternalInterface.call(DragAndDropJS.JS_CHECK_FILE_READER) as Boolean;
					if (success != true)
					{
						return "Browser does not support the HTML5 FileReader";
					}
				}
				
				// Initialize drag and drop on the JavaScript side.
				success = ExternalInterface.call(DragAndDropJS.JS_INITIALIZE_DRAG_AND_DROP, ExternalInterface.objectID,
					_enableFileTransfer, _fileTransferThreshold) as Boolean;
				if (success != true)
				{
					return "Failed to initialize drag and drop";
				}
				
				// Inject an HTML input control so the native file browser dialog can be opened programmatically.
				if (_enableFileBrowse == true)
				{
					success = ExternalInterface.call(DragAndDropJS.JS_INJECT_BROWSE_INPUT) as Boolean;
					if (success != true)
					{
						return "Failed to inject browse input";
					}
				}
				
				// Inject an HTML form to enable file to be uploaded using the native browser upload mechanism.
				if (_enableFileUpload == true)
				{
					success = ExternalInterface.call(DragAndDropJS.JS_INJECT_UPLOAD_FORM) as Boolean;
					if (success != true)
					{
						return "Failed to inject upload form";
					}
				}
				_initialized = true;
			}
			catch(err:Error)
			{
				return err.message;
			}
			return "";
		}
		
		// Opens the native file selection dialog of the web browser.
		public static function browseForFiles():Boolean
		{
			if (_initialized == false)
			{
				throw Error("Control has not been initialized");
			}
			if (_enableFileBrowse == false)
			{
				throw Error("Browse for files not enabled")
			}
			return ExternalInterface.call(DragAndDropJS.JS_BROWSE_FOR_FILES) as Boolean;
		}
		
		// Upload the files that the browser has cached to the given URLs.
		public static function uploadFiles(fileList:Array):Boolean
		{
			if (_initialized == false)
			{
				throw Error("Control has not been initialized");
			}
			if (_enableFileUpload == false)
			{
				throw Error("File upload not enabled");
			}
			return ExternalInterface.call(DragAndDropJS.JS_UPLOAD_FILES, fileList) as Boolean;
		}

		/***
		 * IEventDispatcher functions
		 **/
		
		// We want this control to function as a singleton, so the IEventDispatcher interface functions are 
		// implemented here and wrapped around an internal object.
		protected static var _eventDispatcher:EventDispatcher = new EventDispatcher();
		
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, 
												priority:int = 0, useWeakReference:Boolean = false):void
		{
			_eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public static function dispatchEvent(event:Event):Boolean
		{
			return _eventDispatcher.dispatchEvent(event);
		}
		
		public static function hasEventListener(type:String):Boolean
		{
			return _eventDispatcher.hasEventListener(type);
		}
		
		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			_eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public static function willTrigger(type:String):Boolean
		{
			return _eventDispatcher.willTrigger(type);
		}
		
		/***
		 * Internal constants, variables, and functions
		 **/
		
		// Actionscript functions exposed to the JavaScript code through ExternalInterface.
		public static const AS3_ON_DRAG_ENTER:String = "asOnDragEnter";
		public static const AS3_ON_DRAG_OVER:String = "asOnDragOver";
		public static const AS3_ON_DRAG_LEAVE:String = "asOnDragLeave";
		public static const AS3_ON_DROP_START:String = "asOnDropStart";
		public static const AS3_ON_DROP_FILE:String = "asOnDropFile";
		public static const AS3_ON_DROP_STOP:String = "asOnDropStop";
		public static const AS3_ON_UPLOAD_START:String = "asOnUploadStart";
		public static const AS3_ON_UPLOAD_PROGRESS:String = "asOnUploadProgress";
		public static const AS3_ON_UPLOAD_FILE:String = "asOnUploadFile";
		public static const AS3_ON_UPLOAD_STOP:String = "asOnUploadStop";
		public static const AS3_ON_UPLOAD_ERROR:String = "asOnUploadError";

		// Internal variables.
		protected static var _disableMainWindow:Boolean = true;
		protected static var _enableFileTransfer:Boolean = true;
		protected static var _fileTransferThreshold:int = 40 * 1024 * 1024;
		protected static var _enableFileBrowse:Boolean = true;
		protected static var _enableFileUpload:Boolean = true;
		protected static var _dragOverCallback:Function;
		protected static var _dropFileCallback:Function;
		protected static var _initialized:Boolean = false;

		// Called once when the user drags one or more items over the Flash player.
		protected static function onDragEnter():void
		{
			dispatchEvent(new DragAndDropEvent(DragAndDropEvent.DRAG_ENTER));
		}
		
		// Called repeatedly as the user is dragging one or more items over the Flash player. The parameters 
		// contains the position of the mouse point relative to the upper left corner of the stage. Return
		// one of the drop effect constants to set the mouse cursor.
		protected static function onDragOver(clientX:int, clientY:int):String
		{
			if (_dragOverCallback != null)
			{
				return _dragOverCallback(clientX, clientY);
			}
			else
			{
				return DROPEFFECT_NONE;
			}
		}
		
		// Called once when the user drags one or more items away from the Flash player without dropping.
		protected static function onDragLeave():void
		{
			dispatchEvent(new DragAndDropEvent(DragAndDropEvent.DRAG_LEAVE));
		}
		
		// Called when the user drops one or more items on the Flash player. The parameter contains the total
		// number of items that have been dropped.
		protected static function onDropStart(filesTotal:int):void
		{
			dispatchEvent(DragAndDropEvent.DropStart(filesTotal));
		}
		
		// Called once for each file that the user has dropped on the Flash player. The parameters contain
		// the file name, size, type, modified date, and data if the file contents were loaded. Also included
		// are the number of files that have been loaded and the total number of files that are being loaded.
		protected static function onDropFile(name:String, size:int, type:String, modifiedDate:Date,
											 data:String, filesLoaded:int, filesTotal:int):Boolean
		{
			if (_dropFileCallback != null)
			{
				var file:DragAndDropFile = new DragAndDropFile();
				file.name = name;
				file.size = size;
				file.type = type;
				file.modifiedDate = modifiedDate;
				file.data = data;
				return _dropFileCallback(file, filesLoaded, filesTotal);
			}
			else
			{
				return false;
			}
		}
		
		// Called when all files that were dropped have been transferred to the Flash player.
		protected static function onDropStop():void
		{
			dispatchEvent(new DragAndDropEvent(DragAndDropEvent.DROP_STOP));
		}
		
		// Called when the upload of one or more files is starting. The parameter contains the total number
		// of files that will be uploaded.
		protected static function onUploadStart(filesTotal:int):void
		{
			dispatchEvent(DragAndDropEvent.UploadStart(filesTotal));
		}
		
		// Called when the browser notifies the JavaScript of the progress of an upload. The parameters
		// contain the name of the file and the percent complete.
		protected static function onUploadProgress(fileName:String, percentComplete:int):void
		{
			dispatchEvent(DragAndDropEvent.UploadProgress(fileName, percentComplete));
		}
		
		// Called when the upload of a file to the server is complete. The parameters contain the name of
		// the file, any response string returned by the server, the number of files that have been uploaded,
		// and the total number of files that are being loaded.
		protected static function onUploadFile(fileName:String, serverResponse:String, filesUploaded:int, 
											   filesTotal:int):void
		{
			dispatchEvent(DragAndDropEvent.UploadFile(fileName, serverResponse, filesUploaded, filesTotal));
		}

		// Called when the upload of all files is complete.
		protected static function onUploadStop():void
		{
			dispatchEvent(new DragAndDropEvent(DragAndDropEvent.UPLOAD_STOP));
		}

		// Called when the upload of a file encounters an error. The parameter contains the name of the file
		// that failed to upload.
		protected static function onUploadError(fileName:String):void
		{
			dispatchEvent(DragAndDropEvent.UploadError(fileName));
		}
	}
}
