package lolo.components
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.engine.FontWeight;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.CompositionCompleteEvent;
	import flashx.textLayout.events.FlowElementMouseEvent;
	import flashx.textLayout.formats.TextDecoration;
	
	import lolo.common.Common;
	import lolo.events.components.RichTextEvent;
	import lolo.utils.AutoUtil;

	/**
	 * 可以具有丰富内容的显示文本，支持图文混排
	 * @author LOLO
	 */
	public class RichText extends Sprite
	{
		/**对齐方式，见flashx.textLayout.formats.TextAlign*/
		protected var _align:String = "left";
		/**字体名称列表，名称之间用","进行分隔*/
		protected var _fontFamily:String = "宋体,Arial";
		/**文字尺寸(像素)*/
		protected var _size:uint = 12;
		/**颜色*/
		protected var _color:uint = 0x000000;
		/**是否粗体*/
		protected var _bold:Boolean = false;
		/**是否显示下划线*/
		protected var _underline:Boolean = false;
		/**行与行之间的垂直距离*/
		protected var _leading:* = "150%";
		
		/**文本流*/
		private var _textFlow:TextFlow;
		/**容器控制器*/
		private var _containerController:ContainerController;
		/**当前段落*/
		private var _paragraph:ParagraphElement;
		
		/**设置的宽度*/
		private var _width:uint = 100;
		/**设置的高度*/
		private var _height:uint = 100;
		/**最大段落数*/
		private var _maxParagraphCount:uint = 60;
		/**是否可选*/
		private var _selectable:Boolean;
		/**是否自动设置高度*/
		private var _autoHeight:Boolean = true;
		
		
		
		public function RichText()
		{
			super();
			_textFlow = new TextFlow();
			_containerController = new ContainerController(this, _width, _height);
			_textFlow.flowComposer.addController(_containerController);
			
			_textFlow.addEventListener(FlowElementMouseEvent.CLICK, clickHandler);
			_textFlow.addEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, compositionCompleteHandler);
			
			this.style = Common.style.getStyle("richText");
		}
		
		
		/**
		 * 点击内容元素
		 * @param event
		 */
		private function clickHandler(event:FlowElementMouseEvent):void
		{
			//是链接文本
			if(event.flowElement is LinkElement)
			{
				this.dispatchEvent(new RichTextEvent(RichTextEvent.CLICK_LINK, (event.flowElement as LinkElement).target));
			}
		}
		
		
		/**
		 * 重新合成后
		 * @param event
		 */
		private function compositionCompleteHandler(event:CompositionCompleteEvent):void
		{
			updateHeight();
		}
		
		
		
		/**
		 * 样式
		 */
		public function set style(value:Object):void
		{
			if(value.align != null) this.align = value.align;
			if(value.bold != null) this.bold = value.bold;
			if(value.color != null) this.color = value.color;
			if(value.fontFamily != null) this.fontFamily = value.fontFamily;
			if(value.size != null) this.size= value.size;
			if(value.underline != null) this.underline = value.underline;
			if(value.leading != null) this.leading = value.leading;
			
			if(value.linkNormalFormat != null) _textFlow.linkNormalFormat = value.linkNormalFormat;
			if(value.linkHoverFormat != null) _textFlow.linkHoverFormat = value.linkHoverFormat;
			if(value.linkActiveFormat != null) _textFlow.linkActiveFormat = value.linkActiveFormat;
			
			update();
		}
		
		
		
		
		/**对齐方式，见flashx.textLayout.formats.TextAlign*/
		public function set align(value:String):void
		{
			_align = value;
			_textFlow.setStyle("textAlign", _align);
			update();
		}
		public function get align():String { return _align; }
		
		/**是否粗体*/
		public function set bold(value:Boolean):void
		{
			_bold = value;
			_textFlow.setStyle("fontWeight", _bold ? FontWeight.BOLD : FontWeight.NORMAL);
			update();
		}
		public function get bold():Boolean { return _bold; }
		
		/**颜色*/
		public function set color(value:uint):void
		{
			_color = value;
			_textFlow.setStyle("color", _color);
			update();
		}
		public function get color():uint { return _color; }
		
		/**字体名称列表，名称之间用","进行分隔*/
		public function set fontFamily(value:String):void
		{
			_fontFamily = value;
			_textFlow.setStyle("fontFamily", _fontFamily);
			update();
		}
		public function get fontFamily():String { return _fontFamily; }
		
		/**文字尺寸(像素)*/
		public function set size(value:uint):void
		{
			_size = value;
			_textFlow.setStyle("fontSize", _size);
			update();
		}
		public function get size():uint { return _size; }
		
		/**是否显示下划线*/
		public function set underline(value:Boolean):void
		{
			_underline = value;
			_textFlow.setStyle("textDecoration", _underline ? TextDecoration.UNDERLINE : TextDecoration.NONE);
			update();
		}
		public function get underline():Boolean { return _underline; }
		
		/**行与行之间的垂直距离*/
		public function set leading(value:*):void
		{
			_leading = value;
		}
		public function get leading():* { return _leading; }
		
		
		
		/**
		 * 开始新的段落
		 */
		public function beginParagraph():void
		{
			_paragraph = new ParagraphElement();
		}
		
		
		/**
		 * 结束正在编辑的段落
		 */
		public function endParagraph():void
		{
			if(_paragraph == null) return;
			_textFlow.addChild(_paragraph);
			_paragraph = null;
			
			//第一次添加内容，重设selectable
			if(_textFlow.numChildren == 1) selectable = _selectable;
			
			//超出最大段落数时，从前面移除段落
			while(_textFlow.numChildren > _maxParagraphCount) _textFlow.removeChildAt(0);
			
			//显示内容
			update();
			
			//更新高度
			updateHeight();
		}
		
		
		
		
		/**
		 * 添加一段文本
		 * @param text 文本的内容 
		 * @param prop 文本的属性，见flashx.textLayout.elements.SpanElement
		 */
		public function appendText(text:String, prop:Object=null):void
		{
			if(text == null) return;
			if(_paragraph == null) beginParagraph();
			
			var span:SpanElement = AutoUtil.init(new SpanElement(), null, prop);
			span.text = text;
			span.setStyle("lineHeight", _leading);
			_paragraph.addChild(span);
		}
		
		/**
		 * 添加一段链接文本
		 * @param text 文本的内容
		 * @param data 与链接关联的数据
		 * @param spanProp 内容文本的属性，见flashx.textLayout.elements.SpanElement
		 * @param linkProp 链接文本的属性，见flashx.textLayout.elements.LinkElement
		 */
		public function appendLinkText(text:String, data:String=null, spanProp:Object=null, linkProp:Object=null):void
		{
			if(text == null) return;
			if(_paragraph == null) beginParagraph();
			
			var span:SpanElement = AutoUtil.init(new SpanElement(), null, spanProp);
			var link:LinkElement = AutoUtil.init(new LinkElement(), null, linkProp);
			link.target = data;
			span.text = text;
			span.setStyle("lineHeight", _leading);
			
			link.addChild(span);
			_paragraph.addChild(link);
		}
		
		/**
		 * 添加一个图形
		 * @param source 图形的源
		 * @param prop 图形的属性，见flashx.textLayout.elements.InlineGraphicElement
		 */
		public function appendGraphic(source:DisplayObject, prop:Object=null):void
		{
			if(source == null) return;
			if(_paragraph == null) beginParagraph();
			
			var graphic:InlineGraphicElement = AutoUtil.init(new InlineGraphicElement(), null, prop);
			graphic.source = source;
			_paragraph.addChild(graphic);
		}
		
		
		
		
		
		/**
		 * 更新容器控制器，显示内容
		 */
		public function update():void
		{
			//宽高有改变
			if(_containerController.compositionWidth != _width || _containerController.compositionHeight != _height)
				_containerController.setCompositionSize(_width, _height);
			
			//有内容
			if(_textFlow.numChildren > 0) _textFlow.flowComposer.updateAllControllers();
		}
		
		
		/**
		 * 更新高度
		 */
		public function updateHeight():void
		{
			//允许自动设置高度
			if(autoHeight)
			{
				//高度需要多加3像素，才能显示完整
				_height = _containerController.getContentBounds().height + 3;
				//重新显示内容
				update();
			}
		}
		
		
		
		/**
		 * 是否可选
		 */
		public function set selectable(value:Boolean):void
		{
			_selectable = value;
			if(_textFlow.numChildren == 0) return;//没内容时，不设置，否则将会出现第一行为空行
			_textFlow.interactionManager = value ? new SelectionManager() : null;
		}
		public function get selectable():Boolean { return _selectable; }
		
		
		/**
		 * 最大段落数
		 */
		public function set maxParagraphCount(value:uint):void { _maxParagraphCount = value; }
		public function get maxParagraphCount():uint { return _maxParagraphCount; }
		
		/**
		 * 是否自动设置高度
		 */
		public function set autoHeight(value:Boolean):void { _autoHeight = value; }
		public function get autoHeight():Boolean { return _autoHeight; }
		
		
		
		override public function set width(value:Number):void
		{
			_width = value;
			update();
		}
		
		/**
		 * 获取设置的宽度
		 */
		public function get setWidth():Number { return _width; }
		
		
		
		override public function set height(value:Number):void
		{
			_height = value;
			update();
		}
		
		/**
		 * 获取设置的高度
		 */
		public function get setHeight():Number { return _height; }
		
		
		
		/**
		 * 清除所有内容
		 */
		public function clear():void
		{
			while(_textFlow.numChildren > 0) _textFlow.removeChildAt(0);
		}
		//
	}
}