package lolo.core
{
	/**
	 * 场景
	 * @author LOLO
	 */
	public class Scene extends Module implements IScene
	{
		/**场景ID*/
		protected var _sceneID:int;
		/**场景视图的ID*/
		protected var _viewID:int;
		
		
		
		/**
		 * 场景ID
		 */
		public function set sceneID(value:int):void
		{
			_sceneID = value;
		}
		
		public function get sceneID():int
		{
			return _sceneID;
		}
		
		
		
		/**
		 * 场景视图的ID
		 */
		public function set viewID(value:int):void
		{
			_viewID = value;
		}
		
		public function get viewID():int
		{
			return _viewID;
		}
		//
	}
}