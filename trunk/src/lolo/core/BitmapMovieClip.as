package lolo.core
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import lolo.events.BitmapMovieClipEvent;
	import lolo.utils.AutoUtil;
	import lolo.utils.RTimer;
	
	/**
	 * 位图影片剪辑
	 * 
	 * 关于BitmapMovieClipEvent.ENTER_FRAME事件，与，与flash.display.MovieClip的Event.ENTER_FRAME事件不同的是：
	 * 只会在帧刷新的时候触发该事件，而不是按照帧频不断触发
	 * 
	 * @author LOLO
	 */
	public class BitmapMovieClip extends Bitmap
	{
		/**位图数据包，以及使用信息*/
		private static var _data:Dictionary = new Dictionary();
		/**用于周期清理数据*/
		private static var _clearTimer:RTimer;
		
		
		/**帧序列动画*/
		private var _frameList:Vector.<BitmapMovieClipData>;
		
		/**动画的帧频*/
		private var _fps:uint;
		/**动画是否正在播放中*/
		private var _playing:Boolean;
		/**当前帧编号*/
		private var _currentFrame:uint;
		/**是否反向播放动画*/
		private var _reverse:Boolean;
		
		/**动画的源名称（类完整定义）*/
		private var _sourceName:String = "";
		/**设置的x坐标*/
		private var _x:int;
		/**设置的y坐标*/
		private var _y:int;
		
		/**重复播放次数*/
		public var repeatCount:uint;
		/**动画达到重复播放次数时的停止帧*/
		public var stopFrame:uint;
		/**动画在完成了指定重复次数，并到达了停止帧时的回调（异常情况将不会触发回调，如：位图数据包还未初始化，帧数为0，以及重复次数为0）*/
		public var callback:Function;
		
		/**动画当前已重复播放的次数*/
		private var _currentRepeatCount:uint;
		
		/**用于播放动画*/
		private var _timer:RTimer;
		
		
		/**
		 * 周期清理数据
		 */
		private static function clearTimerHandler():void
		{
			//克隆一份_data进行，稍候对其进行for操作
			var list:Dictionary = new Dictionary();
			var key:String;
			for(key in _data) list[key] = _data[key];
			
			var info:Object;
			for(key in list) {
				info = _data[key];
				//位图数据已经没有在使用了
				if(info.count == 0) {
					//已经被标记过，可以被清除
					if(info.prepareClear) {
						for(var i:int = 0; i < info.frameList.length; i++) {
							info.frameList[i].dispose();
						}
						delete _data[key];
					}
					else {
						info.prepareClear = true;//标记为可清除
					}
				}
				else {
					info.prepareClear = false;
				}
			}
		}
		
		
		
		
		/**
		 * 构造一个位图影片剪辑
		 * @param sourceName 动画的源名称（类完整定义）
		 * @param fps 动画的帧频
		 * @param bitmapData
		 * @param pixelSnapping
		 * @param smoothing
		 */
		public function BitmapMovieClip(sourceName:String="", fps:uint=12, bitmapData:BitmapData=null, pixelSnapping:String="auto", smoothing:Boolean=false)
		{
			super(bitmapData, pixelSnapping, smoothing);
			this.fps = fps;
			this.sourceName = sourceName;
			
			if(_clearTimer == null) {
				_clearTimer = RTimer.getInstance(3 * 60 * 1000, clearTimerHandler);
				_clearTimer.start();
			}
		}
		
		
		
		/**
		 * 播放动画
		 * @param startFrame 动画开始帧（默认值:0 为当前帧）
		 * @param repeatCount 动画的重复播放次数（默认值:0 为无限循环）
		 * @param stopFrame 动画达到重复播放次数时的停留帧（默认值:0 为最后一帧）
		 * @param callback 动画在完成了指定重复次数，并到达了停止帧时的回调（异常情况将不会触发回调，如：位图数据包还未初始化，帧数为0，以及重复次数为0）
		 */
		public function play(startFrame:uint=0, repeatCount:uint=0, stopFrame:uint=0, callback:Function=null):void
		{
			if(startFrame == 0) startFrame = _currentFrame;
			showFrame(startFrame);
			
			_currentRepeatCount = 0;
			this.repeatCount = repeatCount;
			this.stopFrame = stopFrame;
			this.callback = callback;
			
			_playing = true;
			_timer.start();
		}
		
		
		/**
		 * 停止动画的播放
		 */
		public function stop():void
		{
			if(_timer != null) _timer.reset();
			_playing = false;
		}
		
		
		/**
		 * 跳转到指定帧，并继续播放
		 * @param startFrame 动画开始帧
		 * @param repeatCount 动画的重复播放次数（默认值:0 为无限循环）
		 * @param stopFrame 动画达到重复播放次数时的停留帧（默认值:0 为最后一帧）
		 * @param callback 动画在完成了指定重复次数，并到达了停止帧时的回调（异常情况将不会触发回调，如：位图数据包还未初始化，帧数为0，以及重复次数为0）
		 */
		public function gotoAndPlay(value:uint, repeatCount:uint=0, stopFrame:uint=0, callback:Function=null):void
		{
			play(value, repeatCount, stopFrame, callback);
		}
		
		
		/**
		 * 跳转到指定帧，并停止动画的播放
		 */
		public function gotoAndStop(value:uint):void
		{
			stop();
			showFrame(value);
		}
		
		
		/**
		 * 立即播放下一帧（反向播放时为上一帧），并停止动画
		 */
		public function nextFrame():void
		{
			stop();
			showFrame(_reverse ? _currentFrame - 1 : _currentFrame + 1);
		}
		
		
		/**
		 * 立即播放上一帧（反向播放时为下一帧），并停止动画
		 */
		public function prevFrame():void
		{
			stop();
			showFrame(_reverse ? _currentFrame + 1 : _currentFrame - 1);
		}
		
		
		
		/**
		 * 显示指定帧的图像
		 * @param value
		 */
		private function showFrame(frame:int):void
		{
			if(_frameList == null || _frameList.length == 0) {
				//已释放，未清理
				if(_sourceName != "") {
					var sn:String = _sourceName;
					_sourceName = "";
					sourceName = sn;
				}
				return;
			}
			
			if(frame > _frameList.length) frame = _frameList.length;
			else if(frame < 1) frame = 1;
			
			_currentFrame = frame;
			this.bitmapData = _frameList[_currentFrame - 1];
			offsetPoint();
			
			this.dispatchEvent(new BitmapMovieClipEvent(BitmapMovieClipEvent.ENTER_FRAME));
		}
		
		
		
		
		/**
		 * 根据当前图像，偏移坐标
		 */
		public function offsetPoint():void
		{
			var bmcData:BitmapMovieClipData = bitmapData as BitmapMovieClipData;
			
			if(bmcData != null) {
				super.x = _x + bmcData.offsetX;
				super.y = _y + bmcData.offsetY;
			}
			else {
				super.x = _x;
				super.y = _y;
			}
		}
		
		
		
		/**
		 * 动画的源名称（类完整定义）
		 */
		public function set sourceName(value:String):void
		{
			//动画的源名称没有改变
			if(value == _sourceName) return;
			
			var playing:Boolean = _playing;
			
			//释放现有动画数据
			var currentFrame:uint = _currentFrame;
			dispose();
			
			//新的源名称有误
			_sourceName = value;
			if(_sourceName == "") return;
			
			
			//新动画数据已经存在
			if(_data[_sourceName] != null)
			{
				_data[_sourceName].count++;
				_frameList = _data[_sourceName].frameList;
			}
				
				//新动画数据不存在，创建新动画
			else
			{
				var mc:MovieClip = AutoUtil.getInstance(_sourceName);
				
				//新动画不存在
				if(mc == null) {
					trace("注意！！　动画", _sourceName, "不存在");
					return;
				}
				
				//提取新动画的数据
				var i:int;
				var rect:Rectangle;
				var bmcData:BitmapMovieClipData;
				var frameList:Vector.<BitmapMovieClipData> = new Vector.<BitmapMovieClipData>();
				for(i = 1; i <= mc.totalFrames; i++) {
					mc.gotoAndStop(i);
					rect = mc.getBounds(mc);
					if(rect.width < 1) rect.width = 1;//有可能是空帧
					if(rect.height < 1) rect.height = 1;
					
					bmcData = new BitmapMovieClipData(rect.width, rect.height, rect.x, rect.y);
					bmcData.draw(mc, new Matrix(1, 0, 0, 1, -rect.x, -rect.y));
					frameList.push(bmcData);
				}
				
				//记录到数据中 { frameList:帧序列位图数据, count:被使用次数 }
				_data[_sourceName] = { frameList:frameList, count:1 };
				_frameList = frameList;
				
				
				//立即显示当前帧，如果动画是在播放中，继续播放
				showFrame(currentFrame);
				if(playing) {
					_playing = true;
					_timer.start();
				}
			}
			
		}
		public function get sourceName():String { return _sourceName; }
		
		
		
		/**
		 * 动画的帧频
		 */
		public function set fps(value:uint):void
		{
			_fps = value;
			var delay:uint = 1000 / _fps;
			
			if(_timer == null) {
				_timer = RTimer.getInstance(delay, timerHandler);
			}
			else {
				_timer.delay = delay;
			}
		}
		public function get fps():uint { return _fps; }
		
		
		
		/**
		 * 计时器回调（帧刷新）
		 */
		private function timerHandler():void
		{
			var frame:uint;
			if(_reverse) {
				frame = (_currentFrame == 1) ? _frameList.length : _currentFrame - 1;
			}
			else {
				frame = (_currentFrame == _frameList.length) ? 1 : _currentFrame + 1;
			}
			showFrame(frame);
			
			//只有一帧，或没有帧
			if(_frameList.length <= 1) {
				stop();
				return;
			}
			
			//有指定重复播放次数
			if(repeatCount > 0) {
				//到达停止帧
				var stopFrame:uint = (this.stopFrame == 0) ? _frameList.length : this.stopFrame;
				if(_currentFrame == stopFrame)
				{
					this.dispatchEvent(new BitmapMovieClipEvent(BitmapMovieClipEvent.ENTER_STOP_FRAME));
					
					_currentRepeatCount++;
					//达到了重复播放次数
					if(_currentRepeatCount >= repeatCount) {
						stop();
						if(callback != null) {
							callback();
							callback = null;
						}
						this.dispatchEvent(new BitmapMovieClipEvent(BitmapMovieClipEvent.MOVIE_END));
					}
				}
			}
		}
		
		
		
		
		override public function set x(value:Number):void
		{
			_x = value;
			offsetPoint();
		}
		override public function get x():Number { return _x; }
		
		override public function set y(value:Number):void
		{
			_y = value;
			offsetPoint();
		}
		override public function get y():Number { return _y; }
		
		
		/**
		 * 动画是否正在播放中
		 */
		public function get playing():Boolean { return _playing; }
		
		
		/**
		 * 当前帧编号
		 */
		public function get currentFrame():uint { return _currentFrame; }
		
		
		/**
		 * 总帧数
		 */
		public function get totalFrames():uint
		{
			if(_frameList == null) return 0;
			return _frameList.length;
		}
		
		
		/**
		 * 是否反向播放动画
		 */
		public function set reverse(value:Boolean):void { _reverse = value; }
		public function get reverse():Boolean { return _reverse; }
		
		
		/**
		 * 释放占用的内存资源
		 */
		public function dispose():void
		{
			stop();
			bitmapData = null;
			
			if(_data[_sourceName] == null || _frameList == null) return;
			
			_frameList = null;
			_currentFrame = 0;
			_data[_sourceName].count--;
		}
		
		
		
		/**
		 * 清理该动画所使用的资源
		 * 丢弃该动画时，需要主动调用
		 */
		public function clear():void
		{
			dispose();
			
			_timer.clear();
			_timer = null;
		}
		//
	}
}