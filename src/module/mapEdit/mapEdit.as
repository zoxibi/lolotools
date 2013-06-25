import com.adobe.images.JPGEncoder;
import com.adobe.images.PNGEncoder;
import com.greensock.TweenMax;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.filters.BlurFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.ui.Mouse;
import flash.ui.MouseCursor;
import flash.utils.ByteArray;

import lolo.rpg.RpgUtil;
import lolo.utils.zip.ZipReader;
import lolo.utils.zip.ZipWriter;

import module.mapEdit.Tile;

import mx.collections.ArrayCollection;
import mx.containers.ViewStack;
import mx.controls.Alert;
import mx.core.UIComponent;
import mx.events.CloseEvent;
import mx.events.FlexEvent;

import spark.components.List;
import spark.events.IndexChangeEvent;


[Bindable]
[Embed(source="assets/images/icons/Arrow.png")]
public var Arrow:Class;
[Bindable]
[Embed(source="assets/images/icons/Hand.png")]
public var Hand:Class;
[Bindable]
[Embed(source="assets/images/icons/Layer.png")]
public var Layer:Class;

[Bindable]
private var _coverLayerData:ArrayCollection = new ArrayCollection();
[Bindable]
private var _bgLayerData:ArrayCollection = new ArrayCollection();

private const CONTAINER_WIDTH:uint = 780;
private const CONTAINER_HEIGHT:uint = 540;
private const CHUNK_WIDTH:uint = 300;
private const CHUNK_HEIGHT:uint = 200;
private const THUMBNAILS_RECT:Rectangle = new Rectangle(0, 0, 600, 400);

private var _uic:UIComponent;
private var _container:Sprite;
private var _drawTarget:Sprite;
private var _coverC:Sprite;
private var _bgC:Sprite;
private var _tileC:Sprite;
private var _saveFile:File;

private var _imgFile:File;
private var _imgLoader:Loader;
private var _sourceFile:File;

private var _isSpaceHand:Boolean;
private var _autoIndex:int = 0;

private var _layerPanelIsOpen:Boolean = true;




/**
 * 初始化，入口
 * @param event
 */
protected function creationCompleteHandler(event:FlexEvent):void
{
	layerA.selectedIndex = 1;
	
	_uic = new UIComponent();
	_uic.y = 40;
	_uic.graphics.beginFill(0x666666);
	_uic.graphics.drawRect(0, 0, CONTAINER_WIDTH, CONTAINER_HEIGHT);
	_uic.graphics.beginFill(0xFFFFFF);
	_uic.graphics.drawRect(1, 1, CONTAINER_WIDTH - 2, CONTAINER_HEIGHT - 2);
	_uic.graphics.endFill();
	this.addElement(_uic);
	
	_container = new Sprite();
	_uic.addChild(_container);
	_drawTarget = new Sprite();
	_container.addChild(_drawTarget);
	
	_bgC = new Sprite();
	_drawTarget.addChild(_bgC);
	_coverC = new Sprite();
	_drawTarget.addChild(_coverC);
	
	_tileC = new Sprite();
	_container.addChild(_tileC);
	
	var mask:Shape = new Shape();
	mask.graphics.beginFill(0);
	mask.graphics.drawRect(0, 0, CONTAINER_WIDTH, CONTAINER_HEIGHT);
	mask.graphics.endFill();
	_uic.addChild(mask);
	_container.mask = mask;
	
	this.addElement(layerPanel);
	
	this.stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
	this.stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
	
	_container.addEventListener(MouseEvent.MOUSE_DOWN, container_mouseDownHandler);
	_container.addEventListener(MouseEvent.MOUSE_OVER, container_mouseOverHandler);
	_container.addEventListener(MouseEvent.MOUSE_OUT, container_mouseOutHandler);
	this.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseDownHandler);
	
	_tileC.addEventListener(MouseEvent.MOUSE_DOWN, tileC_mouseHandler);
	_tileC.addEventListener(MouseEvent.MOUSE_MOVE, tileC_mouseHandler);
	
	_imgFile = new File();
	_imgFile.addEventListener(Event.SELECT, imgFile_selectHandler);
	_imgLoader = new Loader();
	_imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imgLoader_completeHandler);
	
	_sourceFile = new File();
	_sourceFile.addEventListener(Event.SELECT, sourceFile_selectHandler);
	_sourceFile.addEventListener(Event.COMPLETE, sourceFile_completeHandler);
}



