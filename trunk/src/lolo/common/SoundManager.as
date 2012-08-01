package lolo.common
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import lolo.utils.StringUtil;

	/**
	 * 音频管理
	 * @author LOLO
	 */
	public class SoundManager implements ISoundManager
	{
		/**单例的实例*/
		private static var _instance:SoundManager;
		
		/**音频列表[音频的url为key]*/
		private var _soundList:Dictionary;
		/**当前正在播放的背景音乐列表[url为key]*/
		private var _playingBGMusicList:Dictionary;
		/**当前正在播放的音效列表[url为key]*/
		private var _playingEffectSndList:Dictionary;
		
		/**是否启用背景音频播放*/
		private var _backgroundMusicEnabled:Boolean = true;
		/**是否启用音效播放*/
		private var _effectSoundEnabled:Boolean = true;
		
		
		
		
		/**
		 * 获取实例
		 * @return 
		 */
		public static function getInstance():SoundManager
		{
			if(_instance == null) _instance = new SoundManager(new Enforcer());
			return _instance;
		}
		
		public function SoundManager(enforcer:Enforcer)
		{
			super();
			if(!enforcer) {
				throw new Error("请通过Common.sound获取实例");
				return;
			}
			
			_soundList = new Dictionary();
			_playingBGMusicList = new Dictionary();
			_playingEffectSndList = new Dictionary();
		}
		
		
		
		
		
		/**
		 * 播放背景音乐或音效，并返回音频的SoundChannel对象
		 * @param configName 音频在SoundConfig中的配置名称
		 * @param soundName 音频的名称
		 * @param isBackgroundMusic 是否为背景音乐
		 * @param clearOther 是否清除正在播放的背景音乐或音效
		 * @param repeatCount 重复播放次数
		 * @param replay 如果当前正在播放该音频，是否需要重新播放
		 * @return 
		 */
		public function play(configName:String,
							 soundName:String,
							 isBackgroundMusic:Boolean = false,
							 clearOther:Boolean = true,
							 repeatCount:uint = 0,
							 replay:Boolean = true):SoundChannel
		{
			//是禁止播放的状态
			if(!_backgroundMusicEnabled && isBackgroundMusic) return null;
			if(!_effectSoundEnabled && !isBackgroundMusic) return null;
			
			//获取音频的url
			var url:String = getSoundUrl(configName, soundName);
			
			//拿取音频
			var sound:Sound;
			if(_soundList[url] == null) {
				sound = new Sound();
				sound.addEventListener(IOErrorEvent.IO_ERROR, sound_ioErrorHandler);
				sound.load(new URLRequest(url), new SoundLoaderContext(1000, true));
				_soundList[url] = sound;
			}
			else {
				sound = _soundList[url];
			}
			
			//声音的播放信息（正在播放时才有值）
			var sndChannelInfo:Array = isBackgroundMusic ? _playingBGMusicList[url] : _playingEffectSndList[url];
			
			//正在播放该声音，并且不需要重新播放（只能更改和返回同一声音列表中的第一个声音）
			if(sndChannelInfo != null && !replay) {
				sndChannelInfo[0].currentCount = 0;
				sndChannelInfo[0].repeatCount = repeatCount;
				return sndChannelInfo[0].sndChannel;
			}
			
			//需要清除正在播放的音频信息
			if(clearOther) {
				isBackgroundMusic ? stopAllBackgroundMusic() : stopAllEffectSound();
			}
			
			//对应的声音
			try {
				var sndChannel:SoundChannel = sound.play();
			}
			catch(error:Error) {
				return null;
			}
			
			//声音无法构建，可能由于音频url错误，或硬件问题
			if(sndChannel == null) return null;
			
			//没有对应的正在播放列表
			if(sndChannelInfo == null || clearOther) {
				isBackgroundMusic ?
					_playingBGMusicList[url] = []:
					_playingEffectSndList[url] = [];
			}
			
			//保存信息到对应的正在播放列表
			var info:Object = {sndChannel:sndChannel, repeatCount:repeatCount, currentCount:0, url:url};
			isBackgroundMusic ?
				_playingBGMusicList[url].push(info) :
				_playingEffectSndList[url].push(info);
			
			sndChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			
			return sndChannel;
		}
		
		
		/**
		 * 声音播放完成
		 * @param event
		 */
		private function soundCompleteHandler(event:Event):void
		{
			var url:String;//声音的url
			var list:Array;//url对应的正在播放的音频列表
			var sndChannel:SoundChannel;//声音对象
			var sndChannelInfo:Object;//声音的播放信息
			var isEffSnd:Boolean;//声音是否为特效音乐
			var i:int;
			
			for(url in _playingEffectSndList) {
				list = _playingEffectSndList[url];
				for(i = 0; i < list.length; i++) {
					sndChannelInfo = list[i];
					if(sndChannelInfo.sndChannel == event.target) {
						isEffSnd = true;
						break;
					}
				}
				if(isEffSnd) break;
			}
			
			if(!isEffSnd) {
				for(url in _playingBGMusicList) {
					list = _playingBGMusicList[url];
					
					for(i = 0; i < list.length; i++) {
						sndChannelInfo = list[i];
						if(sndChannelInfo.sndChannel == event.target) {
							break;
						}else {
							sndChannelInfo = null;
						}
					}
					if(sndChannelInfo != null) break;
				}
			}
			
			//移除SoundChannel的事件侦听，准备丢弃
			sndChannelInfo.sndChannel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			
			//还未达到指定的重复次数
			if(sndChannelInfo.currentCount < sndChannelInfo.repeatCount) {
				var sound:Sound = _soundList[url];
				sndChannel = sound.play();
				sndChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
				
				sndChannelInfo.sndChannel = sndChannel;
				sndChannelInfo.currentCount++;
			}
			else {
				isEffSnd ? delete _playingEffectSndList[url] : delete _playingBGMusicList[url];
			}
		}
		
		
		
		/**
		 * 加载音频失败
		 * @param event
		 */
		private function sound_ioErrorHandler(event:Event):void
		{
			trace("加载音频失败", event.target.url);
		}
		
		
		
		/**
		 * 停止指定url所有声音的播放
		 * @param configName 音频在SoundConfig中的配置名称
		 * @param soundName 音频的名称
		 * @param isBackgroundMusic 是否为背景音乐
		 */
		public function stop(configName:String, soundName:String, isBackgroundMusic:Boolean=false):void
		{
			//获取音频的url
			var url:String = getSoundUrl(configName, soundName);
			
			var list:Array = isBackgroundMusic ? _playingBGMusicList[url] : _playingEffectSndList[url];
			
			if(list != null) {
				for(var i:int = 0; i < list.length; i++) {
					var sndChannelInfo:Object = list[i];
					sndChannelInfo.sndChannel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
					sndChannelInfo.sndChannel.stop();
				}
			}
			
			if(isBackgroundMusic) {
				delete _playingBGMusicList[url];
			}
			else {
				delete _playingEffectSndList[url];
			}
		}
		
		
		
		/**
		 * 停止所有背景音乐的播放（不包括音效）
		 */
		public function stopAllBackgroundMusic():void
		{
			for each(var list:Array in _playingBGMusicList)
			{
				for(var i:int = 0; i < list.length; i++) {
					var sndChannelInfo:Object = list[i];
					sndChannelInfo.sndChannel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
					sndChannelInfo.sndChannel.stop();
				}
			}
			_playingBGMusicList = new Dictionary();
		}
		
		/**
		 * 停止所有音效的播放（不包括背景音乐）
		 */
		public function stopAllEffectSound():void
		{
			for each(var list:Array in _playingEffectSndList)
			{
				for(var i:int = 0; i < list.length; i++) {
					var sndChannelInfo:Object = list[i];
					sndChannelInfo.sndChannel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
					sndChannelInfo.sndChannel.stop();
				}
			}
			_playingEffectSndList = new Dictionary();
		}
		
		
		
		
		/**
		 * 是否启用背景音频播放，并停止当前所有正在播放的背景音频
		 */
		public function set backgroundMusicEnabled(value:Boolean):void
		{
			_backgroundMusicEnabled = value;
			if(!value) stopAllBackgroundMusic();
		}
		public function get backgroundMusicEnabled():Boolean { return _backgroundMusicEnabled; }
		
		
		/**
		 * 是否禁止音效播放，并停止当前所有正在播放的音效
		 */
		public function set effectSoundEnabled(value:Boolean):void
		{
			_effectSoundEnabled = value;
			if(!value) stopAllEffectSound();
		}
		public function get effectSoundEnabled():Boolean { return _effectSoundEnabled; }
		
		
		
		
		/**
		 * 获取音频的url
		 * @param configName 音频在SoundConfig中的配置名称
		 * @param soundName 音频的名称
		 * @return 
		 */
		private function getSoundUrl(configName:String, soundName:String):String
		{
			var url:String = Common.config.getSoundConfig(configName);
			url = StringUtil.substitute(url, soundName);
			return Common.getResUrl(url);
		}
		//
	}
}


class Enforcer {}