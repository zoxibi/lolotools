package lolo.common
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.ui.ContextMenu;

	/**
	 * 鼠标管理
	 * @author LOLO
	 */
	public interface IMouseManager
	{
		/**
		 * 皮肤（替代鼠标指针的动画）
		 */
		function set skin(value:MovieClip):void;
		function get skin():MovieClip;
		
		/**
		 * 当前样式
		 */
		function set style(value:String):void;
		function get style():String;
		
		/**
		 * 当前状态
		 */
		function set state(value:String):void;
		function get state():String;
		
		/**
		 * 默认样式
		 */
		function set defaultStyle(value:String):void;
		function get defaultStyle():String;
		
		/**
		 * 是否自动切换状态
		 */
		function set autoSwitchState(value:Boolean):void;
		function get autoSwitchState():Boolean;
		
		/**
		 * 是否显示皮肤
		 */
		function set isShowSkin(value:Boolean):void;
		function get isShowSkin():Boolean;
		
		
		/**
		 * 右键菜单
		 */
		function set contextMenu(cm:ContextMenu):void;
		function get contextMenu():ContextMenu;
		
		
		
		/**
		 * 显示更新
		 */		
		function update():void;
		
		
		/**
		 * 绑定样式
		 * 当绑定目标发生对应的鼠标事件时，将会切换到对应的样式
		 * @param target 要绑定样式的目标
		 * @param style 对应的样式
		 * @param overEventType 鼠标移到目标上的事件类型
		 * @param outEventType 鼠标从目标上移开的事件类型
		 */
		function bindStyle(target:DisplayObject, style:String, overEventType:String=null, outEventType:String=null):void;
		
		/**
		 * 解除样式绑定
		 * @param target 已绑定样式的目标
		 * @param overEventType 鼠标移到目标上的事件类型
		 * @param outEventType 鼠标从目标上移开的事件类型
		 */
		function unbindStyle(target:DisplayObject, overEventType:String=null, outEventType:String=null):void;
		//
	}
}