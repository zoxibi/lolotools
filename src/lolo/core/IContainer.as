package lolo.core
{
	/**
	 * 基本容器
	 * @author LOLO
	 */
	public interface IContainer extends IRSprite
	{
		/**
		 * 初始化用户界面
		 * @param config 界面的配置文件
		 */
		function initUI(config:XML):void;
		
		/**
		 * 在初始化界面完成后，是否自动显示
		 * @param value
		 */
		function set initShow(value:Boolean):void;
	}
}