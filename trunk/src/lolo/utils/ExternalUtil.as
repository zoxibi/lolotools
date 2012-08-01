package lolo.utils
{
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;

	/**
	 * 与外部通信的工具
	 * @author LOLO
	 */
	public class ExternalUtil
	{
		/**在新窗口打开*/
		public static const WINDOW_BLANK:String = "_blank";
		/**在当前窗口打开*/
		public static const WINDOW_SELF:String = "_self";
		/**在父窗口打开*/
		public static const WINDOW_PARENT:String = "_parent";
		
		
		/**
		 * 打开一个浏览器窗口
		 * @param url 网络地址
		 * @param window 目标浏览器窗口
		 */
		public static function openWindow(url:String, window:String="_blank"):void
		{
			var urlRequest:URLRequest = new URLRequest(url);
			
			if(!ExternalInterface.available)
			{
				return navigateToURL(urlRequest, window)
			}
			
			if(/safari|opera/i.test(ExternalInterface.call('function(){return navigator.userAgent}') || 'opera'))
			{
				navigateToURL(urlRequest, window);
			}
			else
			{
				ExternalInterface.call("function(){window.open('" + getURLString(urlRequest) + "','" + window + "');}");
			}
		}
		
		
		/**
		 * 获取url字符串
		 * @param urlRequest
		 * @return 
		 */
		private static function getURLString(urlRequest:URLRequest):String
		{
			var patams:String = urlRequest.data ? URLVariables(urlRequest.data).toString() : "";
			if((urlRequest.method == URLRequestMethod.POST) || !patams)
			{
				return urlRequest.url;
			}
			return urlRequest.url + "?" + patams;
		}
		
		
		/**
		 * 将指定url和title加入到收藏夹
		 * @param url 要收藏的url
		 * @param title 标题、描述
		 */
		public static function addFavorite(url:String, title:String):void
		{
			if(ExternalInterface.available)
			{
				//调用页面的js函数
				ExternalInterface.call("AddFavorite", url, title);
			}
		}
		//
	}
}