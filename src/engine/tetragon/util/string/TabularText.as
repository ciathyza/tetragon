/*
		
				if (_colMaxLength > 0 && s.length - 3 > _colMaxLength)
		 */
		public static function calculateLineWidth(stageWidth:int, charWidth:int, offset:int = 0):void
		{
			_lineWidth = (stageWidth / charWidth) - offset;