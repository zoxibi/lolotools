package lolo.common
{
	import flash.media.SoundChannel;

	/**
	 * 音频管理
	 * @author LOLO
	 */
	public interface ISoundManager
	{
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
		function play(configName:String,
					  soundName:String,
					  isBackgroundMusic:Boolean = false,
					  clearOther:Boolean = true,
					  repeatCount:uint = 0,
					  replay:Boolean = true):SoundChannel;
		
		
		/**
		 * 停止指定url所有声音的播放
		 * @param configName 音频在SoundConfig中的配置名称
		 * @param soundName 音频的名称
		 * @param isBackgroundMusic 是否为背景音乐
		 */
		function stop(configName:String, soundName:String, isBackgroundMusic:Boolean=false):void;
		
		
		/**
		 * 停止所有背景音乐的播放（不包括音效）
		 */
		function stopAllBackgroundMusic():void;
		
		/**
		 * 停止所有音效的播放（不包括背景音乐）
		 */
		function stopAllEffectSound():void;
		
		
		
		
		/**
		 * 是否启用背景音频播放（如果为false将会停止当前所有正在播放的背景音频）
		 */
		function set backgroundMusicEnabled(value:Boolean):void;
		function get backgroundMusicEnabled():Boolean;
		
		/**
		 * 是否启用音效播放（如果为false将会停止当前所有正在播放的音效）
		 */
		function set effectSoundEnabled(value:Boolean):void;
		function get effectSoundEnabled():Boolean;
		//
	}
}