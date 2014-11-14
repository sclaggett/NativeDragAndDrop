package com.sclaggett.dnd
{
	import flash.events.Event;

	public class DragAndDropEvent extends Event
	{
		// Events types
		public static const DRAG_ENTER:String = "dndDragEnter";
		public static const DRAG_LEAVE:String = "dndDragLeave";
		public static const DROP_START:String = "dndDropStart";
		public static const DROP_STOP:String = "dndDropStop";
		public static const UPLOAD_START:String = "dndUploadStart";
		public static const UPLOAD_PROGRESS:String = "dndUploadProgress";
		public static const UPLOAD_FILE:String = "dndUploadFile";
		public static const UPLOAD_ERROR:String = "dndUploadError";
		public static const UPLOAD_STOP:String = "dndUploadStop";
		public static const UPLOAD_CANCELLED:String = "dndUploadCancelled";

		public var fileName:String;
		public var percentComplete:int;
		public var serverResponse:String;
		public var filesProcessed:int;
		public var filesTotal:int;
		public var chunksTotal:int;
		
		public function DragAndDropEvent(type:String):void
		{
			super(type);
		}

		public static function DropStart(filesTotal:int):DragAndDropEvent
		{
			var event:DragAndDropEvent = new DragAndDropEvent(DROP_START);
			event.filesTotal = filesTotal;
			return event;
		}

		public static function UploadStart(filesTotal:int):DragAndDropEvent
		{
			var event:DragAndDropEvent = new DragAndDropEvent(UPLOAD_START);
			event.filesTotal = filesTotal;
			return event;
		}

		public static function UploadProgress(fileName:String, percentComplete:int):DragAndDropEvent
		{
			var event:DragAndDropEvent = new DragAndDropEvent(UPLOAD_PROGRESS);
			event.fileName = fileName;
			event.percentComplete = percentComplete;
			return event;
		}

		public static function UploadFile(fileName:String, serverResponse:String, filesProcessed:int, 
										  filesTotal:int, chunksTotal:int):DragAndDropEvent
		{
			var event:DragAndDropEvent = new DragAndDropEvent(UPLOAD_FILE);
			event.fileName = fileName;
			event.serverResponse = serverResponse;
			event.filesProcessed = filesProcessed;
			event.filesTotal = filesTotal;
			event.chunksTotal = chunksTotal;
			return event;
		}

		public static function UploadError(fileName:String):DragAndDropEvent
		{
			var event:DragAndDropEvent = new DragAndDropEvent(UPLOAD_ERROR);
			event.fileName = fileName;
			return event;
		}

		public static function UploadCancelled():DragAndDropEvent
		{
			return new DragAndDropEvent(UPLOAD_CANCELLED);
		}
	}
}
