package lolo.components
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import lolo.common.Common;
	import lolo.utils.AutoUtil;
	import lolo.utils.RTimer;

	/**
	 * 滚动条
	 * @author LOLO
	 */
	public class ScrollBar extends Sprite
	{
		/**指定滚动条用于水平滚动*/
		public static const HORIZONTAL:String = "horizontal";
		/**指定滚动条用于垂直滚动*/
		public static const VERTICAL:String = "vertical";
		
		/**轨道*/
		private var _track:BaseButton;
		/**滑块*/
		private var _thumb:BaseButton;
		/**向上或向左按钮*/
		private var _upArrow:BaseButton;
		/**向下或向右按钮*/
		private var _downArrow:BaseButton;
		
		/**滚动的内容*/
		private var _content:Sprite;
		/**内容的遮罩*/
		private var _contentMask:Mask;
		/**内容的显示区域（滚动区域）*/
		private var _disArea:Rectangle;
		
		/**是否启用*/
		private var _enabled:Boolean = true;
		/**滚动方向，水平还是垂直*/
		private var _direction:String;
		/**滚动条的尺寸，水平时为width，垂直时为height*/
		private var _size:uint;
		
		/**坐标属性的名称，水平:"x"，垂直:"y"*/
		private var _xy:String;
		/**宽高属性的名称，水平:"width"，垂直:"height"*/
		private var _wh:String;
		/**当前滚动状态是否为向上或向左滚动*/
		private var _scrollUp:Boolean;
		/**当前滚动状态是否为自动滚动行而不是页*/
		private var _scrollLine:Boolean;
		/**当前是否显示（内容尺寸是否超出了显示区域）*/
		private var _isShow:Boolean;
		
		/**在显示内容尺寸改变时，是否自动隐藏或显示*/
		private var _autoDisplay:Boolean;
		
		/**用于在对应的鼠标按下状态，定时滚动行或页*/
		private var _timer:RTimer;
		
		/**是否自动调整滑块尺寸*/
		public var autoThumbSize:Boolean;
		
		/**滑块最小尺寸*/
		public var thumbMinSize:uint = 5;
		/**一行的滚动量*/
		public var lineScrollSize:uint = 15;
		/**一页的滚动量，默认值为0，表示自动使用显示区域的尺寸代替该值*/
		public var pageScrollSize:uint = 0;
		
		/**第一次buttonDown事件后，在按repeatInterval重复buttonDown事件前，需要等待的毫秒数*/
		public var repeatDelay:uint = 500;
		/**在按钮上按住鼠标时，重复buttonDown事件的间隔毫秒数*/
		public var repeatInterval:uint = 35;
		
		
		
		public function ScrollBar()
		{
			super();
			direction = VERTICAL;
			
			_track		= AutoUtil.init(new BaseButton(), this);
			_thumb		= AutoUtil.init(new BaseButton(), this);
			_upArrow	= AutoUtil.init(new BaseButton(), this);
			_downArrow	= AutoUtil.init(new BaseButton(), this);
			
			_timer = RTimer.getInstance(repeatDelay, timerHandler);
		}
		
		
		/**
		 * 样式
		 */
		public function set style(value:Object):void
		{
			if(value.trackSkin != null) _track.skin = value.trackSkin;
			if(value.thumbSkin != null) _thumb.skin = value.thumbSkin;
			if(value.upArrowSkin != null) _upArrow.skin = value.upArrowSkin;
			if(value.downArrowSkin != null) _downArrow.skin = value.downArrowSkin;
			
			if(value.direction != null) direction = value.direction;
			if(value.autoDisplay != null) _autoDisplay = value.autoDisplay;
			if(value.autoThumbSize != null) autoThumbSize = value.autoThumbSize;
			if(value.thumbMinSize != null) thumbMinSize = value.thumbMinSize;
			
			if(value.lineScrollSize != null) lineScrollSize = value.lineScrollSize;
			if(value.pageScrollSize != null) pageScrollSize = value.pageScrollSize;
			if(value.repeatDelay != null) repeatDelay = value.repeatDelay;
			if(value.repeatInterval != null) repeatInterval = value.repeatInterval;
			
			if(value.size != null) size = value.size;
		}
		
		/**
		 * 样式的名称
		 */
		public function set styleName(value:String):void
		{
			style = Common.style.getStyle(value);
		}
		
		
		/**
		 * 轨道的属性
		 */
		public function set trackProp(value:Object):void
		{
			AutoUtil.initObject(_track, value);
		}
		
		/**
		 * 滑块的属性
		 */
		public function set thumbProp(value:Object):void
		{
			AutoUtil.initObject(_thumb, value);
		}
		
		/**
		 * 向上或向左按钮的属性
		 */
		public function set upArrowProp(value:Object):void
		{
			AutoUtil.initObject(_upArrow, value);
		}
		
		/**
		 * 向下或向右按钮的属性
		 */
		public function set downArrowProp(value:Object):void
		{
			AutoUtil.initObject(_downArrow, value);
		}
		
		
		
		/**
		 * 显示更新
		 */
		public function update():void
		{
			if(_disArea == null || _content == null) return;
			
			_content.graphics.clear();//清除用于填充空白区域的绘制内容
			_isShow = _content[_wh] > _disArea[_wh];
			
			if(_autoDisplay) this.visible = _isShow;
			enabled = _enabled;
			
			if(_isShow) {
				if(autoThumbSize)
				{
					_thumb[_wh] = int(_disArea[_wh] / _content[_wh] * _track[_wh]);
					if(_thumb[_wh] < thumbMinSize) _thumb[_wh] = thumbMinSize;
				}
				
				moveContent(_content[_xy]);
				moveThumbByContent();
				
				if(_direction == VERTICAL) _content.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
				this.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
				_track.addEventListener(MouseEvent.MOUSE_DOWN, track_mouseDownHandler);
				_thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumb_mouseDownHandler);
				if(_upArrow != null) _upArrow.addEventListener(MouseEvent.MOUSE_DOWN, arrowMouseDownHandler);
				if(_downArrow != null) _downArrow.addEventListener(MouseEvent.MOUSE_DOWN, arrowMouseDownHandler);
				
				//绘制内容的空白区域
				_content.graphics.beginFill(0x0, 0.001);
				_content.graphics.drawRect(0, 0, _content.width, _content.height);
				_content.graphics.endFill();
			}
			else {
				_thumb[_xy] = _track[_xy];
				_content[_xy] = _disArea[_xy];
				
				if(_direction == VERTICAL) _content.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
				this.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
				_track.removeEventListener(MouseEvent.MOUSE_DOWN, track_mouseDownHandler);
				_thumb.removeEventListener(MouseEvent.MOUSE_DOWN, thumb_mouseDownHandler);
				if(_upArrow != null) _upArrow.removeEventListener(MouseEvent.MOUSE_DOWN, arrowMouseDownHandler);
				if(_downArrow != null) _downArrow.removeEventListener(MouseEvent.MOUSE_DOWN, arrowMouseDownHandler);
			}
		}
		
		
		/**
		 * 鼠标在滑块上按下
		 * @param event
		 */
		private function thumb_mouseDownHandler(event:MouseEvent):void
		{
			var thumbDragBounds:Rectangle = (_direction == HORIZONTAL)
				? new Rectangle(_track.x, _track.y, _track.width - _thumb.width, 0)
				: new Rectangle(_track.x, _track.y, 0, _track.height - _thumb.height);
			
			_thumb.startDrag(false, thumbDragBounds);
			Common.stage.addEventListener(MouseEvent.MOUSE_MOVE, thumb_stageMouseMoveHandler);
			Common.stage.addEventListener(MouseEvent.MOUSE_UP, thumb_stageMouseUpHandler);
		}
		/**
		 * 鼠标在场景移动（滑块按下状态）
		 * @param event
		 */
		private function thumb_stageMouseMoveHandler(event:MouseEvent):void
		{
			moveContentByThumb();
			event.updateAfterEvent();
		}
		/**
		 * 鼠标在场景释放（滑块按下状态）
		 * @param event
		 */
		private function thumb_stageMouseUpHandler(event:MouseEvent):void
		{
			_thumb.stopDrag();
			Common.stage.removeEventListener(MouseEvent.MOUSE_MOVE, thumb_stageMouseMoveHandler);
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, thumb_stageMouseUpHandler);
		}
		
		
		
		/**
		 * 鼠标在箭头上按下
		 * @param event
		 */
		private function arrowMouseDownHandler(event:MouseEvent):void
		{
			_scrollUp = event.currentTarget == _upArrow;
			_scrollLine = true;
			
			_timer.reset();
			_timer.delay = repeatDelay;
			_timer.start();
			
			moveContentByLine();
			Common.stage.addEventListener(MouseEvent.MOUSE_UP, arrow_stageMouseUpHandler);
		}
		/**
		 * 鼠标在场景释放（箭头按下状态）
		 * @param event
		 */
		private function arrow_stageMouseUpHandler(event:MouseEvent):void
		{
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, arrow_stageMouseUpHandler);
			_timer.reset();
		}
		
		
		
		/**
		 * 鼠标在轨道上按下
		 * @param event
		 */
		private function track_mouseDownHandler(event:MouseEvent):void
		{
			var p:int = (_direction == HORIZONTAL) ? _track.mouseX : _track.mouseY;
			_scrollUp = p < _thumb[_xy];
			_scrollLine = false;
			
			_timer.reset();
			_timer.delay = repeatDelay;
			_timer.start();
			
			moveContentByPage();
			Common.stage.addEventListener(MouseEvent.MOUSE_UP, track_stageMouseUpHandler);
		}
		/**
		 * 鼠标在场景释放（轨道按下状态）
		 * @param event
		 */
		private function track_stageMouseUpHandler(event:MouseEvent):void
		{
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, track_stageMouseUpHandler);
			_timer.reset();
		}
		
		
		
		/**
		 * 鼠标滚动滑轮
		 * @param event
		 */
		private function mouseWheelHandler(event:MouseEvent):void
		{
			if(!_enabled) return;
			_scrollUp = event.delta > 0;
			var line:int = (event.delta < 0) ? -event.delta : event.delta;
			moveContentByLine(line);
		}
		
		
		
		/**
		 * 在对应的鼠标按下状态，滚动行或页
		 * @param event
		 */
		private function timerHandler():void
		{
			//刚到达回调时间
			if(_timer.delay == repeatDelay) {
				_timer.reset();
				_timer.delay = repeatInterval;
				_timer.start();
			}
			//滚动
			else {
				_scrollLine ? moveContentByLine() : moveContentByPage();
			}
		}
		
		
		/**
		 * 内容的位置，移动指定行
		 * @param line
		 */
		private function moveContentByLine(line:uint=1):void
		{
			var p:int = line * lineScrollSize;
			if(!_scrollUp) p = -p;
			moveContent(_content[_xy] + p);
		}
		
		
		/**
		 * 内容的位置，移动指定页
		 * @param line
		 */
		private function moveContentByPage(page:uint=1):void
		{
			var tmp:int = (_direction == HORIZONTAL) ? _track.mouseX : _track.mouseY;
			tmp += _track[_xy];
			
			//向上滚动，超出了鼠标位置
			if(_scrollUp && _thumb[_xy] <= tmp) {
				_timer.reset();
				return;
			}
			
			//向下滚动，超出了鼠标位置
			if(!_scrollUp && _thumb[_xy] + _thumb[_wh] >= tmp) {
				_timer.reset();
				return;
			}
			
			var pss:int = (pageScrollSize == 0) ? _disArea[_wh] : pageScrollSize;
			var p:int = page * pss;
			if(!_scrollUp) p = -p;
			moveContent(_content[_xy] + p);
		}
		
		
		private function moveContent(p:int):void
		{
			var max:Number = _disArea[_xy];
			var min:Number = -(_content[_wh] - _disArea[_wh] - _disArea[_xy]);
			
			//向下移动超出区域了
			if(p >= max) {
				_content[_xy] = max;
				_timer.reset();
			}
			//向上移动超出区域了
			else if(p <= min) {
				_content[_xy] = min;
				_timer.reset();
			}
			else {
				_content[_xy] = p;
			}
			
			moveThumbByContent();
		}
		
		
		
		/**
		 * 通过滑块的位置，来移动内容的位置
		 */
		private function moveContentByThumb():void
		{
			_content[_xy] = int(
				- (_thumb[_xy] - _track[_xy])
				/ (_track[_wh] - _thumb[_wh])
				* (_content[_wh] - _disArea[_wh])
				+ _disArea[_xy]
			);
		}
		
		
		/**
		 * 通过内容的位置，来移动滑块的位置
		 */
		private function moveThumbByContent():void
		{
			_thumb[_xy] = int(
				- (_content[_xy] - _disArea[_xy])
				/ (_content[_wh] - _disArea[_wh])
				* (_track[_wh] - _thumb[_wh])
				+ _track[_xy]
			);
		}
		
		
		
		/**
		 * 滚动到底部
		 */
		public function scrollToBottom():void
		{
			moveContent(-999999);
		}
		
		
		
		/**
		 * 初始化
		 */
		public function init():void
		{
			if(_disArea != null && _content != null)
			{
				if(_contentMask == null) {
					_contentMask = new Mask();
					_contentMask.target = _content;
				}
				_contentMask.x = _disArea.x;
				_contentMask.y = _disArea.y;
				_contentMask.rect = { width:_disArea.width, height:_disArea.height };
				
				update();
			}
		}
		
		
		/**
		 * 内容的显示区域（滚动区域）
		 */
		public function set disArea(value:Object):void
		{
			_disArea = new Rectangle(value.x, value.y, value.width, value.height);
			init();
		}
		public function get disArea():Object { return _disArea; }
		
		
		/**
		 * 滚动的内容
		 */
		public function set content(value:Sprite):void
		{
			_content = value;
			init();
		}
		public function get content():Sprite { return _content; }
		
		
		
		/**
		 * 是否启用
		 */
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			value = _enabled && _isShow;
			if(_thumb.visible != value)
			{
				_thumb.visible = value;
				_track.enabled = _upArrow.enabled = _downArrow.enabled = value;
			}
		}
		public function get enabled():Boolean { return _enabled; }
		
		
		
		/**
		 * 滚动方向，水平还是垂直
		 */
		public function set direction(value:String):void
		{
			_direction = value;
			if(value == HORIZONTAL) {
				_xy = "x";
				_wh = "width";
			}
			else {
				_xy = "y";
				_wh = "height";
			}
		}
		public function get direction():String { return _direction; }
		
		
		
		/**
		 * 滚动条的尺寸，水平时为width，垂直时为height
		 */
		public function set size(value:uint):void
		{
			_size = value;
			
			_upArrow[_xy] = 0;
			_downArrow[_xy] = _size - _downArrow[_wh];
			_track[_xy] = _upArrow[_wh];
			_track[_wh] = _size - _track[_xy] - _downArrow[_wh];
			if(_thumb.x == 0 && _thumb.y == 0) _thumb[_xy] = _track[_xy];
		}
		public function get size():uint { return _size; }
		
		
		
		/**
		 * 当前是否显示（内容尺寸是否超出了显示区域）
		 */
		public function get isShow():Boolean { return _isShow; }
		
		
		/**
		 * 在显示内容尺寸改变时，是否自动隐藏或显示
		 */
		public function get autoDisplay():Boolean { return _autoDisplay; }
		public function set autoDisplay(value:Boolean):void
		{
			_autoDisplay = value;
			update();
		}
		
		
		
		
		/**
		 * 用于清理引用，释放内存
		 * 在丢弃该组件时，需要主动调用该方法
		 */
		public function dispose():void
		{
			_timer.reset();
			
			Common.stage.removeEventListener(MouseEvent.MOUSE_MOVE, thumb_stageMouseMoveHandler);
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, thumb_stageMouseUpHandler);
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, arrow_stageMouseUpHandler);
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, track_stageMouseUpHandler);
			
			if(_contentMask != null) _contentMask.dispose();
			if(_track != null) _track.dispose();
			if(_thumb != null) _thumb.dispose();
			if(_upArrow != null) _upArrow.dispose();
			if(_downArrow != null) _downArrow.dispose();
		}
		//
	}
}