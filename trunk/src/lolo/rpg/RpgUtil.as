package lolo.rpg
{
	import flash.geom.Point;

	/**
	 * Rpg工具
	 * @author LOLO
	 */
	public class RpgUtil
	{
		
		
		/**
		 * 获取p2在p1的什么角度
		 * @param p1
		 * @param p2
		 * @return 
		 */
		public static function getAngle(p1:Point, p2:Point):Number
		{
			//两点的x、y值
			var x:Number = p2.x - p1.x;
			var y:Number = p2.y - p1.y;
			var hypotenues:Number = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
			
			//斜边长度
			var cos:Number = x / hypotenues;
			var radian:Number = Math.acos(cos);
			
			//算出角度
			var angle:Number = 180 / (Math.PI / radian);
			if(y < 0) {
				angle = -angle;
			}
			else if(y == 0 && x < 0) {
				angle = 180;
			}
			return angle;
		}
		
		
		
		/**
		 * 获取指定区块的中心点像素坐标
		 * @param tPoint 区块坐标
		 * @param tWidth 区块宽
		 * @param tHeight 区块高
		 * @return 
		 */
		public static function getTileCenterPoint(tPoint:Point, tWidth:int, tHeight:int):Point
		{
			var p:Point = new Point();
			
			//算出目标区块的坐标
			var isEven:Boolean = (tPoint.y % 2) == 0;//是否为偶数行
			p.x = tPoint.x * tWidth;
			p.y = tPoint.y * tHeight * 0.5;
			if(!isEven) p.x += tWidth * 0.5;
			
			//加上半个区块宽高
			p.x += tWidth * 0.5;
			p.y += tHeight * 0.5;
			
			return p;
		}
		
		
		
		
		/**
		 * 获取指定像素坐标所对应的区块坐标
		 * @param pxPoint 像素坐标
		 * @param tWidth 区块宽
		 * @param tHeight 区块高
		 * @return 
		 */
		public static function getTilePoint(pxPoint:Point, tWidth:int, tHeight:int):Point
		{
			var x:uint = pxPoint.x;
			var y:uint = pxPoint.y;
			var tx:int = 0;
			var ty:int = 0;
			
			var cx:int, cy:int, rx:int, ry:int;
			cx = int(x / tWidth) * tWidth + tWidth / 2;
			cy = int(y / tHeight) * tHeight + tHeight / 2;
			
			rx = (x - cx) * tHeight / 2;
			ry = (y - cy) * tWidth / 2;
			
			if(Math.abs(rx) + Math.abs(ry) <= tWidth * tHeight / 4) {
				tx = int(x / tWidth);
				ty = int(y / tHeight) * 2;
			}
			else {
				x = x - tWidth / 2;
				tx = int(x / tWidth) + 1;
				y = y - tHeight / 2;
				ty = int(y / tHeight) * 2 + 1;
			}
			
			//无区块的区域，加上半个区块宽高，得到最近的区块
			if(tx > 99999 || ty > 99999) {
				pxPoint.x += tWidth / 2;
				pxPoint.y += tHeight / 2;
				return getTilePoint(pxPoint, tWidth, tHeight);
			}
			
			return new Point(tx - (ty & 1), ty);
		}
		//
	}
}