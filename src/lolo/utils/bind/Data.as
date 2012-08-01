package lolo.utils.bind
{
	import flash.events.EventDispatcher;
	
	/**
	 * 数据类，用于简化数据绑定功能。
	 * 在数据绑定结构中，数据源可以不继承至该类，但必须的实现IEventDispatcher接口，
	 * 并且在值有改变时，调度ValueChangeEvent.VALUE_CHANGE事件
	 * @author LOLO
	 */
	public class Data extends EventDispatcher
	{
		
		public function Data()
		{
			super();
		}
		
		
		/**
		 * 改变值，并进行验证，是否抛出数据值改变事件
		 * @param valueName 值的名称
		 * @param oldValueName 原值的名称
		 * @param newValue 新值
		 */		
		protected function changeValue(valueName:String, oldValueName:String, newValue:*):void
		{
			var oldValue:* = getProperty(oldValueName);
			setProperty(oldValueName, newValue);
			if(newValue != oldValue)
			{
				this.dispatchEvent(new ValueChangeEvent(ValueChangeEvent.VALUE_CHANGE, valueName, oldValue, newValue));
			}
		}
		
		
		
		/**获取属性的值(继承时，请拷贝该函数到继承类中，并标记为override)*/
		protected function getProperty(name:String):* { return this[name]; }
		
		/**设置属性的值 (继承时，请拷贝该函数到继承类中，并标记为override)*/
		protected function setProperty(name:String, value:*):void { this[name] = value; }
		//
	}
}