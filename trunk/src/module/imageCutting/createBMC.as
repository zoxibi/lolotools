import com.greensock.TweenMax;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import lolo.core.BitmapMovieClip;
import lolo.core.BitmapMovieClipData;

import mx.collections.ArrayList;
import mx.controls.Alert;

/**目标根文件夹*/
private var _rootDirectory:File;
/**原始动画图像列表*/
private var _oMovieData:Dictionary;
/**动画对应的帧频*/
private var _fpsList:Dictionary;
/**需要加载的图像url列表*/
private var _bmpUrlList:Array;
/**图像加载器*/
private var _bmpLoader:Loader;
/**当前显示的动画*/
private var _bmc:BitmapMovieClip;



/**正在保存的数据*/
private var _data:ByteArray;
/**正在保存的动画的index*/
private var _movieIndex:int;
/**正在保存的动画帧的index*/
private var _frameIndex:int;




/**
 * 初始化
 */
private function creatBmcInit():void
{
	_rootDirectory = new File();
	_rootDirectory.addEventListener(Event.SELECT, rootDirectory_selectHandler);
	
	_bmpLoader = new Loader();
	_bmpLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadFrameCompleteHnalder);
}


/**
 * 点击选择根文件夹按钮
 * @param event
 */
protected function selectRootDirectoryBtn_clickHandler(event:MouseEvent):void
{
	_rootDirectory.browseForDirectory("请选择包含序列图像的根文件夹");
}

private function rootDirectory_selectHandler(event:Event):void
{
	savePB.setProgress(savePB.value + 1, savePB.maximum);
	_bmpUrlList = [];
	_oMovieData = new Dictionary();
	_fpsList = new Dictionary();
	var movieList:Array = _rootDirectory.getDirectoryListing();//动画文件夹列表
	
	for(var i:int = 0; i < movieList.length; i++)
	{
		var movieDirectory:File = movieList[i];//帧图像文件夹
		if(!movieDirectory.isDirectory) continue;//必须是文件夹
		var frameFileList:Array = movieDirectory.getDirectoryListing();//帧图像文件列表
		
		for(var n:int = 0; n < frameFileList.length; n++)
		{
			var frameFile:File = frameFileList[n];
			if(frameFile.extension == null) {
				trace("[" + frameFile.url + "] 不是有效的图像文件（后缀有误）");
				continue;
			}
			var extension:String = frameFile.extension.toLocaleLowerCase();
			if(extension != "jpg" && extension != "jpeg" && extension != "png") {
				trace("[" + frameFile.url + "] 不是有效的图像文件");
				continue;
			}
			_bmpUrlList.push(frameFile.url);
		}
	}
	
	movieDDL.dataProvider = new ArrayList();
	readPB.maximum = _bmpUrlList.length;
	readPB.setProgress(0, _bmpUrlList.length);
	loadFrameCompleteHnalder();
	
	this.enabled = false;
}


/**
 * 加载帧图片完成
 * @param event
 */
private function loadFrameCompleteHnalder(event:Event=null):void
{
	if(event != null) {
		var arr:Array = _bmpLoader.contentLoaderInfo.url.split("/");
		var movieName:String = arr[arr.length - 3] + "." + arr[arr.length - 2];
		if(_oMovieData[movieName] == null) {
			_oMovieData[movieName] = new Vector.<BitmapMovieClipData>();
			_fpsList[movieName] = int(fpsText.text);
			movieDDL.dataProvider.addItem({ label:movieName });
			movieDDL.selectedIndex = 0;
		}
		
		var bmcDataRect:Rectangle = new Rectangle(0, 0, _bmpLoader.content.width, _bmpLoader.content.height);
		var bmcData:BitmapMovieClipData = new BitmapMovieClipData(bmcDataRect.width, bmcDataRect.height);
		var bArr:ByteArray = (_bmpLoader.content as Bitmap).bitmapData.getPixels(bmcDataRect);
		bArr.position = 0;
		bmcData.setPixels(bmcDataRect, bArr);
		_oMovieData[movieName].push(bmcData);
		readPB.setProgress(readPB.maximum - _bmpUrlList.length, readPB.maximum);
	}
	
	if(_bmpUrlList.length > 0) {
		_bmpLoader.load(new URLRequest(_bmpUrlList.shift()));
	}
	else {
		movieDDL_changeHandler();
		this.enabled = true;
	}
}