protected function tileCB_changeHandler(event:Event=null):void
{
	_tileC.visible = tileCB.selected;
}

protected function pointCB_changeHandler(event:Event=null):void
{
	for(var i:int=0; i < _tileC.numChildren; i++) {
		(_tileC.getChildAt(i) as Tile).isShowNO = pointCB.selected;
	}
}


/**
 * 鼠标点击区块
 * @param event
 */
private function tileC_mouseHandler(event:MouseEvent):void
{
	if(viewBB.selectedItem.value == "hand" || !event.buttonDown) return;
	var p:Point = RpgUtil.getTilePoint(new Point(_tileC.mouseX, _tileC.mouseY), int(tWidthText.text), int(tHeightText.text));
	var tile:Tile = getTile(p.x, p.y);
	if(tile != null) {
		tile.canPass = !passCB.selected;
		tile.isWater = waterCB.selected;
	}
}



/**
 * 根据x和y，获取一个区块
 * @param x
 * @param y
 * @return 
 */
private function getTile(x:int, y:int):Tile
{
	return _tileC.getChildByName("t" + x + "_" + y) as Tile;
}

private function get hTileCount():int
{
	return _bgC.width / int(tWidthText.text);
}
private function get vTileCount():int
{
	return int(_bgC.height / int(tHeightText.text)) * 2 - 1
}



private var _lastviewBBSelectedIndex:int;
/**
 * 按下键盘
 * @param event
 */
private function stage_keyDownHandler(event:KeyboardEvent):void
{
	if((this.parent.parent as ViewStack).selectedChild != this.parent) return;
	if(event.keyCode == 32) {//空格
		if(viewBB.selectedItem.value == "arrow") {
			_isSpaceHand = true;
			_lastviewBBSelectedIndex = viewBB.selectedIndex;
			viewBB.selectedIndex = 1;
			Mouse.cursor = MouseCursor.HAND;
		}
	}
}

private function stage_keyUpHandler(event:KeyboardEvent):void
{
	if((this.parent.parent as ViewStack).selectedChild != this.parent) return;
	if(event.keyCode == 32) {//空格
		if(_isSpaceHand) {
			_isSpaceHand = false;
			Mouse.cursor = MouseCursor.ARROW;
			viewBB.selectedIndex = _lastviewBBSelectedIndex;
		}
	}
	
	else if(event.keyCode == 81) {
		tileCB.selected = !tileCB.selected;
		tileCB_changeHandler();
	}
	else if(event.keyCode == 87) {
		pointCB.selected = !pointCB.selected;
		pointCB_changeHandler();
	}
	
	else if(event.keyCode == 65) waterCB.selected = !waterCB.selected;
	else if(event.keyCode == 83) passCB.selected = !passCB.selected;
	
	else if(event.keyCode == 90) viewBB.selectedIndex = 0;
	else if(event.keyCode == 88) viewBB.selectedIndex = 1;
	else if(event.keyCode == 67) viewBB.selectedIndex = 2;
	
	else if(event.keyCode == 17) openOrCloseLayerBtn_clickHandler();
	
	viewBB_changeHandler();
}



/**
 * 点击背景容器
 * @param event
 */
private function container_mouseDownHandler(event:MouseEvent):void
{
	//手型，拖动
	if(viewBB.selectedItem.value == "hand") {
		var rect:Rectangle = new Rectangle(
			-_container.width + CONTAINER_WIDTH,
			-_container.height + CONTAINER_HEIGHT,
			_container.width - CONTAINER_WIDTH,
			_container.height - CONTAINER_HEIGHT
		)
		_container.startDrag(false, rect);
	}
}

private function stage_mouseDownHandler(event:MouseEvent):void
{
	_container.stopDrag();
}

private function container_mouseOverHandler(event:MouseEvent):void
{
	Mouse.cursor = viewBB.selectedItem.value;
}
private function container_mouseOutHandler(event:MouseEvent):void
{
	Mouse.cursor = MouseCursor.ARROW;
}



/**
 * 选择类型有改变
 * @param event
 */
protected function viewBB_changeHandler(event:IndexChangeEvent=null):void
{
	_tileC.mouseEnabled = _tileC.mouseChildren = (viewBB.selectedIndex != 2);
}



/**
 * 点击保存按钮
 * @param event
 */
