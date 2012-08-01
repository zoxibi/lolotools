package lolo.components
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import lolo.data.IHashMap;
	import lolo.events.components.ItemEvent;
	import lolo.events.components.PageEvent;
	
	/**
	 * 列表
	 * @author LOLO
	 */
	public class List extends ItemGroup
	{
		/**刷新列表时，根据索引来选中子项*/
		public static const SELECT_MODE_INDEX:String = "index";
		/**刷新列表时，根据键来选中子项*/
		public static const SELECT_MODE_KEY:String = "key";
		
		/**数据*/
		private var _data:IHashMap;
		/**列数*/
		private var _columnCount:uint;
		/**行数*/
		private var _rowCount:uint;
		/**刷新列表时，根据什么来选中子项*/
		private var _selectMode:String;
		/**子项的渲染类*/
		private var _itemRendererClass:Class;
		
		/**子项的缓存池，已移除的子项实例不会立即销毁，将会回收到池中*/
		private var _itemPool:Vector.<IItemRenderer>;
		/**对应的翻页组件*/
		private var _page:Page;
		
		/**当前选中子项的索引*/
		private var _currentSelectedIndex:int = 0;
		/**当前选中子项的键列表*/
		private var _currentSelectedKeys:Array;
		/**上次显示时的状态*/
		private var _lastShowState:Object = {};
		/**是否为首次设置数据*/
		private var _isFirstSetData:Boolean = true;
		/**在刷新时是否需要选中子项*/
		private var _isSelectItem:Boolean = true;
		
		/**在还未选中过子项时，创建列表（设置数据，翻页）是否自动选中第一个子项*/
		public var isDefaultSelect:Boolean = true;
		
		
		
		public function List()
		{
			super();
			_selectMode = SELECT_MODE_INDEX;
			_itemPool = new Vector.<IItemRenderer>();
		}
		
		/**
		 * 数据
		 */
		public function set data(value:IHashMap):void
		{
			_data = value;
			if(_data == null) return;
			
			//有对应的翻页组件
			if(_page != null)
			{
				var currentPage:int = _page.currentPage;
				_page.init(numPerPage, _data.length);
				//当前页有改变，清除索引
				if(_page.currentPage != currentPage)
				{
					_currentSelectedIndex = 0;
					_currentSelectedKeys = null;
				}
			}
			
			_isFirstSetData = true;
			show();
		}
		public function get data():IHashMap { return _data; }
		
		
		
		override public function show():void
		{
			//数据不完整，没有达到显示要求
			if(_data == null || _itemRendererClass == null || _columnCount <= 0 || _rowCount <= 0) return;
			
			//与上次显示时的状态相比，无变更
			if(_data == _lastShowState.data && _columnCount == _lastShowState.columnCount && _rowCount == _lastShowState.rowCount) return;
			
			//保存本次显示时的状态
			_lastShowState.data			= _data;
			_lastShowState.columnCount	= _columnCount;
			_lastShowState.rowCount		= _rowCount;
			
			//计算出要显示多少条子项
			var length:uint = Math.min(numPerPage, _data.length);
			if(_page != null && (_page.currentPage * numPerPage) > _data.length) {
				length = _data.length - (_page.currentPage - 1) * numPerPage;
			}
			
			
			//没有要显示的数据，清空列表
			if(length <= 0) {
				if(_selectedItem != null) selectedItem = null;
				clear();
				return;
			}
			else {
				if(_selectedItem != null && _isFirstSetData && !isDefaultSelect && autoSelectItem) selectedItem = null;
				recoverAllItem();
			}
			
			//根据数据显示（创建）子项
			var item:IItemRenderer;
			var lastItem:IItemRenderer;
			var pageIndex:uint = (_page != null) ? (_page.currentPage - 1) * numPerPage : 0;
			var i:int;
			for(i = 0; i < length; i++)
			{
				item = (_itemPool.length > 0) ? _itemPool.shift() : new _itemRendererClass();
				addChild(item as DisplayObject);
				item.index = i;
				item.data = _data.getValueByIndex(i + pageIndex);
				addItem(item);
				
				if(lastItem != null)
				{
					//新行的开始
					if((i % _columnCount) == 0) {
						item.x = 0;
						item.y = lastItem.y + lastItem.itemHeight + _verticalGap;
					}
					else {
						item.x = lastItem.x + lastItem.itemWidth + _horizontalGap;
						item.y = lastItem.y;
					}
				}
				else {
					item.x = item.y = 0;
				}
				
				lastItem = item;
			}
			
			//不需要选中，代码无需继续执行
			if(!_isSelectItem)
			{
				_isSelectItem = true;
				return;
			}
			
			//首次设置数据，还没有选中过任何子项
			if(_isFirstSetData && _currentSelectedIndex == 0 && _currentSelectedKeys == null)
			{
				_isFirstSetData = false;
				if(isDefaultSelect && autoSelectItem) selectItemByIndex(0);
			}
				
				//通过索引来选中子项
			else if(_selectMode == SELECT_MODE_INDEX)
			{
				autoSelectItemByIndex(_currentSelectedIndex);
			}
				
				//根据键来选中子项
			else
			{
				i = _data.getIndexByKeys(_currentSelectedKeys);
				(i != -1) ? selectItemByIndex(i) : autoSelectItemByIndex(_currentSelectedIndex);
			}
		}
		
		
		/**
		 * 强制刷新显示
		 * @param isSelect 是否需要选中子项
		 */
		public function refresh(isSelect:Boolean=true):void
		{
			_isSelectItem = isSelect;
			_lastShowState = {};
			show();
			
			if(_page != null && _data != null) _page.init(numPerPage, _data.length);
		}
		
		
		/**
		 * 通过索引来选中子项
		 * 如果指定的index不存在，将会自动选中index-1的子项
		 * @param index 指定的索引
		 */
		private function autoSelectItemByIndex(index:uint):void
		{
			if(index >= _itemList.length || _itemList[index] != null) {
				selectItemByIndex(index);
			}
			else {
				index--;
				if(index >= 0) autoSelectItemByIndex(index);
			}
		}
		
		
		override public function set selectedItem(value:IItemRenderer):void
		{
			super.selectedItem = value;
			if(value != null) {
				_currentSelectedIndex = value.index;
				_currentSelectedKeys = _data.getKeysByIndex(_currentSelectedIndex);
			}
			else {
				_currentSelectedIndex = 0;
				_currentSelectedKeys = null;
			}
		}
		
		
		/**
		 * 通过在数据中的索引来选中子项
		 * @param index
		 */
		public function selectItemByDataIndex(index:uint):void
		{
			if(index >= _data.length) index = _data.length - 1;
			if(_page != null) _page.currentPage = Math.ceil((index + 1) / numPerPage);
			_currentSelectedIndex = index % numPerPage;
			_currentSelectedKeys = null;
			refresh();
		}
		
		
		/**
		 * 通过在数据中的键列表来选中子项
		 * @param keys
		 */
		public function selectItemByDataKeys(keys:Array):void
		{
			selectItemByDataIndex(_data.getIndexByKeys(keys));
		}
		
		
		/**
		 * 通过在数据中的键来获取子项
		 * @param key
		 */
		public function getItemByKey(key:*):IItemRenderer
		{
			if(_data == null) return null;
			
			var index:int = _data.getIndexByKey(key);
			if(_page != null) index -= (_page.currentPage - 1) * numPerPage;
			
			return _itemList[index];
		}
		
		
		/**
		 * 通过在数据中的键来设置子项的数据
		 * @param key
		 * @param data
		 */
		public function setItemDataByKey(key:*, data:*):void
		{
			var item:IItemRenderer = getItemByKey(key);
			if(item != null) {
				item.dispose();
				item.data = data;
			}
		}
		
		
		
		
		/**
		 * 每页显示的数量
		 */
		public function get numPerPage():uint
		{
			return _rowCount * _columnCount;
		}
		
		
		/**
		 * 通过列表中的索引，获取对应的在数据中的索引
		 * @param listIndex
		 * @return 
		 */
		public function getDataIndexByListIndex(listIndex:uint):uint
		{
			if(_page != null) {
				return (_page.currentPage - 1) * numPerPage + listIndex;
			}
			else {
				return listIndex;
			}
		}
		
		
		
		
		
		/**
		 * 对应的翻页组件触发翻页事件
		 * @param event
		 */
		private function page_flipHandler(event:PageEvent):void
		{
			_currentSelectedIndex = 0;
			_currentSelectedKeys = null;
			
			refresh(isDefaultSelect);
		}
		
		
		override protected function itemMouseDownHandler(event:MouseEvent):void
		{
			super.itemMouseDownHandler(event);
			var item:IItemRenderer = event.currentTarget as IItemRenderer;
			
			if(autoSelectItem)
			{
				if(_selectedItem == item) {
					if(item.deselect) selectedItem = null;
				}
				else {
					selectedItem = item;
				}
			}
		}
		
		
		override protected function itemClickHandler(event:MouseEvent):void
		{
			var item:IItemRenderer = event.currentTarget as IItemRenderer;
			this.dispatchEvent(new ItemEvent(ItemEvent.ITEM_CLICK, item));
		}
		
		
		
		
		/**
		 * 子项的渲染类
		 */
		public function set itemRendererClass(value:Class):void
		{
			recoverAllItem();
			_itemRendererClass = value;
			refresh();
		}
		public function get itemRendererClass():Class { return _itemRendererClass; }
		
		
		/**
		 * 刷新列表时，根据什么来选中子项
		 */
		public function set selectMode(value:String):void
		{
			_selectMode = value;
			refresh();
		}
		public function get selectMode():String { return _selectMode; }
		
		
		/**
		 * 列数
		 */
		public function set columnCount(value:uint):void
		{
			_columnCount = value;
			show();
		}
		public function get columnCount():uint { return _columnCount; }
		
		/**
		 * 行数
		 */
		public function set rowCount(value:uint):void
		{
			_rowCount = value;
			show();
		}
		public function get rowCount():uint { return _rowCount; }
		
		
		/**
		 * 对应的翻页组件
		 */
		public function set page(value:Page):void
		{
			if(_page == value) return;
			
			if(_page != null) _page.removeEventListener(PageEvent.FLIP, page_flipHandler);
			
			_page = value;
			if(_page != null) _page.addEventListener(PageEvent.FLIP, page_flipHandler);
			
			refresh();
		}
		public function get page():Page { return _page; }
		
		
		
		
		/**
		 * 移除所有子项，并回收到缓存池中
		 */
		private function recoverAllItem():void
		{
			var item:IItemRenderer;
			while(_itemList.length > 0)
			{
				item = _itemList.shift();
				item.group = null;
				item.selected = false;
				item.dispose();
				this.removeChild(item as DisplayObject);
				
				_itemPool.push(item);
			}
			_selectedItem = null;
		}
		
		/**
		 * 清空子项缓存池
		 */
		private function clearItemPool():void
		{
			var item:IItemRenderer;
			while(_itemPool.length > 0)
			{
				item = _itemPool.shift();
				item.clear();
			}
		}
		
		
		override public function clear():void
		{
			if(_page != null) _page.reset();
			recoverAllItem();
			clearItemPool();
			
			_data = null;
			_lastShowState = {};
			_currentSelectedIndex = 0;
			_currentSelectedKeys = null;
		}
		
		
		
		/**
		 * 用于清理引用，释放内存
		 * 在丢弃该组件时，需要主动调用该方法
		 */
		public function dispose():void
		{
			clear();
			if(_page != null) {
				_page.dispose();
				_page = null;
			}
		}
		//
	}
}