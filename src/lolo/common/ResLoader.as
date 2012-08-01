package lolo.common
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import lolo.events.LoadResourceEvent;
	import lolo.utils.zip.ZipReader;

	/**
	 * 资源加载、管理
	 * @author LOLO
	 */
	public class ResLoader extends EventDispatcher implements IResLoader
	{
		/**单例的实例*/
		private static var _instance:ResLoader;
		
		/**加载class资源时，限定加载域*/
		private var _context:LoaderContext;
		
		/**用于加载cloass资源*/
		private var _claLoader:Loader;
		/**用于加载image资源*/
		private var _imgLoader:Loader;
		/**用于加载swf资源*/
		private var _swfLoader:Loader;
		/**用于加载zip资源*/
		private var _zipLoader:URLLoader;
		/**用于加载xml资源*/
		private var _xmlLoader:URLLoader;
		/**临时保存loader的储存列表（防止loader被回收）*/
		private var _tempLoaderList:Dictionary;
		
		/**加载队列*/
		private var _loadList:Array;
		/**当前正在加载的资源的信息*/
		private var _nowLoadInfo:Object;
		/**加载全部结束后的回调函数列表*/
		private var _callbackList:Dictionary;
		/**不重复的key，每次调用load都会递增*/
		private var _key:int = 0;
		
		/**是否正在加载中*/
		private var _isRun:Boolean = false;
		/**需要加载的资源总数*/
		private var _numTotal:uint;
		/**现在时间，用于计算加载速度*/
		private var _nowTime:Number;
		/**现在加载的数据量，用于计算加载速度*/
		private var _nowSize:Number;
		
		/**已经加载完成的资源列表*/
		private var _resList:Dictionary;
		
		/**用于重新加载*/
		private var _reloadTimer:Timer;
		
		
		
		/**
		 * 获取实例
		 * @return 
		 */
		public static function getInstance():ResLoader
		{
			if(_instance == null) _instance = new ResLoader(new Enforcer());
			return _instance;
		}
		
		
		public function ResLoader(enforcer:Enforcer)
		{
			super();
			
			if(!enforcer) {
				throw new Error("请通过Common.loader获取实例");
				return;
			}
			
			_tempLoaderList = new Dictionary();
			_resList = new Dictionary();
			_callbackList = new Dictionary();
			_loadList = [];
			_nowLoadInfo = {};
			
			_context = new LoaderContext(true);
			//_context.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);//加载到子域（模块）
			_context.applicationDomain = ApplicationDomain.currentDomain;//加载到当前域（运行时共享库）
			//_context.applicationDomain = new ApplicationDomain();//加载到新域（独立运行的程序或模块）
			
			_claLoader = new Loader();
			_claLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_claLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			_claLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			_claLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, classCompleteHandler);
			
			_imgLoader = new Loader();
			_imgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_imgLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			_imgLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			_imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageCompleteHandler);
			
			_swfLoader = new Loader();
			_swfLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_swfLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			_swfLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			_swfLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, swfCompleteHandler);
			
			_zipLoader = new URLLoader();
			_zipLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_zipLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_zipLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			_zipLoader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			_zipLoader.addEventListener(Event.COMPLETE, zipCompleteHandler);
			
			_xmlLoader = new URLLoader();
			_xmlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			_xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_xmlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			_xmlLoader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			_xmlLoader.addEventListener(Event.COMPLETE, xmlCompleteHandler);
			
			_reloadTimer = new Timer(10 * 1000);
			_reloadTimer.addEventListener(TimerEvent.TIMER, reload);
		}
		
		
		/**
		 * 加载资源中
		 * @param event
		 */
		private function progressHandler(event:ProgressEvent):void
		{
			_reloadTimer.reset();
			_reloadTimer.start();
			
			var time:int = getTimer();
			var s:Number = (time - _nowTime) / 1000;//与上次测速的间隔时间
			
			//至少指定时间间隔后，才派发加载中事件
			if(s >= 0.1) {
				var size:Number = event.bytesLoaded;
				var kb:Number = (size - _nowSize) / 1024;//每秒加载多少kb数据
				
				var e:LoadResourceEvent = new LoadResourceEvent(LoadResourceEvent.PROGRESS);
				e.name = _nowLoadInfo.name;
				e.progress = (_numTotal - _loadList.length - 1 + event.bytesLoaded / event.bytesTotal) / _numTotal;
				e.speed = Math.ceil(kb / s);//速度
				e.numTotal = _numTotal;
				e.numLoaded = _numTotal - _loadList.length;
				this.dispatchEvent(e);
				
				_nowTime = time;
				_nowSize = size;
			}
		}
		
		/**
		 * 加载资源失败
		 * @param event
		 */
		private function errorHandler(event:Event):void
		{
			_reloadTimer.reset();
			
			trace("加载{ name:" + _nowLoadInfo.name + ", url:" + Common.getResUrl(_nowLoadInfo.url) + " }出错！", event.type);
			this.dispatchEvent(new LoadResourceEvent(LoadResourceEvent.ERROR, _nowLoadInfo.name));
		}
		
		/**
		 * 加载所有资源完成
		 */
		private function loadAllComplete():void
		{
			_reloadTimer.reset();
			
			_isRun = false;
			var key:String = _nowLoadInfo.key;
			_nowLoadInfo = {};
			
			//取出该资源的回调
			var callback:Function = _callbackList[key];
			if(callback != null) callback();
			delete _callbackList[key];
			
			this.dispatchEvent(new LoadResourceEvent(LoadResourceEvent.ALL_COMPLETE));
		}
		
		
		/**
		 * 加载class资源成功
		 * @param event
		 */
		private function classCompleteHandler(event:Event):void
		{
			//调试环境
			if(Common.config.getConfig("bin") == "debug") {
				//不是程序模块资源
				if(_nowLoadInfo.url.indexOf("game/module/") == -1 && _nowLoadInfo.url.indexOf("Game.swf") == -1) {
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, getClassResDataHandler);
					loader.loadBytes(_claLoader.contentLoaderInfo.bytes, new LoaderContext(false, ApplicationDomain.currentDomain));
					_tempLoaderList[loader] = loader;
					return;
				}
			}
			getClassResDataHandler();
		}
		/**
		 * 获取class资源数据
		 */
		private function getClassResDataHandler(event:Event=null):void
		{
			if(event != null) {
				delete _tempLoaderList[event.target.loader];
				event.target.loader.unload();
				event.target.removeEventListener(Event.COMPLETE, getClassResDataHandler);
			}
			
			_resList[_nowLoadInfo.name] = true;
			_claLoader.unload();
			
			this.dispatchEvent(new LoadResourceEvent(LoadResourceEvent.COMPLETE, _nowLoadInfo.name));
			loadNext();
		}
		
		
		/**
		 * 加载image资源成功
		 * @param event
		 */
		private function imageCompleteHandler(event:Event):void
		{
			_resList[_nowLoadInfo.name] = (_imgLoader.content as Bitmap).bitmapData.clone();
			_imgLoader.unload();
			
			this.dispatchEvent(new LoadResourceEvent(LoadResourceEvent.COMPLETE, _nowLoadInfo.name));
			loadNext();
		}
		
		/**
		 * 加载swf资源成功
		 * @param event
		 */
		private function swfCompleteHandler(event:Event):void
		{
			_resList[_nowLoadInfo.name] = _swfLoader.content;
			_swfLoader.unload();
			
			this.dispatchEvent(new LoadResourceEvent(LoadResourceEvent.COMPLETE, _nowLoadInfo.name));
			loadNext();
		}
		
		/**
		 * 加载zip资源成功
		 * @param event
		 */
		private function zipCompleteHandler(event:Event):void
		{
			var bytes:ByteArray = event.target.data as ByteArray;
			_resList[_nowLoadInfo.name] = new ZipReader(bytes);
			
			this.dispatchEvent(new LoadResourceEvent(LoadResourceEvent.COMPLETE, _nowLoadInfo.name));
			loadNext();
		}
		
		/**
		 * 加载xml资源成功
		 * @param event
		 */
		private function xmlCompleteHandler(event:Event):void
		{
			_resList[_nowLoadInfo.name] = new XML(event.target.data);
			
			this.dispatchEvent(new LoadResourceEvent(LoadResourceEvent.COMPLETE, _nowLoadInfo.name));
			loadNext();
		}
		
		
		/**
		 * 继续加载在加载队列中的下一个资源
		 */
		private function loadNext():void
		{
			_reloadTimer.reset();
			_reloadTimer.start();
			
			//加载队列中还有未加载的资源
			if(_loadList.length > 0)
			{
				_nowTime = getTimer();
				_nowSize = 0;
				
				//取出相同key的资源
				var arr:Array = null;
				for(var i:int = 0; i < _loadList.length; i++) {
					if(_loadList[i].key == _nowLoadInfo.key) {
						arr = _loadList.splice(i, 1);
						break;
					}
				}
				
				//没有相同key的资源
				if(arr == null) {
					var callback:Function = _callbackList[_nowLoadInfo.key];
					if(callback != null) callback();
					delete _callbackList[_nowLoadInfo.key];
					_nowLoadInfo = _loadList.shift();
				}
				else {
					_nowLoadInfo = arr[0];
				}
				
				var resUrl:String = Common.getResUrl(_nowLoadInfo.url, _nowLoadInfo.version);
				
				//根据资源的类型，进行不同的加载操作
				switch(_nowLoadInfo.type)
				{
					case Constants.RES_TYPE_CLA:
						_claLoader.load(new URLRequest(resUrl), _context);
						break;
					case Constants.RES_TYPE_IMG:
						_imgLoader.load(new URLRequest(resUrl), new LoaderContext(true));
						break;
					case Constants.RES_TYPE_SWF:
						_swfLoader.load(new URLRequest(resUrl), _context);
						break;
					case Constants.RES_TYPE_ZIP:
						_zipLoader.load(new URLRequest(resUrl));
						break;
					case Constants.RES_TYPE_XML:
						_xmlLoader.load(new URLRequest(resUrl));
						break;
					default:
						_reloadTimer.reset();
						trace("资源类型\"" + _nowLoadInfo.type + "\"无法识别");
				}
			}
			else {
				loadAllComplete();
			}
		}
		
		
		
		
		
		/**
		 * 在加载队列中添加一条资源信息
		 * @param name 要加载的资源的名称
		 * @param url 资源的url地址
		 * @param type 资源的类型
		 * @param version 资源的版本
		 * @param key 资源在列表中的标识
		 * @param isBackground 是否为后台加载
		 */
		public function add(name:String, url:String, type:String, version:uint=0, key:String=null, isBackground:Boolean=false):void
		{
			//该资源已经加载完成
			if(_resList[name]) return;
			
			//检查当前是否正在加载该资源
			if(name == _nowLoadInfo.name) return;
			
			//检查加载队列中是否已经有该资源存在
			for(var i:int = 0; i < _loadList.length; i++)
			{
				if(name == _loadList[i].name) return;
			}
			
			//使用默认key
			if(key == null) key = _key.toString();
			
			//将资源信息添加到加载队列中
			_loadList.push({ name:name, url:url, type:type, version:version, key:key, isBackground:isBackground });
			
			if(_isRun) {
				_numTotal++;
			}
		}
		
		
		/**
		 * 开始加载资源
		 * @param callback 资源加载全部完成时的回调函数
		 * @param key 资源在列表中的标识
		 * @param isBackground 是否为后台加载
		 */
		public function load(callback:Function=null, key:String=null, isBackground:Boolean=false):void
		{
			//使用默认key
			if(key == null) key = _key.toString();
			
			_callbackList[key] = callback;
			_key++;
			
			//没有在加载中，并且加载队列中没有需要加载的资源
			if(!_isRun && _loadList.length == 0) {
				_nowLoadInfo = { key:key };
				loadAllComplete();
				return;
			}
			
			//不是后台加载，清除资源列表中的后台加载项
			if(!isBackground)
			{
				if(_nowLoadInfo.isBackground) {
					stopLoad();
				}
				for(var i:int = 0; i < _loadList.length; i++)
				{
					if(_loadList[i].isBackground) {
						delete _callbackList[_loadList[i].key];//清除加载该资源的回调
						_loadList.splice(i, 1);
						i--;
					}
				}
			}
			
			if(!_isRun) {
				_isRun = true;
				_numTotal = _loadList.length;//记录需要加载的资源总数
				loadNext();
			}
		}
		
		
		/**
		 * 重新加载
		 */
		private function reload(event:TimerEvent):void
		{
			_reloadTimer.reset();
			stopLoad();
			
			_loadList.unshift(_nowLoadInfo);
			loadNext();
		}
		
		
		
		/**
		 * 终止所有加载
		 */
		public function stopLoad():void
		{
			_isRun = false;
			
			try { _claLoader.close(); }
			catch(error:Error) {}
			
			try { _swfLoader.close(); }
			catch(error:Error) {}
			
			try { _imgLoader.close(); }
			catch(error:Error) {}
			
			try { _zipLoader.close(); }
			catch(error:Error) {}
			
			try { _xmlLoader.close(); }
			catch(error:Error) {}
		}
		
		
		
		
		/**
		 * 是否正在加载中
		 * @return 
		 */
		public function get isRun():Boolean
		{
			return _isRun;
		}
		
		/**
		 * 清除加载队列
		 */
		public function clearLoadList():void
		{
			_loadList = [];
			_callbackList = new Dictionary();
		}
		
		/**
		 * 清除指定名称的资源
		 * @param name 资源名称
		 */
		public function clearByName(name:String):void
		{
			delete _resList[name];
		}
		
		/**
		 * 检测指定名称的资源是否已经加载完成
		 * @param name 资源名称
		 */
		public function hasResByName(name:String):Boolean
		{
			return _resList[name] != null;
		}
		
		
		
		
		/**
		 * 获取图片资源
		 * @param name 资源名称
		 * @param clear 获取后是否清除
		 * @return 
		 */
		public function getImage(name:String, clear:Boolean=false):Bitmap
		{
			var img:Bitmap = new Bitmap(_resList[name]);
			if(clear) clearByName(name);
			return img;
		}
		
		/**
		 * 获取swf资源
		 * @param name 资源名称
		 * @param clear 获取后是否清除
		 * @return 
		 */
		public function getSWF(name:String, clear:Boolean=true):DisplayObject
		{
			var swf:DisplayObject = _resList[name];
			if(clear) clearByName(name);
			return swf;
		}
		
		/**
		 * 获取zip资源
		 * @param name 资源名称
		 * @param clear 获取后是否清除
		 * @return 
		 */
		public function getZIP(name:String, clear:Boolean=true):ZipReader
		{
			var zip:ZipReader = _resList[name];
			if(clear) clearByName(name);
			return zip;
		}
		
		/**
		 * 获取xml资源
		 * @param name 资源名称
		 * @param clear 获取后是否清除
		 * @return 
		 */
		public function getXML(name:String, clear:Boolean=false):XML
		{
			var xml:XML = _resList[name];
			if(clear) clearByName(name);
			return xml;
		}
	}
}


class Enforcer {}