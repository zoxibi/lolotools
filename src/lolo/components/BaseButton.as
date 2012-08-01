package lolo.components
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import lolo.common.Common;
	import lolo.utils.AutoUtil;

	/**
	 * 基础按钮（图形皮肤）
	 * 在状态改变时，将皮肤切换到对应的状态
	 * @author LOLO
	 */
	public class BaseButton extends ItemRenderer
	{
		/**正常*/
		public static const STATE_UP:String = "up";
		/**鼠标移上来*/
		public static const STATE_OVER:String = "over";
		/**鼠标按下*/
		public static const STATE_DOWN:String = "down";
		/**禁用*/
		public static const STATE_DISABLED:String = "disabled";
		/**选中：正常*/
		public static const STATE_SELECTED_UP:String = "selectedUp";
		/**选中：鼠标移上来*/
		public static const STATE_SELECTED_OVER:String = "selectedOver";
		/**选中：鼠标按下*/
		public static const STATE_SELECTED_DOWN:String = "selectedDown";
		/**选中：禁用*/
		public static const STATE_SELECTED_DISABLED:String = "selectedDisabled";
		
		/**皮肤*/
		protected var _skin:MovieClip;
		/**指定的点击区域*/
		protected var _hitArea:Sprite;
		
		/**点击区域距顶像素*/
		protected var _hitAreaPaddingTop:int;
		/**点击区域距底像素*/
		protected var _hitAreaPaddingBottom:int;
		/**点击区域距左像素*/
		protected var _hitAreaPaddingLeft:int;
		/**点击区域距右像素*/
		protected var _hitAreaPaddingRight:int;
		
		/**设置的宽度*/
		protected var _width:uint;
		/**设置的高度*/
		protected var _height:uint;
		
		
		
		public function BaseButton()
		{
			super();
			this.mouseChildren = false;
		}
		
		
		/**
		 * 样式
		 */
		public function set style(value:Object):void
		{
			if(value.hitAreaPaddingTop != null) _hitAreaPaddingTop = value.hitAreaPaddingTop;
			if(value.hitAreaPaddingBottom != null) _hitAreaPaddingBottom = value.hitAreaPaddingBottom;
			if(value.hitAreaPaddingLeft != null) _hitAreaPaddingLeft = value.hitAreaPaddingLeft;
			if(value.hitAreaPaddingRight != null) _hitAreaPaddingRight = value.hitAreaPaddingRight;
			
			if(value.skin != null) skin = value.skin;
		}
		
		
		/**
		 * 样式的名称
		 */
		public function set styleName(value:String):void
		{
			style = Common.style.getStyle(value);
		}
		
		
		
		
		/**
		 * 设置皮肤的完整类定义名称
		 * @param value
		 */
		public function set skin(value:String):void
		{
			//移除旧皮肤
			if(_skin != null)
			{
				this.removeChild(_skin);
				_width = 0;
				_height = 0;
			}
			
			//创建新皮肤
			_skin = AutoUtil.getInstance(value);
			this.addChild(_skin);
			if(_width <= 0) _width = _skin.width;
			if(_height <= 0) _height = _skin.height;
			enabled = _enabled;
			
			//有指定点击区域
			_hitArea = _skin.getChildByName("hit") as Sprite;
			if(_hitArea != null)
			{
				_hitArea.alpha = 0;
				this.hitArea = _hitArea;
			}
			else {
				var hitArea:Sprite = new Sprite();
				hitArea.alpha = 0;
				this.addChild(hitArea);
				this.hitArea = hitArea;
			}
			
			update();
		}
		
		
		
		/**
		 * 显示更新
		 */
		public function update():void
		{
			if(_skin == null) return;
			
			//如果皮肤中没有指定的点击区域，根据设置的padding绘制hitArea
			if(_hitArea == null)
			{
				hitArea.graphics.clear();
				hitArea.graphics.beginFill(0);
				hitArea.graphics.drawRect(
					_hitAreaPaddingLeft, _hitAreaPaddingTop,
					_width - _hitAreaPaddingLeft - _hitAreaPaddingRight,
					_height - _hitAreaPaddingTop - _hitAreaPaddingBottom
				);
				hitArea.graphics.endFill();
			}
		}
		
		
		
		
		/**
		 * 切换到指定状态
		 * @param state
		 */
		protected function switchState(state:String):void
		{
			if(_skin != null) _skin.gotoAndStop(state);
		}
		
		
		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			setEventListener();
		}
		
		override public function set selected(value:Boolean):void
		{
			super.selected = value;
			setEventListener();
		}
		
		
		/**
		 * 根据状态，侦听事件或解除事件的侦听
		 */
		private function setEventListener():void
		{
			if(_enabled) {
				this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
				this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
				this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				switchState(_selected ? STATE_SELECTED_UP : STATE_UP);
			}
			else {
				this.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
				this.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
				this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				Common.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
				switchState(_selected ? STATE_SELECTED_DISABLED : STATE_DISABLED);
			}
		}
		
		
		/**
		 * 鼠标移上来
		 * @param event
		 */
		private function rollOverHandler(event:MouseEvent):void
		{
			if(_enabled && !event.buttonDown) rollOver();
		}
		private function rollOver():void
		{
			switchState(_selected ? STATE_SELECTED_OVER : STATE_OVER);
		}
		
		
		/**
		 * 鼠标移开
		 * @param event
		 */
		private function rollOutHandler(event:MouseEvent):void
		{
			if(_enabled && !event.buttonDown) rollOut();
		}
		private function rollOut():void
		{
			switchState(_selected ? STATE_SELECTED_UP : STATE_UP);
		}
		
		
		/**
		 * 鼠标按下
		 * @param event
		 */
		private function mouseDownHandler(event:MouseEvent):void
		{
			if(_enabled) {
				Common.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
				mouseDown();
			}
		}
		private function mouseDown():void
		{
			switchState(_selected ? STATE_SELECTED_DOWN : STATE_DOWN);
		}
		
		
		/**
		 * 鼠标在舞台释放
		 * @param event
		 */
		private function stageMouseUpHandler(event:MouseEvent):void
		{
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
			
			if(event.target == this) {
				rollOverHandler(event);
			}
			else {
				rollOutHandler(event);
			}
		}
		
		
		/**
		 * 返回皮肤中具有指定名称的子显示对象。如果多个子显示对象具有指定名称，则该方法会返回子级列表中的第一个对象。
		 * @param name
		 * @return 
		 */
		public function getSkinChildByName(name:String):DisplayObject
		{
			return _skin.getChildByName(name);
		}
		
		
		
		/**
		 * 点击区域距顶像素
		 */
		public function set hitAreaPaddingTop(value:int):void
		{
			_hitAreaPaddingTop = value;
			update();
		}
		public function get hitAreaPaddingTop():int { return _hitAreaPaddingTop; }
		
		
		/**
		 * 点击区域距底像素
		 */
		public function set hitAreaPaddingBottom(value:int):void
		{
			_hitAreaPaddingBottom = value;
			update();
		}
		public function get hitAreaPaddingBottom():int { return _hitAreaPaddingBottom; }
		
		
		/**
		 * 点击区域距左像素
		 */
		public function set hitAreaPaddingLeft(value:int):void
		{
			_hitAreaPaddingLeft = value;
			update();
		}
		public function get hitAreaPaddingLeft():int { return _hitAreaPaddingLeft; }
		
		
		/**
		 * 点击区域距右像素
		 */
		public function set hitAreaPaddingRight(value:int):void
		{
			_hitAreaPaddingRight = value;
			update();
		}
		public function get hitAreaPaddingRight():int { return _hitAreaPaddingRight; }
		
		
		
		
		override public function set width(value:Number):void
		{
			_skin.width = _width = value;
			update();
		}
		
		override public function set height(value:Number):void
		{
			_skin.height = _height = value;
			update();
		}
		
		
		override public function get itemWidth():uint { return _width; }
		
		override public function get itemHeight():uint { return _height; }
		//
	}
}