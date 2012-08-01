package lolo.components
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import lolo.common.Common;

	/**
	 * 模态背景
	 * @author LOLO
	 */
	public class ModalBackground extends Sprite
	{
		private var _color:uint;//颜色
		
		/**
		 * 构造函数
		 * @param parent 父级容器
		 */
		public function ModalBackground(parent:DisplayObjectContainer)
		{
			super();
			parent.addChildAt(this, 0);
			
			this.alpha = 0.01;
			this.color = 0;
			
			parent.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			parent.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		
		/**
		 * 添加到舞台上时
		 * @param event
		 */
		private function addedToStageHandler(event:Event):void
		{
			if(stage != null) {
				parent.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
				Common.stage.addEventListener(Event.RESIZE, resizeHandler);
				draw();
			}
		}
		
		
		/**
		 * 舞台尺寸有改变
		 * @param event
		 */
		private function resizeHandler(event:Event):void
		{
			draw();
		}
		
		
		/**
		 * 鼠标按下
		 * @param event
		 */
		private function mouseDownHandler(event:Event):void
		{
			Common.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			Common.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		/**
		 * 鼠标移动
		 * @param event
		 */
		private function mouseMoveHandler(event:Event):void
		{
			draw();
		}
		
		/**
		 * 鼠标释放
		 * @param event
		 */
		private function mouseUpHandler(event:Event):void
		{
			Common.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			draw();
		}
		
		
		
		
		/**
		 * 绘制矩形模态背景
		 */
		public function draw():void
		{
			var p:Point = parent.globalToLocal(new Point(0, 0));
			
			this.graphics.clear();
			this.graphics.beginFill(_color);
			this.graphics.drawRect(p.x - 100, p.y - 100, Common.ui.stageWidth + 200, Common.ui.stageHeight + 200);//在周围多绘制100像素的缓冲区
			this.graphics.endFill();
		}
		
		
		
		/**
		 * 颜色
		 * @param value
		 */
		public function set color(value:uint):void
		{
			_color = value;
			draw();
		}
		public function get color():uint { return _color; }
		
		
		
		
		/**
		 * 用于清理引用，释放内存
		 * 在丢弃该组件时，需要主动调用该方法
		 */
		public function dispose():void
		{
			if(parent != null) parent.removeChild(this);
			
			Common.stage.removeEventListener(Event.RESIZE, resizeHandler);
			Common.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		//
	}
}