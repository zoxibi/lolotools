package lolo.ui
{
	import lolo.core.IContainer;
	/**
	 * 加载条
	 * @author LOLO
	 */
	public interface ILoadBar extends IContainer
	{
		/**
		 * 设置是否侦听Common.res资源加载事件
		 * @param value
		 */
		function set addListenerToRes(value:Boolean):void;
		
		/**
		 * 设置显示文本
		 * @param value
		 */
		function set text(value:String):void;
	}
}