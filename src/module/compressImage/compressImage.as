import com.adobe.images.JPGEncoder;
import com.adobe.images.PNGEncoder;
import com.greensock.TweenMax;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.FileFilter;
import flash.utils.ByteArray;
import flash.utils.getTimer;

import mx.events.FlexEvent;

import spark.events.TextOperationEvent;

/**用于打开文件或文件夹*/
private var _file:File;
/**打开状态[1:打开文件, 2:打开文件夹, 3:选择保存文件夹]*/
private var _fileType:int;
/**要压缩的文件列表*/
private var _fileList:Vector.<File>;
/**压缩完毕的文件列表{name, bytes}*/
private var _files:Array;

/**正在压缩的图像索引*/
private var _index:int;
/**临时加载图像文件*/
private var _imgLoader:Loader;
/**用于计算压缩耗时*/
private var _timeArr:Array;


/**
 * 初始化，入口
 * @param event
 */
protected function creationCompleteHandler(event:FlexEvent):void
{
	_file = new File();
	_file.addEventListener(Event.SELECT, fileSelectHandler);
	
	_imgLoader = new Loader();
	_imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imgLoader_completeHandler);
}



/**
 * 点击选择文件
 * @param event
 */
protected function fileBtn_clickHandler(event:MouseEvent):void
{
	_fileType = 1;
	_file.browseForOpen("请选择要压缩的图片", [new FileFilter("图片文件 *.jpg;*.jpeg;*.png", "*.jpg;*.jpeg;*.png")]);
}


/**
 * 点击选择文件夹
 * @param event
 */
protected function folderBtn_clickHandler(event:MouseEvent):void
{
	_fileType = 2;
	_file.browseForDirectory("请选择包含要压缩图像文件的文件夹");
}


/**
 * 选中了文件或者文件夹
 * @param event
 */
private function fileSelectHandler(event:Event):void
{
	var i:int;
	var file:File;
	
	//保存到本地
	if(_fileType == 3) {
		for(i = 0; i < _files.length; i++) {
			file = new File(_file.nativePath + "\\" + _files[i].name);
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeBytes(_files[i].bytes);
			fs.close();
		}
		return;
	}
	
	
	_fileList = new Vector.<File>();
	_files = [];
	saveBtn.enabled = false;
	
	if(_fileType == 1) {
		fileText.text = _file.name;
		_file.load();
		_fileList.push(_file);
	}
	else {
		fileText.text = _file.nativePath;
		var arr:Array = _file.getDirectoryListing();
		for(i = 0; i < arr.length; i++) {
			file = arr[i];
			if(file.extension == null) continue;
			var extension:String = file.extension.toLocaleLowerCase();
			if(extension == "jpg" || extension == "jpeg" || extension == "png") {
				file.load();
				_fileList.push(file);
			}
		}
	}
	
	startBtn.enabled = (_fileList.length > 0);
}



/**
 * 开始压缩
 * @param event
 */
protected function startBtn_clickHandler(event:MouseEvent):void
{
	logText.text = "==============开始压缩==============";
	
	progressBar.label = "压缩进度 0%";
	startBtn.enabled = saveBtn.enabled = false;
	_timeArr = [];
	_files = [];
	_index = -1;
	loadNextImage();
}

private function loadNextImage():void
{
	_index++;
	//压缩完毕
	if(_index >= _fileList.length) {
		saveBtn.enabled = true;
		var time:int;
		for(var i:int=0; i < _timeArr.length; i++) time += _timeArr[i];
		logText.appendText("\n共耗时：" + (int(time / 100) / 10) + "s");
		logText.appendText("\n==============压缩完毕==============");
	}
	else {
		_timeArr.push(getTimer());
		var file:File = _fileList[_index];
		logText.appendText("\n正在压缩文件【" + file.name + "】...");
		_imgLoader.loadBytes(file.data);
	}
}

private function imgLoader_completeHandler(event:Event):void
{
	TweenMax.killDelayedCallsTo(loadNextImage);
	
	var encodedImage:ByteArray;
	var imageData:BitmapData = (_imgLoader.content as Bitmap).bitmapData;
	if (_fileList[_index].extension.toLocaleLowerCase() == "png") {
		encodedImage = PNGEncoder.encode(imageData);
	}
	else {
		encodedImage = new JPGEncoder(qualityHS.value).encode(imageData);
	}
	var file:File = _fileList[_index];
	_files.push({name:file.name, bytes:encodedImage});
	
	var current:int = _index + 1;
	progressBar.setProgress(current, _fileList.length);
	progressBar.label = "压缩进度 " + int(current / _fileList.length * 100) + "%";
	_timeArr[_timeArr.length - 1] = getTimer() - _timeArr[_timeArr.length - 1];
	logText.appendText("\n　　压缩文件【" + file.name + "】完成，耗时：" +  (int(_timeArr[_timeArr.length - 1] / 100) / 10) + "s");
	
	TweenMax.delayedCall(0.1, loadNextImage);
}



/**
 * 保存本地
 * @param event
 */
protected function saveBtn_clickHandler(event:MouseEvent):void
{
	_fileType = 3;
	_file.browseForDirectory("要保存到哪？");
}





protected function qualityHS_changeHandler(event:Event):void
{
	qualityText.text = qualityHS.value.toString();
}

protected function qualityText_focusOutHandler(event:FocusEvent):void
{
	var value:int = int(qualityText.text);
	if(value < 50) value = 50;
	else if(value > 95) value = 95;
	qualityText.text = value.toString();
}

protected function qualityText_changeHandler(event:TextOperationEvent=null):void
{
	qualityHS.value = int(qualityText.text);
}