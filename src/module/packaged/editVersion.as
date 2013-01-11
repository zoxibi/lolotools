/**
 * 编辑版本号
 */
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import mx.controls.Alert;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;


/**当前版本号文件的路径*/
private var _resConfigPath:String;
/**是否有改动*/
public var isChanged:Boolean;


/**
 * 初始化
 * @param event
 */
protected function panel1_creationCompleteHandler(event:FlexEvent):void
{
	contentText.setStyle("fontFamily", "宋体");
	contentText.setStyle("fontSize", 12);
	contentText.setStyle("lineHeight", 20);
	
}


/**
 * 显示
 */
public function show(resConfigPath:String):void
{
	if(_resConfigPath == resConfigPath) return;
	
	_resConfigPath = resConfigPath;
	reloadBtn_clickHandler();
}



/**
 * 点击重读按钮
 * @param event
 */
protected function reloadBtn_clickHandler(event:MouseEvent=null):void
{
	try {
		var file:File = new File(_resConfigPath);
		var stream:FileStream = new FileStream();
		stream.open(file, FileMode.READ);
		contentText.text = stream.readUTFBytes(stream.bytesAvailable);
		stream.close();
		isChanged = false;
	}
	catch(error:Error) {
		_resConfigPath = "";
		PopUpManager.removePopUp(this);
		Alert.show("【资源库】路径配置错误！", "提示");
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