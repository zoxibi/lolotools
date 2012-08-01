package lolo.common
{
	/**
	 * 样式管理
	 * @author LOLO
	 */
	public interface IStyleManager
	{
		/**
		 * 初始化样式表
		 */
		function initStyle():void;
		
		/**
		 * 获取样式表
		 * @param name 样式的名称
		 * @return 
		 */
		function getStyle(name:String):Object;
	}
}