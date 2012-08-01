package lolo.components
{
	import flash.text.TextFieldType;
	
	import lolo.core.RTextField;
	
	/**
	 * 输入文本
	 * @author LOLO
	 */
	public class InputText extends RTextField
	{
		/**是否可以编辑文本*/
		protected var _editable:Boolean;
		
		
		public function InputText()
		{
			super();
			editable = true;
			
			//默认屏蔽的字符
			this.restrict = "^<|>";
		}
		
		
		/**
		 * 是否可以编辑文本
		 * @param value
		 */
		public function set editable(value:Boolean):void
		{
			_editable = value;
			this.type = value ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
		}
		public function get editable():Boolean
		{
			return _editable;
		}
		//
	}
}