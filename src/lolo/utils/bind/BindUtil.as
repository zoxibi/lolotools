package lolo.utils.bind
{
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	/**
	 * 绑定数据工具
	 * @author LOLO
	 */
	public class BindUtil
	{
		
		
		/**
		 * 将公用属性(tHost.tProp) 与 数据源(sHost.sPorp) 进行绑定
		 * 当 数据源(sHost.sPorp) 的值有改变时，公用属性(tHost.tProp) 也会随之改变
		 * @param tHost 要绑定数据的宿主
		 * @param tProp 要绑定数据的宿主的属性
		 * @param sHost 数据源宿主
		 * @param sProp 数据源宿主的属性
		 * @param isExe 是否需要将公用属性(tHost.tProp)初始化成数据源(sHost.sPorp)的值
		 * @return 
		 */
		public static function bindProperty(tHost:Object,
											tProp:String,
											sHost:IEventDispatcher,
											sProp:String,
											isExe:Boolean=false):ChangeWatcher
		{
			if(isExe) tHost[tProp] = sHost[sProp];
			
			var cw:ChangeWatcher = new ChangeWatcher(sHost, sProp, null, tHost, tProp);
			return cw;
		}
		
		
		
		/**
		 * 将setter函数与 数据源(sHost.sPorp) 进行绑定
		 * 当 数据源(sHost.sPorp) 的值有改变时，将会调用setter函数
		 * @param setter 数据改变时，调用的setter函数
		 * @param sHost 数据源宿主
		 * @param sProp 数据源宿主的属性
		 * @param isExe 初始化时，是否需要执行一次setter函数
		 * @return 
		 */
		public static function bindSetter(setter:Function,
										  sHost:IEventDispatcher,
										  sProp:String,
										  isExe:Boolean=false):ChangeWatcher
		{
			if(isExe) setter(sHost[sProp]);
			
			var cw:ChangeWatcher = new ChangeWatcher(sHost, sProp, setter);
			return cw;
		}
		//
	}
}