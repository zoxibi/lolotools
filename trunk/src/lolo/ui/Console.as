package lolo.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * 调试输出控制台
	 * @author LOLO
	 */
	public class Console extends Sprite
	{
		/**单例*/
		private static var _instance:Console;
		
		/**控制台的容器*/
		public var container:DisplayObjectContainer;
		
		/**背景*/
		public var background:Shape;
		/**头部，拖动区域*/
		public var head:Sprite;
		/**关闭按钮*/
		public var closeBtn:Sprite;
		/**标题显示文本*/
		public var titleText:TextField;
		/**内容显示文本*/
		public var contentText:TextField;
		/**输入文本*/
		public var inputIT:TextField;
		
		
		
		/**
		 * 获取实例
		 * @return 
		 */
		public static function getInstance():Console
		{
			if(_instance == null) _instance = new Console(new Enforcer());
			return _instance;
		}
		
		
		/**
		 * 输出到控制台内容文本中，并显示控制台
		 * @param args
		 */
		public static function trace(...args):void
		{
			var console:Console = Console.getInstance();
			if(console.contentText.text != "") console.contentText.appendText("\n");
			for(var i:int = 0; i < args.length; i++)
			{
				if(i != 0) console.contentText.appendText(" ");
				if(args[i] != null) console.contentText.appendText(args[i].toString());
			}
			
			console.show();
		}
		
		
		
		public function Console(enforcer:Enforcer)
		{
			super();
			if(!enforcer) {
				throw new Error("请通过Console.getInstance()获取实例");
				return;
			}
			
			this.x = 250;
			this.y = 130;
			
			background = new Shape();
			background.graphics.beginFill(0xFFFFFF, 0.8);
			background.graphics.lineStyle(0, 0x999999);
			background.graphics.drawRect(0, 0, 500, 330);
			background.graphics.endFill();
			this.addChild(background);
			
			head = new Sprite();
			head.graphics.beginFill(0xE8EAED, 0.8);
			head.graphics.drawRect(1, 1, 499, 12);
			head.graphics.beginFill(0xD6DBE3, 0.8);
			head.graphics.drawRect(1, 13, 499, 13);
			head.graphics.endFill();
			this.addChild(head);
			
			closeBtn = new Sprite();
			closeBtn.graphics.beginFill(0x000000, 0.01);
			closeBtn.graphics.drawRect(0, 0, 8, 8);
			closeBtn.graphics.endFill();
			closeBtn.graphics.lineStyle(1, 0x333333);
			closeBtn.graphics.lineTo(8, 8);
			closeBtn.graphics.moveTo(0, 8);
			closeBtn.graphics.lineTo(8, 0);
			closeBtn.x = 485;
			closeBtn.y = 9;
			closeBtn.buttonMode = true;
			this.addChild(closeBtn);
			
			titleText = new TextField();
			titleText.autoSize = "left";
			titleText.selectable = false;
			titleText.mouseEnabled = false;
			titleText.x = 10;
			titleText.y = 5;
			titleText.defaultTextFormat = new TextFormat("宋体", 12, 0x666666, true);
			titleText.text = "调试控制台";
			this.addChild(titleText);
			
			contentText = new TextField();
			contentText.multiline = true;
			contentText.wordWrap = true;
			contentText.defaultTextFormat = new TextFormat("宋体", 12, 0x333333);
			contentText.type = "input";
			contentText.width = 480;
			contentText.height = 270;
			contentText.x = 10;
			contentText.y = 30;
			contentText.border = true;
			contentText.borderColor = 0xCCCCCC;
			this.addChild(contentText);
			
			inputIT = new TextField();
			inputIT.type = "input";
			inputIT.defaultTextFormat = new TextFormat("宋体", 12, 0x333333);
			inputIT.width = 480;
			inputIT.height = 18;
			inputIT.x = 10;
			inputIT.y = 305;
			inputIT.border = true;
			inputIT.borderColor = 0xCCCCCC;
			this.addChild(inputIT);
			
			
			head.addEventListener(MouseEvent.MOUSE_DOWN, head_mouseDownHandler);
			closeBtn.addEventListener(MouseEvent.CLICK, closeBtn_clickHandler);
			inputIT.addEventListener(KeyboardEvent.KEY_DOWN, inputIT_keyDownHandler);
		}
		
		
		/**
		 * 鼠标在拖动区域按下
		 * @param event
		 */
		private function head_mouseDownHandler(event:MouseEvent):void
		{
			this.addEventListener(MouseEvent.MOUSE_UP, drag_mouseUpHandler);
			this.startDrag();
		}
		/**
		 * 拖动中松开鼠标
		 * @param event
		 */
		private function drag_mouseUpHandler(event:MouseEvent):void
		{
			this.removeEventListener(MouseEvent.MOUSE_UP, drag_mouseUpHandler);
			this.stopDrag();
		}
		
		
		/**
		 * 点击关闭按钮
		 * @param event
		 */
		private function closeBtn_clickHandler(event:MouseEvent):void
		{
			hide();
		}
		
		
		/**
		 * 在输入框按键
		 * @param event
		 */
		private function inputIT_keyDownHandler(event:KeyboardEvent):void
		{
			//按下 Enter 键
			if(event.keyCode == 13) {
				this.dispatchEvent(new DataEvent(DataEvent.DATA, false, false, inputIT.text));
			}
		}
		
		
		
		/**
		 * 在舞台按键
		 * @param event
		 */
		private function stage_keyDownHandler(event:KeyboardEvent):void
		{
			//按下 Esc 键
			if(event.keyCode == 27) hide();
		}
		
		
		
		/**
		 * 显示
		 */
		public function show():void
		{
			if(container != null) {
				container.addChild(this);
				stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
			}
		}
		
		/**
		 * 隐藏
		 */
		public function hide():void
		{
			if(stage != null) stage.removeEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
			if(this.parent != null) this.parent.removeChild(this);
		}
		//
	}
}


class Enforcer {}