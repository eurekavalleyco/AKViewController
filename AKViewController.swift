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

class AKViewController: UIViewController {
    
    // MARK: - Public API
    
    // MARK: • IBOutlets
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    // MARK: • Variables
    
    // MARK: • Functions
    
    // MARK: - Private API
    
    // MARK: • IBOutlets
    
    lazy private var statusBarView: AKView! = {
        let statusBarView = AKView.init()
        statusBarView.userInteractionEnabled = false
        statusBarView.translatesAutoresizingMaskIntoConstraints = false
        statusBarView.backgroundColor = UIColor.clearColor()
        return statusBarView
    }()
    lazy private var contentSizeView: UIView! = {
        let contentSizeView = UIView.init()
        contentSizeView.userInteractionEnabled = false
        contentSizeView.translatesAutoresizingMaskIntoConstraints = false
        contentSizeView.backgroundColor = UIColor.clearColor()
        return contentSizeView
    }()
    private var constraintContentSizeBottom: NSLayoutConstraint!
    
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
        
        self.view.addSubview(self.statusBarView)
        self.view.sendSubviewToBack(self.statusBarView)
        self.view.addConstraint(self.statusBarView.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor))
        self.view.addConstraint(self.statusBarView.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor))
        self.view.addConstraint(self.statusBarView.topAnchor.constraintEqualToAnchor(self.view.topAnchor))
        self.view.addConstraint(self.statusBarView.bottomAnchor.constraintEqualToAnchor(self.topLayoutGuide.bottomAnchor))
        
        self.view.addSubview(self.contentSizeView)
        self.view.sendSubviewToBack(self.contentSizeView)
        self.view.addConstraint(self.contentSizeView.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor))
        self.view.addConstraint(self.contentSizeView.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor))
        self.view.addConstraint(self.contentSizeView.topAnchor.constraintEqualToAnchor(self.topLayoutGuide.bottomAnchor))
        self.constraintContentSizeBottom = self.contentSizeView.bottomAnchor.constraintEqualToAnchor(self.bottomLayoutGuide.topAnchor)
        self.view.addConstraint(self.constraintContentSizeBottom)
        self.view.addConstraint(self.contentSizeView.widthAnchor.constraintLessThanOrEqualToAnchor(self.contentView.widthAnchor))
        self.view.addConstraint(self.contentSizeView.heightAnchor.constraintLessThanOrEqualToAnchor(self.contentView.heightAnchor))
        let constraintWidth = self.contentSizeView.widthAnchor.constraintEqualToAnchor(self.contentView.widthAnchor)
        constraintWidth.priority = UILayoutPriorityDefaultLow
        self.view.addConstraint(constraintWidth)
        let constraintHeight = self.contentSizeView.heightAnchor.constraintEqualToAnchor(self.contentView.heightAnchor)
        constraintHeight.priority = UILayoutPriorityDefaultLow
        self.view.addConstraint(constraintHeight)
        
        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height ?? 0
        self.scrollView.contentInset = UIEdgeInsets(top: self.scrollView.contentInset.top, left: self.scrollView.contentInset.left, bottom: tabBarHeight, right: self.scrollView.contentInset.right)
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: self.scrollView.scrollIndicatorInsets.top, left: self.scrollView.scrollIndicatorInsets.left, bottom: tabBarHeight, right: self.scrollView.scrollIndicatorInsets.right)
    }
    
    // MARK: • Delegated
    
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardDidAppear), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardFrameWillChange), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    private func removeObserversFromKeyboard() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidChangeFrameNotification, object: nil)
    }
    
    private func addObserversToStatusBar() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.statusBarBoundsDidChange), name: AKViewBoundsDidChangeNotification, object: nil)
    }
    
    private func removeObserversFromStatusBar() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AKViewBoundsDidChangeNotification, object: nil)
    }
    
    // MARK: • Responders
    
    func keyboardDidAppear(notification: NSNotification) {
        self.scrollView.flashScrollIndicators()
    }
    
    func keyboardFrameWillChange(notification: NSNotification) {
        let frameEnd = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let animationDuration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue as NSTimeInterval
        
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        let tabBarHeight = (statusBarHeight > 0.0) ? (self.tabBarController?.tabBar.frame.size.height ?? 0) : 0.0
        let inset = max(self.view.frame.size.height-frameEnd.origin.y-tabBarHeight, 0.0)
        self.constraintContentSizeBottom.constant = -1.0*inset
        self.view.setNeedsUpdateConstraints()
        UIView.animateWithDuration(animationDuration, delay: 0.0, options: .CurveEaseIn, animations: {
            self.view.layoutIfNeeded()
            self.scrollView.contentInset = UIEdgeInsets(top: self.scrollView.contentInset.top, left: self.scrollView.contentInset.left, bottom: inset, right: self.scrollView.contentInset.right)
            self.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: self.scrollView.scrollIndicatorInsets.top, left: self.scrollView.scrollIndicatorInsets.left, bottom: inset, right: self.scrollView.scrollIndicatorInsets.right)
        }, completion:nil)
    }
    
    func statusBarBoundsDidChange(notification: NSNotification) {
        let view = notification.object as! UIView
        if (!view.isEqual(self.statusBarView)) {
            return
        }
        
        let statusBarBounds = (notification.userInfo![NOTIFICATION_OBJECT_KEY] as! NSValue).CGRectValue()
        self.scrollView.contentInset = UIEdgeInsets(top: statusBarBounds.size.height, left: self.scrollView.contentInset.left, bottom: self.scrollView.contentInset.bottom, right: self.scrollView.contentInset.right)
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: statusBarBounds.size.height, left: self.scrollView.scrollIndicatorInsets.left, bottom: self.scrollView.scrollIndicatorInsets.bottom, right: self.scrollView.scrollIndicatorInsets.right)
    }
    
}
