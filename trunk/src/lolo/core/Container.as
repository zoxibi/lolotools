package lolo.core
{
	import lolo.utils.AutoUtil;

	/**
	 * 基本容器
	 * @author LOLO
	 */
	public class Container extends RSprite implements IContainer
	{
		/**用户界面配置*/
		protected var _uiConfig:XML;
		
		
		/**
		 * 初始化用户界面
		 * @param config 界面的配置文件
		 */
		public function initUI(config:XML):void
		{
			AutoUtil.autoUI(this, config);
			_uiConfig = config;
		}
		
		
		/**
		 * 默认是否为显示状态
		 * @param value
		 */
		public function set initShow(value:Boolean):void
		{
			if(value) nowShow();
		}
		//
	}
}