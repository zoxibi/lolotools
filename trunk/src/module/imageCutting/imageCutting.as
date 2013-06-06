import com.adobe.images.PNGEncoder;
import com.greensock.TweenMax;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.net.FileFilter;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import imageCutting.CenterPoint;
import imageCutting.MainBG;

import lolo.core.BitmapMovieClip;
import lolo.core.BitmapMovieClipData;
import lolo.events.BitmapMovieClipEvent;
import lolo.utils.AutoUtil;

import mx.collections.ArrayList;
import mx.controls.Alert;
import mx.core.UIComponent;
import mx.events.FlexEvent;

import spark.events.IndexChangeEvent;
import spark.events.TextOperationEvent;

/**注册点移动范围*/
private static const CENTER_POINT_RECT:Rectangle = new Rectangle(10, 10, 380, 380);
/**动画的画布面积*/
private static const CANVAS_RECT:Rectangle = new Rectangle(0, 0, 400, 400);

private var _uic:UIComponent;
private var _mcc:Sprite;

private var _centerPoint:Sprite;


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


/**
 * 初始化
 * @param event
 */
private function creationCompleteHandler(event:FlexEvent):void
{
	_rootDirectory = new File();
	_rootDirectory.addEventListener(Event.SELECT, rootDirectory_selectHandler);
	
	_uic = new UIComponent();
	_uic.x = 40;
	_uic.y = 40;
	this.addElementAt(_uic, 0);
	
	var mainBG:MainBG = new MainBG();
	_uic.addChild(mainBG);
	
	_mcc = new Sprite();
	_uic.addChild(_mcc);
	
	_centerPoint = new CenterPoint();
	_centerPoint.x = 200;
	_centerPoint.y = 300;
	_uic.addChild(_centerPoint);
	_centerPoint.addEventListener(MouseEvent.MOUSE_DOWN, centerPoint_mouseDownHandler);
	
	_bmpLoader = new Loader();
	_bmpLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadFrameCompleteHnalder);
}


/**
 * 注册点图标拖动实现
 */
private function centerPoint_mouseDownHandler(event:MouseEvent):void
{
	_centerPoint.startDrag(false, CENTER_POINT_RECT);
	this.stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
	this.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
}
private function stage_mouseMoveHandler(event:MouseEvent=null):void
{
	cpxText.text = _centerPoint.x.toString();
	cpyText.text = _centerPoint.y.toString();
	if(event) event.updateAfterEvent();
}
private function stage_mouseUpHandler(event:MouseEvent):void
{
	this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
	this.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
	_centerPoint.stopDrag();
}
private function cpInputText_changeHandler(event:TextOperationEvent):void
{
	var value:int = int(cpxText.text);
	if(value < CENTER_POINT_RECT.x) value = CENTER_POINT_RECT.x;
	else if(value > CENTER_POINT_RECT.width) value = CENTER_POINT_RECT.width;
	_centerPoint.x = value;
	
	value = int(cpyText.text);
	if(value < CENTER_POINT_RECT.y) value = CENTER_POINT_RECT.y;
	else if(value > CENTER_POINT_RECT.height) value = CENTER_POINT_RECT.height;
	_centerPoint.y = value;
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
		var aa:ByteArray = (_bmpLoader.content as Bitmap).bitmapData.getPixels(bmcDataRect);
		aa.position = 0;
		bmcData.setPixels(bmcDataRect, aa);
		_oMovieData[movieName].push(bmcData);
		readPB.setProgress(readPB.maximum - _bmpUrlList.length, readPB.maximum);
	}
	
	if(_bmpUrlList.length > 0) {
		_bmpLoader.load(new URLRequest(_bmpUrlList.shift()));
	}
	else {
		movieDDL_changeHandler();
	}
}


/**
 * 动画列表有选中
 * @param event
 */
protected function movieDDL_changeHandler(event:IndexChangeEvent=null):void
{
	if(_bmc != null) {
		_bmc.removeEventListener(BitmapMovieClipEvent.ENTER_FRAME, bmc_enterFrameHandler);
	}
	var fps:int = _fpsList[movieDDL.selectedItem.label];
	fpsText.text = fps.toString();
	_bmc = new BitmapMovieClip("", fps);
	_bmc.addEventListener(BitmapMovieClipEvent.ENTER_FRAME, bmc_enterFrameHandler);
	_bmc.frameList = _oMovieData[movieDDL.selectedItem.label];
	
	//将动画居中到画布显示
	_bmc.x = (CANVAS_RECT.width - _bmc.frameList[0].width) / 2 ;
	_bmc.y = (CANVAS_RECT.height - _bmc.frameList[0].height) / 2;
	addToCanvas(_bmc);
	
	playBtn_clickHandler();
}


