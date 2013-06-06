package lolo.rpg
{
	import flash.geom.Point;

	/**
	 * RPG地图寻路（A*）
	 * @author LOLO
	 */
	public class Wayfinding
	{
		/**偏移和代价，偶数行(0,2,4...)[右下、左下、左上、右上、右、下、左、上]*/
		private static const OFFSETS_E:Array = [ [0,1,10], [-1,1,10], [-1,-1,10], [0,-1,10], [1,0,14], [0,2,14], [-1,0,14], [0,-2,14] ];
		/**偏移和代价，奇数行*/
		private static const OFFSETS_O:Array = [ [1,1,10], [0,1,10], [0,-1,10], [1,-1,10], [1,0,14], [0,2,14], [-1,0,14], [0,-2,14] ];
		
		
		/**是否有找到可通行的路线*/
		private static var isPathFind:Boolean;
		/**关闭列表*/
		private static var closeA:Array;
		/**完成列表（已经考察过的坐标点）*/
		private static var findA:Array;
		/**开放列表*/
		private static var openA:Array;
		/**结果路径*/
		private static var walkA:Array;
		/**结束点*/
		private static var endP:Point;
		
		
		
		
		/**
		 * 根据传入数据，查找出起点和重点间的最佳路径。
		 * 如果起点无法到达终点，将返回null。
		 * 如果起点和重点相同，将返回[]
		 * @param mapData 地图数据
		 * @param startP 开始点
		 * @param endP 结束点
		 * @return 可通行的路线，如果没找到
		 */
		public static function search(mapData:Array, startP:Point, endP:Point):Array
		{
			if(startP.equals(endP)) return [];
			
			Wayfinding.endP = endP;
			isPathFind = false;
			setFindA(mapData);
			openA = [];
			closeA = [];
			searchPath(startP.x, startP.y, startP.x, startP.y, 0);
			
			return isPathFind ? path : null;
		}
		
		
		
		/**
		 * 设置完成列表，标记可以考察的坐标点
		 * @param mapData
		 */
		private static function setFindA(mapData:Array):void
		{
			findA = [];
			for(var i:* in mapData) {
				findA[i] = [];
				for(var j:* in mapData[i]) {
					//高度大于0的点才可以考察
//					findA[i][j] = (mapData[i][j].depth > 0) ? 0 : 1;
					findA[i][j] = mapData[i][j].canPass ? 0 : 1;
				}
			}
		}
		
		
		
		/**
		 * 寻找附近的路径
		 * @param nx 当前点
		 * @param ny
		 * @param px 目标点
		 * @param py
		 * @param g 总代价
		 */
		private static function searchPath(nx:uint, ny:uint, px:uint, py:uint, g:uint):void
		{
			var hval:uint = 0;//当前点到终点的代价值
			var gval:uint = 0;//起点到当前点的代价值
			var min:uint = 0;
			var len:uint = 0;
			findA[ny][nx] = 1;
			closeA.push([nx, ny, px, py]);
			var dir:Array = (ny % 2 == 0) ? OFFSETS_E : OFFSETS_O;
			
			//八方向寻路
			for(var n:int = 0; n < 8; n++)
			{
				var adjX:int = nx + dir[n][0];//相邻节点x
				var adjY:int = ny + dir[n][1];
				
				//坐标点超出范围
				if(adjX < 0 || adjX >= findA.length || adjY < 0 || adjY >= findA.length) continue;
				
				//找到了终点，放入关闭列表
				if(adjX == endP.x && adjY == endP.y) {
					closeA.push([adjX, adjY, nx, ny]);
					isPathFind = true;
					return;
				}
				
				//坐标点还未考察过
				if(findA[adjY][adjX] == 0) {
					hval = dir[n][2];
					gval = g + dir[n][2];
					findA[adjY][adjX] = gval;//设置为G值
					openA.push([adjX, adjY, nx, ny, gval + hval, gval]);
				}
				else if(findA[adjY][adjX] > 1) {
					gval = g + dir[n][2];
					if(gval < findA[adjY][adjX]) {
						hval = 10* (Math.abs(endP.x - adjX) + Math.abs(endP.y - adjY));
						for(var j:int = 1; j < openA.length; j++) {
							if(openA[j][0] == adjX && openA[j][1] == adjY) {
								openA[j] = [adjX, adjY, nx, ny, gval + hval, gval];
								findA[adjY][adjX] = gval;
								break;
							}
						}
					}
				}
			}
			
			//开放列表中没有路径
			if(openA.length == 0) {
				isPathFind = false;
				return;
			}
			
			//获取最小F值
			len = openA.length;
			for(var m:int = 0; m < len; m++) {
				if(openA[min][4] > openA[m][4]) {
					min = m;
				}
			}
			
			//递归调用，继续寻路
			var tCloseA:Array = openA.splice(min, 1);
			searchPath(tCloseA[0][0], tCloseA[0][1], tCloseA[0][2], tCloseA[0][3], tCloseA[0][5]);
		}
		
		
		
		/**
		 * 在查找完成的结果中获取一条最佳路径
		 * @return 
		 */
		private static function get path():Array
		{
			var i:uint = closeA.length - 1;
			var n:uint = 0;
			walkA = [];
			walkA[0] = [];
			walkA[0][0] = closeA[i][0];
			walkA[0][1] = closeA[i][1];
			var px:uint = closeA[i][2];
			var py:uint = closeA[i][3];
			
			for(var j:int = i-1; j >= 0; j--) {
				if(px == closeA[j][0] && py == closeA[j][1]) {
					n++;
					walkA[n] = [];
					walkA[n][0] = closeA[j][0];
					walkA[n][1] = closeA[j][1];
					px = closeA[j][2];
					py = closeA[j][3];
				}
			}
			
			walkA.reverse();
			return walkA;
		}
		//
	}
}