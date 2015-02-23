//
//  MailboxViewController.swift
//  Hu-Mailbox
//
//  Created by Hi_Hu on 2/17/15.
//  Copyright (c) 2015 hi_hu. All rights reserved.
//

import UIKit

class MailboxViewController: UIViewController {

    @IBOutlet weak var mailboxContainerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var msgContainerView: UIView!
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var rightIcon: UIImageView!
    @IBOutlet weak var leftIcon: UIImageView!
    @IBOutlet weak var modalView: UIImageView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var composeContainerView: UIView!
    
    // segment control
    @IBOutlet weak var laterView: UIImageView!
    @IBOutlet weak var archiveView: UIImageView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var menuIcon: UIImageView!
    @IBOutlet weak var composeIcon: UIImageView!
    
    var edgeGesture: UIScreenEdgePanGestureRecognizer!
    var mailboxPanGesture: UIPanGestureRecognizer!
    
    var mailboxViewOrigin: CGPoint!
    var mailboxViewOffset: CGFloat!
    var mailboxPanCenter: CGPoint!
    var menuOpen: Bool!
    var msgViewOrigin: CGPoint!     // original center point of msgView
    var msgPanCenter: CGPoint!      // current center point of msgView
    var offsetIcon: CGFloat!        // offset of the left and right icons
    var rightIconOrigin: CGPoint!
    var leftIconOrigin: CGPoint!
    
    // color variables
    var bgGrey: UIColor!
    var bgGreen: UIColor!
    var bgRed: UIColor!
    var bgYellow: UIColor!
    var bgBrown: UIColor!
    var bgBlue: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        scrollView.contentSize.height = feedImageView.frame.size.height + 230

