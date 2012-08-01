package lolo.common
{
	/**
	 * 配置信息管理
	 * @author LOLO
	 */
	public interface IConfigManager
	{
		/**
		 * 初始化网页目录下的Config.xml
		 */
		function initConfig():void;
		
		/**
		 * 初始化资源配置文件
		 */
		function initResConfig():void;
		
		/**
		 * 初始化界面配置文件
		 */
		function initUIConfig():void;
		
		/**
		 * 初始化音频配置文件
		 */
		function initSoundConfig():void;
		
		
		/**
		 * 获取网页目录下Config.xml文件的配置信息
		 * @param name 配置的名称
		 * @return
		 */
		function getConfig(name:String):String;
		
		/**
		 * 获取资源配置文件信息
		 * @param name 配置的名称
		 * @return { url, version }
		 */
		function getResConfig(name:String):Object;
		
		/**
		 * 获取界面配置文件信息
		 * @param name 配置的名称
		 * @return
		 */
		function getUIConfig(name:String):String;
		
		/**
		 * 获取音频配置文件信息
		 * @param name 配置的名称
		 * @return
		 */
		function getSoundConfig(name:String):String;
		//
	}
}