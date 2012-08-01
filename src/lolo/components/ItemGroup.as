package lolo.components
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import lolo.events.components.ItemEvent;

	/**
	 * 子项集合
	 * 排列（创建）子项
	 * 子项间的选中方式会互斥
	 * @author LOLO
	 */
	public class ItemGroup extends Sprite implements IItemGroup
	{
		/**使用子项的x,y进行布局（默认）*/
		public static const LAYOUT_ABSOLUTE:String = "absolute";
		/**水平方向进行布局*/
		public static const LAYOUT_HORIZONTAL:String = "horizontal";
		/**垂直方向进行布局*/
		public static const LAYOUT_VERTICAL:String = "vertical";
		
		
		/**布局方式*/
		protected var _layout:String;
		/**水平方向子项间的像素间隔*/
		protected var _horizontalGap:int;
		/**垂直方向子项间的像素间隔*/
		protected var _verticalGap:int;
		/**包含的子项的列表*/
		protected var _itemList:Vector.<IItemRenderer>;
		/**当前选中的子项*/
		protected var _selectedItem:IItemRenderer;
		/**是否启用*/
		protected var _enabled:Boolean = true;
		
		/**在对应的鼠标事件发生时，是否自动切换子项的选中状态*/
		public var autoSelectItem:Boolean = true;
		
		
		
		public function ItemGroup()
		{
			super();
			_layout = LAYOUT_ABSOLUTE;
			_itemList = new Vector.<IItemRenderer>();
		}
		
		
		/**
		 * 显示
		 * 根据数据对子项（创建）进行布局，排列
		 */
		public function show():void
		{
			if(_layout == LAYOUT_ABSOLUTE || _itemList.length == 0) return;
			
			var item:IItemRenderer;
			var position:int = 0;
			for(var i:int = 0; i < _itemList.length; i++)
			{
				item = _itemList[i];
				
				//只对父级是当前集合的可见的子项进行布局排序
				if(item.parent == this && item.visible)
				{
					switch(_layout) {
						
						case LAYOUT_HORIZONTAL:
							item.x = position;
							position += item.itemWidth + _horizontalGap;
							break;
						
						case LAYOUT_VERTICAL:
							item.y = position;
							position += item.itemHeight + _verticalGap;
							break;
					}
				}
			}
		}
		
		
		/**
		 * 添加一个子项
		 * @param item
		 */
		public function addItem(item:IItemRenderer):void
		{
			//已经是该集合的子项，不再重复添加
			for(var i:int=0; i<_itemList.length; i++) if(_itemList[i] == item) return;
			
			_itemList.push(item);
			item.group = this;
			item.enabled = _enabled;
			item.index = _itemList.length - 1;
			item.addEventListener(MouseEvent.CLICK, itemClickHandler);
			item.addEventListener(MouseEvent.MOUSE_DOWN, itemMouseDownHandler);
		}
		
		/**
		 * 移除一个子项
		 * @param item
		 */
		public function removeItem(item:IItemRenderer):void
		{
			var delIndex:int = -1;
			
			//重排子项
			for(var i:int = 0 ; i < _itemList.length; i++)
			{
				if(delIndex != -1) {
					_itemList[i].index = i - 1;
				}
				else if(_itemList[i] == item) {
					delIndex = i;
				}
			}
			
			//移除指定的子项
			if(delIndex != -1)
			{
				_itemList.splice(delIndex, 1);
				show();
				
				item.removeEventListener(MouseEvent.CLICK, itemClickHandler);
				item.removeEventListener(MouseEvent.MOUSE_DOWN, itemMouseDownHandler);
				if(item == _selectedItem) _selectedItem = null;
				if(item.selected) item.selected = false;
				item.index = 0;
				item.group = null;
			}
		}
		
		
		/**
		 * 鼠标按下子项
		 * @param event
		 */
		protected function itemMouseDownHandler(event:MouseEvent):void
		{
			var item:IItemRenderer = event.currentTarget as IItemRenderer;
			this.dispatchEvent(new ItemEvent(ItemEvent.ITEM_MOUSE_DOWN, item));
		}
		
		
		/**
		 * 鼠标单击子项
		 * @param event
		 */
		protected function itemClickHandler(event:MouseEvent):void
		{
			var item:IItemRenderer = event.currentTarget as IItemRenderer;
			switchItem(item);
			this.dispatchEvent(new ItemEvent(ItemEvent.ITEM_CLICK, item));
		}
		
		
		/**
		 * 切换子项的选中状态
		 * @param event
		 */
		protected function switchItem(item:IItemRenderer):void
		{
			if(autoSelectItem) {
				if(_selectedItem == item) {
					if(item.deselect) selectedItem = null;
				}
				else {
					selectedItem = item;
				}
			}
		}
		
		
		/**
		 * 通过索引获取子项
		 * @param index
		 * @return 
		 */
		public function getItemByIndex(index:int):IItemRenderer
		{
			return _itemList[index];
		}
		
		
		/**
		 * 通过索引选中子项
		 * @param index 
		 */
		public function selectItemByIndex(index:int):void
		{
			if(index < 0) index = 0;
			if(index >= _itemList.length) index = _itemList.length - 1;
			selectedItem = _itemList[index];
		}
		
		/**
		 * 当前选中的子项
		 * @param value 当value的group属性不是当前集合，或者为null时，什么都不选中
		 */
		public function set selectedItem(value:IItemRenderer):void
		{
			var oldItem:IItemRenderer = _selectedItem;
			_selectedItem = value;
			
			if(value != null && value.group == this) _selectedItem.selected = true;
			
			if(oldItem != null)
			{
				//是同一个子项
				if(oldItem == value) {
					if(oldItem.deselect) oldItem.selected = false;//可以取消选中
					return;
				}
				oldItem.selected = false;
			}
			
			this.dispatchEvent(new ItemEvent(ItemEvent.ITEM_SELECTED, value));
		}
		public function get selectedItem():IItemRenderer { return _selectedItem; }
		
		
		/**
		 * 获取当前选中子项的数据
		 */
		public function get selectedItemData():*
		{
			return (_selectedItem != null) ? _selectedItem.data : null;
		}
		
		
		/**
		 * 获取子项的数量
		 */
		public function get numItems():uint
		{
			return _itemList.length;
		}
		
		
		/**
		 * 是否启用
		 */
		public function set enabled(value:Boolean):void
		{
			if(_enabled == value) return;
			
			_enabled = value;
			for(var i:int=0; i < _itemList.length; i++) _itemList[i].selected = value;
		}
		public function get enabled():Boolean { return _enabled; }
		
		
		
		/**
		 * 布局方式
		 */
		public function set layout(value:String):void
		{
			_layout = value;
			show();
		}
		public function get layout():String { return _layout; }
		
		
		/**
		 * 水平方向子项间的像素间隔
		 */
		public function set horizontalGap(value:int):void
		{
			_horizontalGap = value;
			show();
		}
		public function get horizontalGap():int { return _horizontalGap; }
		
		
		/**
		 * 垂直方向子项间的像素间隔
		 */
		public function set verticalGap(value:int):void
		{
			_verticalGap = value;
			show();
		}
		public function get verticalGap():int { return _verticalGap; }
		
		
		
		/**
		 * 清空
		 */
		public function clear():void
		{
			var item:IItemRenderer;
			while(_itemList.length > 0)
			{
				item = _itemList.shift();
				item.index = 0;
				item.group = null;
				item.removeEventListener(MouseEvent.CLICK, itemClickHandler);
				item.removeEventListener(MouseEvent.MOUSE_DOWN, itemMouseDownHandler);
				if(item.parent == this) {
					super.removeChild(item as DisplayObject);
					item.dispose();
				}
			}
			_selectedItem = null;
		}
		
		
		
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			super.addChild(child);
			show();
			return child;
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			super.addChildAt(child, index);
			show();
			return child;
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			super.removeChild(child);
			show();
			return child;
		}
		
		override public function removeChildAt(index:int):DisplayObject
		{
			var child:DisplayObject = super.removeChildAt(index);
			show();
			return child;
		}
		//
	}
}