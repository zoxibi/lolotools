import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.net.URLRequest;

import mx.events.FlexEvent;


/**目标根文件夹*/
private var _rootDirectory:File;

/**
 * 初始化
 * @param event
 */
private function creationCompleteHandler(event:FlexEvent):void
{
	_rootDirectory = new File();
	_rootDirectory.addEventListener(Event.SELECT, rootDirectory_selectHandler);
}



/**
 * 点击选择根文件夹按钮
 * @param event
 */
protected function selectRootDirectoryBtn_clickHandler(event:MouseEvent):void
{
	_rootDirectory.browseForDirectory("请选择包含序列图像的根文件夹");
}


/**
 * 选择了 根文件夹
 * @param event
 */
//private function rootDirectory_selectHandler(event:Event):void
//{
//	var movieList:Array = _rootDirectory.getDirectoryListing();//动画文件夹列表
//	
//	for(var i:int = 0; i < movieList.length; i++)
//	{
//		var movieDirectory:File = movieList[i];//帧图像文件夹
//		if(!movieDirectory.isDirectory) continue;//必须是文件夹
//		var frameFileList:Array = movieDirectory.getDirectoryListing();//帧图像文件列表
//		for(var n:int = 0; n < frameFileList.length; n++)
//		{
//			var frameFile:File = frameFileList[n];
//			if(frameFile.extension == null) {
//				trace("[" + frameFile.url + "] 不是有效的图像文件（后缀有误）");
//				continue;
//			}
//			var extension:String = frameFile.extension.toLocaleLowerCase();
//			if(extension != "jpg" && extension != "jpeg" && extension != "png") {
//				trace("[" + frameFile.url + "] 不是有效的图像文件");
//				continue;
//			}
//			
//			frameFile.addEventListener(Event.COMPLETE, loadFrameFileCompleteHnalder);
//			frameFile.addEventListener(
//			frameFile.load();
//			trace(frameFile.data);
//		}
//	}
//}


//private function loadFrameFileCompleteHnalder(event:Event):void
//{
//	var frameFile:File = event.target as File;
//	frameFile.removeEventListener(Event.COMPLETE, loadFrameFileCompleteHnalder);
//	trace(frameFile.data);
//}




private var _imageList:Array;
private var _count:int;

/**
 * 选择了 根文件夹
 * @param event
 */
private function rootDirectory_selectHandler(event:Event):void
{
	var arr:Array = _rootDirectory.getDirectoryListing();
	_imageList = [];
	_count = arr.length;
	for(var i:int = 0; i < arr.length; i++) {
		var file:File = arr[i];
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, image_completeHandler);
		loader.load(new URLRequest(file.url));
	}
}


private function image_completeHandler(event:Event):void
{
	_imageList.push(event.target.loader.content.bitmapData);
	if(_imageList.length < _count) return;
	
}




