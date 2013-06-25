import com.adobe.images.PNGEncoder;
import com.greensock.TweenMax;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.net.FileFilter;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;

import lolo.utils.AutoUtil;

import mx.controls.Alert;




//////////////////////////////【将swf中的mc导出成位图序列】//////////////////////////////

private var _emcSwfFile:File;
private var _emcSwfLoader:Loader;
private var _emcLoaderContext:LoaderContext;
private var _emcRect:Rectangle;
private var _emcPngList:Vector.<BitmapData>;
private var _emcPngSaveFile:File;



/**
 * 点击选择按钮
 * @param event
 */
protected function emcSelectSwfBtn_clickHandler(event:MouseEvent):void
{
	emcMcDefText.editable = emcPreviewBtn.enabled = emcBtn.enabled = emcSaveBtn.enabled = false;
	
	if(_emcSwfFile == null) {
		_emcSwfFile = new File();
		_emcSwfFile.addEventListener(Event.SELECT, swfFile_selectHandler);
		_emcSwfFile.addEventListener(Event.COMPLETE, swfFile_completeHandler);
	}
	_emcSwfFile.browseForOpen("请选择要提取动画的swf文件", [new FileFilter("SWF文件 *.swf", "*.swf")]);
}

private function swfFile_selectHandler(event:Event):void
{
	emcSwfUrlText.text = _emcSwfFile.url;
	_emcSwfFile.load();
}

private function swfFile_completeHandler(event:Event):void
{
	if(_emcSwfLoader == null) {
		_emcSwfLoader = new Loader();
		_emcSwfLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, swfLoadCompleteHandler);
		_emcLoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
		_emcLoaderContext.allowCodeImport = true;
	}
	_emcSwfLoader.loadBytes(_emcSwfFile.data, _emcLoaderContext);
}

private function swfLoadCompleteHandler(event:Event):void
{
	emcMcDefText.editable = emcPreviewBtn.enabled = true;
}



/**
 * 点击预览按钮
 * @param event
 */
protected function emcPreviewBtn_clickHandler(event:MouseEvent):void
{
	emcBtn.enabled = emcSaveBtn.enabled = false;
	
	var disObj:DisplayObject = AutoUtil.getInstance(emcMcDefText.text);
	if(disObj == null) {
		Alert.show("您填写的MC定义有误！");
	}
	else {
		emcBtn.enabled = true;
		
		//提取动画的最大宽高和最小坐标
		_emcRect = disObj.getBounds(disObj);
		var mc:MovieClip = disObj as MovieClip;
		if(mc != null) {
			var r:Rectangle;
			for(var i:int = 0; i < mc.totalFrames; i++) {
				mc.gotoAndStop(i + 1);
				r = disObj.getBounds(mc);
				if(r.x < _emcRect.x) _emcRect.x = r.x;
				if(r.y < _emcRect.y) _emcRect.y = r.y;
				if(r.x > 0) r.width += r.x;
				if(r.y > 0) r.height += r.y;
				if(r.width > _emcRect.width) _emcRect.width = r.width;
				if(r.height > _emcRect.height) _emcRect.height = r.height;
			}
			mc.play();
		}
		//将动画居中到画布显示
		disObj.x = (CANVAS_RECT.width - _emcRect.width) / 2 - _emcRect.x;
		disObj.y = (CANVAS_RECT.height - _emcRect.height) / 2 - _emcRect.y;
		addToCanvas(disObj);
	}
}



/**
 * 点击将传统MC生成位图动画按钮
 * @param event
 */
protected function emcBtn_clickHandler(event:MouseEvent):void
{
	emcMcDefText.editable = emcPreviewBtn.enabled = emcBtn.enabled = emcSaveBtn.enabled = false;
	var mc:MovieClip = _mcc.getChildAt(0) as MovieClip;
	if(mc != null) mc.gotoAndStop(1);
	_emcPngList = new Vector.<BitmapData>();
	if(emcMcRectCB.selected) {
		var w:int = int(emcWidthText.text);
		var h:int = int(emcHeightText.text);
		_emcRect = new Rectangle(
			Math.min(_emcRect.x, -(w / 2)), Math.min(_emcRect.y, -(h / 2)),
			Math.max(_emcRect.width, w), Math.max(_emcRect.height, h)
		);
	}
	createMcPngList();
}

private function createMcPngList():void
{
	var bitmapData:BitmapData = new BitmapData(_emcRect.width, _emcRect.height, true, 0);
	bitmapData.draw(_mcc.getChildAt(0), new Matrix(1, 0, 0, 1, -_emcRect.x, -_emcRect.y));
	_emcPngList.push(bitmapData);
	
	var mc:MovieClip = _mcc.getChildAt(0) as MovieClip;
	if(mc != null) {
		if(_emcPngList.length < mc.totalFrames) {
			mc.nextFrame();
			emcPB.setProgress(_emcPngList.length / mc.totalFrames, 1);
			TweenMax.delayedCall(0.01, createMcPngList);
			return;
		}
	}
	
	emcPB.setProgress(1, 1);
	emcMcDefText.editable = emcPreviewBtn.enabled = emcBtn.enabled = emcSaveBtn.enabled = true;
}



/**
 * 点击保存按钮
 * @param event
 */
protected function emcSaveBtn_clickHandler(event:MouseEvent):void
{
	if(_emcPngSaveFile == null) {
		_emcPngSaveFile = new File();
		_emcPngSaveFile.addEventListener(Event.SELECT, mcPngSaveSelectHandler);
	}
	_emcPngSaveFile.browseForDirectory("要保存到哪？");
}

private function mcPngSaveSelectHandler(event:Event):void
{
	for(var i:int = 0; i < _emcPngList.length; i++) {
		var file:File = new File(_emcPngSaveFile.nativePath + "\\" + (i+1) + ".png");
		var fs:FileStream = new FileStream();
		fs.open(file, FileMode.WRITE);
		fs.writeBytes(PNGEncoder.encode(_emcPngList[i]));
		fs.close();
	}
	Alert.show("储存完毕！");
}



/**
 * 选择或取消，限制导出动画的宽高
 * @param event
 */
protected function emcMcRectCB_clickHandler(event:MouseEvent):void
{
	emcBtn.enabled = emcSaveBtn.enabled = false;
	emcWidthText.enabled = emcHeightText.enabled = emcMcRectCB.selected;
}