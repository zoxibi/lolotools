package lolo.common
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;
	
	import lolo.utils.zip.ZipReader;

	/**
	 * 资源加载、管理
	 * @author LOLO
	 */
	public interface IResLoader extends IEventDispatcher
	{
		/**
		 * 在加载队列中添加一条资源信息
		 * @param name 要加载的资源的名称
		 * @param url 资源的url地址
		 * @param type 资源的类型
		 * @param version 资源的版本
		 * @param key 资源在列表中的标识
		 * @param isBackground 是否为后台加载
		 */
		function add(name:String, url:String, type:String, version:uint=0, key:String=null, isBackground:Boolean=false):void;
		
		
		/**
		 * 开始加载资源
		 * @param callback 资源加载全部完成时的回调函数
		 * @param key 资源在列表中的标识
		 * @param isBackground 是否为后台加载
		 */
		function load(callback:Function=null, key:String=null, isBackground:Boolean=false):void;
		
		
		/**
		 * 终止所有加载
		 */
		function stopLoad():void;
		
		
		/**
		 * 是否正在加载中
		 * @return 
		 */
		function get isRun():Boolean;
		
		
		/**
		 * 清除加载队列
		 */
		function clearLoadList():void;
		
		
		/**
		 * 清除指定名称的资源
		 * @param name 资源名称
		 */
		function clearByName(name:String):void;
		
		
		/**
		 * 检测指定名称的资源是否已经加载完成
		 * @param name 资源名称
		 */
		function hasResByName(name:String):Boolean;
		
		
		/**
		 * 获取图片资源
		 * @param name 资源名称
		 * @param clear 获取后是否清除
		 * @return 
		 */
		function getImage(name:String, clear:Boolean=false):Bitmap;
		
		/**
		 * 获取swf资源
		 * @param name 资源名称
		 * @param clear 获取后是否清除
		 * @return 
		 */
		function getSWF(name:String, clear:Boolean=true):DisplayObject;
		
		/**
		 * 获取zip资源
		 * @param name 资源名称
		 * @param clear 获取后是否清除
		 * @return 
		 */
		function getZIP(name:String, clear:Boolean=true):ZipReader;
		
		/**
		 * 获取xml资源
		 * @param name 资源名称
		 * @param clear 获取后是否清除
		 * @return 
		 */
		function getXML(name:String, clear:Boolean=false):XML;
		//
	}
}