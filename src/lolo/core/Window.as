package lolo.core
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import lolo.common.Common;
	import lolo.components.BaseButton;
	import lolo.components.Button;
	import lolo.components.ItemGroup;
	import lolo.events.components.ItemEvent;
	import lolo.ui.ICenterDisplayObject;
	import lolo.utils.AutoUtil;
	
	/**
	 * 窗口
	 * @author LOLO
	 */
	public class Window extends Module implements IWindow, ICenterDisplayObject
	{
		/**背景的容器*/
		protected var _backgroundC:Sprite;
		/**面板容器*/
		protected var _panelC:Sprite;
		/**选项卡按钮组*/
		protected var _tabBtnGroup:ItemGroup;
		/**关闭按钮*/
		protected var _closeBtn:BaseButton;
		/**当前显示的面板*/
		protected var _currentPanel:IRSprite;
		
		/**面板的引用列表*/
		protected var _panelList:Dictionary;
		
		/**当前窗口的ID*/
		private var _windowID:int;
		
		/**选项卡按钮的默认属性*/
		public var tabBtnDefaultProp:Object;
		
		
		public function Window()
		{
			super();
			_backgroundC = AutoUtil.init(new Sprite(), this);
			_tabBtnGroup = AutoUtil.init(new ItemGroup(), this);
			_closeBtn = AutoUtil.init(new BaseButton(), this);
			_panelC = AutoUtil.init(new Sprite(), this);
			
			styleName = "window";
			Common.ui.centerToStage(this);
			_panelList = new Dictionary();
			
			_closeBtn.addEventListener(MouseEvent.CLICK, closeBtn_clickHandler);
			_tabBtnGroup.addEventListener(ItemEvent.ITEM_SELECTED, tabBtnGroup_itemSelectedHandler);
		}
		
		
		
		/**
		 * 设置样式
		 * @param value
		 */
		public function set style(value:Object):void
		{
			if(value.background != null) background = value.background;
			if(value.backgroundProp != null) backgroundProp = value.backgroundProp;
			if(value.tabBtnGroupProp != null) tabBtnGroupProp = value.tabBtnGroupProp;
			if(value.tabBtnDefaultProp != null) {
				tabBtnDefaultProp = value.tabBtnDefaultProp;
				tabBtnProp = value.tabBtnDefaultProp;
			}
			if(value.closeBtnProp != null) closeBenProp = value.closeBtnProp;
		}
		
		
		/**
		 * 样式的名称
		 */
		public function set styleName(value:String):void
		{
			style = Common.style.getStyle(value);
		}
		
		
		/**
		 * 设置背景图
		 * @param value 背景图片的类定义名称
		 */
		public function set background(value:String):void
		{
			while(_backgroundC.numChildren > 0) _backgroundC.removeChildAt(0);
			AutoUtil.init(AutoUtil.getInstance(value), _backgroundC);
		}
		
		/**
		 * 背景图属性
		 * @param value
		 */
		public function set backgroundProp(value:Object):void
		{
			if(_backgroundC.numChildren > 0) {
				AutoUtil.initObject(_backgroundC.getChildAt(0), value);
			}
		}
		
		
		/**
		 * 选项卡按钮组属性
		 * @param value
		 */
		public function set tabBtnGroupProp(value:Object):void
		{
			AutoUtil.initObject(_tabBtnGroup, value);
			_tabBtnGroup.show();
		}
		
		/**
		 * 选项卡按钮属性
		 * @param value
		 */
		public function set tabBtnProp(value:Object):void
		{
			for(var i:int=0; i < _tabBtnGroup.numChildren; i++) {
				AutoUtil.initObject(_tabBtnGroup.getChildAt(i), value);
			}
			_tabBtnGroup.show();
		}
		
		/**
		 * 关闭按钮属性
		 * @param value
		 */
		public function set closeBenProp(value:Object):void
		{
			AutoUtil.initObject(_closeBtn, value);
		}
		
		
		
		
		/**
		 * 添加、注册一个面板
		 * @param panel 面板的实例
		 * @param name 面板的名称（也是选项卡按钮的名称）
		 * @param label 在选项卡按钮上显示的标签
		 */
		protected function addPanel(panel:DisplayObject, name:String, label:String):void
		{
			panel.name = name;
			_panelC.addChild(panel);
			_panelList[name] = panel;
			
			var tabBtn:Button = AutoUtil.init(new Button(), null, tabBtnDefaultProp);
			tabBtn.name = name;
			tabBtn.label = label;
			
			_tabBtnGroup.addItem(tabBtn);
			_tabBtnGroup.addChild(tabBtn);
		}
		
		
		
		
		/**
		 * 当前所选择的选项卡按钮有变换
		 * @param event
		 */
		protected function tabBtnGroup_itemSelectedHandler(event:ItemEvent):void
		{
			if(event.item) switchPanel(_panelList[event.item.name] as IRSprite);
		}
		
		
		/**
		 * 点击关闭按钮
		 * @param event
		 */
		protected function closeBtn_clickHandler(event:MouseEvent):void
		{
			Common.ui.closeWindow(this);
		}
		
		
		
		
		
		/**
		 * 切换面板
		 * @param panel 要切换至的面板
		 */
		protected function switchPanel(panel:IRSprite):void
		{
			if(_currentPanel == panel) return;
			if(_currentPanel != null) _currentPanel.hide();
			
			_currentPanel = panel;
			_currentPanel.show();
		}
		
		
		
		/**
		 * 设置指定名称的选项卡按钮是否可见
		 * @param name
		 * @param visible
		 */
		protected function setTabBtnVisible(name:String, visible:Boolean):void
		{
			var btn:Button = _tabBtnGroup.getChildByName(name) as Button;
			if(btn != null) {
				btn.visible = visible;
				_tabBtnGroup.show();
			}
		}
		
		
		
		override public function hide():void
		{
			if(!_isShow) return;
			
			//清除选中
			_currentPanel = null;
			_tabBtnGroup.selectedItem = null;
			
			//隐藏所有面板
			for(var i:int = 0; i < _panelC.numChildren; i++) {
				var panel:IRSprite = _panelC.getChildAt(i) as IRSprite;
				panel.hide();
			}
			
			super.hide();
		}
		
		
		
		/**
		 * 窗口ID
		 */
		public function set windowID(value:int):void
		{
			_windowID = value;
		}
		
		public function get windowID():int
		{
			return _windowID;
		}
		
		/**
		 * 当前打开的面板名称
		 */
		public function set panelName(value:String):void
		{
			var btn:Button = _tabBtnGroup.getChildByName(value) as Button;
			if(btn != null) btn.selected = true;
		}
		
		public function get panelName():String
		{
			return (_currentPanel != null) ? _currentPanel.name : "";
		}
		
		
		/**
		 * 获取居中宽度
		 * @return 
		 */
		public function get centerWidth():uint
		{
			return _backgroundC.width;
		}
		
		/**
		 * 获取居中高度
		 * @return 
		 */
		public function get centerHeight():uint
		{
			return _backgroundC.height;
		}
		//
	}
}