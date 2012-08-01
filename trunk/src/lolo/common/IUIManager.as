package lolo.common
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	import lolo.ui.ICenterDisplayObject;
	import lolo.ui.IRequestModal;

	/**
	 * 用户界面管理
	 * @author LOLO
	 */
	public interface IUIManager
	{
		/**
		 * 初始化，入口函数
		 */
		function init():void;
		
		
		
		/**
		 * 显示加载条
		 * @param listener 是否侦听资源加载事件
		 */
		function showLoadBar(isListenResLoad:Boolean=true):void;
		
		/**
		 * 隐藏加载条
		 */
		function hideLoadBar():void;
		
		
		
		/**
		 * 添加显示对象到指定的层中
		 * @param child 显示对象
		 * @param layerName 层的名称
		 */
		function addChildToLayer(child:DisplayObject, layerName:String):void;
		
		/**
		 * 从指定层中移除指定显示对象
		 * @param child 显示对象
		 * @param layerName 层的名称
		 */
		function removeChildToLayer(child:DisplayObject, layerName:String):void;
		
		
		
		/**
		 * 将显示对象在窗口层中打开
		 * @param window 显示对象
		 * @param closeOther 是否关闭其他已打开的窗口
		 */
		function openWindow(window:DisplayObject, closeOther:Boolean=true):void;
		
		/**
		 * 关闭指定的窗口
		 * @param window 要关闭的窗口
		 */
		function closeWindow(window:DisplayObject):void;
		
		/**
		 * 关闭所有窗口
		 */
		function closeAllWindow():void;
		
		
		
		/**
		 * 切换显示指定ID的场景
		 * @param sceneID 场景ID
		 * @param rest 场景初始化参数列表
		 */
		function showScene(sceneID:int, ...rest):void;
		
		/**
		 * 显示上一个场景
		 */
		function showLastScene():void;
		
		/**
		 * 获取上一个场景的ID
		 * @return 
		 */
		function get lastSceneID():int;
		
		/**
		 * 获取当前场景的ID，没有进入场景时，值为0（默认）
		 * @return 
		 */
		function get nowSceneID():int;
		
		/**
		 * 获取当前场景视图的ID，没有进入场景或者场景没有设置过视图ID时，值为0（默认）
		 * @return 
		 */
		function get nowSceneViewID():int;
		
		
		
		/**
		 * 显示指定ID的窗口
		 * @param windowID 窗口的ID 
		 * @param rest 窗口初始化参数列表
		 */
		function showWindow(windowID:int, ...rest):void;
		
		/**
		 * 获取当前窗口的ID，没有打开窗口时，值为0（默认）
		 * @return 
		 */
		function get nowWindowID():int;
		
		/**
		 * 获取当前窗口中已打开面板的名称，没有打开窗口或面板时，值为null（默认）
		 * @return 
		 */
		function get nowWindowPanelName():String;
		
		
		
		/**
		 * 将与服务端通信的请求进行模态的界面
		 * @return 
		 */
		function get requesModal():IRequestModal;
		
		
		
		/**
		 * 将显示对象居中于舞台
		 * @param view
		 */
		function centerToStage(view:ICenterDisplayObject):void;
		
		
		
		/**
		 * 获取舞台宽度
		 * @return 
		 */
		function get stageWidth():int;
		
		/**
		 * 获取舞台高度
		 * @return 
		 */
		function get stageHeight():int;
		//
	}
}