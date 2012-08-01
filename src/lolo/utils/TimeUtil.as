package lolo.utils
{
	/**
	 * 时间操作工具
	 * @author LOLO
	 */
	public class TimeUtil
	{
		/**时间类型，毫秒*/
		public static const TYPE_MS:String = "ms";
		/**时间类型，秒*/
		public static const TYPE_S:String = "s";
		/**时间类型，分钟*/
		public static const TYPE_M:String = "m";
		/**时间类型，小时*/
		public static const TYPE_H:String = "h";
		
		
		/**时间单位，天*/
		public static var day:String = "Day";
		/**时间单位，天(复数)*/
		public static var days:String = "Days";
		/**时间单位，小时*/
		public static var hour:String = "Hour";
		/**时间单位，分钟*/
		public static var minute:String = "Minute";
		/**时间单位，秒*/
		public static var second:String = "Second";
		
		/**格式化时，天的格式["v":值，"u":单位]*/
		public static var dFormat:String = "vu";
		/**格式化时，小时的格式["v":值，"u":单位]*/
		public static var hFormat:String = "v:";
		/**格式化时，分钟的格式["v":值，"u":单位]*/
		public static var mFormat:String = "v:";
		/**格式化时，秒的格式["v":值，"u":单位]*/
		public static var sFormat:String = "v";
		
		
		
		/**
		 * 格式化时间
		 * @param time 时间的值
		 * @param type 时间的类型
		 * @param dFormat 天的格式["v":值，"u":单位]
		 * @param hFormat 小时的格式["v":值，"u":单位]
		 * @param mFormat 分钟的格式["v":值，"u":单位]
		 * @param sFormat 秒的格式["v":值，"u":单位]
		 * @param hFilled 是否补齐小时位
		 * @param dToH 是否将天位转化成小时位
		 * @return 至少包含分钟和秒的格式化时间
		 */
		public static function format(time:Number,
									  type:String="ms",
									  dFormat:String="",
									  hFormat:String="",
									  mFormat:String="",
									  sFormat:String="",
									  hFilled:Boolean=false,
									  dToH:Boolean=false):String
		{
			//转化成毫秒
			time = convertType(type, TYPE_MS, time);
			
			var h:int = time / 3600000;
			var m:int = (time % 3600000) / 60000;
			var s:int = Math.ceil((time % 3600000) % 60000 / 1000);
			var d:int = h / 24;
			
			var str:String = "";
			
			//天
			if(d > 0 && !dToH)
			{
				if(dFormat == "") dFormat = TimeUtil.dFormat;
				str += dFormat.replace(/u/g, (d > 1) ? days : day);
				str = str.replace(/v/g, StringUtil.leadingZero(d));
			}
			
			//小时
			if(h > 0 || d > 0 || hFilled)
			{
				if(hFormat == "") hFormat = TimeUtil.hFormat;
				str += hFormat.replace(/u/g, hour);
				str = str.replace(/v/g, StringUtil.leadingZero(dToH ? h : h % 24));
			}
			
			//分钟
			if(mFormat == "") mFormat = TimeUtil.mFormat;
			str += mFormat.replace(/u/g, minute);
			str = str.replace(/v/g, StringUtil.leadingZero(m));
			
			//秒
			if(sFormat == "") sFormat = TimeUtil.sFormat;
			str += sFormat.replace(/u/g, second);
			str = str.replace(/v/g, StringUtil.leadingZero(s));
			
			return str;
		}
		
		
		
		
		/**
		 * 转换时间类型
		 * @param typeFrom 原来的类型
		 * @param typeTo 要转换成什么类型
		 * @param value 时间原来类型的值
		 * @return 
		 */
		public static function convertType(typeFrom:String, typeTo:String, value:Number):Number
		{
			if(typeFrom == typeTo) return value;
			
			//转换成毫秒
			switch(typeFrom)
			{
				case TYPE_S: 
					value *= 1000;
					break;
				case TYPE_M:
					value *= 60000;
					break;
				case TYPE_H:
					value *= 3600000;
					break;
			}
			
			//返回指定类型
			switch(typeTo)
			{
				case TYPE_S: return value / 1000;
				case TYPE_M: return value / 60000;
				case TYPE_H: return value / 3600000;
				default: return value;
			}
		}
		//
	}
}