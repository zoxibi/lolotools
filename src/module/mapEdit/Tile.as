package module.mapEdit
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import lolo.effects.AsEffect;
	import lolo.rpg.RpgUtil;
	
	/**
	 * 区块
	 * @author LOLO
	 */
	public class Tile extends Sprite
	{
		private var _noText:TextField;
		
		public var tileWidth:int;
		public var tileHeight:int;
		
		private var _canPass:Boolean = true;
		private var _isWater:Boolean;
		
		
		/**
		 * 
		 * @param x
		 * @param y
		 * @param width
		 * @param height
		 */
		public function Tile(x:int, y:int, width:int, height:int)
		{
			super();
			tileWidth = width;
			tileHeight = height;
			
			draw();
			var p:Point = RpgUtil.getTileCenterPoint(new Point(x, y), width, height);
			this.x = p.x - width / 2;
			this.y = p.y - height / 2;
			
			_noText = new TextField();
			_noText.defaultTextFormat = new TextFormat("宋体", 12, 0xFFFFFF);
			_noText.autoSize = TextFieldAutoSize.LEFT;
			_noText.selectable = _noText.mouseEnabled = _noText.mouseWheelEnabled = false;
			_noText.text = x + "," + y;
			_noText.filters = [AsEffect.getStrokeFilter(0x302010)];
			_noText.x = (width - _noText.textWidth) / 2;
			_noText.y = (height - _noText.textHeight) / 2;
		}
		

		private function draw(color:uint=0xFFFFFF, alpha:Number=0.01, width:int=0, height:int=0):void
		{
			if(width == 0) width = tileWidth;
			if(height == 0) height = tileHeight;
			graphics.clear();
			graphics.beginFill(color, alpha);
			graphics.lineStyle(1, 0x00CC00, 0.3);
			graphics.moveTo(0, height / 2);
			graphics.lineTo(width / 2, 0);
			graphics.lineTo(width, height / 2);
			graphics.lineTo(width / 2, height);
			graphics.lineTo(0 , height / 2);
			graphics.endFill();
			
			if(_isWater) {
				graphics.lineStyle(0, 0xFF0000, 0.3);
				graphics.beginFill(0xFF0000, 0.3);
				graphics.drawCircle(width / 2, height / 2, Math.min(width, height) * 0.3);
			}
		}
		
		
		
		/**
		 * 是否显示编号
		 * @param value
		 */
		public function set isShowNO(value:Boolean):void
		{
			if(value) {
				this.addChild(_noText);
			}
			else {
				if(_noText.parent) this.removeChild(_noText);
			}
		}
		
		
		/**
		 * 是否可以通行
		 */
		public function set canPass(value:Boolean):void
		{
			_canPass = value;
			if(value) {
				draw();
			}
			else {
				draw(0xFF0000, 0.3);
			}
		}
		
		public function get canPass():Boolean
		{
			return _canPass;
		}
		
		
		
		/**
		 * 是否是水域
		 */
		public function set isWater(value:Boolean):void
		{
			_isWater = value;
			canPass = _canPass;
		}
		
		public function get isWater():Boolean
		{
			return _isWater;
		}
	//
	}
}