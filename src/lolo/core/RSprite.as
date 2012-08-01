package lolo.core
{
	import com.greensock.TweenMax;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;

	/**
	 * 基本显示对象
	 * 
	 * 实现：
	 * show() & startup()
	 * hide() & reset()
	 * 默认淡入淡出效果
	 * @author LOLO
	 */
	public class RSprite extends Sprite implements IRSprite
	{
		/**是否已经显示(显示过程中)*/
		protected var _isShow:Boolean = false;
		/**是否已经启动*/
		protected var _isStartup:Boolean = false;
		/**是否已经重置*/
		protected var _isReset:Boolean = true;
		
		/**对父级容器的引用*/
		protected var _parent:DisplayObjectContainer;
		/**鼠标遮挡物*/
		protected var _mouseOccluder:Sprite;
		
		
		/**是否自动添加到显示对象、从显示对象中移除*/
		private var _autoRemove:Boolean = true;
		/**在显示或隐藏动画中是否遮挡住鼠标*/
		private var _autoBlockMouse:Boolean = true;
		
		/**显示动画的持续时间(单位:秒)*/
		protected var _showEffectDuration:Number = 0.3;
		/**隐藏动画的持续时间(单位:秒)*/
		protected var _hideEffectDuration:Number = 0.2;
		/**显示动画的延迟时间(单位:秒)*/
		protected var _showEffectDelay:Number = 0;
		/**隐藏动画的延迟时间(单位:秒)*/
		protected var _hideEffectDelay:Number = 0;
		
		
		public function RSprite()
		{
			super();
			
			this.alpha = 0;
			this.visible = false;
			this.addEventListener(Event.ADDED, addedHandler);
			
			_mouseOccluder = new Sprite();
		}
		
		
		/**
		 * 添加到显示列表中时
		 * @param event
		 */
		private function addedHandler(event:Event):void
		{
			if(this.parent != null) {
				_parent = this.parent;
				try {
					if(!_isShow && _autoRemove) this.parent.removeChild(this);
				}
				catch(err:Error) {}
			}
		}
		
		
		/**
		 * 设置是否遮挡住鼠标
		 * @param value
		 */		
		public function set blockMouse(value:Boolean):void
		{
			if(value && _autoBlockMouse) {
				_mouseOccluder.graphics.clear();
				var rect:Rectangle = this.getBounds(this);
				
				_mouseOccluder.graphics.beginFill(0, 0.001);
				_mouseOccluder.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
				_mouseOccluder.graphics.endFill();
				this.addChild(_mouseOccluder);
			}else {
				if(_mouseOccluder.parent == this) this.removeChild(_mouseOccluder);
			}
		}
		
		
		
		/**
		 * 播放显示动画
		 * 继承类替换该方法时，在动画播放完毕时，一定要调用showEffectComplete方法来启动该显示对象
		 */
		protected function showEffectStart():void
		{
			TweenMax.killTweensOf(this);
			TweenMax.to(this, _showEffectDuration, { delay:_showEffectDelay, alpha:1, onComplete:showEffectComplete });
		}
		
		/**
		 * 播放显示动画完毕
		 */
		protected function showEffectComplete():void
		{
			if(!_isStartup) {
				_isStartup = true;
				_isReset = false;
				startup();
			}
			blockMouse = false;
		}
		
		/**
		 * 启动
		 */
		protected function startup():void
		{
			
		}
		
		
		
		
		/**
		 * 播放隐藏动画
		 * 继承类替换该方法时，在动画播放完毕时，一定要调用hideEffectComplete方法来重置该显示对象
		 */
		protected function hideEffectStart():void
		{
			TweenMax.killTweensOf(this);
			TweenMax.to(this, _hideEffectDuration, { delay:_hideEffectDelay, alpha:0, onComplete:hideEffectComplete });
		}
		
		/**
		 * 播放隐藏动画完毕
		 */
		protected function hideEffectComplete():void
		{
			if(this.parent != null) {
				_parent = this.parent;
				if(_autoRemove) this.parent.removeChild(this);
			}
			this.visible = false;
			
			if(!_isReset) {
				_isStartup = false;
				_isReset = true;
				reset();
			}
		}
		
		/**
		 * 重置
		 */
		protected function reset():void
		{
			
		}
		
		
		
		
		/**
		 * 显示
		 */
		public function show():void
		{
			if(!_isShow) {
				blockMouse = true;
				
				_isShow = true;
				this.visible = true;
				if(this.parent == null && _parent != null && _autoRemove) _parent.addChild(this);
				showEffectStart();
			}
		}
		
		/**
		 * 隐藏
		 */
		public function hide():void
		{
			if(_isShow) {
				blockMouse = true;
				
				_isShow = false;
				hideEffectStart();
			}
		}
		
		/**
		 * 当前如果为显示状态，将会切换到隐藏状态。
		 * 相反，如果为隐藏状态，将会切换到显示状态
		 */	
		public function showOrHide():void
		{
			_isShow ? hide() : show();
		}
		
		
		
		
		/**
		 * 立即显示
		 */
		public function nowShow():void
		{
			if(_isShow && !_isStartup) _isShow = false;
			
			var duration:Number = _showEffectDuration;
			var delay:Number = _showEffectDelay;
			_showEffectDuration = 0;
			_showEffectDelay = 0;
			show();
			_showEffectDuration = duration;
			_showEffectDelay = delay;
		}
		
		/**
		 * 立即隐藏
		 */
		public function nowHide():void
		{
			if(!_isShow && !_isReset) _isShow = true;
			
			var duration:Number = _hideEffectDuration;
			var delay:Number = _hideEffectDelay;
			_hideEffectDuration = 0;
			_hideEffectDelay = 0;
			hide();
			_hideEffectDuration = duration;
			_hideEffectDelay = delay;
		}
		
		/**
		 * 立即切换到显示状态，或者立即切换到隐藏状态
		 */
		public function nowShowOrHide():void
		{
			_isShow ? nowHide() : nowShow();
		}
		
		
		
		/**
		 * 当前是否为显示状态
		 */	
		public function get isShow():Boolean
		{
			return _isShow;
		}
		
		
		
		/**
		 * 是否自动添加到显示对象、从显示对象中移除
		 */		
		public function get autoRemove():Boolean { return _autoRemove; }
		public function set autoRemove(value:Boolean):void { _autoRemove = value; }
		
		/**
		 * 在显示或隐藏动画中是否遮挡住鼠标响应
		 */		
		public function get autoBlockMouse():Boolean { return _autoBlockMouse; }
		public function set autoBlockMouse(value:Boolean):void { _autoBlockMouse = value; }
		
		/**
		 * 显示动画的持续时间(单位:秒)
		 */
		public function get showEffectDuration():Number { return _showEffectDuration; }
		public function set showEffectDuration(value:Number):void { _showEffectDuration = value; }
		
		/**
		 * 隐藏动画的持续时间(单位:秒)
		 */
		public function get hideEffectDuration():Number { return _hideEffectDuration; }
		public function set hideEffectDuration(value:Number):void { _hideEffectDuration = value; }
		
		/**
		 * 隐藏动画的延迟时间(单位:秒)
		 */
		public function get showEffectDelay():Number { return _showEffectDelay; }
		public function set showEffectDelay(value:Number):void { _showEffectDelay = value; }
		
		/**
		 * 隐藏动画的延迟时间(单位:秒)
		 */
		public function get hideEffectDelay():Number { return _hideEffectDelay; }
		public function set hideEffectDelay(value:Number):void { _hideEffectDelay = value; }
		//
	}
}