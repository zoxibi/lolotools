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



[Bindable]
[Embed(source="assets/images/icons/P_RunnableAs_Sm_N.png")]
private var P_RunnableAs_Sm_N:Class;

[Bindable]
[Embed(source="assets/images/icons/P_ModuleAs_Sm_N.png")]
private var P_ModuleAs_Sm_N:Class;



/**当前程序项目配置文件的路径*/
private var _asProPath:String;
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
public function show(asProPath:String):void
{
	if(_asProPath == asProPath) return;
	
	_asProPath = asProPath;
	reloadBtn_clickHandler();
}



/**
 * 点击重读按钮
 * @param event
 */
protected function reloadBtn_clickHandler(event:MouseEvent=null):void
{
	try {
		var file:File = new File(_asProPath);
		var stream:FileStream = new FileStream();
		stream.open(file, FileMode.READ);
		var xml:XML = new XML(stream.readUTFBytes(stream.bytesAvailable));
		stream.close();
		isChanged = false;
		
		var treeData:Array = [];
		var treeDataKey:Dictionary = new Dictionary();
		var xmlItem:XML;
		for each(xmlItem in xml.applications.application)
		{
			var path:String = xmlItem.@path;
			path = "src/" + path;
			treeDataKey[path] = treeData.length;
			var arr1:Array = path.split("/");
			var arr2:Array = arr1[arr1.length - 1].split(".");
			treeData.push({
				label		: arr2[0] + ".swf",
				sourcePath	: path,
				children	: []
			});
		}
		
		for each(xmlItem in xml.modules.module)
		{
			var application:String = xmlItem.@application;
			treeData[treeDataKey[application]].children.push({
				label		: String(xmlItem.@destPath),
				sourcePath	: String(xmlItem.@sourcePath)
			});
		}
		
		moduleTree.dataProvider = null;
		moduleTree.callLater(moduleTreeCallLater);
		moduleTree.dataProvider = treeData;
	}
	catch(error:Error) {
		_asProPath = "";
		PopUpManager.removePopUp(this);
		Alert.show("【程序模块】路径配置错误！", "提示");
	}
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
