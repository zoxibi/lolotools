package lolo.components
{
	import flash.text.TextFieldAutoSize;
	
	import lolo.common.Common;
	import lolo.core.RTextField;
	import lolo.events.components.ToolTipEvent;

	/**
	 * 显示文本
	 * @author LOLO
	 */
	public class Label extends RTextField
	{
		/**在文本长宽超过设定的尺寸时，是否自动省略文本*/
		public var omission:Boolean = true;
		/**是否在省略了文本时，自动将tooltip设置成原始文本值*/
		public var autoTooltip:Boolean = true;
		
		
		/**文字省略时，替代的文本*/
		protected var _moreText:String = "...";
		/**原始文本值*/
		protected var _originalText:String = "";
		/**当前tooltip*/
		protected var _tooltip:String = null;
		
		
		public function Label()
		{
			super();
			
			this.autoSize = TextFieldAutoSize.LEFT;
			this.selectable = false;
			
			this.style = Common.style.getStyle("label");
		}
		
		
		
		override public function set style(value:Object):void
		{
			super.style = value;
			
			if(value.moreText != null) _moreText = value.moreText;
		}
		
		
		
		/**
		 * 原始文本值
		 */
		public function get originalText():String
		{
			return _originalText;
		}
		
		
		/**
		 * 当前tooltip
		 */
		public function get tooltip():String
		{
			return _tooltip;
		}
		
		
		
		
		/**
		 * 检查文本长宽是否超过设定的尺寸，省略文本
		 */
		private function omissionText():void
		{
			var execTest:Boolean = true;//是否执行自动省略测试
			var omission:Boolean = false;//文本是否超出了设置的宽高
			
			if(this.omission)
			{
				if(_width == 0) execTest = false;//没设置宽度
				if(multiline && _height == 0) execTest = false;//多行，没设置高度
				
				var index:int = 0;
				var str:String = "";
				var backStr:String = "";
				var backIndex:int = 0;//当前已往后倒退的索引
			
				while(execTest)
				{
					if(!omission) {
						str += _originalText.charAt(index);
						_currentText = str;
						showCurrentText();
					}
					else {
						backIndex++;
						str = backStr.slice(0, backStr.length - backIndex);
						_currentText = str + _moreText;
						showCurrentText();
						
						if(!multiline && this.textWidth <= _width && super.text.indexOf(_moreText) != -1) {
							execTest = false;
						}
						else if(multiline && this.textHeight <= _height && super.text.indexOf(_moreText) != -1) {
							execTest = false;
						}
						
						//回退检测的次数大于了替代文本的长度（文本宽高不够），跳出循环
						if(backIndex >= _moreText.length) break;
					}
					
					if(!multiline && this.textWidth > _width) {
						omission = true;
					}
					else if(multiline && this.textHeight > _height) {
						omission = true;
					}
					
					if(omission && backStr == "") backStr = str;
					
					if(!omission) {
						index++;
						if(index >= _originalText.length) execTest = false;
					}
					
				}
			}
			
			resetSize();
			
			_tooltip = omission ? _originalText : null;
			if(autoTooltip) ToolTip.register(this, _tooltip);
			this.dispatchEvent(new ToolTipEvent(ToolTipEvent.SHOW, _tooltip));
		}
		
		
		
		override public function set text(value:String):void
		{
			//显示设置的文本
			if(value == null) value = "";
			_originalText = _currentText = value;
			showCurrentText();
			resetSize();
			
			omissionText();
		}
		
		
		override public function set width(value:Number):void
		{
			super.width = value;
			omissionText();
		}
		
		override public function set height(value:Number):void
		{
			super.height = value;
			omissionText();
		}
		
		override public function set multiline(value:Boolean):void
		{
			super.multiline = value;
			omissionText();
		}
		
		
		
		/**
		 * 用于清理引用，释放内存
		 * 在丢弃该组件时，需要主动调用该方法
		 */
		public function dispose():void
		{
			ToolTip.unregister(this);
		}
		//
	}
}