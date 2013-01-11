/**
 * 编辑版本号
 */
import com.greensock.TweenMax;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.Dictionary;

import module.packaged.ExportItemRenderer;

import mx.controls.Alert;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;



/**当前程序项目资源的路径*/
private var _resPath:String;
/**是否有改动*/
public var isChanged:Boolean;




/**
 * 初始化
 * @param event
 */
protected function panel1_creationCompleteHandler(event:FlexEvent):void
{
	
}




/**
 * 显示
 */
public function show(resPath:String):void
{
	if(_resPath == resPath) return;
	
	_resPath = resPath;
	reloadBtn_clickHandler();
}

/**
 * 点击重读按钮
 * @param event
 */
protected function reloadBtn_clickHandler(event:MouseEvent=null):void
{
	try {
		var file:File = new File(_resPath);
		var treeData:Array = [];
		searchDirectory(file, treeData);
		moduleTree.dataProvider = treeData;
	}
	catch(error:Error) {
		_resPath = "";
		PopUpManager.removePopUp(this);
		Alert.show("【资源库路径 或 资源类型】配置错误！", "提示");
	}
}

/**
 * 搜索文件夹，并将结果按照Tree数据添加到数组中
 * @param file
 * @param arr
 */
private function searchDirectory(file:File, arr:Array):void
{
	var extension:String = file.extension;
	if(file.name == ".svn" || extension == "fla" || extension == "zip") {
		return;
	}
	
	var data:Object = { label:file.name, file:file };
	if(file.isDirectory)
	{
		data.children = [];
		var files:Array = file.getDirectoryListing();
		for each(var cFile:File in files) {
			searchDirectory(cFile, data.children);
		}
	}
	arr.push(data);
}



private function moduleTreeCallLater():void
{
	for each(var item:Object in moduleTree.dataProvider)
	{
		moduleTree.expandChildrenOf(item, true);
	}
	moduleTree.scrollToIndex(0);
	TweenMax.delayedCall(0.5, setSelected, [moduleTree.dataProvider]);
}



/**
 * 双击Tree Item
 * @param event
 */
protected function moduleTree_itemDoubleClickHandler(event:Event):void
{
	moduleTree.expandItem(moduleTree.selectedItem, !moduleTree.isItemOpen(moduleTree.selectedItem));
}


/**
 * 点击全选或反选
 * @param event
 */
protected function selectAllCB_changeHandler(event:Event):void
{
	moduleTreeCallLater();
}

private function setSelected(data:Object):void
{
	for each(var item:Object in data)
	{
		var renderer:ExportItemRenderer = moduleTree.itemToItemRenderer(item) as ExportItemRenderer;
		trace(renderer);
		if(renderer == null) continue;
		renderer.selectCB.selected = selectAllCB.selected;
		if(item.children != null) setSelected(item.children);
	}
}



/**
 * 点击确定按钮
 * @param event
 */
protected function defineBtn_clickHandler(event:MouseEvent):void
{
	isChanged = true;
	PopUpManager.removePopUp(this);
}


/**
 * 点击取消按钮
 * @param event
 */
protected function cencelBtn_clickHandler(event:MouseEvent):void
{
	PopUpManager.removePopUp(this);
}
