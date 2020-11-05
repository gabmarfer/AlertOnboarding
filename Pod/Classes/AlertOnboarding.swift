//
//  AlertOnboarding.swift
//  AlertOnboarding
//
//  Created by Philippe on 26/09/2016.
//  Copyright © 2016 CookMinute. All rights reserved.
//

import UIKit

@objc public protocol AlertOnboardingDelegate {
    func alertOnboardingSkipped(_ currentStep: Int, maxStep: Int)
    func alertOnboardingCompleted()
    func alertOnboardingNext(_ nextStep: Int)
    
    @objc optional func alertOnboardingDidDisplayStep(alertOnboarding: AlertOnboarding, alertChildPageViewController: AlertChildPageViewController, step: Int)
}

open class AlertOnboarding: UIView, AlertPageViewDelegate {
    
    //FOR DATA  ------------------------
    fileprivate var arrayOfAlerts = [Alert]()
    
    //FOR DESIGN    ------------------------
    open var buttonBottom: UIButton!
    fileprivate var alertPageViewController: AlertPageViewController!
    open var background: UIView!
    
    //PUBLIC VARS   ------------------------
    @objc open var colorForAlertViewBackground: UIColor = UIColor.white
    
    @objc open var colorButtonBottomBackground: UIColor = UIColor(red: 226/255, green: 237/255, blue: 248/255, alpha: 1.0)
    @objc open var colorButtonText: UIColor = UIColor(red: 118/255, green: 125/255, blue: 152/255, alpha: 1.0)
    
    @objc open var colorTitleLabel: UIColor = UIColor(red: 171/255, green: 177/255, blue: 196/255, alpha: 1.0)
    @objc open var colorDescriptionLabel: UIColor = UIColor(red: 171/255, green: 177/255, blue: 196/255, alpha: 1.0)
    
    @objc open var fontTitleLabel: UIFont? = UIFont(name: "Avenir-Heavy", size: 17);
    @objc open var fontDescriptionLabel: UIFont? = UIFont(name: "Avenir-Book", size: 13);
    @objc open var fontButtonText: UIFont? = UIFont(name: "Avenir-Black", size: 15);
    @objc open var textAlignmentDescriptionLabel: NSTextAlignment = .natural
    
    @objc open var colorPageIndicator = UIColor(red: 171/255, green: 177/255, blue: 196/255, alpha: 1.0)
    @objc open var colorCurrentPageIndicator = UIColor(red: 118/255, green: 125/255, blue: 152/255, alpha: 1.0)
    
    @objc open var imageContentMode: UIView.ContentMode = .scaleToFill
    /// Defines proportion between imageView and its containerView. Default is 80% (0.8)
    open var imageAspectRatio: CGFloat?
    
    open var heightForAlertView: CGFloat!
    open var widthForAlertView: CGFloat!
    
    @objc open var percentageRatioHeight: CGFloat = 0.8
    @objc open var percentageRatioWidth: CGFloat = 0.8
    
    @objc open var nextInsteadOfSkip = false
    
    @objc open var titleNextButton = "NEXT"
    @objc open var titleSkipButton = "SKIP"
    @objc open var titleGotItButton = "GOT IT !"
    
    @objc open var delegate: AlertOnboardingDelegate?
    
