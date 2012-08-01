package lolo.core
{
	import flash.display.BlendMode;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import lolo.common.Common;
	import lolo.effects.AsEffect;

	/**
	 * 基本文本对象
	 * @author LOLO
	 */
	public class RTextField extends TextField
	{
		/**对齐方式，可选值["left", "right", "center"]*/
		protected var _align:String = "left";
		/**是否粗体*/
		protected var _bold:Boolean = false;
		/**颜色*/
		protected var _color:uint = 0x000000;
		/**字体*/
		protected var _font:String = "宋体";
		/**文字尺寸(像素)*/
		protected var _size:uint = 12;
		/**是否显示下划线*/
		protected var _underline:Boolean = false;
		/**行与行之间的垂直间距*/
		protected var _leading:int = 3;
		/**描边滤镜颜色*/
		protected var _stroke:uint = 0x0;
		
		
		/**文本类型*/
		protected var _textType:String = "htmlText";
		/**设置的宽*/
		protected var _width:int = 0;
		/**设置的高*/
		protected var _height:int = 0;
		
		
		/**当前显示的文本*/
		protected var _currentText:String = "";
		
		
		
		
		/**
		 * 构造一个文本显示对象
		 */
		public function RTextField()
		{
			super();
			
			this.blendMode = BlendMode.LAYER;
			this.style = Common.style.getStyle("textField");
		}
		
		
		
		/**
		 * 样式
		 * @param value
		 */
		public function set style(value:Object):void
		{
			if(value.align != null) _align = value.align;
			if(value.bold != null) _bold = value.bold;
			if(value.color != null) _color = value.color;
			if(value.font != null) _font = value.font;
			if(value.size != null) _size= value.size;
			if(value.underline != null) _underline = value.underline;
			if(value.leading != null) _leading = value.leading;
			
			if(value.stroke != null) this.stroke = value.stroke;
			
			showCurrentText();
		}
		
		
		
		/**对齐方式，可选值["left", "right", "center"]*/
		public function set align(value:String):void
		{
			_align = value;
			showCurrentText();
		}
		public function get align():String { return _align; }
		
		/**是否粗体*/
		public function set bold(value:Boolean):void
		{
			_bold = value;
			showCurrentText();
		}
		public function get bold():Boolean { return _bold; }
		
		/**颜色*/
		public function set color(value:uint):void
		{
			_color = value;
			showCurrentText();
		}
		public function get color():uint { return _color; }
		
		/**字体*/
		public function set font(value:String):void
		{
			_font = value;
			showCurrentText();
		}
		public function get font():String { return _font; }
		
		/**文字尺寸(像素)*/
		public function set size(value:uint):void
		{
			_size = value;
			showCurrentText();
		}
		public function get size():uint { return _size; }
		
		/**是否显示下划线*/
		public function set underline(value:Boolean):void
		{
			_underline = value;
			showCurrentText();
		}
		public function get underline():Boolean { return _underline; }
		
		/**行与行之间的垂直间距*/
		public function set leading(value:int):void
		{
			_leading = value;
			showCurrentText();
		}
		public function get leading():int { return _leading; }
		
		
		/**描边滤镜颜色*/
		public function set stroke(value:String):void
		{
			//不需要描边
			if(value == "none") {
				this.filters = null;
				_stroke = 0x0;
			}else {
				this.filters = [AsEffect.getStrokeFilter(uint(value))];
				_stroke = uint(value);
			}
		}
		public function get stroke():String { return _stroke.toString(16); }
		
		
		
		
		/**
		 * 显示当前文本，渲染style
		 */
		public function showCurrentText():void
		{
			var format:TextFormat = new TextFormat();
			format.align	= _align;
			format.bold		= _bold;
			format.font		= _font;
			format.color	= _color;
			format.size		= _size;
			format.underline= _underline;
			format.leading	= _leading;
			this.defaultTextFormat = format;
			
			super[_textType] = _currentText;
		}
		
		
		
		/**
		 * 文本类型，可选值["text", "htmlText"]
		 * @param value
		 */		
		public function set textType(value:String):void
		{
			_textType = value;
			showCurrentText();
		}
		
		
		/**
		 * 获取当前显示的文本值，包括html字符
		 * @return 
		 */		
		public function get currentText():String
		{
			return _currentText;
		}
		
		
		
		/**
		 * 设置文本显示内容
		 * @param value
		 */
		override public function set text(value:String):void
		{
			if(value == null) value = "";
			_currentText = value;
			showCurrentText();
			resetSize();
		}
		
		
		/**
		 * 设置文本显示内容在语言包中的ID，将会通过ID自动到语言包中拿取对应的内容
		 * @param value
		 */
		public function set textID(value:String):void
		{
			text = Common.language.getLanguage(value);
		}
		
		
		
		/**
		 * 设置文本显示html内容
		 * @param value
		 */
		override public function set htmlText(value:String):void
		{
			var textType:String = _textType;
			_textType = "htmlText";
			this.text = value;
			_textType = textType;
		}
		
		
		
		/**
		 * 文本的宽度
		 * @param value
		 */
		override public function set width(value:Number):void
		{
			super.width = _width = value;
		}
		
		/**
		 * 文本的高度
		 * @param value
		 */
		override public function set height(value:Number):void
		{
			super.height = _height = value;
		}
		
		
		/**
		 * 是否为多行文本
		 * @param value
		 */
		override public function set multiline(value:Boolean):void
		{
			super.multiline = super.wordWrap = value;
			resetSize();
		}
		
		
		
		/**
		 * 重置文本的宽高，将宽高设定到用户指定的宽高
		 */
		protected function resetSize():void
		{
			if(_width > 0) super.width = _width;
			if(_height > 0) super.height = _height;
		}
		//
	}
}