package lolo.utils
{
	import flash.geom.Point;

	/**
	 * 提供数学运算的工具类
	 * @author LOLO
	 */
	public class MathUtil
	{
		
		/**
		 * 获取p2在p1的什么角度
		 * @param p1 坐标点1
		 * @param p2 坐标点2
		 * @return 
		 */
		public static function getAngle(p1:Point, p2:Point):Number
		{
			//两点的x,y值，斜边
			var x:Number = p2.x - p1.x;
			var y:Number = p2.y - p1.y;
			var hypotenuse:Number = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
			
			//斜边长度，弧度
			var cos:Number = x / hypotenuse;
			var radian:Number = Math.acos(cos);
			
			//角度
			var angle:Number = 180 / (Math.PI / radian);
			
			//用弧度算出角度
			if(y < 0) {
				angle = -angle;
			}
			else if(y == 0 && x < 0) {
				angle = 180;
			}
			
			return angle;
		}
		//
	}
}