/**
 * 动画帧刷新
 * @param event
 */
private function bmc_enterFrameHandler(event:BitmapMovieClipEvent):void
{
	frameText.text = _bmc.currentFrame + "/" + _bmc.totalFrames;
}

private function playBtn_clickHandler(event:MouseEvent=null):void
{
	//点击播放
	if(playBtn.label == ">" || event == null) {
		playBtn.label = "II";
		_bmc.play();
	}
	else {
		playBtn.label = ">";
		_bmc.stop();
	}
}

private function frameControlBtn_clickHandler(event:MouseEvent):void
{
	playBtn.label = ">";
	(event.target == prevFrameBtn) ? _bmc.prevFrame() : _bmc.nextFrame();
}

protected function fpsText_changeHandler(event:TextOperationEvent):void
{
	_bmc.fps = int(fpsText.text);
	_fpsList[movieDDL.selectedItem.label] = _bmc.fps;
}



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


/**正在保存的数据*/
private var _data:ByteArray;
/**正在保存的动画的index*/
private var _movieIndex:int;
/**正在保存的动画帧的index*/
private var _frameIndex:int;

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
	
	_data.writeShort(movieDDL.dataProvider.length);//写入动画数量
	
	//开始保存数据
	saveData();
}

private function saveData():void
{
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
	_data.writeBytes(bmcData.getPixels(rect));//写入图像数据
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
	var file:File = new File(directory.nativePath + "\\bitmapMovieClipData");
	var fs:FileStream = new FileStream();
	fs.open(file, FileMode.WRITE);
	fs.writeBytes(_data);
	fs.close();
	Alert.show("储存完毕！");
}





//////////////////////////////【导出传统MC】//////////////////////////////

private var _swfFile:File;
private var _swfLoader:Loader;
private var _loaderContext:LoaderContext;
private var _mcRect:Rectangle;
private var _mcPngList:Vector.<BitmapData>;
private var _mcPngSaveFile:File;

/**
 * 点击选择按钮
 * @param event
 */
protected function selectSwfBtn_clickHandler(event:MouseEvent):void
{
	swfMcText.editable = mcPreviewBtn.enabled = createMcPngBtn.enabled = saveMcPngBtn.enabled = false;
	
	if(_swfFile == null) {
		_swfFile = new File();
		_swfFile.addEventListener(Event.SELECT, swfFile_selectHandler);
		_swfFile.addEventListener(Event.COMPLETE, swfFile_completeHandler);
	}
	_swfFile.browseForOpen("请选择要提取动画的swf文件", [new FileFilter("SWF文件 *.swf", "*.swf")]);
}

private function swfFile_selectHandler(event:Event):void
{
	swfFileUrlText.text = _swfFile.url;
	_swfFile.load();
}

private function swfFile_completeHandler(event:Event):void
{
	if(_swfLoader == null) {
		_swfLoader = new Loader();
		_swfLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, swfLoadCompleteHandler);
		_loaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
		_loaderContext.allowCodeImport = true;
	}
	_swfLoader.loadBytes(_swfFile.data, _loaderContext);
}

private function swfLoadCompleteHandler(event:Event):void
{
	swfMcText.editable = mcPreviewBtn.enabled = true;
}

/**
 * 点击预览按钮
 * @param event
 */
protected function mcPreviewBtn_clickHandler(event:MouseEvent):void
{
	createMcPngBtn.enabled = saveMcPngBtn.enabled = false;
	
	var disObj:DisplayObject = AutoUtil.getInstance(swfMcText.text);
	if(disObj == null) {
		Alert.show("您填写的MC定义有误！");
	}
	else {
		createMcPngBtn.enabled = true;
		
		//提取动画的最大宽高和最小坐标
		_mcRect = disObj.getBounds(disObj);
		var mc:MovieClip = disObj as MovieClip;
		if(mc != null) {
			var r:Rectangle;
			for(var i:int = 0; i < mc.totalFrames; i++) {
				mc.gotoAndStop(i + 1);
				r = disObj.getBounds(mc);
				if(r.x < _mcRect.x) _mcRect.x = r.x;
				if(r.y < _mcRect.y) _mcRect.y = r.y;
				if(r.x > 0) r.width += r.x;
				if(r.y > 0) r.height += r.y;
				if(r.width > _mcRect.width) _mcRect.width = r.width;
				if(r.height > _mcRect.height) _mcRect.height = r.height;
			}
			mc.play();
		}
		//将动画居中到画布显示
		disObj.x = (CANVAS_RECT.width - _mcRect.width) / 2 - _mcRect.x;
		disObj.y = (CANVAS_RECT.height - _mcRect.height) / 2 - _mcRect.y;
		addToCanvas(disObj);
	}
}

