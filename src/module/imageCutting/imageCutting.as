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
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import imageCutting.CenterPoint;
import imageCutting.MainBG;

import lolo.core.BitmapMovieClip;
import lolo.core.BitmapMovieClipData;
import lolo.events.BitmapMovieClipEvent;

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




/**
 * 初始化
 * @param event
 */
private function creationCompleteHandler(event:FlexEvent):void
{
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
	_centerPoint.y = 230;
	_uic.addChild(_centerPoint);
	_centerPoint.addEventListener(MouseEvent.MOUSE_DOWN, centerPoint_mouseDownHandler);
	
	
	creatBmcInit();
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
	if(_bmc == null) return;
	_bmc.fps = int(fpsText.text);
	_fpsList[movieDDL.selectedItem.label] = _bmc.fps;
}

/**
 * 将帧频应用到所有动画
 * @param event
 */
protected function fpsToAllBtn_clickHandler(event:MouseEvent):void
{
	for(var movieName:String in _fpsList) {
		_fpsList[movieName] = int(fpsText.text);
	}
}



/**
 * 色调与滑条
 * @param event
 */
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






//////////////////////////////【其他】//////////////////////////////

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


