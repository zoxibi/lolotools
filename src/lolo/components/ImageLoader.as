package lolo.components
{
	import com.greensock.TweenMax;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import lolo.common.Common;
	import lolo.utils.StringUtil;
	
	/**
	 * 以HTTP方式加载显示对象文件
	 * @author LOLO
	 */
	public class ImageLoader extends Loader
	{
		/**显示对象文件所在的路径*/
		private var _path:String;
		/**显示对象文件的名称*/
		private var _fileName:String;
		/**当前显示对象文件的完整路径*/
		private var _url:String;
		
		/**设置的宽度*/
		private var _widht:uint;
		/**设置的高度*/
		private var _height:uint;
		
		/**加载完成后，从不可见到可见，alpha动画的持续时间*/
		public var showEffectDuration:Number = 0.3;
		
		
		public function ImageLoader()
		{
			super();
		}
		
		
		/**
		 * 显示对象文件的名称
		 */
		public function set fileName(value:String):void
		{
			_fileName = value;
			loadFile();
		}
		public function get fileName():String { return _fileName; }
		
		
		/**
		 * 显示对象文件所在的路径
		 */
		public function set path(value:String):void
		{
			_path = value;
			loadFile();
		}
		public function get path():String { return _path; }
		
		
		/**
		 * 显示对象文件所在的路径
		 */
		public function set pathFormatName(value:String):void
		{
			path = Common.config.getUIConfig(value);
		}
		
		
		
		/**
		 * 加载文件
		 */
		private function loadFile(fileName:String=null):void
		{
			if(fileName != null) _fileName = fileName;
			if(_path == null || _fileName == null) return;
			
			var url:String = Common.getResUrl(StringUtil.substitute(_path, _fileName));
			
			if(url != _url)
			{
				_url = url;
				this.contentLoaderInfo.addEventListener(Event.COMPLETE, loadHandler);
				this.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadHandler);
				load(new URLRequest(_url), new LoaderContext(true));
			}
		}
		
		
		/**
		 * 加载成功或失败
		 * @param event
		 */
		private function loadHandler(event:Event):void
		{
			//加载完成
			if(event.type == Event.COMPLETE)
			{
				if(_widht > 0) width = _widht;
				if(_height > 0) height = _height;
				
				this.alpha = 0;
				TweenMax.to(this, showEffectDuration, { alpha:1 });
			}
			//加载失败
			else
			{
				trace("ImageLoader 加载", _url, "失败！");
			}
			
			this.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadHandler);
			this.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadHandler);
		}
		
		
		override public function unload():void
		{
			_url = null;
			
			try { super.unload(); }
			catch(error:Error) {}
			
			try { super.close(); }
			catch(error:Error) {}
		}
		
		
		override public function set width(value:Number):void
		{
			_widht = value;
			if(content != null) content.width = _widht;
		}
		override public function get width():Number
		{
			return _widht > 0 ? _widht : super.width;
		}
		
		
		override public function set height(value:Number):void
		{
			_height = value;
			if(content != null) content.height = _height;
		}
		override public function get height():Number
		{
			return _height > 0 ? _height : super.height;
		}
		//
	}
}