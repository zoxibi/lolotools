import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.net.FileFilter;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import mx.events.FlexEvent;



private var _sFile1:File;
private var _language1:Dictionary;
private var _language2:Dictionary;



/**
 * 初始化，入口
 * @param event
 */
protected function creationCompleteHandler(event:FlexEvent):void
{
	_sFile1 = new File();
	_sFile1.addEventListener(Event.SELECT, sFile1_selectHandler);
	_sFile1.addEventListener(Event.COMPLETE, sFile1_completeHandler);
}



/**
 * 点击选择主语言包按钮
 * @param event
 */
protected function select1Btn_clickHandler(event:MouseEvent):void
{
	_sFile1.browseForOpen("请选择主语言包");
}

private function sFile1_selectHandler(event:Event):void
{
	_sFile1.load();
}

private function sFile1_completeHandler(event:Event):void
{
	_language1 = new Dictionary();
	_language2 = new Dictionary();
	analyzeData(_sFile1, _language1);
}



/**
 * 解析导入的数据
 * @param file
 * @param dic
 */
private function analyzeData(file:File, dic:Dictionary):void
{
	if(file.extension == "txt") {
		var str:String = file.data.readUTFBytes(file.data.length);
		var items:Array = str.split("\r\n");
		var elements:Array;
		for(var i:int = 1 ; i < items.length; i++) {
			elements = items[i].split("\t");
			dic[elements[0]] = { content:elements[1], translate:elements[2] };
		}
	}
}






protected function select2Btn(event:MouseEvent):void
{
	// TODO Auto-generated method stub
	
}



/**
 * 点击导出
 * @param event
 */
protected function exportBtn_clickHandler(event:MouseEvent):void
{
	var dic:Dictionary = _language1;
	if(typeRBG.selectedValue == "xml") {
		var str:String = '<?xml version="1.0" encoding="utf-8"?><language>';
		for(var key:String in dic) {
			str += '<item id="' + key + '"><![CDATA[' + dic[key].translate + ']]></item>';
		}
		str += '</language>';
		trace(str);
		new File().save(new XML(str), "test.xml");
	}
}



