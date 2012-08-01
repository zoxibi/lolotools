package lolo.events
{
	import flash.events.Event;
	/**
	 * 位图影片剪辑
	 * @author LOLO
	 */
	public class BitmapMovieClipEvent extends Event
	{
		/**帧刷新（与Event.ENTER_FRAME不同的是，动画只有在播放时，切换帧才会触发该事件）*/
		public static const ENTER_FRAME:String = "bmcEnterFrame";
		
		/**动画进入了停止帧*/
		public static const ENTER_STOP_FRAME:String = "bmcEnterStopFrame";
		
		/**动画在完成了指定重复次数，并到达了停止帧（异常情况将不会触发该事件，如：位图数据包还未初始化，帧数为0，以及重复次数为0）*/
		public static const MOVIE_END:String = "bmcMovieEnd";
		
		
		
		
		public function BitmapMovieClipEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		//
	}
}