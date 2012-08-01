package lolo.components
{
	import flash.events.IEventDispatcher;
	/**
	 * 子项集合接口
	 * 排列（创建）子项
	 * 子项间的选中方式会互斥
	 * @author LOLO
	 */
	public interface IItemGroup extends IEventDispatcher
	{
		/**
		 * 显示
		 * 根据数据对子项（创建）进行布局，排列
		 */
		function show():void;
		
		/**
		 * 添加一个子项
		 * @param item
		 */
		function addItem(item:IItemRenderer):void;
		
		/**
		 * 移除一个子项
		 * @param item
		 */
		function removeItem(item:IItemRenderer):void;
		
		/**
		 * 清空
		 */
		function clear():void;
		
		/**
		 * 通过索引获取子项
		 * @param index
		 * @return 
		 */
		function getItemByIndex(index:int):IItemRenderer;
		
		/**
		 * 通过索引选中子项
		 * @param index 
		 */
		function selectItemByIndex(index:int):void;
		
		/**
		 * 设置当前选中的子项
		 * @param value 当value的group属性不是当前集合，或者为null时，什么都不选中
		 */
		function set selectedItem(value:IItemRenderer):void;
		/**
		 * 获取当前选中的子项
		 */
		function get selectedItem():IItemRenderer;
		
		/**
		 * 获取当前选中子项的数据
		 */
		function get selectedItemData():*;
		
		/**
		 * 获取子项的数量
		 */
		function get numItems():uint;
		
		/**是否启用*/
		function set enabled(value:Boolean):void;
		function get enabled():Boolean;
		
		
		
		/**布局方式*/
		function set layout(value:String):void;
		function get layout():String;
		
		/**水平方向子项间的像素间隔*/
		function set horizontalGap(value:int):void;
		function get horizontalGap():int;
		
		/**垂直方向子项间的像素间隔*/
		function set verticalGap(value:int):void;
		function get verticalGap():int;
		//
	}
}