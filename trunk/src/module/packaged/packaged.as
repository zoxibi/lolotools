import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import lolo.utils.StringUtil;

import mx.collections.ArrayList;
import mx.events.FlexEvent;


/**项目列表*/
private var _projectList:XML;



/**
 * 初始化，入口
 * @param event
 */
protected function creationCompleteHandler(event:FlexEvent):void
{
	var stream:FileStream = new FileStream();
	var file:File = new File("app:/assets/xml/ProjectList.xml");
	stream.open(file, FileMode.READ);
	_projectList = new XML(stream.readUTFBytes(stream.bytesAvailable));
	stream.close();
	
	var al:ArrayList = new ArrayList();
	for(var i:int=0; i<_projectList.project.length(); i++) {
		al.addItem({ label:String(_projectList.project[i].@name) });
	}
	projectDDL.dataProvider = al;
	
	
	packagedPathIT.text = "E:/Framework/release";
	sourcePathIT.text = "E:/Framework/source/Framework/src";
}


/**
 * 点击查看打包目录按钮
 * @param event
 */
protected function packagedPathBtn_clickHandler(event:MouseEvent):void
{
	var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
	nativeProcessStartupInfo.executable = new File("c:/Windows/explorer.exe");
	var processArgs:Vector.<String> = new Vector.<String>();
	processArgs.push(StringUtil.slashToBackslash(packagedPathIT.text));
	nativeProcessStartupInfo.arguments = processArgs;
	
	new NativeProcess().start(nativeProcessStartupInfo);
}



/**
 * 点击选择程序模块目录按钮
 * @param event
 */
protected function sourcePathBtn_clickHandler(event:MouseEvent):void
{
	var directory:File = new File(sourcePathIT.text);
	directory.addEventListener(Event.SELECT, sourcePath_SelectHandler);
	directory.browseForDirectory("请选择程序模块目录");
}

private function sourcePath_SelectHandler(event:Event):void 
{
	sourcePathIT.text = StringUtil.getDirectory((event.target as File).url);
}



/**
 * 点击选择资源库目录按钮
 * @param event
 */
protected function resBtn_clickHandler(event:MouseEvent):void
{
	var directory:File;
	try {
		directory = new File(resPathIT.text + resVersionIT.text);
	}
	catch(err:Error) {
		directory = File.applicationDirectory;
	}
	directory.addEventListener(Event.SELECT, resPath_SelectHandler);
	directory.browseForDirectory("请选择资源库目录");
}

private function resPath_SelectHandler(event:Event):void 
{
	var arr:Array = StringUtil.getDirectory((event.target as File).url).split("/");
	resVersionIT.text = arr.pop();
	
	var resPath:String = "";
	for(var i:int = 0; i < arr.length; i++) {
		resPath += arr[i] + "/";
	}
	resPathIT.text = resPath;
}





