package lolo.core
{
	/**
	 * 窗口
	 * @author LOLO
	 */
	public interface IWindow extends IModule
	{
		/**
		 * 窗口ID
		 */
		function set windowID(value:int):void;
		function get windowID():int;
		
		
		/**
		 * 当前打开的面板名称
		 */
		function set panelName(value:String):void;
		function get panelName():String;
	}
}