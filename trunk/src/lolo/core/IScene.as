package lolo.core
{
	/**
	 * 场景
	 * @author LOLO
	 */
	public interface IScene extends IModule
	{
		/**
		 * 场景ID
		 */
		function set sceneID(value:int):void;
		function get sceneID():int;
		
		/**
		 * 场景视图的ID
		 */
		function set viewID(value:int):void;
		function get viewID():int;
		//
	}
}