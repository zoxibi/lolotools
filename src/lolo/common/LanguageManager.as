package lolo.common
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import lolo.utils.RTimer;
	import lolo.utils.StringUtil;
	import lolo.utils.zip.ZipReader;

	/**
	 * 语言包管理
	 * @author LOLO
	 */
	public class LanguageManager extends EventDispatcher implements ILanguageManager
	{
		/**单例的实例*/
		private static var _instance:LanguageManager;
		
		/**提取完成的语言包储存在此*/
		private var _language:Dictionary;
		/**语言包原始xml数据*/
		private var _languageXML:XML;
		/**目前已提取的数量*/
		private var _extractNum:int = 0;
		/**用于提取语言包*/
		private var _extractTimer:RTimer;
		
		
		
		/**
		 * 获取实例
		 * @return 
		 */
		public static function getInstance():LanguageManager
		{
			if(_instance == null) _instance = new LanguageManager(new Enforcer());
			return _instance;
		}
		
		
		public function LanguageManager(enforcer:Enforcer)
		{
			super();
			if(!enforcer) {
				throw new Error("请通过Common.language获取实例");
				return;
			}
			
			_language = new Dictionary();
			
			_extractTimer = RTimer.getInstance(80, extractTimerHandler);
		}
		
		
		/**
		 * 初始化语言包
		 */
		public function initLanguage():void
		{
			//获取zip类型的语言包
			if(Common.config.getConfig("languageType") == "zip")
			{
				var zip:ZipReader = Common.loader.getZIP("language");
				_languageXML = new XML(zip.getFile("Language.xml"));
			}
			else {
				_languageXML = Common.loader.getXML("language", true);
			}
			
			extractTimerHandler();
		}
		
		
		/**
		 * 通过ID在语言包中获取对应的字符串
		 * @param id 在语言包中的ID
		 * @param rest 用该参数替换字符串内的"{n}"标记
		 * @return 
		 */
		public function getLanguage(id:String, ...rest):String
		{
			var str:String = _language[id];
			if(rest.length > 0) {
				str = StringUtil.substitute(str, rest);
			}
			return str;
		}
		
		
		/**
		 * 定时解析语言包
		 * @param event
		 */
		private function extractTimerHandler():void
		{
			_extractTimer.reset();
			
			var len:int = _extractNum + 300;//每次解析的数量
			if(len > _languageXML.item.length()) len = _languageXML.item.length();
			var i:int = _extractNum;
			for(; i < len; i++) {
				var content:String = _languageXML.item[i];
				content = content.replace(/\[br\]/g, "\n");
				_language[String(_languageXML.item[i].@id)] = content;
			}
			_extractNum = len;
			
			//还有语言包需要提取
			if(_extractNum < _languageXML.item.length()) {
				_extractTimer.start();
			}
			//提取完毕
			else {
				_languageXML = null;
				_extractTimer.clear();
				_extractTimer = null;
				
				this.dispatchEvent(new Event("initLanguageComplete"));
			}
		}
		//
	}
}


class Enforcer {}