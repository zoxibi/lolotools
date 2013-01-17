import com.adobe.images.PNGEncoder;

import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.net.URLRequest;

import mx.controls.Alert;
import mx.events.FlexEvent;

import spark.events.TextOperationEvent;


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




protected function redHS_changeHandler(event:Event):void
{
	redIT.text = redHS.value.toString();
}

protected function greenHS_changeHandler(event:Event):void
{
	greenIT.text = greenHS.value.toString();
}

protected function blueHS_changeHandler(event:Event):void
{
	blueIT.text = blueHS.value.toString();
}

protected function redIT_changeHandler(event:TextOperationEvent):void
{
	redHS.value = uint(redIT.text);
}

protected function greenIT_changeHandler(event:TextOperationEvent):void
{
	greenHS.value = uint(greenIT.text);
}

protected function blueIT_changeHandler(event:TextOperationEvent):void
{
	blueHS.value = uint(blueIT.text);
}





private var _imageList:Array;
private var _count:int;
private var _rectList:Array;
private var _imgList:Array;

/**
 * 选择了 根文件夹
 * @param event
 */
private function rootDirectory_selectHandler(event:Event):void
{
	var arr:Array = _rootDirectory.getDirectoryListing();
	_count = arr.length;
	_imageList = [];
	saveBtn.enabled = false;
	
	loadImage();
}


private function loadImage():void
{
	var arr:Array = _rootDirectory.getDirectoryListing();
	if(_imageList.length < arr.length) {
		var file:File = arr[_imageList.length];
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, image_completeHandler);
		loader.load(new URLRequest(file.url));
	}
}


private function image_completeHandler(event:Event):void
{
	_imageList.push(event.target.loader.content.bitmapData);
	if(_imageList.length < _count) {
		loadImage();
		return;
	}
	_rectList = [];
	_imgList = [];
	
	var i:int;
	var x:int;
	var y:int;
	var bitmapData:BitmapData;
	var rect:Rectangle;
	var color:uint;
	var red:uint;
	var green:uint;
	var blue:uint;
	var needTransparent:Boolean;
	var tRed:uint = uint(redIT.text);
	var tGreen:uint = uint(greenIT.text);
	var tBlue:uint = uint(blueIT.text);
	
	for(i = 0; i < _imageList.length; i++)
	{
		bitmapData = new BitmapData(_imageList[i].width, _imageList[i].height, true, 0);
		bitmapData.draw(_imageList[i]);
		_imgList.push(bitmapData);
		
		for(x = 0; x < bitmapData.width; x++) {
			for(y = 0; y < bitmapData.height; y++) {
				color = bitmapData.getPixel32(x, y);
				red = color >>> 16 & 0xFF;
				green = color >>> 8 & 0xFF;
				blue = color & 0xFF;
				
				if(colorGroup.selectedValue == "red")
					needTransparent = (red > tRed) && (green < tGreen) && (blue < tBlue);
				else if(colorGroup.selectedValue == "green")
					needTransparent = (red < tRed) && (green > tGreen) && (blue < tBlue);
				else
					needTransparent = (red < tRed) && (green < tGreen) && (blue > tBlue);
				if(needTransparent) bitmapData.setPixel32(x, y, 0);
			}
		}
		
		rect = new Rectangle();
		_rectList.push(rect);
		for(x = 0; x < bitmapData.width; x++) {
			for(y = 0; y < bitmapData.height; y++) {
				if(bitmapData.getPixel32(x, y) != 0) {
					rect.x = x;
					x = bitmapData.width;
					break;
				}
			}
		}
		for(x = bitmapData.width - 1; x > 0; x--) {
			for(y = 0; y < bitmapData.height; y++) {
				if(bitmapData.getPixel32(x, y) != 0) {
					rect.width = x;
					x = 0;
					break;
				}
			}
		}
		
		for(y = 0; y < bitmapData.height; y++) {
			for(x = 0; x < bitmapData.width; x++) {
				if(bitmapData.getPixel32(x, y) != 0) {
					rect.y = y;
					y = bitmapData.height;
					break;
				}
			}
		}
		for(y = bitmapData.height - 1; y > 0; y--) {
			for(x = 0; x < bitmapData.width; x++) {
				if(bitmapData.getPixel32(x, y) != 0) {
					rect.height = y;
					y = 0;
					break;
				}
			}
		}
	}
	
	saveBtn.enabled = true;
}


private var _file:File;
protected function saveBtn_clickHandler(event:MouseEvent):void
{
	if(_file == null) {
		_file = new File();
		_file.addEventListener(Event.SELECT, fileSelectHandler);
	}
	_file.browseForDirectory("要保存到哪？");
}

private function fileSelectHandler(event:Event):void
{
	var rect:Rectangle = new Rectangle(_rectList[1].x, _rectList[1].y, _rectList[1].width, _rectList[1].height);
	var i:int;
	for(i = 1; i < _rectList.length; i++) {
		if(_rectList[i].x < rect.x) rect.x = _rectList[i].x;
		if(_rectList[i].y < rect.y) rect.y = _rectList[i].y;
		if(_rectList[i].width > rect.width) rect.width = _rectList[i].width;
		if(_rectList[i].height > rect.height) rect.height = _rectList[i].height;
	}
	
	
	for(i = 0; i < _imgList.length; i++)
	{
		var newBMD:BitmapData = new BitmapData(rect.width - rect.x, rect.height - rect.y, true, 0);
		newBMD.draw(_imgList[i], new Matrix(1, 0, 0, 1, -rect.x, -rect.y));
		
		var file:File = new File(_file.nativePath + "\\" + i + ".png");
		var fs:FileStream = new FileStream();
		fs.open(file, FileMode.WRITE);
		fs.writeBytes(PNGEncoder.encode(newBMD));
		fs.close();
	}
	Alert.show("储存完毕！");
}






