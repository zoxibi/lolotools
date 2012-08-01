package lolo.ui
{
	/**
	 * 可居中于舞台的显示对象
	 * @author LOLO
	 */
	public interface ICenterDisplayObject
	{
		/**
		 * 获取居中宽度
		 * @return 
		 */
		function get centerWidth():uint;
		
		/**
		 * 获取居中高度
		 * @return 
		 */
		function get centerHeight():uint;
		
		
		/**
		 * 设置水平x坐标
		 */
		function set x(value:Number):void;
		
		/**
		 * 设置垂直y坐标
		 */
		function set y(value:Number):void;
		//
	}
}