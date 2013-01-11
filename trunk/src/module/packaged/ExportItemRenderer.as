package module.packaged
{
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.core.BitmapAsset;
	
	import spark.components.CheckBox;
	
	/**
	 * 用于导出选项类
	 * @author LOLO
	 */
	public class ExportItemRenderer extends TreeItemRenderer
	{
		public var selectCB:CheckBox;
		public var fileIcon:BitmapAsset;
		
		
		public function ExportItemRenderer()
		{
			super();
			
			this.setStyle("fontFamily", "宋体");
			this.setStyle("fontSize", 14);
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		
		
		private function mouseDownHandler(event:MouseEvent):void
		{
			if(event.target != selectCB) {
				selectCB.selected = !selectCB.selected;
			}
		}
		
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			selectCB = new CheckBox();
			selectCB.y = 10;
			this.addChild(selectCB);
		}
		
		
		override public function set data(value:Object):void
		{
			super.data = value;
			if(value == null) return;
			if(value.file != null) {
				selectCB.visible = !data.file.isDirectory;
				
				if(fileIcon != null) {
					fileIcon.bitmapData.dispose();
					this.removeChild(fileIcon);
				}
				
				var iconBitmapData:BitmapData;
				for each(iconBitmapData in value.file.icon.bitmaps) {
					if(iconBitmapData.width == 16) break;
				}
				fileIcon = new BitmapAsset(iconBitmapData);
				fileIcon.width = 16;
				fileIcon.height = 16;
				this.addChild(fileIcon);
			}
		}
		
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			selectCB.x = label.x + 5;
			if(data.file != null && !data.file.isDirectory) label.x += 20;
			
			if(icon != null && fileIcon != null) {
				fileIcon.x = icon.x;
				fileIcon.y = icon.y;
				icon.visible = false;
			}
		}
		//
	}
}