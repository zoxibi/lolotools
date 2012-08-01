package lolo.utils
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import lolo.common.Common;

	/**
	 * 图片工具
	 * @author LOLO
	 */
	public class ImageUtil
	{
		
		
		/**
		 * 等比例缩放图片，并居中
		 * @param img 要缩放的图片
		 * @param tRect 目标位置
		 */
		public static function uniform(img:DisplayObject, tRect:Rectangle=null):void
		{
			if(tRect == null) tRect = new Rectangle(0, 0, Common.ui.stageWidth, Common.ui.stageHeight);
			
			var oWidth:int = img.width;
			var oHeight:int = img.height;
			
			img.width = tRect.width;
			img.height = tRect.width / oWidth * oHeight;
			
			if(img.height < tRect.height) {
				img.width = tRect.height / oHeight * oWidth;
				img.height = tRect.height;
			}
			
			img.x = (tRect.width - img.width) / 2 + tRect.x;
			img.y = (tRect.height - img.height) / 2 + tRect.y;
		}
		//
	}
}