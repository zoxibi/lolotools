package lolo.utils
{
	import com.adobe.serialization.json.AdobeJSON;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;
	
	import lolo.components.AlertText;
	import lolo.components.BaseButton;
	import lolo.components.Button;
	import lolo.components.CheckBox;
	import lolo.components.ComboBox;
	import lolo.components.DragArea;
	import lolo.components.IItemRenderer;
	import lolo.components.ImageLoader;
	import lolo.components.InputText;
	import lolo.components.ItemGroup;
	import lolo.components.Label;
	import lolo.components.LinkText;
	import lolo.components.List;
	import lolo.components.Mask;
	import lolo.components.ModalBackground;
	import lolo.components.MultiColorLabel;
	import lolo.components.NumberText;
	import lolo.components.Page;
	import lolo.components.RadioButton;
	import lolo.components.RichText;
	import lolo.components.ScrollBar;
	import lolo.components.ToolTip;
	import lolo.core.BitmapMovieClip;
	import lolo.core.Container;
	
	/**
	 * 自动化工具
	 * @author LOLO
	 */
	public class AutoUtil
	{
		/**
		 * 自动化生成用户界面
		 * @param target 需要自动化生成用户界面的目标
		 * @param config 界面的配置信息
		 */
		public static function autoUI(target:DisplayObjectContainer, config:XML):void
		{
			initToolTip(target, config.@toolTip);
			initJsonString(target, config.@properties);
			
			for each(var item:XML in config.*)
			{
				var obj:DisplayObject;//创建的显示对象实例
				var name:String = item.@name;//指定的obj的实例名称
				var targetName:String = item.@target;//指定目标，在某些组件中有特殊意义
				var group:String = item.@group;//是ItemRenderer时，指定的所属的组
				var parent:String = item.@parent;//指定的父级容器
				
				//尝试直接从目标中拿该对象的引用
				if(name != "") obj = target[name];
				
				switch(item.name().toString())
				{
					//容器
					case "container":
						if(obj == null) obj = new Container();
						(obj as Container).initUI(item);//继续初始化obj的UI
						break;
					
					//普通的显示对象，一般为fla文件中导出的类
					case "displayObject":
						if(obj == null) obj = getInstance(item.@definition);
						break;
					
					//普通容器(flash.display.Sprite)
					case "sprite":
						if(obj == null) obj = new Sprite();
						break;
					
					//位图影片剪辑
					case "bitmapMC":
						if(obj == null) obj = new BitmapMovieClip();
						break;
					
					//显示文本
					case "label":
						if(obj == null) obj = new Label();
						break;
					
					//内容多色（可以是动画）显示文本
					case "mcLabel":
						if(obj == null) obj = new MultiColorLabel();
						break;
					
					//富显示文本
					case "richText":
						if(obj == null) obj = new RichText();
						break;
					
					//输入文本
					case "inputText":
						if(obj == null) obj = new InputText();
						break;
					
					//链接文本
					case "linkText":
						if(obj == null) obj = new LinkText();
						break;
					
					//提示文本
					case "alertText":
						if(obj == null) obj = new AlertText();
						break;
					
					//显示数字的文本
					case "numberText":
						if(obj == null) obj = new NumberText();
						break;
					
					//按钮
					case "button":
						if(obj == null) obj = new Button();
						break;
					
					//基本按钮
					case "baseButton":
						if(obj == null) obj = new BaseButton();
						break;
					
					//多选框
					case "checkBox":
						if(obj == null) obj = new CheckBox();
						break;
					
					//单选框
					case "radioButton":
						if(obj == null) obj = new RadioButton();
						break;
					
					//Item集合
					case "itemGroup":
						if(obj == null) obj = new ItemGroup();
						break;
					
					//列表
					case "list":
						if(obj == null) obj = new List();
						break;
					
					//翻页组件
					case "page":
						if(obj == null) obj = new Page();
						break;
					
					//滚动条
					case "scrollBar":
						if(obj == null) obj = new ScrollBar();
						if(targetName != "") (obj as ScrollBar).content = target[targetName];
						break;
					
					//图像加载器
					case "imageLoader":
						if(obj == null) obj = new ImageLoader();
						break;
					
					//组合框
					case "comboBox":
						if(obj == null) obj = new ComboBox();
						(obj as ComboBox).initUI(item);
						break;
					
					//模态背景
					case "modalBG":
						if(obj == null) obj = new ModalBackground(target);
						break;
					
					//拖动区域
					case "dragArea":
						if(obj == null) obj = new DragArea(target as Sprite);
						break;
					
					//遮罩
					case "mask":
						if(obj == null) obj = new Mask();
						if(targetName != "") (obj as Mask).target = target[targetName];
						break;
					
					default :
						obj = null;
				}
				
				if(obj != null)
				{
					if(!(obj is Container) && !(obj is ComboBox)) {
						initToolTip(obj, item.@toolTip);
						initJsonString(obj, item.@properties);
					}
					
					//有指定实例名称，将引用赋值给target
					if(name != "") target[name] = obj;
					
					//是ItemRenderer，并且有指定的组
					if(obj is IItemRenderer && group != "")
					{
						(obj as IItemRenderer).group = target[group];
					}
					
					//有指定父级容器
					if(parent != "") 
					{
						if(parent != "null") (target[parent] as DisplayObjectContainer).addChild(obj);
					}
					//不是模态背景和遮罩
					else if(!(obj is ModalBackground) && !(obj is Mask))
					{
						target.addChild(obj);
					}
					
					obj = null;
				}
			}
		}
		
		
		/**
		 * 通过JSON字符串，初始化目标的ToolTip
		 * @param target 需要初始化的目标
		 * @param jsonStr 属性的JSON字符串
		 */
		public static function initToolTip(target:DisplayObject, jsonStr:String):void
		{
			if(jsonStr != "")
			{
				var prop:Object = AdobeJSON.decode(jsonStr);
				if(prop.styleName != null) ToolTip.registerStyle(target, prop.styleName);
				
				ToolTip.register(target, prop.text, prop.toolTipID);
			}
		}
		
		
		/**
		 * 初始化实例，先初始化属性对象，在初始化JSON字符串属性对象
		 * @param target 目标实例
		 * @param parent 目标实例如果是显示对象，可以指定容器
		 * @param obj 初始化属性对象
		 * @param jsonStr JSON字符串属性对象
		 * @return 初始化完毕的实例对象（即参数target）
		 */
		public static function init(target:Object, parent:DisplayObjectContainer=null, obj:Object=null, jsonStr:String=null):*
		{
			if(target == null) return null;
			if(obj != null) initObject(target, obj);
			if(jsonStr != null) initJsonString(target, jsonStr);
			if(parent != null && target is DisplayObject) parent.addChild(target as DisplayObject);
			return target;
		}
		
		
		
		/**
		 * 初始化属性对象
		 * @param target 目标对象的引用
		 * @param obj 属性对象
		 */
		public static function initObject(target:Object, obj:Object):void
		{
			obj = ObjectUtil.baseClone(obj);//拷贝出一个副本，用于操作
			
			//优先处理的属性
			if(obj.skin != null) {
				target.skin = obj.skin;
				delete obj.skin;
			}
			if(obj.styleName != null) {
				target.styleName = obj.styleName;
				delete obj.styleName;
			}
			if(obj.style != null) {
				target.style = obj.style;
				delete obj.style;
			}
			if(obj.autoSize != null) {
				target.autoSize = obj.autoSize;
				delete obj.autoSize;
			}
			if(obj.autoTooltip != null) {
				target.autoTooltip = obj.autoTooltip;
				delete obj.autoTooltip;
			}
			if(obj.direction != null) {
				target.direction = obj.direction;
				delete obj.direction;
			}
			
			for(var properties:String in obj)
			{
				try {
					target[properties] = obj[properties];
				}
				catch(error:Error) {
					trace("\n");
					trace("-=-=-=-=-=-=-=-=-= initObject Error =-=-=-=-=-=-=-=-=-");
					trace("     error:", error);
					trace("    target:", target);
					trace("properties:", properties);
					trace("     value:", obj[properties]);
					trace("-=-=-=-=-=-=-=-=-=-=-=-=- END =-=-=-=-=-=-=-=-=-=-=-=-");
					trace("\n");
				}
			}
		}
		
		
		/**
		 * 初始化JSON字符串
		 * @param target 目标对象的引用
		 * @param jsonStr JSON字符串属性对象
		 */
		public static function initJsonString(target:Object, jsonStr:String):void
		{
			if(jsonStr.length > 0) initObject(target, AdobeJSON.decode(jsonStr));
		}
		
		
		/**
		 * 根据类的完整定义名称，返回类实例
		 * @param definition 类的完整定义名称
		 */
		public static function getInstance(definition:String):*
		{
			try {
				var tempClass:Class = getDefinitionByName(definition) as Class;
				return new tempClass();
			}
			catch(error:Error) {
				return null;
			}
		}
		//
	}
}