        // set color variables
        bgGrey = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1)
        bgGreen = UIColor(red: 0.3843, green: 0.85, blue: 0.3843, alpha: 1)
        bgRed = UIColor(red: 0.9372, green: 0.3294, blue: 0.047, alpha: 1)
        bgYellow = UIColor(red: 1, green: 0.8274, blue: 0.1254, alpha: 1)
        bgBrown = UIColor(red: 0.847, green: 0.65, blue: 0.4588, alpha: 1)
        bgBlue = UIColor(red: 0.3176, green: 0.7255, blue: 0.8588, alpha: 1)

        // set the origins of the assets
        mailboxViewOrigin = mailboxContainerView.center
        msgViewOrigin = msgView.center
        rightIconOrigin = rightIcon.center
        leftIconOrigin = leftIcon.center

        // menu offset
        mailboxViewOffset = 270
        
        // menu is closed
        menuOpen = false
        
        // center offset of msg and icon
        offsetIcon = 187.5
        
        // alpha out assets
        rightIcon.alpha = 0
        leftIcon.alpha = 0
        modalView.alpha = 0
        menuView.alpha = 0
        laterView.alpha = 0
        archiveView.alpha = 0
        
        // add edge gesture
        edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: "onEdgePan:")
        edgeGesture.edges = UIRectEdge.Left
        mailboxContainerView.addGestureRecognizer(edgeGesture)

        mailboxPanGesture = UIPanGestureRecognizer(target: self, action: "mailboxPan:")
        
        // registering keyboard events
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPanMessage(sender: UIPanGestureRecognizer) {
        
        var position = sender.locationInView(view)
        var translation = sender.translationInView(view)
        var velocity = sender.velocityInView(view)
        var rangeX = checkXTranslationRange(translation.x)
        
        if(sender.state == UIGestureRecognizerState.Began) {
            // set the center
            msgPanCenter = msgView.center
            
        } else if(sender.state == UIGestureRecognizerState.Changed) {
            
            // change the msgView center
            msgView.center.x = msgPanCenter.x + translation.x
            
            // change background color and icon based on translation range value
            switch rangeX {
                case 2:
                    msgContainerView.backgroundColor = bgRed
                    leftIcon.image = UIImage(named: "delete_icon.png")
                    leftIcon.center.x = msgView.center.x - offsetIcon
                case 1:
                    msgContainerView.backgroundColor = bgGreen
                    leftIcon.image = UIImage(named: "archive_icon.png")
                    leftIcon.center.x = msgView.center.x - offsetIcon
                case 0:
                    msgContainerView.backgroundColor = bgGrey
                    if(translation.x < 0) {
                        rightIcon.alpha = abs(translation.x / 60)
                    } else {
                        leftIcon.alpha = abs(translation.x / 60)
                    }
                case -1:
                    msgContainerView.backgroundColor = bgYellow
                    rightIcon.image = UIImage(named: "later_icon.png")
                    rightIcon.center.x = msgView.center.x + offsetIcon
                case -2:
                    msgContainerView.backgroundColor = bgBrown
                    rightIcon.image = UIImage(named: "list_icon.png")
                    rightIcon.center.x = msgView.center.x + offsetIcon
                default:
                    break
            }
            
        } else if(sender.state == UIGestureRecognizerState.Ended) {
            
            switch rangeX {
                case 0:
                    UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: nil, animations: { () -> Void in

                        self.msgView.center.x = self.msgViewOrigin.x
                        self.rightIcon.alpha = 0
                        self.leftIcon.alpha = 0

                    }, completion: { (Bool) -> Void in
                        // code
                    })
                case 1:
                    // auto slide msg off the screen to the right
                    UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: nil, animations: { () -> Void in
                        
                        // slide msgView off screen
                        self.msgView.center.x = self.msgViewOrigin.x + 360
                        self.leftIcon.center.x = self.msgView.center.x - self.offsetIcon
                        
                        }, completion: { (Bool) -> Void in
                            self.feedShift(true)
                            self.resetMessage()
                    })
                case 2:
                    // auto slide msg off the screen to the right
                    UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: nil, animations: { () -> Void in
                    
                    // slide msgView off screen
                    self.msgView.center.x = self.msgViewOrigin.x + 360
                    self.leftIcon.center.x = self.msgView.center.x - self.offsetIcon
                    
                    }, completion: { (Bool) -> Void in
                        
                    self.feedShift(true)
                })
                case -1, -2:
                    // auto slide msg off the screen to the left
                    UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: nil, animations: { () -> Void in
                        
                        // slide msgView off screen
                        self.msgView.center.x = self.msgViewOrigin.x - 360
                        self.rightIcon.center.x = self.msgView.center.x + self.offsetIcon
                        
                        }, completion: { (Bool) -> Void in
                            
                            // set the dialogue image based on rangeX
                            if(rangeX == -1) {
                                self.modalView.image = UIImage(named: "reschedule.png")
                            } else {
                                self.modalView.image = UIImage(named: "list.png")
                            }

                            UIView.animateWithDuration(0.3, animations: { () -> Void in
                                self.modalView.alpha = 1
                            })
                    })
                default:
                    break
            }
        }
    }
    
    // map translation ranges to an Int
    func checkXTranslationRange(tX: CGFloat) -> Int {
        // check translation value and map it to a range
        if(190 >= tX && tX > 60 ) {
            return 1 // green
        }
        if(-60 >= tX && tX > -190 ) {
            return -1 // yellow
        }
        if(-190 >= tX) {
            return -2 // brown
        }
        if(tX > 190 ) {
            return 2 // red
        }
        if(60 >= tX  && tX < -60) {
            return 0
        }
        return 0
    }
    
    // shift feed up if true, down if false
    func feedShift(up: Bool) {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            if(up) {
                self.feedImageView.center.y = self.feedImageView.center.y - self.msgContainerView.frame.height
            }
            if(up == false) {
                self.feedImageView.center.y = self.feedImageView.center.y + self.msgContainerView.frame.height
            }
        })
    }
    
    // reset the icons and msgView
    func resetMessage() {        

        delay(0.5, { () -> () in
            
            // reset icons
            self.rightIcon.center = self.rightIconOrigin
            self.rightIcon.image = UIImage(named: "later_icon.png")
            self.rightIcon.alpha = 0
            self.leftIcon.center = self.leftIconOrigin
            self.leftIcon.image = UIImage(named: "archive_icon.png")
            self.leftIcon.alpha = 0
            
            // reset msgView
            self.msgView.center = CGPoint(x: self.msgViewOrigin.x, y: self.msgViewOrigin.y - 86)
            
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                // code
                self.msgView.center = self.msgViewOrigin
            })
            
            self.feedShift(false)
        })
    }

    @IBAction func menuDidPress(sender: AnyObject) {
        if(!menuOpen) {
            menuView.alpha = 1
        }
        menuSlide()
    }

    func onEdgePan(sender: UIScreenEdgePanGestureRecognizer) {
        if(!menuOpen) {
            menuView.alpha = 1
        }
        var translation = sender.translationInView(view)
        
        if(sender.state == UIGestureRecognizerState.Began) {

            mailboxPanCenter = mailboxContainerView.center
            
        } else if(sender.state == UIGestureRecognizerState.Changed) {
            
            mailboxContainerView.center.x = mailboxPanCenter.x + translation.x
            
        } else if(sender.state == UIGestureRecognizerState.Ended) {

            if(translation.x > 100) {
                menuOpen = false
                menuSlide()
            } else {
                menuOpen = true
                menuSlide()
            }
        }
    }
    
    // panning for when menu is open
    func mailboxPan(sender: UIPanGestureRecognizer) {
        
        var translation = sender.translationInView(view)
        
        if(sender.state == UIGestureRecognizerState.Began) {
            
            mailboxPanCenter = mailboxContainerView.center
            
        } else if(sender.state == UIGestureRecognizerState.Changed) {
            
            mailboxContainerView.center.x = mailboxPanCenter.x + translation.x
            
        } else if(sender.state == UIGestureRecognizerState.Ended) {
            
            if(translation.x < -20) {
                menuOpen = true
                menuSlide()
            } else {
                menuOpen = false
                menuSlide()
            }
        }
    }
    
    func menuSlide() {
        if(!menuOpen) {
            UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 1.2, initialSpringVelocity: 15, options: nil, animations: { () -> Void in
                
                self.mailboxContainerView.center.x = self.mailboxContainerView.frame.width / 2 + self.mailboxViewOffset
                
                }) { (Bool) -> Void in
                    self.menuOpen = true
                    
                    // remove edgePan add regular pan
                    self.mailboxContainerView.removeGestureRecognizer(self.edgeGesture)
                    self.mailboxContainerView.addGestureRecognizer(self.mailboxPanGesture)
                    
            }
        } else {
            UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 1.2, initialSpringVelocity: 15, options: nil, animations: { () -> Void in
                
                self.mailboxContainerView.center.x = self.mailboxViewOrigin.x
                
                }) { (Bool) -> Void in
                    self.menuOpen = false

                    // remove regular pan add edge pan
                    self.mailboxContainerView.removeGestureRecognizer(self.mailboxPanGesture)
                    self.mailboxContainerView.addGestureRecognizer(self.edgeGesture)
                    self.menuView.alpha = 0
            }
        }
    }
    
    @IBAction func modalDidTap(sender: UITapGestureRecognizer) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.modalView.alpha = 0
        })
        feedShift(true)
        resetMessage()
    }

    @IBAction func segmentDidPress(sender: UISegmentedControl) {
        var index = sender.selectedSegmentIndex
        var tintColor: UIColor!

        self.laterView.alpha = 1
        self.scrollView.alpha = 1
        self.archiveView.alpha = 1
        
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 1.2, initialSpringVelocity: 15, options: nil, animations: { () -> Void in
            switch index {
            case 0:
                self.laterView.center.x = 160
                self.scrollView.center.x = 480
                self.archiveView.center.x = 800
                sender.tintColor = self.bgYellow
                self.menuIcon.image = UIImage(named: "menu_icon_yellow.png")
                self.composeIcon.image = UIImage(named: "compose_icon_yellow.png")
            case 1:
                self.laterView.center.x = -160
                self.scrollView.center.x = 160
                self.archiveView.center.x = 480
                sender.tintColor = self.bgBlue
                self.menuIcon.image = UIImage(named: "menu_icon.png")
                self.composeIcon.image = UIImage(named: "compose_icon.png")
            case 2:
                self.laterView.center.x = -480
                self.scrollView.center.x = -160
                self.archiveView.center.x = 160
                sender.tintColor = self.bgGreen
                self.menuIcon.image = UIImage(named: "menu_icon_green.png")
                self.composeIcon.image = UIImage(named: "compose_icon_green.png")
            default:
                break
            }
        }, completion: { (Bool) -> Void in
            switch index {
            case 0:
                self.scrollView.alpha = 0
                self.archiveView.alpha = 0
            case 1:
                self.laterView.alpha = 0
                self.archiveView.alpha = 0
            case 2:
                self.laterView.alpha = 0
                self.scrollView.alpha = 0
            default:
                break
            }
        })
    }
    
    @IBAction func composeDidPress(sender: AnyObject) {
        UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 1.3, initialSpringVelocity: 10, options: nil, animations: { () -> Void in
            // code
            self.composeContainerView.alpha = 1
            self.composeContainerView.center.y = 284
        }) { (Bool) -> Void in
            // code
        }
    }
    @IBAction func cancelDidPress(sender: AnyObject) {
        view.endEditing(true)
        UIView.animateWithDuration(1.5, delay: 0, usingSpringWithDamping: 1.5, initialSpringVelocity: 10, options: nil, animations: { () -> Void in
            // code
            self.composeContainerView.center.y = 852
            }) { (Bool) -> Void in
            self.composeContainerView.alpha = 0
        }
    }
    
    // keyboard show & hide functions
    func keyboardWillShow(notification: NSNotification!) {
        var userInfo = notification.userInfo!
        
        // Get the keyboard height and width from the notification
        // Size varies depending on OS, language, orientation
        var kbSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue().size
        var durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] as NSNumber
        var animationDuration = durationValue.doubleValue
        var curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey] as NSNumber
        var animationCurve = curveValue.integerValue
        
        UIView.animateWithDuration(animationDuration, delay: 0.0, options: UIViewAnimationOptions(UInt(animationCurve << 16)), animations: {
            
        }, completion: nil)
    }
    
    func keyboardWillHide(notification: NSNotification!) {
        var userInfo = notification.userInfo!
        
        // Get the keyboard height and width from the notification
        // Size varies depending on OS, language, orientation
        var kbSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue().size
        var durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] as NSNumber
        var animationDuration = durationValue.doubleValue
        var curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey] as NSNumber
        var animationCurve = curveValue.integerValue
        
        UIView.animateWithDuration(animationDuration, delay: 0.0, options: UIViewAnimationOptions(UInt(animationCurve << 16)), animations: {
            
            }, completion: nil)
    }
    
    // shake gesture
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: (UIEvent!)) {
        if(event.subtype == UIEventSubtype.MotionShake) {
            
            var alert = UIAlertController(
                title: "Undo last action?",
                message: "Are you sure you want to undo and move 1 item from Trash back to Inbox?",
                preferredStyle: UIAlertControllerStyle.Alert
            )

            alert.addAction(UIAlertAction(
                title: "Cancel",
                style: UIAlertActionStyle.Default, handler: nil)
            )

            alert.addAction(UIAlertAction(
                title: "Undo",
                style: .Default, handler: { action in
                switch action.style{
                case .Default:
                    self.resetMessage()
                case .Cancel:
                    println("cancel")
                case .Destructive:
                    println("destructive")
                }
            }))

            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
