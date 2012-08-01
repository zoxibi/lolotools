package lolo.common
{
	import flash.display.Stage;
	import flash.net.LocalConnection;
	
	import lolo.net.IService;

	/**
	 * 公用接口、方法、引用集合
	 * @author LOLO
	 */
	public class Common
	{
		/**舞台*/
		public static var stage:Stage;
		
		/**后台通信服务*/
		public static var service:IService;
		
		/**用户界面管理*/
		public static var ui:IUIManager;
		/**资源加载、管理*/
		public static var loader:IResLoader;
		/**配置信息管理*/
		public static var config:IConfigManager;
		/**语言包管理*/
		public static var language:ILanguageManager;
		/**样式管理*/
		public static var style:IStyleManager;
		
		/**音频管理*/
		public static var sound:ISoundManager;
		/**鼠标管理*/
		public static var mouse:IMouseManager;
		
		
		
		/**应用的版本号*/
		public static var version:String;
		/**资源库的语言、版本*/
		public static var resVersion:String;
		/**后台服务器的网络地址*/
		public static var serviceUrl:String = "";
		/**当前后台服务类型*/
		public static var serviceType:String = "";
		/**资源服务器的网络地址*/
		public static var resServerUrl:String = "";
		/**初始数据，由FlashVars传人*/
		public static var initData:Object;
		
		
		
		/**
		 * 强制内存回收
		 */
		public static function gc():void
		{
			try {
				new LocalConnection().connect("gc");
				new LocalConnection().connect("gc");
			}
			catch(err:Error) {}
		}
		
		
		/**
		 * 将资源地址转换成正确的网络地址
		 * @param url 资源的url
		 * @param version 资源的版本号
		 * return 
		 */
		public static function getResUrl(url:String, version:uint=0):String
		{
			url = url.replace(/\{resVersion\}/g, resVersion);//将url中的字符“{resVersion}”，转换成当前资源库的语言、版本
			url = resServerUrl + url;//加上资源服务器的网络地址
			
			//调试环境
			if(Common.config.getConfig("bin") == "debug") {
				//不是程序模块资源
				if(url.indexOf("game/module/") == -1 && url.indexOf("Game.swf") == -1) {
					url = url.replace("assets/", "");
					url = Common.config.getConfig("resUrl") + url;
				}
			}
			
			//如果有指定资源的小版本号，加上大版本号和小版本号
			if(version > 0) url += "?version=" + Common.version + "v" + version;
			
			return url;
		}
		
		
		
		/**
		 * 通过key来获取初始数据，如果没有该数据，或者数据为空（空字符串），将会返回null
		 * @param key
		 * @return 
		 */
		public static function getInitDataByKey(key:String):String
		{
			var value:String = initData[key];
			if(value == "") value = null;
			return value;
		}
		//
	}
}