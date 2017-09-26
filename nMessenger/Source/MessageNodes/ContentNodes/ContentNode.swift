//
// Copyright (c) 2016 eBay Software Foundation
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import AsyncDisplayKit

//MARK: ContentNode
/**
 Content node class for NMessenger.
 Define the content a a MessageNode or a MessageGroup
 */
open class ContentNode: ASDisplayNode {
    
    // MARK: Public Parameters
    /** Bubble that defines the background for the message*/
    open var backgroundBubble: Bubble?
    /** UIViewController that holds the cell. Allows the cell the present View Controllers. Generally used for UIMenu or UIAlert Options*/
    open weak var currentViewController: UIViewController?
    /** MessageConfigurationProtocol hold common definition for all messages. Defaults to **StandardMessageConfiguration***/
    open var bubbleConfiguration : BubbleConfigurationProtocol = StandardBubbleConfiguration() {
        didSet {
            self.updateBubbleConfig(self.bubbleConfiguration)
        }
    }
    /** Bool if the cell is an incoming or out going message.
     Set backgroundBubble.bubbleColor when value is changed
     */
    open var isIncomingMessage = true {
        didSet {
             self.backgroundBubble?.bubbleColor = isIncomingMessage ? bubbleConfiguration.getIncomingColor() : bubbleConfiguration.getOutgoingColor()
            
            self.setNeedsLayout()
        }
    }
    
    // MARK: Initialisers
    /**
     Overriding init to initialise the node
     */    
    public init(bubbleConfiguration: BubbleConfigurationProtocol? = nil) {
        if let bubbleConfiguration = bubbleConfiguration {
            self.bubbleConfiguration = bubbleConfiguration
        }
        super.init()
        //make sure the bubble is set correctly
        self.updateBubbleConfig(self.bubbleConfiguration)
    }
    
    //MARK: Node Lifecycle
    /**
     Overriding didLoad and calling helper method addSublayers
     */
    override open func didLoad() {
        super.didLoad()
        self.isOpaque = false
    }
    
    //MARK: Node Lifecycle helper methods
    
    /** Updates the bubble config by setting all necessary properties (background bubble, bubble color, layout)
     - parameter newValue: the new BubbleConfigurationProtocol
     */
    open func updateBubbleConfig(_ newValue: BubbleConfigurationProtocol) {
        self.backgroundBubble = self.bubbleConfiguration.getBubble()
        
        self.backgroundBubble?.bubbleColor = isIncomingMessage ? bubbleConfiguration.getIncomingColor() : bubbleConfiguration.getOutgoingColor()
        
        self.setNeedsLayout()
    }
    
    //MARK: Override AsycDisaplyKit Methods
    
    /**
     Draws the content in the bubble. This is called on a background thread.
     */

    open override func drawParameters(forAsyncLayer layer: _ASDisplayLayer) -> NSObjectProtocol? {
        guard let backgroundBubble = backgroundBubble else { return nil }
        return ["bubble": backgroundBubble, "isIncomingMessage": isIncomingMessage] as NSDictionary
    }

    open override class func draw(_ bounds: CGRect, withParameters parameters: Any?, isCancelled isCancelledBlock: () -> Bool, isRasterizing: Bool) {
        guard let parameters = parameters as? NSDictionary else { return }
        guard let bubble = parameters["bubble"] as? Bubble else { return }
        bubble.sizeToBounds(bounds)
        bubble.createLayer()

        let context = UIGraphicsGetCurrentContext()!
        context.saveGState() 
        context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 2.0, color: UIColor.gray.cgColor)

        if let path = bubble.layer.path {
            bubble.bubbleColor.setFill()
            let bezierPath = UIBezierPath(cgPath: path)
            if let isIncomingMessage = parameters["isIncomingMessage"] as? Bool, !isIncomingMessage {
                let mirror = CGAffineTransform(scaleX: -1.0, y: 1.0)
                let translate = CGAffineTransform(translationX: bubble.calculatedBounds.width, y: 0)
                bezierPath.apply(mirror)
                bezierPath.apply(translate)
            }

            bezierPath.fill()
            context.clip(to: bezierPath.bounds)
        }
        context.restoreGState()
    }

    //MARK: Override AsycDisaplyKit helper methods
    
    /**
     Calls closer after a time delay
     - parameter delay: Must be Double.
     - parameter closure: Must be an ()->()
     */
    open func delay(_ delay: Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }

    
    //MARK: UITapGestureRecognizer Selector
    
    /**
     Selector to handle long press on message and show custom menu
     - parameter recognizer: Must be UITapGestureRecognizer
     */
    open func messageNodeLongPressSelector(_ recognizer: UITapGestureRecognizer) {
    }

}
