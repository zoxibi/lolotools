package lolo.components
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * Item渲染器
	 * @author LOLO
	 */
	public class ItemRenderer extends Sprite implements IItemRenderer
	{
		/**是否启用*/
		protected var _enabled:Boolean = true;
		/**是否已选中*/
		protected var _selected:Boolean;
		/**在已选中时，是否可以取消选中*/
		protected var _deselect:Boolean;
		
		/**所属的组*/
		protected var _group:IItemGroup;
		/**在组中的索引*/
		protected var _index:uint;
		/**数据*/
		protected var _data:*;
		
		/**Item的宽度*/
		protected var _itemWidth:uint;
		/**Item的高度*/
		protected var _itemHeight:uint;
		
		
		
		
		public function ItemRenderer()
		{
			super();
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 9999);
			this.addEventListener(MouseEvent.CLICK, clickHandler, false, 9999);
		}
		
		
		
		
		/**
		 * 是否已选中
		 */
		public function set selected(value:Boolean):void
		{
			_selected = value;
			if(_group != null) {
				if(_selected) {
					if(group.selectedItem != this) group.selectedItem = this;
				}
				else {
					if(group.selectedItem == this) group.selectedItem = null;
				}
			}
		}
		public function get selected():Boolean { return _selected; }
		
		
		/**
		 * 在已选中时，是否可以取消选中
		 */
		public function set deselect(value:Boolean):void { _deselect = value; }
		public function get deselect():Boolean { return _deselect; }
		
		/**
		 * 是否启用
		 */
		public function set enabled(value:Boolean):void { _enabled = value; }
		public function get enabled():Boolean { return _enabled; }
		
		
		/**
		 * 数据
		 */
		public function set data(value:*):void { _data = value; }
		public function get data():* { return _data; }
		
		/**
		 * 在组中的索引
		 */
		public function set index(value:uint):void { _index = value; }
		public function get index():uint { return _index; }
		
		
		/**
		 * 所属的组
		 */
		public function set group(value:IItemGroup):void
		{
			if(_group == value) return;
			
			if(_group != null) _group.removeItem(this);
			
			_group = value;
			if(_group != null) _group.addItem(this);
		}
		public function get group():IItemGroup { return _group; }
		
		
		
		/**
		 * Item的宽度
		 */
		public function set itemWidth(value:uint):void { _itemWidth = value; }
		public function get itemWidth():uint
		{
			return (_itemWidth > 0) ? _itemWidth : this.width;
		}
		
		
		/**
		 * Item的高度
		 */
		public function set itemHeight(value:uint):void { _itemHeight = value; }
		public function get itemHeight():uint
		{
			return (_itemHeight > 0) ? _itemHeight : this.height;
		}
		
		
		
		/**
		 * 鼠标按下
		 * @param event
		 */
		private function mouseDownHandler(event:MouseEvent):void
		{
			if(!_enabled) event.stopImmediatePropagation();
		}
		
		/**
		 * 鼠标单击
		 * @param event
		 */
		private function clickHandler(event:MouseEvent):void
		{
			if(!_enabled) event.stopImmediatePropagation();
		}
		
		
		/**
		 * 在被回收到缓存池时，回调的方法
		 * 所在的列表进行回收时，会自动调用该方法，无需手动调用
		 */
		public function dispose():void
		{
			_group = null;
			ToolTip.unregister(this);
		}
		
		/**
		 * 该Item已经不会再使用时，回调的方法
		 * 所在的列表进行清理时，会自动调用该方法，无需手动调用
		 */
		public function clear():void
		{
			
		}
		//
	}
}