protected function saveBtn_clickHandler(event:MouseEvent):void
{
	if(_saveFile == null) {
		_saveFile = new File();
		_saveFile.addEventListener(Event.SELECT, saveFile_selectHandler);
	}
	_saveFile.browseForDirectory("要保存到哪？");
}

private function saveFile_selectHandler(event:Event):void
{
	file = new File(_saveFile.nativePath);
	file.deleteDirectory(true);
	
	
	//区块和配置信息
	var sourceData:ZipWriter = new ZipWriter();
	var mapData:ByteArray = new ByteArray();
	var tWidth:int = getTile(0, 0).tileWidth;
	var tHeight:int = getTile(0, 0).tileHeight;
	var v:int = vTileCount;
	var h:int = hTileCount;
	var arr:Array = [];
	var x:int;
	var y:int;
	var file:File;
	var fs:FileStream;
	for(y = 0; y < v; y++) {
		arr[y] = [];
		for(x = 0; x < h; x++) {
			var tile:Tile = getTile(x, y);
			arr[y][x] = { canPass:tile.canPass, isWater:tile.isWater };
		}
	}
	var mapInfo:Object = {
		mapWidth:_bgC.width, mapHeight:_bgC.height,
		tileWidth:tWidth, tileHeight:tHeight,
		chunkWidth:CHUNK_WIDTH, chunkHeight:CHUNK_HEIGHT,
		hTileCount:h, vTileCount:v,
		data:arr
	}
	
	
	//保存图块
	v = Math.ceil(_bgC.height / CHUNK_HEIGHT);
	h = Math.ceil(_bgC.width / CHUNK_WIDTH);
	var width:int;
	var height:int;
	var bitmapData:BitmapData;
	var jpg:JPGEncoder = new JPGEncoder(80);
	for(y = 0; y < v; y++) {
		height = Math.min(_bgC.height - y * CHUNK_HEIGHT, CHUNK_HEIGHT);
		for(x = 0; x < h; x++) {
			width = Math.min(_bgC.width - x * CHUNK_WIDTH, CHUNK_WIDTH);
			bitmapData = new BitmapData(width, height);
			bitmapData.draw(_drawTarget, new Matrix(1, 0, 0, 1, -CHUNK_WIDTH * x, -CHUNK_HEIGHT * y));
			
			file = new File(_saveFile.nativePath + "\\chunks\\" + x + "_" + y + ".jpg");
			fs = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeBytes(jpg.encode(bitmapData));
			fs.close();
		}
	}
	
	mapInfo.hChunkCount = h;
	mapInfo.vChunkCount = v;
	
	
	//保存缩略图
	var scale:Number = Math.min(THUMBNAILS_RECT.width / _bgC.width, THUMBNAILS_RECT.height / _bgC.height);
	bitmapData = new BitmapData(_bgC.width * scale, _bgC.height * scale);
	var matrix:Matrix = new Matrix();
	matrix.scale(scale, scale);
	bitmapData.draw(_drawTarget, matrix);
	bitmapData.applyFilter(bitmapData, new Rectangle(0,0,bitmapData.width,bitmapData.height), new Point(), new BlurFilter(1.1, 1.1));
	
	file = new File(_saveFile.nativePath + "\\thumbnails.jpg");
	fs = new FileStream();
	fs.open(file, FileMode.WRITE);
	fs.writeBytes(jpg.encode(bitmapData));
	fs.close();
	
	mapInfo.thumbnailsScale = scale;
	
	
	//保存遮挡物
	var i:int = _coverLayerData.length - 1;
	var layer:Sprite;
	var pngData:ByteArray;
	mapInfo.covers = [];
	for(;i >= 0; i--) {
		layer = _coverLayerData.getItemAt(i).layer;
		bitmapData = new BitmapData(layer.width, layer.height, true, 0);
		bitmapData.draw(layer);
		pngData = PNGEncoder.encode(bitmapData);
		
		file = new File(_saveFile.nativePath + "\\covers\\" + i +".png");
		fs = new FileStream();
		fs.open(file, FileMode.WRITE);
		fs.writeBytes(pngData);
		fs.close();
		
		sourceData.addFile("cover" + i +".png", pngData);//保存到源文件里
		
		mapInfo.covers.push({id:i, point:new Point(layer.x, layer.y)});
	}
	
	
	//保存区块和配置信息
	mapData.writeObject(mapInfo);
	mapData.compress();
	file = new File(_saveFile.nativePath + "\\mapData");
	fs = new FileStream();
	fs.open(file, FileMode.WRITE);
	fs.writeBytes(mapData);
	fs.close();
	
	
	//保存源文件
	i = _bgLayerData.length - 1;
	mapInfo.bgs = [];
	for(;i >= 0; i--) {//背景
		layer = _bgLayerData.getItemAt(i).layer;
		bitmapData = new BitmapData(layer.width, layer.height, true, 0);
		bitmapData.draw(layer);
		sourceData.addFile("bg" + i +".png", jpg.encode(bitmapData));
		
		mapInfo.bgs.push({id:i, point:new Point(layer.x, layer.y)});
	}
	
	mapData = new ByteArray();
	mapData.writeObject(mapInfo);
	sourceData.addFile("mapData", mapData);
	sourceData.finish();
	
	file = new File(_saveFile.nativePath + "\\sourceData.zip");
	fs = new FileStream();
	fs.open(file, FileMode.WRITE);
	fs.writeBytes(sourceData.byteArray);
	fs.close();
	
	
	Alert.show("保存完毕！");
}




