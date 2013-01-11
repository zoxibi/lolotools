import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import lolo.utils.StringUtil;

import module.packaged.EditModule;
import module.packaged.EditRes;
import module.packaged.EditVersion;

import mx.collections.ArrayList;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;


/**项目列表*/
private var _projectList:XML;
/**项目配置*/
private var _projectConfig:XML;

/**编辑版本号模块*/
private var _editVersion:EditVersion;
/**编辑导出资源模块*/
private var _editRes:EditRes;
/**编辑要导出的程序模块*/
private var _editModule:EditModule;


/**
 * 初始化，入口
 * @param event
 */
protected function creationCompleteHandler(event:FlexEvent):void
{
	_editVersion = new EditVersion();
	_editVersion.x = 50;
	_editVersion.y = 50;
	
	_editModule = new EditModule();
	_editModule.x = 50;
	_editModule.y = 50;
	
	_editRes = new EditRes();
	_editRes.x = 50;
	_editRes.y = 50;
	
	
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
	projectDDL.selectedIndex = 0;
	
	
	packagedPathIT.text = "E:/Framework/release";
	sourcePathIT.text = "E:/Framework/source/Framework";
	resPathIT.text = "E:/Framework/res/";
	resVersionIT.text = "zh_CN";
	authorIT.text = "LOLO";
	winRarPathIT.text = "C:/Program Files/WinRAR/WinRAR.exe";
	mxmlcPathIT.text = "D:/Program Files/Adobe/Adobe Flash Builder 4.6/sdks/4.6.0/bin/mxmlc.exe";
}





/**
 * 点击查看打包目录按钮
 * @param event
 */
protected function packagedPathLookBtn_clickHandler(event:MouseEvent):void
{
	var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
	nativeProcessStartupInfo.executable = new File("c:/Windows/explorer.exe");
	var processArgs:Vector.<String> = new Vector.<String>();
	processArgs.push(StringUtil.slashToBackslash(packagedPathIT.text));
	nativeProcessStartupInfo.arguments = processArgs;
	
	new NativeProcess().start(nativeProcessStartupInfo);
}



/**
 * 点击选择打包目录按钮
 * @param event
 */
protected function packagedPathBtn_clickHandler(event:MouseEvent):void
{
	var directory:File = new File(packagedPathIT.text);
	directory.addEventListener(Event.SELECT, packagedPath_SelectHandler);
	directory.browseForDirectory("请选择打包目录");
}

private function packagedPath_SelectHandler(event:Event):void 
{
	packagedPathIT.text = StringUtil.getDirectory((event.target as File).url);
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


/**
 * 点击选择WinRAR.exe按钮
 * @param event
 */
protected function winRarPathBtn_clickHandler(event:MouseEvent):void
{
	var directory:File = new File(winRarPathIT.text);
	directory.addEventListener(Event.SELECT, winRarPath_SelectHandler);
	directory.browseForOpen("请选择 WinRAR.exe");
}

private function winRarPath_SelectHandler(event:Event):void 
{
	winRarPathIT.text = StringUtil.getDirectory((event.target as File).url);
}



/**
 * 点击选择mxmlc.exe按钮
 * @param event
 */
protected function mxmlcPathBtn_clickHandler(event:MouseEvent):void
{
	var directory:File = new File(mxmlcPathIT.text);
	directory.addEventListener(Event.SELECT, mxmlcPath_SelectHandler);
	directory.browseForOpen("请选择 mxmlc.exe");
}

private function mxmlcPath_SelectHandler(event:Event):void 
{
	mxmlcPathIT.text = StringUtil.getDirectory((event.target as File).url);
}







/**
 * 点击编辑程序模块按钮
 * @param event
 */
protected function editModuleBtn_clickHandler(event:MouseEvent):void
{
	PopUpManager.addPopUp(_editModule, this, true);
	_editModule.show(sourcePathIT.text + "/.actionScriptProperties");
}


/**
 * 点击编辑导出资源按钮
 * @param event
 */
protected function editResBtn_clickHandler(event:MouseEvent):void
{
	PopUpManager.addPopUp(_editRes, this, true);
	_editRes.show(resPathIT.text + resVersionIT.text);
}


/**
 * 点击编辑版本号按钮
 * @param event
 */
protected function editVersionBtn_clickHandler(event:MouseEvent):void
{
	PopUpManager.addPopUp(_editVersion, this, true);
	_editVersion.show(resPathIT.text + resVersionIT.text + "/xml/core/resConfig.xml");
}



/**
 * 点击打包按钮
 * @param event
 */
protected function packagedBtn_clickHandler(event:MouseEvent):void
{
	
}