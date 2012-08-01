package lolo.core
{
	/**
	 * 基本显示对象
	 * @author LOLO
	 */
	public interface IRSprite
	{
		/**
		 * 显示
		 */
		function show():void;
		
		/**
		 * 隐藏
		 */
		function hide():void;
		
		/**
		 * 当前如果为显示状态，将会切换到隐藏状态。
		 * 相反，如果为隐藏状态，将会切换到显示状态
		 */		
		function showOrHide():void;
		
		
		/**
		 * 立即显示
		 */
		function nowShow():void;
		
		/**
		 * 立即隐藏
		 */
		function nowHide():void;
		
		/**
		 * 立即切换到显示状态，或者立即切换到隐藏状态
		 */
		function nowShowOrHide():void;
		
		
		
		/**
		 * 当前是否为显示状态
		 */
		function get isShow():Boolean;
		
		
		/**
		 * 实例名称
		 */
		function get name():String;
		function set name(value:String):void;
		
		
		/**
		 * 是否自动添加到显示对象、从显示对象中移除
		 */		
		function get autoRemove():Boolean;
		function set autoRemove(value:Boolean):void;
		
		/**
		 * 在显示或隐藏动画中是否遮挡住鼠标
		 */		
		function get autoBlockMouse():Boolean;
		function set autoBlockMouse(value:Boolean):void;
		
		/**
		 * 显示动画的持续时间(单位:秒)
		 */
		function get showEffectDuration():Number;
		function set showEffectDuration(value:Number):void;
		
		/**
		 * 隐藏动画的持续时间(单位:秒)
		 */
		function get hideEffectDuration():Number;
		function set hideEffectDuration(value:Number):void;
		
		/**
		 * 隐藏动画的延迟时间(单位:秒)
		 */
		function get showEffectDelay():Number;
		function set showEffectDelay(value:Number):void;
		
		/**
		 * 隐藏动画的延迟时间(单位:秒)
		 */
		function get hideEffectDelay():Number;
		function set hideEffectDelay(value:Number):void;
		//
	}
}