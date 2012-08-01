package lolo.common
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;

	/**
	 * 鼠标样式、显示管理
	 * @author LOLO
	 */
	public class MouseManager extends Sprite implements IMouseManager
	{
		/**单例的实例*/
		private static var _instance:MouseManager;
		
		
		/**皮肤（替代鼠标指针的动画）*/
		private var _skin:MovieClip = null;
		/**当前样式*/
		private var _style:String = null;
		/**当前状态*/
		private var _state:String;
		/**默认样式*/
		private var _defaultStyle:String = null;
		/**是否显示皮肤*/
		private var _isShowSkin:Boolean;
		/**是否自动切换状态*/
		private var _autoSwitchState:Boolean = true;
		/**是否自动隐藏默认光标*/
		private var _autoHideCursor:Boolean = true;
		
		/**绑定的样式列表，以实例为key*/
		private var _bindStyleList:Dictionary;
		
		/**当前正在显示样式的目标*/
		private var _currentTarget:DisplayObject;
		
		
		
		/**
		 * 获取实例
		 * @return 
		 */
		public static function getInstance():MouseManager
		{
			if(_instance == null) _instance = new MouseManager(new Enforcer());
			return _instance;
		}
		
		
		public function MouseManager(enforcer:Enforcer)
		{
			super();
			if(!enforcer) {
				throw new Error("请通过Common.mouse获取实例");
				return;
			}
			
			_state = Constants.MOUSE_STATE_NORMAL;
			_bindStyleList = new Dictionary();
			this.mouseEnabled = this.mouseChildren = false;
			
			var cm:ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();
			contextMenu = cm;
		}
		
		
		/**
		 * 皮肤（替代鼠标指针的动画）
		 */
		public function set skin(value:MovieClip):void
		{
			if(_skin != null) this.removeChild(_skin);
			
			_skin = value;
			if(_skin != null)
			{
				_skin.mouseEnabled = _skin.mouseChildren = false;
				_skin.gotoAndStop(1);
				this.addChild(_skin);
				update();
			}
		}
		public function get skin():MovieClip { return _skin; }
		
		
		/**
		 * 当前样式
		 */
		public function set style(value:String):void
		{
			_style = value;
			update();
		}
		public function get style():String { return _style; }
		
		/**
		 * 当前状态
		 */
		public function set state(value:String):void
		{
			_state = value;
			if(_skin != null) _skin.gotoAndStop(value);
		}
		public function get state():String { return _state; }
		
		
		/**
		 * 默认样式
		 */
		public function set defaultStyle(value:String):void
		{
			_defaultStyle = value;
			style = value;
		}
		public function get defaultStyle():String { return _defaultStyle; }
		
		
		/**
		 * 是否自动切换状态
		 */
		public function set autoSwitchState(value:Boolean):void
		{
			_autoSwitchState = value;
			
			if(_autoSwitchState && _isShowSkin)
			{
				Common.stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDownHandler);
				Common.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
				Common.stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
				if(_state == null) stage_mouseUpHandler();
			}
			else
			{
				Common.stage.removeEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDownHandler);
				Common.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
				Common.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
				stage_mouseUpHandler();
			}
		}
		public function get autoSwitchState():Boolean { return _autoSwitchState; }
		
		
		
		/**
		 * 是否启用
		 */
		public function set isShowSkin(value:Boolean):void
		{
			_isShowSkin = value;
			autoSwitchState = _autoSwitchState;
			var cm:ContextMenu = (Common.stage.getChildAt(0) as InteractiveObject).contextMenu;
			
			if(_isShowSkin) {
				Common.ui.addChildToLayer(this, Constants.LAYER_NAME_ADORN);
				if(_autoHideCursor) {
					Mouse.hide();
					stage_mouseMoveHandler();
					if(cm != null) cm.addEventListener(ContextMenuEvent.MENU_SELECT, stage_contextMenuSelectHandler);
				}
			}
			else {
				Mouse.show();
				Common.ui.removeChildToLayer(this, Constants.LAYER_NAME_ADORN);
				if(cm != null) cm.removeEventListener(ContextMenuEvent.MENU_SELECT, stage_contextMenuSelectHandler);
			}
		}
		public function get isShowSkin():Boolean { return _isShowSkin; }
		
		
		/**
		 * 是否自动隐藏默认光标
		 */
		public function set autoHideCursor(value:Boolean):void { _autoHideCursor = value; }
		public function get autoHideCursor():Boolean { return _autoHideCursor; }
		
		
		
		override public function set contextMenu(cm:ContextMenu):void
		{
			var stage:InteractiveObject = Common.stage.getChildAt(0) as InteractiveObject;
			if(stage.contextMenu != null) {
				stage.contextMenu.removeEventListener(ContextMenuEvent.MENU_SELECT, stage_contextMenuSelectHandler);
			}
			
			stage.contextMenu = cm;
			if(stage.contextMenu != null && _autoHideCursor && _isShowSkin) {
				stage.contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, stage_contextMenuSelectHandler);
			}
		}
		/**
		 * 打开右键菜单
		 * @param event
		 */
		private function stage_contextMenuSelectHandler(event:ContextMenuEvent):void
		{
			if(_autoHideCursor && _isShowSkin) Mouse.hide();
		}
		
		
		
		
		
		/**
		 * 显示更新
		 */		
		public function update():void
		{
			if(_skin == null || _style == null) return;
			_skin.gotoAndStop(_style + ":" + _state);
		}
		
		
		
		/**
		 * 鼠标在舞台上按下
		 * @param event
		 */
		private function stage_mouseDownHandler(event:MouseEvent):void
		{
			_state = Constants.MOUSE_STATE_PRESS;
			update();
		}
		
		/**
		 * 鼠标在舞台上释放
		 * @param event
		 */
		private function stage_mouseUpHandler(event:MouseEvent=null):void
		{
			_state = Constants.MOUSE_STATE_NORMAL;
			update();
		}
		
		/**
		 * 鼠标在舞台上移动
		 * @param event
		 */
		private function stage_mouseMoveHandler(event:MouseEvent=null):void
		{
			this.x = Common.stage.mouseX;
			this.y = Common.stage.mouseY;
			if(event != null) event.updateAfterEvent();
		}
		
		
		
		
		/**
		 * 绑定样式
		 * 当绑定目标发生对应的鼠标事件时，将会切换到对应的样式
		 * @param target 要绑定样式的目标
		 * @param style 对应的样式
		 * @param overEventType 鼠标移到目标上的事件类型
		 * @param outEventType 鼠标从目标上移开的事件类型
		 */
		public function bindStyle(target:DisplayObject, style:String, overEventType:String=null, outEventType:String=null):void
		{
			target.addEventListener((overEventType == null) ? MouseEvent.ROLL_OVER : overEventType, styleBingTarget_rollOverHandler);
			target.addEventListener((outEventType == null) ? MouseEvent.ROLL_OUT : outEventType, styleBingTarget_rollOutHandler);
			_bindStyleList[target] = style;
		}
		
		/**
		 * 解除样式绑定
		 * @param target 已绑定样式的目标
		 * @param overEventType 鼠标移到目标上的事件类型
		 * @param outEventType 鼠标从目标上移开的事件类型
		 */
		public function unbindStyle(target:DisplayObject, overEventType:String=null, outEventType:String=null):void
		{
			if(_currentTarget == target) {
				style = _defaultStyle;
				_currentTarget = null;
			}
			
			target.removeEventListener((overEventType == null) ? MouseEvent.ROLL_OVER : overEventType, styleBingTarget_rollOverHandler);
			target.removeEventListener((outEventType == null) ? MouseEvent.ROLL_OUT : outEventType, styleBingTarget_rollOutHandler);
			delete _bindStyleList[target];
		}
		
		
		/**
		 * 鼠标移到已绑定样式的目标上
		 * @param event
		 */
		private function styleBingTarget_rollOverHandler(event:MouseEvent):void
		{
			_currentTarget = event.currentTarget as DisplayObject;
			style = _bindStyleList[event.currentTarget];
		}
		
		/**
		 * 鼠标从已绑定样式的目标上移开
		 * @param event
		 */
		private function styleBingTarget_rollOutHandler(event:MouseEvent):void
		{
			_currentTarget = null;
			style = _defaultStyle;
		}
		//
	}
}


class Enforcer {}