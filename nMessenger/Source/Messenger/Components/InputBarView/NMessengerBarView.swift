//
// Copyright (c) 2016 eBay Software Foundation
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import AVFoundation
import Photos
import PureLayout

//MARK: InputBarView
/**
 InputBarViewDelegate protocol for NMessenger.
 Defines methods to be implemented inorder to use the InputBar
 */
public protocol InputBarViewDelegate : class {
    /**
     Should define behavior when attach button is tapped
     */
    func onAttach()
    
    /**
     Should define behavior when send button is tapped
     */
    func onSendText(_ text: String)
}

/**
 InputBarView class for NMessenger.
 Define the input bar for NMessenger. This is where the user would type text and open the camera or photo library.
 */
open class NMessengerBarView: InputBarView, UITextViewDelegate {
    
    //MARK: Public Parameters
    //InputBarViewDelegate that implemets the delegate methods
    open weak var inputBarDelegate: InputBarViewDelegate?
    
    //Container for all views
    open var inputBarView = UIView()
    
    //Left View providing integration flexibility to change the left input bar buttons
    open var leftView: UIView = UIView(forAutoLayout: ())
    
    //RightView providing integration flexibility to change the right input bar buttons
    open var rightView: UIView = UIView(forAutoLayout: ())
    
    //Providing access to send button, to allow integrator to remove it and add custom right view buttons
    open var sendButton: UIButton = UIButton()
    
    //Providing access to attach button, to allow integrator to remove it and add custom left view buttons
    open var attachButton: UIButton = UIButton(type: .contactAdd)
    
    open var textInputAreaViewHeight: NSLayoutConstraint = NSLayoutConstraint()
    
    open var textInputViewHeight: NSLayoutConstraint = NSLayoutConstraint()
    
    //CGFloat to the fine the number of rows a user can type
    open var numberOfRows:CGFloat = 3
    //String as placeholder text in input view
    open var inputTextViewPlaceholder: String = "NMessenger"
        {
        willSet(newVal)
        {
            textInputView.text = newVal
        }
    }
    
    //MARK: Private Parameters
    //CGFloat as defualt height for input view
    fileprivate let textInputViewHeightConst:CGFloat = 30
    
    // MARK: Initialisers
    /**
     Initialiser the view.
     */
    public required init() {
        super.init()
    }
    