/**
 * 点击将传统MC生成位图动画按钮
 * @param event
 */
protected function createMcPngBtn_clickHandler(event:MouseEvent):void
{
	swfMcText.editable = mcPreviewBtn.enabled = createMcPngBtn.enabled = saveMcPngBtn.enabled = false;
	var mc:MovieClip = _mcc.getChildAt(0) as MovieClip;
	if(mc != null) mc.gotoAndStop(1);
	_mcPngList = new Vector.<BitmapData>();
	if(swfMcRectCB.selected) {
		var w:int = int(swfMcWidthText.text);
		var h:int = int(swfMcHeightText.text);
		_mcRect = new Rectangle(
			Math.min(_mcRect.x, -(w / 2)), Math.min(_mcRect.y, -(h / 2)),
			Math.max(_mcRect.width, w), Math.max(_mcRect.height, h)
		);
	}
	createMcPngList();
}

private function createMcPngList():void
{
	var bitmapData:BitmapData = new BitmapData(_mcRect.width, _mcRect.height, true, 0);
	bitmapData.draw(_mcc.getChildAt(0), new Matrix(1, 0, 0, 1, -_mcRect.x, -_mcRect.y));
	_mcPngList.push(bitmapData);
	
	var mc:MovieClip = _mcc.getChildAt(0) as MovieClip;
	if(mc != null) {
		if(_mcPngList.length < mc.totalFrames) {
			mc.nextFrame();
			createMcPngPB.setProgress(_mcPngList.length / mc.totalFrames, 1);
			TweenMax.delayedCall(0.01, createMcPngList);
			return;
		}
	}
	
	createMcPngPB.setProgress(1, 1);
	swfMcText.editable = mcPreviewBtn.enabled = createMcPngBtn.enabled = saveMcPngBtn.enabled = true;
}

/**
 * 点击保存按钮
 * @param event
 */
protected function saveMcPngBtn_clickHandler(event:MouseEvent):void
{
	if(_mcPngSaveFile == null) {
		_mcPngSaveFile = new File();
		_mcPngSaveFile.addEventListener(Event.SELECT, mcPngSaveSelectHandler);
	}
	_mcPngSaveFile.browseForDirectory("要保存到哪？");
}

private function mcPngSaveSelectHandler(event:Event):void
{
	for(var i:int = 0; i < _mcPngList.length; i++) {
		var file:File = new File(_mcPngSaveFile.nativePath + "\\" + (i+1) + ".png");
		var fs:FileStream = new FileStream();
		fs.open(file, FileMode.WRITE);
		fs.writeBytes(PNGEncoder.encode(_mcPngList[i]));
		fs.close();
	}
	Alert.show("储存完毕！");
}

protected function swfMcRectCB_clickHandler(event:MouseEvent):void
{
	createMcPngBtn.enabled = saveMcPngBtn.enabled = false;
	swfMcWidthText.enabled = swfMcHeightText.enabled = swfMcRectCB.selected;
}




/**
 * 将一个显示对象添加到画布
 * @param disObj
 */
private function addToCanvas(disObj:DisplayObject):void
{
	while(_mcc.numChildren > 0) {
		var mc:MovieClip = _mcc.getChildAt(0) as MovieClip;
		if(mc != null) {
			mc.gotoAndStop(1);
		}
		else {
			var bmc:BitmapMovieClip = _mcc.getChildAt(0) as BitmapMovieClip;
			if(bmc != null) bmc.stop();
		}
		_mcc.removeChildAt(0);
	}
	_mcc.addChild(disObj);
}






private var _imageList:Array;
private var _count:int;
private var _rectList:Array;
private var _imgList:Array;

/**
 * 选择了 根文件夹
 * @param event
 */
//private function rootDirectory_selectHandler(event:Event):void
//{
//	var arr:Array = _rootDirectory.getDirectoryListing();
//	_count = arr.length;
//	_imageList = [];
//	saveBtn.enabled = false;
//	
//	loadImage();
//}


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
//protected function saveBtn_clickHandler(event:MouseEvent):void
//{
//	if(_file == null) {
//		_file = new File();
//		_file.addEventListener(Event.SELECT, fileSelectHandler);
//	}
//	_file.browseForDirectory("要保存到哪？");
//}

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