/**
 * 点击保存按钮
 * @param event
 */
protected function saveBtn_clickHandler(event:MouseEvent):void
{
	_data = new ByteArray();
	_movieIndex = 0;
	_frameIndex = 0;
	
	savePB.maximum = 0;
	for(var i:int=0; i < movieDDL.dataProvider.length; i++) {
		savePB.maximum += _oMovieData[movieDDL.dataProvider.getItemAt(i).label].length;
	}
	savePB.setProgress(0, savePB.maximum);
	
	_data.writeShort(movieDDL.dataProvider.length);//写入动画总数量
	
	//开始保存数据
	saveData();
}

private function saveData():void
{
	this.enabled = false;
	savePB.setProgress(savePB.value + 1, savePB.maximum);
	
	var movieName:String = movieDDL.dataProvider.getItemAt(_movieIndex).label;
	//第一帧
	if(_frameIndex == 0) {
		_data.writeUTF(movieName);//写入当前动画名称
		_data.writeShort(_oMovieData[movieName].length);//写入当前动画的总帧数
		_data.writeShort(_fpsList[movieName]);//写入当前动画的帧频
	}
	
	//得到动画的最小不透明区域
	var bmcData:BitmapMovieClipData = _oMovieData[movieName][_frameIndex];
	var rect:Rectangle = new Rectangle();
	var x:int;
	var y:int;
	for(x = 0; x < bmcData.width; x++) {
		for(y = 0; y < bmcData.height; y++) {
			if(bmcData.getPixel32(x, y) != 0) {
				rect.x = x;
				x = bmcData.width;
				break;
			}
		}
	}
	for(x = bmcData.width - 1; x > 0; x--) {
		for(y = 0; y < bmcData.height; y++) {
			if(bmcData.getPixel32(x, y) != 0) {
				rect.width = x - rect.x;
				x = 0;
				break;
			}
		}
	}
	for(y = 0; y < bmcData.height; y++) {
		for(x = 0; x < bmcData.width; x++) {
			if(bmcData.getPixel32(x, y) != 0) {
				rect.y = y;
				y = bmcData.height;
				break;
			}
		}
	}
	for(y = bmcData.height - 1; y > 0; y--) {
		for(x = 0; x < bmcData.width; x++) {
			if(bmcData.getPixel32(x, y) != 0) {
				rect.height = y - rect.y;
				y = 0;
				break;
			}
		}
	}
	
	_data.writeShort(rect.width);//写入图像宽
	_data.writeShort(rect.height);//写入图像高
	_data.writeShort(_centerPoint.x - rect.x - (CANVAS_RECT.width - bmcData.width) / 2);//写入图像x偏移
	_data.writeShort(_centerPoint.y - rect.y - (CANVAS_RECT.height - bmcData.height) / 2);//写入图像y偏移
	var bmcByteArray:ByteArray = bmcData.getPixels(rect);
	_data.writeInt(bmcByteArray.length);//写入图像数据大小
	_data.writeBytes(bmcByteArray);//写入图像数据
	
	_frameIndex++;
	//这个动画写完了
	if(_frameIndex == _oMovieData[movieName].length) {
		_frameIndex = 0;
		_movieIndex++;
		//所有动画都写完了
		if(_movieIndex == movieDDL.dataProvider.length)
		{
			var directory:File = new File();
			directory.addEventListener(Event.SELECT, saveDataDirectory_selectHandler);
			directory.addEventListener(Event.CANCEL, saveDataDirectory_cancelHandler);
			directory.browseForDirectory("要保存到哪？");
			return;
		}
	}
	
	TweenMax.delayedCall(0.01, saveData);
}

private function saveDataDirectory_selectHandler(event:Event):void
{
	var directory:File = event.target as File;
	directory.removeEventListener(Event.SELECT, saveDataDirectory_selectHandler);
	
	_data.compress();
	var arr:Array = movieDDL.dataProvider.getItemAt(0).label.split(".");
	var file:File = new File(directory.nativePath + "\\" + arr[0]);
	var fs:FileStream = new FileStream();
	fs.open(file, FileMode.WRITE);
	fs.writeBytes(_data);
	fs.close();
	
	this.enabled = true;
	Alert.show("储存完毕！");
}

private function saveDataDirectory_cancelHandler(event:Event):void
{
	this.enabled = true;
}

