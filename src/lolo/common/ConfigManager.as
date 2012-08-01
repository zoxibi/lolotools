package lolo.common
{
	/**
	 * 配置信息管理
	 * @author LOLO
	 */
	public class ConfigManager implements IConfigManager
	{
		/**单例的实例*/
		private static var _instance:ConfigManager;
		
		/**网页目录下的Config.xml配置文件*/
		private var _config:XML;
		/**资源配置文件*/
		private var _resConfig:XML;
		/**界面配置文件*/
		private var _uiConfig:XML;
		/**音频配置文件*/
		private var _soundConfig:XML;
		
		
		
		/**
		 * 获取实例
		 * @return 
		 */
		public static function getInstance():ConfigManager
		{
			if(_instance == null) _instance = new ConfigManager(new Enforcer());
			return _instance;
		}
		
		
		public function ConfigManager(enforcer:Enforcer)
		{
			super();
			if(!enforcer) {
				throw new Error("请通过Common.config获取实例");
				return;
			}
		}
		
		
		/**
		 * 初始化网页目录下的Config.xml
		 */
		public function initConfig():void
		{
			_config = Common.loader.getXML("config", true);
			
			Common.resVersion = getConfig("resVersion");
			Common.serviceUrl = getConfig("socketServiceUrl");
		}
		
		/**
		 * 初始化资源配置文件
		 */
		public function initResConfig():void
		{
			_resConfig = Common.loader.getXML("resConfig", true);
			Common.version = _resConfig.version;
		}
		
		/**
		 * 初始化界面配置文件
		 */
		public function initUIConfig():void
		{
			_uiConfig = Common.loader.getXML("uiConfig", true);
		}
		
		
		/**
		 * 初始化音频配置文件
		 */
		public function initSoundConfig():void
		{
			_soundConfig = Common.loader.getXML("soundConfig", true);
		}
		
		
		
		/**
		 * 获取网页目录下Config.xml文件的配置信息
		 * @param name 配置的名称
		 */
		public function getConfig(name:String):String
		{
			if(_config == null) return "";
			return _config[name].@value;
		}
		
		/**
		 * 获取资源配置文件信息
		 * @param name 配置的名称
		 * @return { url, version }
		 */
		public function getResConfig(name:String):Object
		{
			return { url:_resConfig[name].@url, version:_resConfig[name].@version };
		}
		
		/**
		 * 获取界面配置文件信息
		 * @param name 配置的名称
		 * @return
		 */
		public function getUIConfig(name:String):String
		{
			return _uiConfig[name].@value;
		}
		
		
		/**
		 * 获取音频配置文件信息
		 * @param name 配置的名称
		 * @return
		 */
		public function getSoundConfig(name:String):String
		{
			return _soundConfig[name].@value;
		}
		//
	}
}


class Enforcer {}