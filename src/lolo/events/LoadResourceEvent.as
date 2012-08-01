package lolo.events
{
	import flash.events.Event;
	/**
	 * 加载资源事件
	 * @author LOLO
	 */
	public class LoadResourceEvent extends Event
	{
		/**加载单个资源完成*/
		public static const COMPLETE:String = "LoadResourceCOMPLETE";
		
		/**加载所有资源完成*/
		public static const ALL_COMPLETE:String = "LoadAllResourceComplete";
		
		/**加载资源中*/
		public static const PROGRESS:String = "LoadResourceProgress";
		
		/**加载资源失败*/
		public static const ERROR:String = "LoadResourceError";
		
		
		/**正在加载资源的名称*/
		public var name:String;
		/**已加载的总比例(0~1，kb/s)*/
		public var progress:Number;
		/**加载的速度*/
		public var speed:Number;
		/**加载队列的资源总数*/
		public var numTotal:uint;
		/**当前加载的资源，在资源队列表中的编号*/
		public var numLoaded:Number;
		
		
		/**
		 * 构造一个加载资源事件
		 * @param type
		 * @param name
		 * @param progress
		 * @param speed
		 * @param numTotal
		 * @param numLoaded
		 */		
		public function LoadResourceEvent(type:String, name:String="", progress:Number=0, speed:Number=0, numTotal:uint=0, numLoaded:uint=0)
		{
			super(type);
			this.name = name;
			this.progress = progress;
			this.speed = speed;
			this.numTotal = numTotal;
			this.numLoaded = numLoaded;
		}
	}
}