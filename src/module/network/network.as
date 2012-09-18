
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.utils.ByteArray;

import mx.controls.Alert;
import mx.events.FlexEvent;



/**PING程序本机进程*/
private var _pingNP:NativeProcess;
/**测试下载的URLLoader*/
private var _testLoader:URLLoader;



/**
 * 初始化，入口
 * @param event
 */
protected function creationCompleteHandler(event:FlexEvent):void
{
	_pingNP = new NativeProcess();
	_pingNP.addEventListener(NativeProcessExitEvent.EXIT, pingNP_exitHandler);
	_pingNP.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, pingNP_standardOutputDataHandler);
	
	_testLoader = new URLLoader();
	_testLoader.addEventListener(Event.COMPLETE, testLoader_completeHandler);
	_testLoader.addEventListener(IOErrorEvent.IO_ERROR, testLoader_errorHandler);
	_testLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, testLoader_errorHandler);
	_testLoader.addEventListener(ProgressEvent.PROGRESS, testLoader_progressHandler);
}




/**
 * 点击ping按钮
 * @param event
 */
protected function pingBtn_clickHandler(event:MouseEvent):void
{
	if(pingBtn.label == "开始") {
		var npsi:NativeProcessStartupInfo = new NativeProcessStartupInfo();
		npsi.executable = new File("c:/Windows/System32/ping.exe");
		var args:Vector.<String> = new Vector.<String>();
		args.push(pingHostText.text);
		args.push("-t");
		npsi.arguments = args;
		
		pingBtn.label = "终止";
		pingOutputText.text = "";
		_pingNP.start(npsi);
	}
	else {
		_pingNP.exit();
	}
}

/**
 * ping进程退出
 * @param event
 */
private function pingNP_exitHandler(event:NativeProcessExitEvent):void
{
	pingBtn.label = "开始";
}

/**
 * ping进程有数据
 * @param event
 */
private function pingNP_standardOutputDataHandler(event:ProgressEvent):void
{
	pingOutputText.appendText(_pingNP.standardOutput.readMultiByte(_pingNP.standardOutput.bytesAvailable, "gb2312"));
}



/**
 * 点击生成测试数据按钮
 * @param event
 */
protected function createDataBtn_clickHandler(event:MouseEvent):void
{
	var file:File = File.desktopDirectory.resolvePath("LoloNetworkTestData");
	var fileStream:FileStream = new FileStream();
	fileStream.open(file,FileMode.WRITE);
	var bytes:ByteArray = new ByteArray();
	bytes.length = int(targetDataSizeText.text) * 1024 * 1024;
	fileStream.writeBytes(bytes);
	fileStream.close();
	
	//http://www.wlhgame.com:888/LoloNetworkTestData
	
	Alert.show("已在您的桌面生成了一个大小为：" + int(targetDataSizeText.text) + "MByte，名称为：LoloNetworkTestData 的测试文件。");
}


/**
 * 点击下载按钮
 * @param event
 */
protected function downloadBtn_clickHandler(event:MouseEvent):void
{
	if(downloadBtn.label == "开始") {
		
	}
	else {
		
	}
}

private function testLoader_progressHandler(event:Event):void
{
	
}

private function testLoader_errorHandler(event:Event):void
{
	Alert.show("加载错误：\n" + event.toString());
	resetTestDownLoad();
}

private function testLoader_completeHandler(event:Event):void
{
	resetTestDownLoad();
}


/**
 * 重置下载测试
 */
private function resetTestDownLoad():void
{
	downloadBtn.label = "开始";
}
