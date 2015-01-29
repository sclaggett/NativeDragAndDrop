package com.sclaggett.dnd
{
	/**
	 * Native drag and drop JavaScript functions. This file exists to separate the JavaScript functions that
	 * are injected into the browser DOM from the Actionscript code for improved readability.
	 */
	
	public class DragAndDropJS
	{
		/**
		 * Utility functions
		 */
		
		// Adds an event handler to an object using one of three methods: the W3C method, the IE method, or
		// the old school method.
		public static var JS_ADD_EVENT_HANDLE:String = "jsAddEventHandler";
		public static var INSERT_JS_ADD_EVENT_HANDLER:String =
			"document.insertScript = function () {" +
				"if (document." + JS_ADD_EVENT_HANDLE + " == null) {" +
					JS_ADD_EVENT_HANDLE + " = function (object, event, handler) {" +
						"if (object.addEventListener) {" +
							"object.addEventListener(event, handler, false);" +
						"} else if (object.attachEvent) {" +
							"object.attachEvent('on' + event, handler);" +
						"} else {" +
							"object['on' + event] = handler;" +
						"}" +
					"}" +
				"}" +
			"}";
		
		// Handler that prevents the default behavior of an event.
		public static var JS_PREVENT_DEFAULT:String = "jsPreventDefault";
		public static var INSERT_JS_PREVENT_DEFAULT:String =
			"document.insertScript = function () {" +
				"if (document." + JS_PREVENT_DEFAULT + " == null) {" +
					JS_PREVENT_DEFAULT + " = function (event) {" +
						"event = event || window.event;" +
						"if (event.stopPropagation()) {" +
							"event.stopPropagation();" +
						"}" +
						"if (event.preventDefault) {" +
							"event.preventDefault();" +
						"}" +
					"}" +
				"}" +
			"}";
		
		/**
		 * Initialization functions
		 */
		
		// Disables the drag and drop behavior of the main browser window. This is generally desirable 
		// because the user may accidentally drop a file outside of the Flash player. The default browser
		// behavior when this happens is to redirect away from the HTML page that contains this SWF and to 
		// load the dropped file in its place, which generally isn’t what the user intended. Returns true 
		// if successful.
		public static var JS_DISABLE_MAIN_WINDOW:String = "jsDisableMainWindow";
		public static var INSERT_JS_DISABLE_MAIN_WINDOW:String = 
			"document.insertScript = function () {" +
				"if (document." + JS_DISABLE_MAIN_WINDOW + " == null) {" +
					JS_DISABLE_MAIN_WINDOW + " = function () {" +
						JS_ADD_EVENT_HANDLE + "(window, 'dragover', " + JS_ON_DRAG_OVER_WINDOW + ");" +
						JS_ADD_EVENT_HANDLE + "(window, 'drop', " + JS_ON_DRAG_DROP_WINDOW + "); " +
						"return true;" +
					"}" +
				"}" +
			"}";
		
		// Makes sure the browser supports HTML5 FileReader. Returns true if FileReader support is available,
		// false otherwise. FileReader is a requirement to read in the contents of the dropped files.
		public static var JS_CHECK_FILE_READER:String = "jsCheckFileReader";
		public static var INSERT_JS_CHECK_FILE_READER:String = 
			"document.insertScript = function () {" +
				"if (document." + JS_CHECK_FILE_READER + " == null) {" +
					JS_CHECK_FILE_READER + " = function () {" +
						"return (window.FileReader != null);" +
					"}" +
				"}" +
			"}";
		
		// Adds the drag and drop event listeners to the Flash player. Returns true if successful or false if
		// the Flash player cannot be found.
		public static var JS_INITIALIZE_DRAG_AND_DROP:String = "jsInitializeDragAndDrop";
		public static var INSERT_JS_INITIALIZE_DRAG_AND_DROP:String =
			"document.insertScript = function () {" +
				"if (document." + JS_INITIALIZE_DRAG_AND_DROP + " == null) {" +
					JS_INITIALIZE_DRAG_AND_DROP + " = function (flashPlayerId, transferFiles, transferThreshold, " +
							"chunkedUploadSize, chunkedErrorLimit) {" +
						"document.flashPlayer = document.getElementById(flashPlayerId);" +
						"if (document.flashPlayer == null) {" +
							"return false;" +
						"}" +
						JS_ADD_EVENT_HANDLE + "(document.flashPlayer, 'dragenter', " + JS_ON_DRAG_ENTER + ");" +
						JS_ADD_EVENT_HANDLE + "(document.flashPlayer, 'dragleave', " + JS_ON_DRAG_LEAVE + ");" +
						JS_ADD_EVENT_HANDLE + "(document.flashPlayer, 'dragover', " + JS_ON_DRAG_OVER + ");" +
						JS_ADD_EVENT_HANDLE + "(document.flashPlayer, 'drop', " + JS_ON_DROP + ");" +
						"document.fileCache = new Object();" + 
						"document.transferFiles = transferFiles;" + 
						"document.transferThreshold = transferThreshold;" +
						"document.chunkedUploadSize = chunkedUploadSize;" +
						"document.chunkedErrorLimit = chunkedErrorLimit;" +
						"return true;" +
					"}" +
				"}" +
			"}";
		
		// Injects the hidden input field into the DOM that will be used to browse for files. Returns true if
		// successful.
		public static var JS_INJECT_BROWSE_INPUT:String = "jsInjectBrowseInput";
		public static var INSERT_JS_INJECT_BROWSE_INPUT:String =
			"document.insertScript = function () {" +
				"if (document." + JS_INJECT_BROWSE_INPUT + " == null) {" +
					JS_INJECT_BROWSE_INPUT + " = function () {" +
						"var browseDiv = document.createElement('div');" +
						"browseDiv.innerHTML = \"<input id='fileBrowser' type='file' multiple='true' " + 
							"style='display: none' />\";" +
						"var body = document.getElementsByTagName('body')[0];" +
						"body.appendChild(browseDiv);" +
						"var fileBrowser = document.getElementById('fileBrowser');" +
						"fileBrowser.addEventListener('change', " + JS_ON_FILES_SELECTED + ", false);" +
						"return true;" +
					"}" +
				"}" +
			"}";
		
		// Injects a hidden form into the DOM that will be used when uploading files. Returns true if successful.
		public static var JS_INJECT_UPLOAD_FORM:String = "jsInjectUploadForm";
		public static var INSERT_JS_INJECT_UPLOAD_FORM:String =
			"document.insertScript = function () {" +
				"if (document." + JS_INJECT_UPLOAD_FORM + " == null) {" +
					JS_INJECT_UPLOAD_FORM + " = function () {" +
						"var formDiv = document.createElement('div');" +
						"formDiv.innerHTML = \"<form id='uploadForm' enctype='multipart/form-data' " + 
							"style='display: none;' />\";" +
						"var body = document.getElementsByTagName('body')[0];" +
						"body.appendChild(formDiv);" +
						"return true;" +
					"}" +
				"}" +
			"}";
		
		/**
		 * File loading functions
		 */
		
		// Passes a file to the Flash player and then checks if all files have been loaded. Notifies the 
		// Flash player if the drop operation is complete.
		public static var JS_PASS_FILE_TO_FLASH:String = "jsPassFileToFlash";
		public static var INSERT_JS_PASS_FILE_TO_FLASH:String =
			"document.insertScript = function () {" +
				"if (document." + JS_PASS_FILE_TO_FLASH + " == null) {" +
					JS_PASS_FILE_TO_FLASH + " = function (file, filesTotal, data) {" +
						"document.filesLoaded += 1;" +
						"var cacheFile = document.flashPlayer." + DragAndDrop.AS3_ON_DROP_FILE + 
							"(file.name, file.size, file.type, file.lastModifiedDate, data, " + 
							"document.filesLoaded, filesTotal);" +
						"if (cacheFile == true) {" +
							"document.fileCache[file.name] = file;" +
						"}" +
						"if (document.filesLoaded == filesTotal) {" +
							"document.flashPlayer." + DragAndDrop.AS3_ON_DROP_STOP + "();" +
						"}" +
					"}" +
				"}" +
			"}";
		
		// Event handler that is invoked when a file is loaded. Calls the function above to pass the file to
		// the Flash player.
		public static var JS_ON_FILE_LOADED:String = "jsOnFileLoaded";
		public static var INSERT_JS_ON_FILE_LOADED:String =
			"document.insertScript = function () {" +
				"if (document." + JS_ON_FILE_LOADED + " == null) {" +
					JS_ON_FILE_LOADED + " = function (file, filesTotal) {" +
						"return function(event) {" +
							JS_PASS_FILE_TO_FLASH + "(file, filesTotal, event.target.result);" +
						"};" +
					"}" +
				"}" +
			"}";
		
		// Processes the list of files that originate from either a drag and drop event or the browser file 
		// selection dialog. Either initiates a load of the file contents or calls the function above to pass
		// the file to the Flash player.
		public static var JS_PROCESS_FILES:String = "jsProcessFiles";
		public static var INSERT_JS_PROCESS_FILES:String =
			"document.insertScript = function () {" +
				"if (document." + JS_PROCESS_FILES + " == null) {" +
					JS_PROCESS_FILES + " = function (files) {" +
						"document.filesLoaded = 0;" +
						"for (index = 0; index < files.length; index++) {" +
							"var file = files[index];" +
							"if ((document.transferFiles == true) && (file.size < document.transferThreshold)) {" +
								"var reader = new FileReader();" +
								"reader.onload = " + JS_ON_FILE_LOADED + "(file, files.length);" +
								"reader.readAsDataURL(file);" +
							"} else {" +
								JS_PASS_FILE_TO_FLASH + "(file, files.length, null);" +
							"}" +
						"}" +
					"}" +
				"}" +
			"}";

		// Schedules a list of files for processing by the above function after a 300 millisecond delay. The
		// purpose of this delay is to give the Flash player a chance to update the UI before the whole
		// system begins the task of processing the list of files.
		public static var JS_SCHEDULE_FILES:String = "jsScheduleFiles";
		public static var INSERT_JS_SCHEDULE_FILES:String =
			"document.insertScript = function () {" +
				"if (document." + JS_SCHEDULE_FILES + " == null) {" +
					JS_SCHEDULE_FILES + " = function (files) {" +
						"document.flashPlayer." + DragAndDrop.AS3_ON_DROP_START + "(files.length);" +
						"setTimeout(function() {" +
							JS_PROCESS_FILES + "(files);" +
						"}, 300);" +
					"}" +
				"}" +
			"}";

		/**
		 * Drag and drop functions
		 */
		
		// Drag over event handler for the main window. The drop effect is set to "none" to provide a visual
		// indication that the area outside the Flash player is not a drop target.
		public static var JS_ON_DRAG_OVER_WINDOW:String = "jsOnDragOverWindow";
		public static var INSERT_JS_ON_DRAG_OVER_WINDOW:String =
			"document.insertScript = function () {" +
				"if (document." + JS_ON_DRAG_OVER_WINDOW + " == null) {" +
					JS_ON_DRAG_OVER_WINDOW + " = function (event) {" +
						JS_PREVENT_DEFAULT + "(event);" +
						"if (event.dataTransfer) {" +
							"event.dataTransfer.dropEffect = '" + DragAndDrop.DROPEFFECT_NONE + "';" +
						"}" +
						"return false;" +
					"}" +
				"}" +
			"}";
		
		// Drop event handler for the main window.
		public static var JS_ON_DRAG_DROP_WINDOW:String = "jsOnDragDropWindow";
		public static var INSERT_JS_ON_DRAG_DROP_WINDOW:String =
			"document.insertScript = function () {" +
				"if (document." + JS_ON_DRAG_DROP_WINDOW + " == null) {" +
					JS_ON_DRAG_DROP_WINDOW + " = function (event) {" +
						JS_PREVENT_DEFAULT + "(event);" + 
						"return false;" +
					"}" +
				"}" +
			"}";
		
		// Drag enter event handler for the Flash player.
		public static var JS_ON_DRAG_ENTER:String = "jsOnDragEnter";
		public static var INSERT_JS_ON_DRAG_ENTER:String =
			"document.insertScript = function () {" +
				"if (document." + JS_ON_DRAG_ENTER + " == null) {" +
					JS_ON_DRAG_ENTER + " = function (event) {" +
						JS_PREVENT_DEFAULT + "(event);" +
						"document.flashPlayer." + DragAndDrop.AS3_ON_DRAG_ENTER + "();" +
						"return false;" +
					"}" +
				"}" +
			"}";
		
		// Drag leave event handler for the Flash player.
		public static var JS_ON_DRAG_LEAVE:String = "jsOnDragLeave";
		public static var INSERT_JS_ON_DRAG_LEAVE:String =
			"document.insertScript = function () {" +
				"if (document." + JS_ON_DRAG_LEAVE + " == null) {" +
					JS_ON_DRAG_LEAVE + " = function (event) {" +
						JS_PREVENT_DEFAULT + "(event);" +
						"document.flashPlayer." + DragAndDrop.AS3_ON_DRAG_LEAVE + "();" +
						"return false;" +
					"}" +
				"}" +
			"}";
		
		// Drag over event handler for the Flash player.
		public static var JS_ON_DRAG_OVER:String = "jsOnDragOver";
		public static var INSERT_JS_ON_DRAG_OVER:String =
			"document.insertScript = function () {" +
				"if (document." + JS_ON_DRAG_OVER + " == null) {" +
					JS_ON_DRAG_OVER + " = function (event) {" +
						JS_PREVENT_DEFAULT + "(event);" +
						"var dropEffect = document.flashPlayer." + DragAndDrop.AS3_ON_DRAG_OVER + 
							"(event.clientX - document.flashPlayer.offsetLeft, event.clientY - " + 
							"document.flashPlayer.offsetTop);" +
						"if (event.dataTransfer) {" +
							"event.dataTransfer.dropEffect = dropEffect;" +
						"}" +
						"return false;" +
					"}" +
				"}" +
			"}";
		
		// Drop event handler for the Flash player. Invokes the above function to schedule the dropped files
		// for processing.
		public static var JS_ON_DROP:String = "jsOnDrop";
		public static var INSERT_JS_ON_DROP:String =
			"document.insertScript = function () {" +
				"if (document." + JS_ON_DROP + " == null) {" +
					JS_ON_DROP + " = function (event) {" +
						JS_PREVENT_DEFAULT + "(event);" +
						"if (event.dataTransfer && event.dataTransfer.files) {" +
							JS_SCHEDULE_FILES + "(event.dataTransfer.files);" +
						"}" +
						"return false;" +
					"}" +
				"}" +
			"}";
		
		/**
		 * File browser functions
		 */
		
		// Invoked by the Actionscript code to create a browser file selection dialog. Returns true if
		// successful.
		public static var JS_BROWSE_FOR_FILES:String = "jsBrowseForFiles";
		public static var INSERT_JS_BROWSE_FOR_FILES:String =
			"document.insertScript = function () {" +
				"if (document." + JS_BROWSE_FOR_FILES + " == null) {" +
					JS_BROWSE_FOR_FILES + " = function () {" +
						"var fileBrowser = document.getElementById('fileBrowser');" +
						"fileBrowser.click();" +
						"return true;" +
					"}" +
				"}" +
			"}";
		
		// Event handler that is invoked when the user selects one or more files using the browser file 
		// selection dialog. Invokes the above function to schedule the selected files for processing.
		public static var JS_ON_FILES_SELECTED:String = "jsOnFilesSelected";
		public static var INSERT_JS_ON_FILES_SELECTED:String =
			"document.insertScript = function (){ " +
				"if (document." + JS_ON_FILES_SELECTED + " == null) {" +
					JS_ON_FILES_SELECTED + " = function (event) {" +
						"if (event.target.files) {" +
							JS_SCHEDULE_FILES + "(event.target.files);" +
						"}" +
					"}" +
				"}" +
			"}";
		
		/**
		 * Form-base file upload functions
		 */
		
		// Event handler that is invoked with information regarding the progress of a form-base upload.
		public static var JS_ON_FORM_UPLOAD_PROGRESS:String = "jsOnFormUploadProgress";
		public static var INSERT_JS_ON_FORM_UPLOAD_PROGRESS:String =
			"document.insertScript = function () {" +
				"if (document." + JS_ON_FORM_UPLOAD_PROGRESS + " == null) {" +
					JS_ON_FORM_UPLOAD_PROGRESS + " = function (file) {" +
						"return function(event) {" +
							"var percentComplete = -1;" +
							"if (event.lengthComputable) {" +
								"percentComplete = Math.round(event.loaded * 100 / event.total);" +
							"}" +
							"document.flashPlayer." + DragAndDrop.AS3_ON_UPLOAD_PROGRESS + "(file.name, " + 
								"percentComplete);" +
						"};" +
					"}" +
				"}" +
			"}";
		
		// Event handler that is invoked when a form-based file upload is complete.
		public static var JS_ON_FORM_UPLOAD_COMPLETE:String = "jsOnFormUploadComplete";
		public static var INSERT_JS_ON_FORM_UPLOAD_COMPLETE:String =
			"document.insertScript = function () {" +
				"if (document." + JS_ON_FORM_UPLOAD_COMPLETE + " == null) {" +
					JS_ON_FORM_UPLOAD_COMPLETE + " = function (file, filesTotal) {" +
						"return function(event) {" +
							"document.filesUploaded += 1;" +
							"document.flashPlayer." + DragAndDrop.AS3_ON_UPLOAD_FILE + "(file.name, " + 
								"event.target.responseText, document.filesUploaded, filesTotal);" +
							"if (document.filesUploaded == filesTotal) {" +
								"document.flashPlayer." + DragAndDrop.AS3_ON_UPLOAD_STOP + "();" +
							"}" +
						"};" +
					"}" +
				"}" +
			"}";
		
		// Event handler that is invoked when a form-based file upload encounters an error.
		public static var JS_ON_FORM_UPLOAD_ERROR:String = "jsOnFormUploadError";
		public static var INSERT_JS_ON_FORM_UPLOAD_ERROR:String =
			"document.insertScript = function () {" +
				"if (document." + JS_ON_FORM_UPLOAD_ERROR + " == null) {" +
					JS_ON_FORM_UPLOAD_ERROR + " = function (file) {" +
						"return function(event) {" +
							"document.flashPlayer." + DragAndDrop.AS3_ON_UPLOAD_ERROR + "(file.name);" +
						"};" +
					"}" +
				"}" +
			"}";
		
		// Uploads the specified files to the given URL using a form-based mechanism. Returns true if successful.
		public static var JS_FORM_UPLOAD_FILES:String = "jsFormUploadFiles";
		public static var INSERT_JS_FORM_UPLOAD_FILES:String =
			"document.insertScript = function () {" +
				"if (document." + JS_FORM_UPLOAD_FILES + " == null) {" +
					JS_FORM_UPLOAD_FILES + " = function (fileList) {" +
						"document.flashPlayer." + DragAndDrop.AS3_ON_UPLOAD_START + "(fileList.length);" +
						"document.filesUploaded = 0;" +
						"for (index = 0; index < fileList.length; index++) {" +
							"var uploadFile = fileList[index];" +
							"var file = document.fileCache[uploadFile.name];" +
							"var uploadRequest = new XMLHttpRequest();" +
							"uploadRequest.addEventListener('progress', " + JS_ON_FORM_UPLOAD_PROGRESS + "(file), " + 
								"false);" +
							"uploadRequest.addEventListener('load', " + JS_ON_FORM_UPLOAD_COMPLETE + "(file, " + 
								"fileList.length), false);" +
							"uploadRequest.addEventListener('error', " + JS_ON_FORM_UPLOAD_ERROR + "(file), false);" +
							"uploadRequest.addEventListener('abort', " + JS_ON_FORM_UPLOAD_ERROR + "(file), false);" +
							"var formData = new FormData(document.getElementById('uploadForm'));" +
							"formData.append('filedata', file);" +
							"uploadRequest.open(uploadFile.method, uploadFile.url);" +
							"uploadRequest.send(formData);" +
						"}" +
						"return true;" +
					"}" +
				"}" +
			"}";
		
		/**
		 * Chunked file upload functions
		 */

		// Event handler that is invoked when a chunk has been asynchronously uploaded to the server.
		public static var JS_ON_CHUNKED_UPLOAD_COMPLETE:String = "jsOnChunkedUploadComplete";
		public static var INSERT_JS_ON_CHUNKED_UPLOAD_COMPLETE:String =
			"document.insertScript = function () {" +
				"if (document." + JS_ON_CHUNKED_UPLOAD_COMPLETE + " == null) {" +
					JS_ON_CHUNKED_UPLOAD_COMPLETE + " = function (event) {" +
						"if (document.uploadCancelled == true) {" +
							"return;" +
						"}" +
						"if (event.target.status == 200) {" +
							"document.currentChunkNumber += 1;" +
							"document.currentFileOffset += document.chunkSize;" +
							"document.flashPlayer." + DragAndDrop.AS3_ON_UPLOAD_PROGRESS + "(document.currentFile.name, " +
								"document.currentFileOffset * 100 / document.currentFile.size);" +
							"if (" + JS_CHUNKED_READ_FILE + "() == false) {" +
								"document.filesUploaded += 1;" +
								"document.flashPlayer." + DragAndDrop.AS3_ON_UPLOAD_FILE + "(document.currentUploadFile.name, '', " +
									"document.filesUploaded, document.uploadFileList.length, document.currentChunkNumber);" +
								"if (" + JS_CHUNKED_UPLOAD_NEXT_FILE + "() == false) {" +
									"document.flashPlayer." + DragAndDrop.AS3_ON_UPLOAD_STOP + "();" +
								"}" +
							"}" +
						"} else {" +
							"document.errorCount += 1;" +
							"if (document.errorCount < document.chunkedErrorLimit) {" +
								JS_CHUNKED_UPLOAD_FILE + "();" +
							"} else {" +
								"document.flashPlayer." + DragAndDrop.AS3_ON_UPLOAD_ERROR + "(document.currentUploadFile.name);" +
							"}" +
						"}" +
					"}" +
				"}" +
			"}";
			
		// Event handler that is invoked when an error is encountered while asynchronously uploading a chunk to the server.
		public static var JS_ON_CHUNKED_UPLOAD_ERROR:String = "jsOnChunkedUploadError";
		public static var INSERT_JS_ON_CHUNKED_UPLOAD_ERROR:String =
			"document.insertScript = function () {" +
				"if (document." + JS_ON_CHUNKED_UPLOAD_ERROR + " == null) {" +
					JS_ON_CHUNKED_UPLOAD_ERROR + " = function (event) {" +
						"if (document.uploadCancelled == true) {" +
							"return;" +
						"}" +
						"document.errorCount += 1;" +
						"if (document.errorCount < document.chunkedErrorLimit) {" +
							JS_CHUNKED_UPLOAD_FILE + "();" +
						"} else {" +
							"document.flashPlayer." + DragAndDrop.AS3_ON_UPLOAD_ERROR + "(document.currentUploadFile.name);" +
						"}" +
					"}" +
				"}" +
			"}";
		
		// Starts asynchronously uploading the next file on the list as a series of chunks.
		public static var JS_CHUNKED_UPLOAD_NEXT_FILE:String = "jsChunkedUploadNextFile";
		public static var INSERT_JS_CHUNKED_UPLOAD_NEXT_FILE:String =
			"document.insertScript = function () {" +
				"if (document." + JS_CHUNKED_UPLOAD_NEXT_FILE + " == null) {" +
					JS_CHUNKED_UPLOAD_NEXT_FILE + " = function () {" +
						"if (document.filesUploaded >= document.uploadFileList.length) {" +
							"return false;" +
						"}" +
						"document.currentUploadFile = document.uploadFileList[document.filesUploaded];" +
						"document.currentFile = document.fileCache[document.currentUploadFile.name];" +
						"document.currentFileOffset = 0;" +
						"document.currentChunkNumber = 0;" +
						"document.flashPlayer." + DragAndDrop.AS3_ON_UPLOAD_PROGRESS + "(document.currentFile.name, 0);" +
						"return " + JS_CHUNKED_READ_FILE + "();" +
					"}" +
				"}" +
			"}";

		// Asynchronously reads the next chunk of the file that is currently being uploaded.
		public static var JS_CHUNKED_READ_FILE:String = "jsChunkedReadFile";
		public static var INSERT_JS_CHUNKED_READ_FILE:String =
			"document.insertScript = function () {" +
				"if (document." + JS_CHUNKED_READ_FILE + " == null) {" +
					JS_CHUNKED_READ_FILE + " = function () {" +
						"if (document.currentFileOffset >= document.currentFile.size) {" +
							"return false;" +
						"}" +
						"if ((document.currentFileOffset + document.chunkedUploadSize) <= document.currentFile.size) {" +
							"document.chunkSize = document.chunkedUploadSize;" +
						"} else {" +
							"document.chunkSize = document.currentFile.size - document.currentFileOffset;" +
						"}" +
						"document.fileReader.readAsBinaryString(document.currentFile.slice(document.currentFileOffset, document.currentFileOffset + document.chunkSize));" +
						"return true;" +
					"}" +
				"}" +
			"}";
		
		// Event handler that is invoked when an asynchronous file read is complete.
		public static var JS_ON_CHUNKED_READER_LOAD_END:String = "jsOnChunkedReaderLoadEnd";
		public static var INSERT_JS_ON_CHUNKED_READER_LOAD_END:String =
			"document.insertScript = function () {" +
				"if (document." + JS_ON_CHUNKED_READER_LOAD_END + " == null) {" +
					JS_ON_CHUNKED_READER_LOAD_END + " = function (event) {" +
						"if (event.target.readyState == FileReader.DONE) {" +
							"document.chunkSize = event.loaded;" +
							"document.currentChunk = event.target.result;" +
							"document.errorCount = 0;" +
							JS_CHUNKED_UPLOAD_FILE + "();" +
						"}" +
					"}" +
				"}" +
			"}";
		
		// Start an asynchronous upload of the current chunk of binary data.
		public static var JS_CHUNKED_UPLOAD_FILE:String = "jsChunkedUploadFile";
		public static var INSERT_JS_CHUNKED_UPLOAD_FILE:String =
			"document.insertScript = function () {" +
				"if (document." + JS_CHUNKED_UPLOAD_FILE + " == null) {" +
					JS_CHUNKED_UPLOAD_FILE + " = function () {" +
						"if (document.uploadCancelled == true) {" +
							"return;" +
						"}" +
						"var xmlHttpRequest = new XMLHttpRequest();" +
						"xmlHttpRequest.addEventListener('load', " + JS_ON_CHUNKED_UPLOAD_COMPLETE + ", false);" +
						"xmlHttpRequest.addEventListener('error', " + JS_ON_CHUNKED_UPLOAD_ERROR + ", false);" + 
						"xmlHttpRequest.open(document.currentUploadFile.method, document.currentUploadFile.url + (document.currentChunkNumber + 1));" +
						"var blob = new Blob([document.currentChunk], {type:'application/x-binary'});" +
						"xmlHttpRequest.send(blob);" +
					"}" +
				"}" +
			"}";
		
		// Uploads the specified files to the given URL using a chunked HTTP mechanism. Returns true if successful.
		public static var JS_CHUNKED_UPLOAD_FILES:String = "jsChunkedUploadFiles";
		public static var INSERT_JS_CHUNKED_UPLOAD_FILES:String =
			"document.insertScript = function () {" +
				"if (document." + JS_CHUNKED_UPLOAD_FILES + " == null) {" +
					JS_CHUNKED_UPLOAD_FILES + " = function (fileList) {" +
						"document.flashPlayer." + DragAndDrop.AS3_ON_UPLOAD_START + "(fileList.length);" +
						"document.fileReader = new FileReader();" +
						"document.fileReader.onloadend = " + JS_ON_CHUNKED_READER_LOAD_END + ";" +
						"document.uploadFileList = fileList;" +
						"document.filesUploaded = 0;" +
						"document.uploadCancelled = false;" +
						"return " + JS_CHUNKED_UPLOAD_NEXT_FILE + "();" +
					"}" +
				"}" +
			"}";

		// Cancels and pending chunked upload
		public static var JS_CHUNKED_UPLOAD_CANCEL:String = "jsChunkedUploadCancel";
		public static var INSERT_JS_CHUNKED_UPLOAD_CANCEL:String =
			"document.insertScript = function () {" +
				"if (document." + JS_CHUNKED_UPLOAD_CANCEL + " == null) {" +
					JS_CHUNKED_UPLOAD_CANCEL + " = function () {" +
						"document.uploadCancelled = true;" +
						"document.flashPlayer." + DragAndDrop.AS3_ON_UPLOAD_CANCELLED + "();" +
						"return true;" +
					"}" +
				"}" +
			"}";
	}
}
