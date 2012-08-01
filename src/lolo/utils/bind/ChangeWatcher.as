package lolo.utils.bind
{
	import flash.events.IEventDispatcher;

	/**
	 * 观察监听数据值的改变
	 * @author LOLO
	 */
	public class ChangeWatcher
	{
		/**数据源宿主*/
		private var _sHost:IEventDispatcher;
		/**数据源宿主的属性*/
		private var _sProp:String;
		/**要绑定数据的宿主*/
		private var _tHost:Object;
		/**要绑定数据的宿主的属性*/
		private var _tProp:String;
		/**数据改变时需要调用的setter方法*/
		private var _setter:Function;
		
		
		
		
		public function ChangeWatcher(sHost:IEventDispatcher,
									  sProp:String,
									  setter:Function=null,
									  tHost:Object=null,
									  tProp:String="")
		{
			_sHost = sHost;
			_sProp = sProp;
			_setter = setter;
			_tHost = tHost;
			_tProp = tProp;
			
			watch();
		}
		
		
		
		/**
		 * 数据值有改变
		 * @param event
		 */
		private function valueChangeHandler(event:ValueChangeEvent):void
		{
			//如果是绑定的属性，并且值有改变
			if(event.valueName == _sProp && event.newValue != event.oldValue)
			{
				if(_setter != null) _setter(event.newValue);
				if(_tHost != null) _tHost[_tProp] = event.newValue;
			}
		}
		
		
		
		
		/**
		 * 启动并监听数据的改变
		 */
		public function watch():void
		{
			_sHost.addEventListener(ValueChangeEvent.VALUE_CHANGE, valueChangeHandler);
		}
		
		
		
		/**
		 * 清除
		 */
		public function clear():void
		{
			_sHost.removeEventListener(ValueChangeEvent.VALUE_CHANGE, valueChangeHandler);
			_sHost = null;
			_tHost = null;
			_setter = null;
		}
		//
	}
}