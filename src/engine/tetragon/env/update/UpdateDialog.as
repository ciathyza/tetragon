/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * Tetragon : Game Engine for multi-platform ActionScript projects.
 * http://www.tetragonengine.com/ - Copyright (C) 2012 Sascha Balkau
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
package tetragon.env.update
{
	import lib.display.UpdateDialogIcon;

	import tetragon.core.display.shape.RectangleShape;
	import tetragon.env.update.au.ui.AUUpdateUI;
	import tetragon.util.ui.createUIButton;
	import tetragon.util.ui.createUILabel;
	import tetragon.util.ui.createUIProgressBar;
	import tetragon.util.ui.createUITextArea;
	import tetragon.view.ui.controls.Button;
	import tetragon.view.ui.controls.Label;
	import tetragon.view.ui.controls.ProgressBar;
	import tetragon.view.ui.controls.TextArea;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	
	/**
	 * UpdateDialog class
	 */
	public class UpdateDialog extends AUUpdateUI
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _titleLabel:Label;
		/** @private */
		private var _messageLabel:Label;
		/** @private */
		private var _releaseNotes:TextArea;
		/** @private */
		private var _progressBar:ProgressBar;
		/** @private */
		private var _okButton:Button;
		/** @private */
		private var _cancelButton:Button;
		
		/** @private */
		private var _titleFormat:TextFormat;
		/** @private */
		private var _textFormat:TextFormat;
		/** @private */
		private var _notesFormat:TextFormat;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override public function updateProgress(progress:int):void
		{
			_progress = progress;
			if (_messageLabel) _messageLabel.text = "Progress: " + _progress + "%";
			if (_progressBar) _progressBar.setProgress(_progress, 100);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onOKButtonClick(e:MouseEvent):void
		{
			if (_currentState == STATUS_AVAILABLE)
				dispatchEvent(new Event(EVENT_DOWNLOAD_UPDATE));
			else if (_currentState == STATUS_INSTALL)
				dispatchEvent(new Event(EVENT_INSTALL_UPDATE));
		}
		
		
		/**
		 * @private
		 */
		private function onCancelButtonClick(e:MouseEvent):void
		{
			if (_currentState == STATUS_INSTALL)
				dispatchEvent(new Event(EVENT_INSTALL_LATER));
			else
				dispatchEvent(new Event(EVENT_CANCEL_UPDATE));
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function setup():void
		{
			_titleFormat = new TextFormat("Bitstream Vera Sans", 26, 0xFFFFFF);
			_textFormat = new TextFormat("Bitstream Vera Sans", 12, 0xEEEEEE);
			_notesFormat = new TextFormat("Bitstream Vera Sans", 10, 0x222222);
			
			var bg:RectangleShape = new RectangleShape(520, 330, 0x262626);
			var icon:UpdateDialogIcon = new UpdateDialogIcon();
			icon.x = 10;
			icon.y = 10;
			
			addChild(bg);
			addChild(icon);
		}
		
		
		/**
		 * @private
		 */
		override protected function createUpdateAvailableState():void
		{
			_titleLabel = createUILabel(110, 10, 370, 35, _titleFormat, false, "Update Available");
			_uiContainer.addChild(_titleLabel);
			
			var message:String = "An updated version of " + _applicationName
				+ " is available and can be downloaded."
				+ "\n\nInstalled version:\t" + _currentVersion
				+ "\nUpdate version:\t" + _updateVersion;
			_messageLabel = createUILabel(110, 50, 370, 94, _textFormat, true, message);
			_uiContainer.addChild(_messageLabel);
			
			_releaseNotes = createUITextArea(110, 140, 380, 92, _notesFormat, true, false, _updateDescription);
			_uiContainer.addChild(_releaseNotes);
			
			_okButton = createUIButton(110, 250, 140, 28, true, "Download now");
			_okButton.addEventListener(MouseEvent.CLICK, onOKButtonClick);
			_uiContainer.addChild(_okButton);
			
			_cancelButton = createUIButton(260, 250, 140, 28, false, "Download later");
			_cancelButton.addEventListener(MouseEvent.CLICK, onCancelButtonClick);
			_uiContainer.addChild(_cancelButton);
		}
		
		
		/**
		 * @private
		 */
		override protected function createUpdateDownloadState():void
		{
			_titleLabel = createUILabel(110, 10, 370, 35, _titleFormat, false, "Downloading Update");
			_uiContainer.addChild(_titleLabel);
			
			_messageLabel = createUILabel(110, 70, 370, 18, _textFormat, true, "Progress: " + _progress + "%");
			_uiContainer.addChild(_messageLabel);
			
			_progressBar = createUIProgressBar(110, 92, 370, 16);
			_uiContainer.addChild(_progressBar);
			
			_releaseNotes = createUITextArea(110, 140, 380, 92, _notesFormat, true, false, _updateDescription);
			_uiContainer.addChild(_releaseNotes);
			
			_cancelButton = createUIButton(110, 250, 140, 28, false, "Cancel");
			_cancelButton.addEventListener(MouseEvent.CLICK, onCancelButtonClick);
			_uiContainer.addChild(_cancelButton);
		}
		
		
		/**
		 * @private
		 */
		override protected function createUpdateInstallState():void
		{
			_titleLabel = createUILabel(110, 10, 370, 35, _titleFormat, false, "Install Update");
			_uiContainer.addChild(_titleLabel);
			
			var message:String = "The update for " + _applicationName + " is downloaded and ready to be installed."
				+ "\n\nInstalled version:\t" + _currentVersion
				+ "\nUpdate version:\t" + _updateVersion;
			_messageLabel = createUILabel(110, 50, 370, 94, _textFormat, true, message);
			_uiContainer.addChild(_messageLabel);
			
			_releaseNotes = createUITextArea(110, 140, 380, 92, _notesFormat, true, false, _updateDescription);
			_uiContainer.addChild(_releaseNotes);
			
			_okButton = createUIButton(110, 250, 140, 28, true, "Install now");
			_okButton.addEventListener(MouseEvent.CLICK, onOKButtonClick);
			_uiContainer.addChild(_okButton);
			
			_cancelButton = createUIButton(260, 250, 140, 28, false, "Postpone until restart");
			_cancelButton.addEventListener(MouseEvent.CLICK, onCancelButtonClick);
			_uiContainer.addChild(_cancelButton);
		}
		
		
		/**
		 * @private
		 */
		override protected function createUpdateErrorState():void
		{
			_titleLabel = createUILabel(110, 10, 360, 35, _titleFormat, false, "Update Error");
			_uiContainer.addChild(_titleLabel);
			
			var message:String = "An error occured while updating:";
			_messageLabel = createUILabel(110, 70, 360, 34, _textFormat, false, message);
			_uiContainer.addChild(_messageLabel);
			
			_releaseNotes = createUITextArea(110, 100, 360, 82, _notesFormat, true, false, _errorText);
			_uiContainer.addChild(_releaseNotes);
			
			_cancelButton = createUIButton(110, 250, 140, 28, false, "Close");
			_cancelButton.addEventListener(MouseEvent.CLICK, onCancelButtonClick);
			_uiContainer.addChild(_cancelButton);
		}
		
		
		/**
		 * @private
		 */
		override protected function removeUIListeners():void
		{
			if (_okButton) _okButton.removeEventListener(MouseEvent.CLICK, onOKButtonClick);
			if (_cancelButton) _cancelButton.removeEventListener(MouseEvent.CLICK, onCancelButtonClick);
		}
	}
}
