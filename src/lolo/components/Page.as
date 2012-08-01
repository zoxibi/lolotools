package lolo.components
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import lolo.common.Common;
	import lolo.events.components.PageEvent;
	import lolo.utils.AutoUtil;
	import lolo.utils.StringUtil;

	/**
	 * 翻页组件
	 * @author LOLO
	 */
	public class Page extends Sprite
	{
		/**首页按钮*/
		protected var _firstBtn:Button;
		/**尾页按钮*/
		protected var _lastBtn:Button;
		/**上一页按钮*/
		protected var _prevBtn:Button;
		/**下一页按钮*/
		protected var _nextBtn:Button;
		/**页码显示文本*/
		protected var _pageText:Label;
		
		/**当前页*/
		protected var _currentPage:uint;
		/**总页数*/
		protected var _totalPage:uint;
		/**页码显示文本的格式化字符串*/
		protected var _pageTextFormat:String = "{0}/{1}";
		
		/**是否启用*/
		protected var _enabled:Boolean = true;
		
		
		public function Page()
		{
			super();
			
			_firstBtn	= AutoUtil.init(new Button(), this, { enabled:false });
			_lastBtn	= AutoUtil.init(new Button(), this, { enabled:false });
			_prevBtn	= AutoUtil.init(new Button(), this, { enabled:false });
			_nextBtn	= AutoUtil.init(new Button(), this, { enabled:false });
			_pageText	= AutoUtil.init(new Label(), this);
			
			_firstBtn.addEventListener(MouseEvent.CLICK, firstBtn_clickHandler);
			_lastBtn.addEventListener(MouseEvent.CLICK, lastBtn_clickHandler);
			_prevBtn.addEventListener(MouseEvent.CLICK, prevBtn_clickHandler);
			_nextBtn.addEventListener(MouseEvent.CLICK, nextBtn_clickHandler);
		}
		
		
		/**
		 * 页码显示文本的格式化字符串
		 */
		public function set pageTextFormat(value:String):void { _pageTextFormat = value; }
		public function get pageTextFormat():String { return _pageTextFormat; }
		
		/**
		 * 页码显示文本的格式化字符串的ID，将会根据该ID自动到语言包中取出内容
		 * @param value
		 */
		public function set pageTextFormatID(value:String):void
		{
			_pageTextFormat = Common.language.getLanguage(value);
		}
		
		
		
		/**
		 * 首页按钮的属性
		 */
		public function set firstBtnProp(value:Object):void
		{
			AutoUtil.initObject(_firstBtn, value);
		}
		
		/**
		 * 尾页按钮的属性
		 */
		public function set lastBtnProp(value:Object):void
		{
			AutoUtil.initObject(_lastBtn, value);
		}
		
		/**
		 * 上一页按钮的属性
		 */
		public function set prevBtnProp(value:Object):void
		{
			AutoUtil.initObject(_prevBtn, value);
		}
		
		/**
		 * 下一页按钮的属性
		 */
		public function set nextBtnProp(value:Object):void
		{
			AutoUtil.initObject(_nextBtn, value);
		}
		
		/**
		 * 页码显示文本的属性
		 */
		public function set pageTextProp(value:Object):void
		{
			AutoUtil.initObject(_pageText, value);
		}
		
		
		
		
		/**
		 * 点击首页按钮
		 * @param event
		 */
		protected function firstBtn_clickHandler(event:MouseEvent):void
		{
			currentPage = 1;
			this.dispatchEvent(new PageEvent(PageEvent.FLIP, _currentPage, _totalPage));
		}
		
		/**
		 * 点击尾页按钮
		 * @param event
		 */
		protected function lastBtn_clickHandler(event:MouseEvent):void
		{
			currentPage = _totalPage;
			this.dispatchEvent(new PageEvent(PageEvent.FLIP, _currentPage, _totalPage));
		}
		
		/**
		 * 点击上一页按钮
		 * @param event
		 */
		protected function prevBtn_clickHandler(event:MouseEvent):void
		{
			currentPage = _currentPage - 1;
			this.dispatchEvent(new PageEvent(PageEvent.FLIP, _currentPage, _totalPage));
		}
		
		/**
		 * 点击下一页按钮
		 * @param event
		 */
		protected function nextBtn_clickHandler(event:MouseEvent):void
		{
			currentPage = _currentPage + 1;
			this.dispatchEvent(new PageEvent(PageEvent.FLIP, _currentPage, _totalPage));
		}
		
		
		/**
		 * 当前页
		 */
		public function set currentPage(value:uint):void
		{
			_currentPage = value;
			update();
		}
		public function get currentPage():uint { return _currentPage; }
		
		
		/**
		 * 总页数
		 */
		public function set totalPage(value:uint):void
		{
			_totalPage = value;
			update();
		}
		public function get totalPage():uint { return _totalPage; }
		
		
		
		/**
		 * 根据数量初始化
		 * 如果有与列表相关联，列表将会自动调用该方法
		 * @param numPerPage 每页显示的数量
		 * @param numTotal 总数量
		 */		
		public function init(numPerPage:uint, numTotal:uint):void
		{
			_totalPage = Math.ceil(numTotal / numPerPage);
			if(_currentPage == 0 && _totalPage > 0) _currentPage = 1;
			if(_currentPage > _totalPage) _currentPage = _totalPage;
			update();
		}
		
		
		/**
		 * 显示更新
		 */	
		public function update():void
		{
			_firstBtn.enabled	= _enabled && _currentPage > 1;
			_lastBtn.enabled	= _enabled && _currentPage < _totalPage;
			_prevBtn.enabled	= _firstBtn.enabled;
			_nextBtn.enabled	= _lastBtn.enabled;
			_pageText.text = StringUtil.substitute(_pageTextFormat, _currentPage, _totalPage);
		}
		
		
		
		/**
		 * 是否启用
		 */
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			_firstBtn.enabled = value;
			_lastBtn.enabled = value;
			_prevBtn.enabled = value;
			_nextBtn.enabled = value;
		}
		public function get enabled():Boolean { return _enabled; }
		
		
		
		/**
		 * 首页按钮
		 */
		public function get firstBtn():Button { return _firstBtn; }
		
		/**
		 * 尾页按钮
		 */
		public function get lastBtn():Button { return _lastBtn; }
		
		/**
		 * 上一页按钮
		 */
		public function get prevBtn():Button { return _prevBtn; }
		
		/**
		 * 下一页按钮
		 */
		public function get nextBtn():Button { return _nextBtn; }
		
		/**
		 * 页码显示文本
		 */
		public function get pageText():Label { return _pageText; }
		
		
		
		/**
		 * 重置
		 */
		public function reset():void
		{
			_totalPage = _currentPage = 0;
			update();
		}
		
		
		
		/**
		 * 用于清理引用，释放内存
		 * 在丢弃该组件时，需要主动调用该方法
		 */
		public function dispose():void
		{
			_firstBtn.dispose();
			_lastBtn.dispose();
			_prevBtn.dispose();
			_nextBtn.dispose();
			_pageText.dispose();
		}
		//
	}
}