    /**
     Initialiser the view.
     - parameter controller: Must be NMessengerViewController. Sets controller for the view.
     Calls helper method to setup the view
     */
    public required init(controller:NMessengerViewController) {
        super.init(controller: controller)
        load()
    }
    /**
     Initialiser the view.
     - parameter controller: Must be NMessengerViewController. Sets controller for the view.
     - parameter frame: Must be CGRect. Sets frame for the view.
     Calls helper method to setup the view
     */
    public required init(controller:NMessengerViewController,frame: CGRect) {
        super.init(controller: controller,frame: frame)
        load()
    }
    /**
     - parameter aDecoder: Must be NSCoder
     Calls helper method to setup the view
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }
    
    // MARK: Initialiser helper methods
    /**
     Loads the view constraints and does intial setup.
     */
    fileprivate func load() {
        
        inputBarView.backgroundColor = UIColor.n1LighterGreyColor()
        
        addSubview(inputBarView)
        inputBarView.frame = bounds
        
        inputBarView.addSubview(textInputAreaView)
        
        rightView.backgroundColor = UIColor.white
        leftView.backgroundColor = UIColor.white
        
        textInputAreaView.addSubview(rightView)
        textInputAreaView.addSubview(leftView)
        
        sendButton.setTitle("Send", for: UIControlState.normal)
        sendButton.setTitleColor(UIColor.blue, for: .normal)
        sendButton.setTitleColor(UIColor.gray, for: .disabled)
        sendButton.backgroundColor = UIColor.white
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        sendButton.addTarget(self, action: #selector(sendButtonClicked), for: .touchUpInside)
        
        rightView.addSubview(sendButton)
        
        attachButton.backgroundColor = UIColor.white
        attachButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        attachButton.addTarget(self, action: #selector(onAttach), for: .touchUpInside)
        
        leftView.addSubview(attachButton)
        
        textInputView.delegate = self
        textInputAreaView.addSubview(textInputView)
        
        sendButton.isEnabled = false
        addInputSelectorPlaceholder()
    }
    
    open override func updateConstraints() {
        super.updateConstraints()
        inputBarView.autoSetDimension(.height, toSize: 43)
        
        inputBarView.autoPinEdgesToSuperviewEdges()
        
        textInputAreaView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        
        rightView.autoPinEdge(toSuperviewEdge: .top)
        rightView.autoPinEdge(toSuperviewEdge: .bottom)
        rightView.autoPinEdge(toSuperviewEdge: .right)
        
        sendButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5))
        
        leftView.autoPinEdge(toSuperviewEdge: .top)
        leftView.autoPinEdge(toSuperviewEdge: .bottom)
        leftView.autoPinEdge(toSuperviewEdge: .left)
        
        attachButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5))
        
        textInputView.autoPinEdge(toSuperviewEdge: .top)
        textInputView.autoPinEdge(toSuperviewEdge: .bottom)
        textInputView.autoPinEdge(.left, to: .right, of: leftView)
        textInputView.autoPinEdge(.right, to: .left, of: rightView)
    }
    
    //MARK: TextView delegate methods
    
    /**
     Implementing textViewShouldBeginEditing in order to set the text indictor at position 0
     */
    open func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        
        if(textView.text == inputTextViewPlaceholder){
            textView.text = "";
        }
        
        if !textView.text.isEmpty {
            
            UIView.animate(withDuration: 0.1, animations: {
                self.sendButton.isEnabled = true
            });
            
        }else{
            
            DispatchQueue.main.async(execute: {
                textView.selectedRange = NSMakeRange(0, 0)
            });
        }
        
        textView.textColor = UIColor.n1DarkestGreyColor()
        UIView.animate(withDuration: 0.1, animations: {
            self.sendButton.isEnabled = true
        })
        DispatchQueue.main.async(execute: {
            textView.selectedRange = NSMakeRange(0, 0)
        });
        return true
    }
    /**
     Implementing textViewShouldEndEditing in order to re-add placeholder and hiding send button when lost focus
     */
    open func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textInputView.text.isEmpty {
            addInputSelectorPlaceholder()
        }
        UIView.animate(withDuration: 0.1, animations: {
            self.sendButton.isEnabled = false
        })
        textInputView.resignFirstResponder()
        return true
    }
    /**
     Implementing shouldChangeTextInRange in order to remove placeholder when user starts typing and to show send button
     Re-sizing the text area to default values when the return button is tapped
     Limit the amount of rows a user can write to the value of numberOfRows
     */
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text == "" && (text != "\n")
        {
            UIView.animate(withDuration: 0.1, animations: {
                self.sendButton.isEnabled = true
            })
            return true
        }
        else if (text == "\n") && textView.text != ""{
            if textView == textInputView {
                textInputViewHeight.constant = textInputViewHeightConst
                textInputAreaViewHeight.constant = textInputViewHeightConst+10
                inputBarDelegate?.onSendText(textInputView.text)
                textInputView.text = ""
                return false
            }
        }
        else if (text != "\n")
        {
            
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            
            var textWidth: CGFloat = UIEdgeInsetsInsetRect(textView.frame, textView.textContainerInset).width
            
            textWidth -= 2.0 * textView.textContainer.lineFragmentPadding
            
            let boundingRect: CGRect = newText.boundingRect(with: CGSize(width: textWidth, height: 0), options: [NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.usesFontLeading], attributes: [NSFontAttributeName: textView.font!], context: nil)
            
            let numberOfLines = boundingRect.height / textView.font!.lineHeight;
            
            
            return numberOfLines <= numberOfRows
        }
        return false
    }
    /**
     Implementing textViewDidChange in order to resize the text input area
     */
    open func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
        textInputViewHeight.constant = newFrame.size.height
        
        textInputAreaViewHeight.constant = newFrame.size.height+10
    }
    
    //MARK: TextView helper methods
    /**
     Adds placeholder text and change the color of textInputView
     */
    fileprivate func addInputSelectorPlaceholder() {
        textInputView.text = inputTextViewPlaceholder
        textInputView.textColor = UIColor.lightGray
    }
    
    //MARK: selectors
    /**
     Send button selector
     Sends the text in textInputView to the controller
     */
    open func sendButtonClicked() {
        textInputViewHeight.constant = textInputViewHeightConst
        textInputAreaViewHeight.constant = textInputViewHeightConst+10
        if textInputView.text != ""
        {
            inputBarDelegate?.onSendText(textInputView.text)
            textInputView.text = ""
        }
    }
    /**
     attachment button selector
     */
    open func onAttach() {
        inputBarDelegate?.onAttach()
    }
}