/**
 * 点击载入源文件按钮
 * @param event
 */
protected function loadBtn_clickHandler(event:MouseEvent):void
{
	_sourceFile.browseForOpen("请选择地图源文件");
}

private function sourceFile_selectHandler(event:Event):void
{
	_sourceFile.load();
}

private function sourceFile_completeHandler(event:Event):void
{
	var zip:ZipReader = new ZipReader(_sourceFile.data);
	var info:Object = zip.getFile("mapData").readObject();
	var i:int, x:int, y:int, tile:Tile, sprite:Sprite, loader:Loader, item:Object;
	_autoIndex = 0;
	
	
	//生成背景图
	_bgLayerData = new ArrayCollection();
	while(_bgC.numChildren > 0) _bgC.removeChildAt(0);
	for(i = 0; i < info.bgs.length; i++) {
		_autoIndex++;
		item = info.bgs[i];
		loader = new Loader();
		loader.loadBytes(zip.getFile("bg" + item.id + ".png"));
		sprite = new Sprite();
		sprite.x = item.point.x;
		sprite.y = item.point.y;
		sprite.addChild(loader);
		_bgC.addChild(sprite);
		_bgLayerData.addItem({label:"图层" + _autoIndex, layer:sprite});
	}
	if(_bgLayerData.length > 0) bgList.selectedIndex = 0;
	
	
	//生成遮挡物
	_coverLayerData = new ArrayCollection();
	while(_coverC.numChildren > 0) {
		_coverC.removeChildAt(0).removeEventListener(MouseEvent.MOUSE_DOWN, cover_mouseDownHandler);
	}
	for(i = 0; i < info.covers.length; i++) {
		_autoIndex++;
		item = info.covers[i];
		loader = new Loader();
		loader.loadBytes(zip.getFile("cover" + item.id + ".png"));
		sprite = new Sprite();
		sprite.x = item.point.x;
		sprite.y = item.point.y;
		sprite.addEventListener(MouseEvent.MOUSE_DOWN, cover_mouseDownHandler);
		sprite.addChild(loader);
		_coverC.addChild(sprite);
		_coverLayerData.addItem({label:"图层" + _autoIndex, layer:sprite});
	}
	if(_coverLayerData.length > 0) coverList.selectedIndex = 0;
	
	
	//生成区块
	while(_tileC.numChildren > 0) _tileC.removeChildAt(0);
	for(y = 0; y < info.vTileCount; y++) {
		for(x = 0; x < info.hTileCount; x++) {
			tile = new Tile(x, y, info.tileWidth, info.tileHeight);
			tile.isShowNO = pointCB.selected;
			tile.name = "t" + x + "_" + y;
			tile.canPass = info.data[y][x].canPass;
			tile.isWater = info.data[y][x].isWater;
			_tileC.addChild(tile);
		}
	}
}




/**
 * 点击添加按钮
 * @param event
 */
protected function addBtn_clickHandler(event:MouseEvent):void
{
	var typeArr:Array = ["遮挡物", "背景"];
	_imgFile.browseForOpen("请选择【" + typeArr[layerA.selectedIndex] +"】文件");
}


private function imgFile_selectHandler(event:Event):void
{
	_imgLoader.load(new URLRequest(_imgFile.url));
}

