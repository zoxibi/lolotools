package lolo.common
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	import lolo.core.IRSprite;
	import lolo.core.IScene;
	import lolo.core.IWindow;
	import lolo.ui.ICenterDisplayObject;
	import lolo.ui.ILoadBar;
	import lolo.ui.IRequestModal;
	
	/**
	 * 用户界面管理
	 * @author LOLO
	 */
	public class UIManager extends Sprite implements IUIManager
	{
		/**背景层*/
		protected var _bgLayer:Sprite;
		/**场景层*/
		protected var _sceneLayer:Sprite;
		/**UI层*/
		protected var _uiLayer:Sprite;
		/**窗口层*/
		protected var _windowLayer:Sprite;
		/**顶级UI层*/
		protected var _uiTopLayer:Sprite;
		/**游戏指导层*/
		protected var _guideLayer:Sprite;
		/**提示消息层*/
		protected var _alertLayer:Sprite;
		/**顶级层*/
		protected var _topLayer:Sprite;
		/**装饰层*/
		protected var _adornLayer:Sprite;
		
		/**模块加载条*/
		protected var _loadBar:ILoadBar;
		/**将与服务端通信的请求进行模态的界面*/
		protected var _requestModal:IRequestModal;
		
		/**模块初始化参数，以及储存一些临时变量*/
		protected var _args:Object;
		/**当前场景*/
		protected var _nowScene:IScene;
		/**当前窗口*/
		protected var _nowWindow:IWindow;
		
		
		
		public function UIManager()
		{
			super();
			
			_args = {};
			
			_bgLayer = new Sprite();
			_bgLayer.mouseEnabled = false;
			_bgLayer.name = Constants.LAYER_NAME_BG;
			this.addChild(_bgLayer);
			
			_sceneLayer = new Sprite();
			_sceneLayer.mouseEnabled = false;
			_sceneLayer.name = Constants.LAYER_NAME_SCENE;
			this.addChild(_sceneLayer);
			
			_uiLayer = new Sprite();
			_uiLayer.mouseEnabled = false;
			_uiLayer.name = Constants.LAYER_NAME_UI;
			this.addChild(_uiLayer);
			
			_windowLayer = new Sprite();
			_windowLayer.mouseEnabled = false;
			_windowLayer.name = Constants.LAYER_NAME_WINDOW;
			this.addChild(_windowLayer);
			
			_uiTopLayer = new Sprite();
			_uiTopLayer.mouseEnabled = false;
			_uiTopLayer.name = Constants.LAYER_NAME_UI_TOP;
			this.addChild(_uiTopLayer);
			
			_guideLayer = new Sprite();
			_guideLayer.mouseEnabled = false;
			_guideLayer.name = Constants.LAYER_NAME_GUIDE;
			this.addChild(_guideLayer);
			
			_alertLayer = new Sprite();
			_alertLayer.mouseEnabled = false;
			_alertLayer.name = Constants.LAYER_NAME_ALERT;
			this.addChild(_alertLayer);
			
			_topLayer = new Sprite();
			_topLayer.mouseEnabled = false;
			_topLayer.name = Constants.LAYER_NAME_TOP;
			this.addChild(_topLayer);
			
			_adornLayer = new Sprite();
			_adornLayer.mouseEnabled = false;
			_adornLayer.name = Constants.LAYER_NAME_ADORN;
			this.addChild(_adornLayer);
		}
		
		
		
		/**
		 * 初始化，入口函数
		 */
		public function init():void
		{
		}
		
		
		
		/**
		 * 显示加载条
		 * @param listener 是否侦听资源加载事件
		 */
		public function showLoadBar(isListenResLoad:Boolean=true):void
		{
			_loadBar.addListenerToRes = isListenResLoad;
			addChildToLayer(_loadBar as DisplayObject, Constants.LAYER_NAME_TOP);
		}
		
		/**
		 * 隐藏加载条
		 */
		public function hideLoadBar():void
		{
			removeChildToLayer(_loadBar as DisplayObject, Constants.LAYER_NAME_TOP);
		}
		
		
		/**
		 * 添加显示对象到指定的层中
		 * @param child 显示对象
		 * @param layerName 层的名称
		 */
		public function addChildToLayer(child:DisplayObject, layerName:String):void
		{
			if(layerName == Constants.LAYER_NAME_WINDOW) {
				throw new Error("要将显示对象添加到window层，请使用openWindow方法");
				return;
			}
			
			var layer:DisplayObjectContainer = this.getChildByName(layerName) as DisplayObjectContainer;
			if(layer != null && child != null) {
				showDisplayObject(child, layer);
			}
		}
		
		/**
		 * 从指定层中移除指定显示对象
		 * @param child 显示对象
		 * @param layerName 层的名称
		 */
		public function removeChildToLayer(child:DisplayObject, layerName:String):void
		{
			var layer:DisplayObjectContainer = this.getChildByName(layerName) as DisplayObjectContainer;
			if(layer != null && child != null) {
				if(child.parent == layer) hideDisplayObject(child);
			}
		}
		
		
		
		/**
		 * 显示一个显示对象，并添加到指定容器中。
		 * 如果显示对象为IRsprite，将会调用show方法进行显示
		 * @param target 目标显示对象
		 * @param parent 父级容器
		 */
		private function showDisplayObject(target:DisplayObject, parent:DisplayObjectContainer):void
		{
			if(target.parent == parent) {
				target.parent.setChildIndex(target, target.parent.numChildren - 1);
			}else {
				parent.addChild(target);
			}
			
			if(target is IRSprite) {
				(target as IRSprite).show();
			}else {
				target.visible = true;
			}
		}
		
		/**
		 * 隐藏一个显示对象，并自动从父级容器中移除。
		 * 如果显示对象为IRsprite，将会调用hide方法进行隐藏
		 * @param target
		 */
		private function hideDisplayObject(target:DisplayObject):void
		{
			if(target == null) return;
			
			if(target is IRSprite) {
				(target as IRSprite).hide();
			}else {
				target.visible = false;
				if(target.parent) target.parent.removeChild(target);
			}
		}
		
		
		
		
		
		/**
		 * 将显示对象在窗口层中打开
		 * @param window 显示对象
		 * @param closeOther 是否关闭其他已打开的窗口
		 */
		public function openWindow(window:DisplayObject, closeOther:Boolean=true):void
		{
			if(closeOther) closeAllWindow();
			showDisplayObject(window, _windowLayer);
		}
		
		/**
		 * 关闭指定的窗口
		 * @param window 要关闭的窗口
		 */
		public function closeWindow(window:DisplayObject):void
		{
			hideDisplayObject(window);
			if(_nowWindow == window) _nowWindow = null;
		}
		
		/**
		 * 关闭所有窗口
		 */
		public function closeAllWindow():void
		{
			_nowWindow = null;
			
			var list:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			for(var i:int = 0; i < _windowLayer.numChildren; i++) {
				list.push(_windowLayer.getChildAt(i));
			}
			while(list.length > 0) {
				hideDisplayObject(list.shift());
			}
		}
		
		/**
		 * 打开或者关闭窗口模块
		 * @param window 要打开或者关闭的窗口模块
		 * @param panelName 窗口模块中，面板的名称
		 * @param closeOther 是否关闭其他已打开的窗口
		 */
		public function openOrCloseWindow(window:IWindow, panelName:String, closeOther:Boolean=true):void
		{
			//不是当前已打开的窗口模块
			if(window != _nowWindow) {
				openWindow(window as DisplayObject, closeOther);
				window.panelName = panelName;
				_nowWindow = window;
			}
			else {
				//不是已打开的面板
				if(_nowWindow.panelName != panelName) {
					_nowWindow.panelName = panelName;
				}else {
					closeWindow(window as DisplayObject);
					_nowWindow = null;
				}
			}
		}
		
		
		
		
		
		/**
		 * 切换显示指定ID的场景
		 * @param sceneID 场景ID
		 * @param rest 场景初始化参数列表
		 */
		public function showScene(sceneID:int, ...rest):void
		{
			//临时储存这次切换场景时，携带的参数。在显示的时候，再记录到当前场景参数中
			_args.sceneArgs = rest[0];
		}
		
		/**
		 * 显示上一个场景
		 */
		public function showLastScene():void
		{
			if(_args.lastSceneID != null) {
				var args:Array = _args.lastSceneArgs.concat();
				args.unshift(_args.lastSceneID);
				showScene.apply(null, args);
			}
		}
		
		/**
		 * 获取上一个场景的ID
		 * @return 
		 */
		public function get lastSceneID():int
		{
			return _args.lastSceneID;
		}
		
		/**
		 * 获取当前场景的ID，没有进入场景时，值为0（默认）
		 * @return 
		 */
		public function get nowSceneID():int
		{
			if(_nowScene == null) return 0;
			return _nowScene.sceneID;
		}
		
		/**
		 * 获取当前场景视图的ID，没有进入场景或者场景没有设置过视图ID时，值为0（默认）
		 * @return 
		 */
		public function get nowSceneViewID():int
		{
			if(_nowScene == null) return 0;
			return _nowScene.viewID;
		}
		
		
		/**
		 * 切换到指定场景
		 * @param scene 要切换至的场景
		 */
		protected function switchScene(scene:IScene):void
		{
			closeAllWindow();
			
			if(_nowScene != null) {
				_args.lastSceneID = _nowScene.sceneID;
				_args.lastSceneArgs = _args.currentSceneArgs;//记录到上个场景参数中
				if(_nowScene != scene) _nowScene.hide();
			}
			
			_nowScene = scene;
			_args.currentSceneArgs = _args.sceneArgs;//记录到当前场景参数中
			showDisplayObject(_nowScene as DisplayObject, _sceneLayer);
		}
		
		
		/**
		 * 显示指定ID的窗口
		 * @param windowID 窗口的ID 
		 * @param rest 窗口初始化参数列表
		 */
		public function showWindow(windowID:int, ...rest):void
		{
			throw new Error("showWindow方法应由子类实现");
		}
		
		/**
		 * 获取当前窗口的ID，没有打开窗口时，值为0（默认）
		 * @return 
		 */
		public function get nowWindowID():int
		{
			return (_nowWindow != null) ? _nowWindow.windowID : 0;
		}
		
		/**
		 * 获取当前窗口中已打开面板的名称，没有打开窗口或面板时，值为null（默认）
		 * @return 
		 */
		public function get nowWindowPanelName():String
		{
			return (_nowWindow != null) ? _nowWindow.panelName : null;
		}
		
		
		
		/**
		 * 将与服务端通信的请求进行模态的界面
		 * @return 
		 */
		public function get requesModal():IRequestModal
		{
			return _requestModal;
		}
		
		
		
		/**
		 * 将显示对象居中于舞台
		 * @param view
		 */
		public function centerToStage(view:ICenterDisplayObject):void
		{
			view.x = int( (stageWidth - view.centerWidth) / 2 );
			view.y = int( (stageHeight - view.centerHeight) / 2 );
		}
		
		
		/**
		 * 获取舞台宽度
		 * @return 
		 */
		public function get stageWidth():int
		{
			return (Common.stage != null) ? Common.stage.stageWidth : 1000;
		}
		
		/**
		 * 获取舞台高度
		 * @return 
		 */
		public function get stageHeight():int
		{
			return (Common.stage != null) ? Common.stage.stageHeight : 600;
		}
		//
	}
}