    @objc public init (arrayOfAlerts: [Alert]) {
        super.init(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
        self.configure()
        self.arrayOfAlerts = arrayOfAlerts
        
        self.interceptOrientationChange()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
    }
    
    deinit {
        print("Called deinit")
    }
    
    //-----------------------------------------------------------------------------------------
    // MARK: PUBLIC FUNCTIONS    --------------------------------------------------------------
    //-----------------------------------------------------------------------------------------
    
    @objc open func show() {
        
        //Update Color
        self.buttonBottom.backgroundColor = colorButtonBottomBackground
        self.backgroundColor = colorForAlertViewBackground
        self.buttonBottom.setTitleColor(colorButtonText, for: UIControl.State())
        self.buttonBottom.setTitle(self.titleSkipButton, for: UIControl.State())
        
        self.alertPageViewController = AlertPageViewController(arrayOfAlerts: arrayOfAlerts, alertView: self)
        self.alertPageViewController.delegate = self
        self.insertSubview(self.alertPageViewController.view, aboveSubview: self)
        self.insertSubview(self.buttonBottom, aboveSubview: self)
        
        // Only show once
        if self.superview != nil {
            return
        }
        
        // Find current stop viewcontroller
        if let topController = getTopViewController() {
            let superView: UIView = topController.view
            superView.addSubview(self.background)
            superView.addSubview(self)
            self.configureConstraints(topController.view)
            self.animateForOpening()
        }
    }
    
    //Hide onboarding with animation
    @objc open func hide(){
        self.checkIfOnboardingWasSkipped()
        DispatchQueue.main.async { () -> Void in
            self.animateForEnding()
        }
    }
    
    
    //------------------------------------------------------------------------------------------
    // MARK: PRIVATE FUNCTIONS    --------------------------------------------------------------
    //------------------------------------------------------------------------------------------
    
    //MARK: Check if onboarding was skipped
    fileprivate func checkIfOnboardingWasSkipped(){
        let currentStep = self.alertPageViewController.currentStep
        if currentStep < (self.alertPageViewController.arrayOfAlerts.count - 1) && !self.alertPageViewController.isCompleted {
            self.delegate?.alertOnboardingSkipped(currentStep, maxStep: self.alertPageViewController.maxStep)
        }
        else {
            self.delegate?.alertOnboardingCompleted()
        }
    }
    
    
    //MARK: FOR CONFIGURATION    --------------------------------------
    fileprivate func configure() {
        self.buttonBottom = UIButton(frame: CGRect(x: 0,y: 0, width: 0, height: 0))
        self.buttonBottom.titleLabel?.font = fontButtonText
        self.buttonBottom.addTarget(self, action: #selector(AlertOnboarding.onClick), for: .touchUpInside)
        
        self.background = UIView(frame: CGRect(x: 0,y: 0, width: 0, height: 0))
        self.background.backgroundColor = UIColor.black
        self.background.alpha = 0.5
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
    }
    
    
    fileprivate func configureConstraints(_ superview: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        buttonBottom.translatesAutoresizingMaskIntoConstraints = false
        alertPageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        background.translatesAutoresizingMaskIntoConstraints = false
        alertPageViewController.pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        removeConstraints(constraints)
        buttonBottom.removeConstraints(buttonBottom.constraints)
        alertPageViewController.view.removeConstraints(alertPageViewController.view.constraints)
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: percentageRatioWidth),
            heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: percentageRatioHeight),
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor),
            
            alertPageViewController.view.widthAnchor.constraint(equalTo: widthAnchor),
            alertPageViewController.view.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.9),
            alertPageViewController.view.topAnchor.constraint(equalTo: topAnchor),
            alertPageViewController.view.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            
            background.leftAnchor.constraint(equalTo: superview.leftAnchor),
            background.rightAnchor.constraint(equalTo: superview.rightAnchor),
            background.topAnchor.constraint(equalTo: superview.topAnchor),
            background.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            
            alertPageViewController.pageControl.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            alertPageViewController.pageControl.bottomAnchor.constraint(equalTo: buttonBottom.topAnchor),
            
            buttonBottom.widthAnchor.constraint(equalTo: widthAnchor),
            buttonBottom.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.1),
            buttonBottom.bottomAnchor.constraint(equalTo: bottomAnchor),
            buttonBottom.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
        ])
    }
    
    //MARK: FOR ANIMATIONS ---------------------------------
    fileprivate func animateForOpening(){
        self.alpha = 1.0
        self.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        UIView.animate(withDuration: 1, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
    }
    
    fileprivate func animateForEnding(){
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
            }, completion: {
                [weak self] finished in
                guard let self = self else { return }
                // On main thread
                DispatchQueue.main.async {
                    () -> Void in
                    self.stopInterceptingOrientationChanges()
                    self.delegate = nil
                    self.alertPageViewController.delegate = nil
                    self.background.removeFromSuperview()
                    self.removeFromSuperview()
                    self.alertPageViewController.removeFromParent()
                    self.alertPageViewController.view.removeFromSuperview()
                }
        })
    }
    
    //MARK: BUTTON ACTIONS ---------------------------------
    
    @objc func onClick(){
        if (nextInsteadOfSkip) {
            if let viewController = self.alertPageViewController.viewControllerAtIndex((self.alertPageViewController.pageController.viewControllers?[0] as! AlertChildPageViewController).pageIndex!-1)
            {
                self.alertPageViewController.pageController.setViewControllers([viewController], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
                self.alertPageViewController.didMoveToPageIndex(pageIndex: (viewController as! AlertChildPageViewController).pageIndex)
                
                return;
            }
        }
        
        self.hide()
    }
    
    //MARK: ALERTPAGEVIEWDELEGATE    --------------------------------------
    
    func nextStep(_ step: Int) {
        self.delegate?.alertOnboardingNext(step)
    }
    
    //MARK: OTHERS    --------------------------------------
    fileprivate func getTopViewController() -> UIViewController? {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
        return topController
    }
    
    //MARK: NOTIFICATIONS PROCESS ------------------------------------------
    fileprivate func interceptOrientationChange(){
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(AlertOnboarding.onOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    fileprivate func stopInterceptingOrientationChanges() {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func onOrientationChange(){
        if let superview = self.superview {
            self.configureConstraints(superview)
        }
    }
}