private function imgLoader_completeHandler(event:Event):void
{
	_autoIndex++;
	var layer:Sprite = new Sprite();
	layer.addChild(event.target.loader.content);
	
	var layerData:ArrayCollection = (layerA.selectedIndex == 0) ? _coverLayerData : _bgLayerData;
	var c:Sprite = (layerA.selectedIndex == 0) ? _coverC : _bgC;
	c.addChild(layer);
	layerData.addItemAt({label:"图层" + _autoIndex, layer:layer}, 0);
	if(layerData.length == 1) ((layerA.selectedIndex == 0 ? coverList : bgList) as List).selectedIndex = 0;
	if(layerA.selectedIndex == 0) layer.addEventListener(MouseEvent.MOUSE_DOWN, cover_mouseDownHandler);
	//背景层
	if(layerA.selectedIndex == 1 && _bgLayerData.length > 1) {
		Alert.yesLabel = "右边";
		Alert.noLabel = "下方";
		Alert.show("要将图块添加到相对于之前添加的图片的哪个方向？", "提示", 3, this, addBG_closeHandler);
	}
}

private function addBG_closeHandler(event:CloseEvent):void
{
	var layer:DisplayObject = _bgLayerData.getItemAt(0).layer;
	var lastLayer:DisplayObject = _bgLayerData.getItemAt(1).layer;
	if(event.detail == Alert.YES) {
		layer.x = lastLayer.x + lastLayer.width;
		layer.y = lastLayer.y;
	}
	else {
		layer.y = lastLayer.y + lastLayer.height;
	}
}

private function cover_mouseDownHandler(event:MouseEvent):void
{
	if(viewBB.selectedIndex != 2) return;
	var cover:Sprite = event.currentTarget as Sprite;
	cover.startDrag();
	for(var i:int = 0; i < _coverLayerData.length; i++) {
		if(_coverLayerData.getItemAt(i).layer == cover) {
			coverList.selectedIndex = i;
			return;
		}
	}
}



/**
 * 点击生成区块按钮
 * @param event
 */
protected function createTileBtn_clickHandler(event:MouseEvent):void
{
	while(_tileC.numChildren > 0) _tileC.removeChildAt(0);
	var tWidth:int = int(tWidthText.text);
	var tHeight:int = int(tHeightText.text);
	var v:int = vTileCount;
	var h:int = hTileCount;
	for(var y:int = 0; y < v; y++) {
		for(var x:int = 0; x < h; x++) {
			var tile:Tile = new Tile(x, y, tWidth, tHeight);
			tile.isShowNO = pointCB.selected;
			tile.name = "t" + x + "_" + y;
			_tileC.addChild(tile);
		}
	}
}




/**
 * 点击删除按钮
 * @param event
 */
protected function delBtn_clickHandler(event:MouseEvent):void
{
	var list:List = (layerA.selectedIndex == 0) ? coverList : bgList;
	if(list.selectedItem != null) {
		var c:Sprite = (layerA.selectedIndex == 0) ? _coverC : _bgC;
		c.removeChild(list.dataProvider.removeItemAt(list.selectedIndex).layer);
	}
}

/**
 * 点击向上或者向下按钮
 * @param event
 */
private function upOrDownBtn_clickHandler(event:MouseEvent):void
{
	if(layerA.selectedIndex != 0) return;
	if(_coverLayerData.length == 0) return;
	
	var index:int = coverList.selectedIndex;
	var item:Object = _coverLayerData.getItemAt(index);
	if(event.currentTarget == upBtn) {
		if(coverList.selectedIndex == 0) return;
		index -= 1;
	}
	else {
		if(coverList.selectedIndex == _coverLayerData.length - 1) return;
		index += 1;
	}
	_coverLayerData.removeItemAt(_coverLayerData.getItemIndex(item));
	_coverLayerData.addItemAt(item, index);
	coverList.selectedIndex = index;
	
	var i:int = _coverLayerData.length - 1;
	for(;i >= 0; i--) {
		_coverC.addChild(_coverLayerData.getItemAt(i).layer);
	}
}



/**
 * 点击开启或关闭图层的按钮
 * @param event
 */
protected function openOrCloseLayerBtn_clickHandler(event:MouseEvent=null):void
{
	TweenMax.killTweensOf(layerPanel);
	TweenMax.to(layerPanel, 0.3, {x:_layerPanelIsOpen ? -250 : 0});
	_layerPanelIsOpen = !_layerPanelIsOpen;
}


