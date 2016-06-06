//
//  AKViewController.swift
//  pcyp-ios
//
//  Created by Ken M. Haggerty on 6/6/16.
//  Copyright © 2016 Peter Cicchino Youth Project. All rights reserved.
//

// MARK: Imports

import UIKit

// MARK: Definitions

var AKViewBoundsDidChangeNotification = "kAKViewBoundsDidChangeNotification"

class AKView: UIView {
    override var bounds: CGRect {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(AKViewBoundsDidChangeNotification, object: self, userInfo: [NOTIFICATION_OBJECT_KEY : NSValue.init(CGRect: self.bounds)])
        }
    }
}

extension UIViewAnimationCurve {
    func toOptions() -> UIViewAnimationOptions {
        return UIViewAnimationOptions(rawValue: UInt(rawValue << 16))
    }
}

// MARK: - AKViewController

class AKViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Public API
    
    // MARK: • IBOutlets
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var constraintContentSizeBottom: NSLayoutConstraint!
    
    // MARK: • Variables
    
    // MARK: • Functions
    
    // MARK: - Private API
    
    // MARK: • IBOutlets
    
    @IBOutlet private var statusBarSize: UIView!
    
    // MARK: • Variables
    
    // MARK: • Inits
    
    deinit {
        self.teardown()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.setup()
    }
    
    // MARK: • Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: • Delegated (UITextFieldDelegate)
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    // MARK: • Overwritten
    
    override func setup() {
        super.setup()
        
        self.addObserversToStatusBar()
        self.addObserversToKeyboard()
    }
    
    override func teardown() {
        self.removeObserversFromStatusBar()
        self.removeObserversFromKeyboard()
        
        super.teardown()
    }
    
    // MARK: • IBActions
    
    // MARK: • Observers
    
    private func addObserversToKeyboard() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardFrameWillChange), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    private func removeObserversFromKeyboard() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidChangeFrameNotification, object: nil)
    }
    
    private func addObserversToStatusBar() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.statusBarBoundsDidChange), name: AKViewBoundsDidChangeNotification, object: nil)
    }
    
    private func removeObserversFromStatusBar() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AKViewBoundsDidChangeNotification, object: nil)
    }
    
    // MARK: • Responders
    
    func keyboardFrameWillChange(notification: NSNotification) {
        let frameEnd = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let animationDuration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue as NSTimeInterval
        
        let inset = self.view.frame.size.height-frameEnd.origin.y
        self.constraintContentSizeBottom.constant = inset
        self.view.setNeedsUpdateConstraints()
        UIView.animateWithDuration(animationDuration, delay: 0.0, options: .CurveEaseIn, animations: {
            self.view.layoutIfNeeded()
            self.scrollView.contentInset = UIEdgeInsets(top: self.scrollView.contentInset.top, left: self.scrollView.contentInset.left, bottom: inset, right: self.scrollView.contentInset.right)
            self.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: self.scrollView.scrollIndicatorInsets.top, left: self.scrollView.scrollIndicatorInsets.left, bottom: inset, right: self.scrollView.scrollIndicatorInsets.right)
            }, completion: {
                (finished: Bool) in
                self.scrollView.flashScrollIndicators()
        })
    }
    
    func statusBarBoundsDidChange(notification: NSNotification) {
        let view = notification.object as! UIView
        if (!view.isEqual(self.statusBarSize)) {
            return
        }
        
        let statusBarBounds = (notification.userInfo![NOTIFICATION_OBJECT_KEY] as! NSValue).CGRectValue()
        self.scrollView.contentInset = UIEdgeInsets(top: statusBarBounds.size.height, left: self.scrollView.contentInset.left, bottom: self.scrollView.contentInset.bottom, right: self.scrollView.contentInset.right)
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: statusBarBounds.size.height, left: self.scrollView.scrollIndicatorInsets.left, bottom: self.scrollView.scrollIndicatorInsets.bottom, right: self.scrollView.scrollIndicatorInsets.right)
    }
    
}
