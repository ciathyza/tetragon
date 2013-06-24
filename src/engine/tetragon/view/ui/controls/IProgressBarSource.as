package tetragon.view.ui.controls
{
	import flash.events.IEventDispatcher;
	
	
	/**
	 * IProgressBarSource
	 */
	public interface IProgressBarSource extends IEventDispatcher
	{
		function get bytesLoaded():uint;
		function set bytesLoaded(v:uint):void;
		function get bytesTotal():uint;
		function set bytesTotal(v:uint):void;
	}
}
