import com.adobe.serialization.json.AdobeJSON;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.FileFilter;
import flash.net.FileReference;
import flash.net.SharedObject;

import module.dataView.DataListItem;

import mx.controls.Alert;
import mx.events.FlexEvent;
import mx.events.ListEvent;

private var _so:SharedObject;
private var _file:FileReference;
private var _fileType:FileFilter;


/**
 * 初始化
 * @param event
 */
private function creationCompleteHandler(event:FlexEvent):void
{
	dataListTree.labelField = "@label";
	
	_file = new FileReference();
	_fileType = new FileFilter("所有文件", "*");
	_file.addEventListener(Event.SELECT, selectHandler);
	_file.addEventListener(Event.COMPLETE, completeHandler);
	
	_so = SharedObject.getLocal("LOLO_VarView");
	if(_so.data.xmlRB != null) xmlRB.selected = _so.data.xmlRB;
	if(_so.data.jsonRB != null) jsonRB.selected = _so.data.jsonRB;
	if(_so.data.compressCB != null) compressCB.selected = _so.data.compressCB;
}




/**
 * 查看json字符串
 * @param event
 */
private function lookJsonStr(event:MouseEvent=null):void
{
	try {
		var data:Object = AdobeJSON.decode(dataText.text);
	}
	catch(error:Error) {
		Alert.show("不是有效的json数据！");
		return;
	}
	
	DataListItem.valueFieldX = 200;
	dataListTree.dataProvider = analysisObject(<data label="数据结构"></data>, data);
}

/**
 * 将object解析成tree需要的xml数据
 * @param parent
 * @param data
 * @return 
 */
private function analysisObject(parent:XML, data:Object):XML
{
	var node:XML;
	
	if(data is Array) {
		for(var i:int = 0; i < data.length; i++) {
			node = new XML("<node></node>");
			node.@label = "[" + i + "]";
			node.@value = data[i];
			parent.appendChild(node);
			
			if(data[i] as Object) analysisObject(node, data[i]);
		}
	}
		
	else {
		for(var prop:String in data) {
			node = new XML("<node></node>");
			node.@label = prop;
			node.@value = data[prop];
			parent.appendChild(node);
			
			if(data[prop] as Object) analysisObject(node, data[prop]);
		}
	}
	
	return parent;
}





/**
 * 查看xml字符串
 * @param event
 */
private function lookXmlStr(event:MouseEvent=null):void
{
	try {
		var data:XML = new XML(dataText.text);
	}
	catch(error:Error) {
		Alert.show("不是有效的xml数据！");
		return;
	}
	
	DataListItem.valueFieldX = 200;
	dataListTree.dataProvider = analysisXml(<data label="数据结构"></data>, data);
}

/**
 * 将xml解析成tree需要的xml数据
 * @param parent
 * @param data
 * @return 
 */
private function analysisXml(parent:XML, data:XML):XML
{
	for(var i:int = 0; i < data.children().length(); i++)
	{
		var item:XML = data.children()[i];
		var node:XML = new XML("<node></node>");
		node.@label = item.name();
		
		if(item.hasComplexContent())
		{
			analysisXml(node, item);
		}
		else {
			node.@value = item;
		}
		parent.appendChild(node);
	}
	return parent;
}




/**
 * 查看文件
 * @param event
 */
private function lookFile(event:MouseEvent):void
{
	_so.data.xmlRB = xmlRB.selected;
	_so.data.jsonRB = jsonRB.selected;
	_so.data.compressCB = compressCB.selected;
	
	_file.browse([_fileType]);
}

/**
 * 选中文件
 * @param event
 */
private function selectHandler(event:Event):void
{
	_file.load();
	fileNameText.text = _file.name;
}

/**
 * 载入文件完毕
 * @param event
 */
private function completeHandler(event:Event):void
{
	var xml:XML;
	var json:String;
	
	try {
		if(compressCB.selected) _file.data.uncompress();
	} catch(error:Error) {
		Alert.show("解压文件失败！");
		return;
	}
	
	if(xmlRB.selected)
	{
		try {
			xml = new XML(_file.data.toString());
		} catch(error:Error) {
			try {
				xml = new XML(_file.data.readObject() as String);
			}catch(error:Error) {
				Alert.show("不是有效的xml数据！");
				return;
			}
		}
	}
	else {
		try {
			json = _file.data.readObject() as String;
		} catch(error:Error) {
			try {
				json = _file.data.toString();
			}catch(error:Error) {
				Alert.show("不是有效的json数据！");
				return;
			}
		}
	}
	
	dataText.text = xmlRB.selected ? xml : json;
	
	xmlRB.selected ? lookXmlStr() : lookJsonStr();
}




/**
 * tree选中item
 * @param event
 */
private function dataListTree_changeHandler(event:ListEvent):void
{
	valueText.text = event.itemRenderer.data.@value;
}


