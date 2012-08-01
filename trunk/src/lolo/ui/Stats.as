package lolo.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	/**
	 * 内存，FPS统计面板
	 * @author LOLO
	 */
	public class Stats extends Sprite
	{
		/**单例*/
		private static var _instance:Stats;
		
		/**统计面板的容器*/
		public var container:DisplayObjectContainer;
		
		/**背景*/
		public var background:Shape;
		/**统计图表*/
		public var chart:Shape;
		/**帧频显示文本*/
		public var fpsText:TextField;
		/**当前内存使用量（MB）显示文本*/
		public var memText:TextField;
		/**内存最大使用量（MB）显示文本*/
		public var maxText:TextField;
		
		/**当前背景透明度*/
		private var _bgAlpha:Number = 0;
		
		/**数据记录*/
		private var _memoryList:Array = [];
		/**上次记录时间*/
		private var _lastTime:int;
		/**距离上次记录，已运行的帧数*/
		private var _frameNum:int;
		/**记录中，最大的内存使用值*/
		private var _maxMemory:Number = 0;
		
		
		
		/**
		 * 获取实例
		 * @return 
		 */
		public static function getInstance():Stats
		{
			if(_instance == null) _instance = new Stats(new Enforcer());
			return _instance;
		}
		
		
		
		public function Stats(enforcer:Enforcer)
		{
			super();
			if(!enforcer) {
				throw new Error("请通过Stats.getInstance()获取实例");
				return;
			}
			this.mouseEnabled = this.mouseChildren = false;
			
			background = new Shape();
			this.addChild(background);
			
			chart = new Shape();
			this.addChild(chart);
			
			fpsText = new TextField();
			fpsText.autoSize = "left";
			fpsText.selectable = false;
			fpsText.x = 5;
			fpsText.y = 5;
			fpsText.defaultTextFormat = new TextFormat("_sans", 9, 0xFFFFFF, true);
			this.addChild(fpsText);
			
			memText = new TextField();
			memText.autoSize = "left";
			memText.selectable = false;
			memText.x = 5;
			memText.y = 20;
			memText.defaultTextFormat = new TextFormat("_sans", 9, 0xFFFFFF, true);
			this.addChild(memText);
			
			maxText = new TextField();
			maxText.autoSize = "left";
			maxText.selectable = false;
			maxText.x = 5;
			maxText.y = 35;
			maxText.defaultTextFormat = new TextFormat("_sans", 9, 0xFFFFFF, true);
			this.addChild(maxText);
			
			
			background.graphics.clear();
			background.graphics.beginFill(0, 0.6);
			background.graphics.drawRect(0, 0, 270, 55);
			background.graphics.endFill();
		}
		
		
		
		
		/**
		 * 帧刷新
		 * @param event
		 */
		private function enterFrameHandler(event:Event):void
		{
			var nowtime:Number = getTimer();
			var time:Number = nowtime - _lastTime;
			_frameNum++;
			
			//统计内存
			var mem:Number = System.totalMemory / 1024 / 1024;
			mem = int(mem * 1000) / 1000;
			if(mem > _maxMemory) _maxMemory = mem;
			
			//1秒统计2次帧频
			if(time < 500) return;
			var fps:int = 1000 / (time / _frameNum);
			_frameNum = 0;
			
			_memoryList.unshift(mem);
			if(_memoryList.length > 40) _memoryList.pop();
			
			chart.graphics.clear();
			var len:int = _memoryList.length;
			for(var i:int = 0; i < len; i++) {
				var memory:Number = _memoryList[i];
				if(memory > 400) memory = 400;//图表中只显示最大值为400的内存
				var x:int = i * 5 + 65;
				var y:int = 45 - (45 / (400 / memory)) + 5;
				
				if(i == 0) {
					chart.graphics.moveTo(x, y);
				}
				else {
					var color:uint;
					if(memory > 300) color = 0xFF0000;
					else if(memory > 180) color = 0xFFFF00;
					else color = 0x00FF00;
					
					chart.graphics.lineStyle(1, color);
					chart.graphics.lineTo(x, y);
				}
			}
			
			fpsText.text = "FPS:" + fps + " / " + stage.frameRate;
			memText.text = "MEM:" + mem;
			maxText.text = "MAX:" + _maxMemory;
			
			_lastTime = nowtime;
		}
		
		
		
		/**
		 * 显示
		 */
		public function show():void
		{
			if(container != null) {
				container.addChild(this);
				_frameNum = 0;
				_lastTime = getTimer();
				this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}
		
		/**
		 * 隐藏
		 */
		public function hide():void
		{
			this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			if(this.parent != null) this.parent.removeChild(this);
		}
		
		
		/**
		 * 获取当前是否显示
		 */
		public function get isShow():Boolean
		{
			return parent != null;
		}
		//
	}
}


class Enforcer {}