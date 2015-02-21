//
//  MailboxViewController.swift
//  Hu-Mailbox
//
//  Created by Hi_Hu on 2/17/15.
//  Copyright (c) 2015 hi_hu. All rights reserved.
//

import UIKit

class MailboxViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var msgContainerView: UIView!
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var rightIcon: UIImageView!
    @IBOutlet weak var leftIcon: UIImageView!

    var msgViewOrigin: CGPoint!     // original center point of msgView
    var msgPanCenter: CGPoint!      // current center point of msgView
    var rightIconOrigin: CGPoint!
    var leftIconOrigin: CGPoint!
    var offsetIcon: CGFloat!        // offset of the left and right icons
    
    var bgGrey: UIColor!
    var bgGreen: UIColor!
    var bgRed: UIColor!
    var bgYellow: UIColor!
    var bgBrown: UIColor!
    
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

        // set the origins of the assets
        msgViewOrigin = msgView.center
        rightIconOrigin = rightIcon.center
        leftIconOrigin = leftIcon.center
        rightIcon.alpha = 0
        leftIcon.alpha = 0

        offsetIcon = 187.5
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
//         println("translation: \(translation)    velocity: \(velocity)    center: \(msgView.center)")
            
            // change the msgView center
            msgView.center = CGPoint(x: msgPanCenter.x + translation.x, y: msgPanCenter.y)
            
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
                case 1, 2:
                    // auto slide msg off the screen to the right
                    UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: nil, animations: { () -> Void in
                        
                        // slide msgView off screen
                        self.msgView.center.x = self.msgViewOrigin.x + 360
                        self.leftIcon.center.x = self.msgView.center.x - self.offsetIcon
                        
                        }, completion: { (Bool) -> Void in
                            // code
                            self.feedShift(true)
                            delay(0.5, { () -> () in
                                self.resetIcons()
                                self.resetMessage()
                            })
                    })
                case -1, -2:
                    // auto slide msg off the screen to the left
                    UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: nil, animations: { () -> Void in
                        
                        // slide msgView off screen
                        self.msgView.center.x = self.msgViewOrigin.x - 360
                        self.rightIcon.center.x = self.msgView.center.x + self.offsetIcon
                        
                        }, completion: { (Bool) -> Void in
                            // code
                            self.feedShift(true)
                            delay(0.5, { () -> () in
                                self.resetIcons()
                                self.resetMessage()
                            })
                    })
                    if(rangeX == -1) {
                        // show ImageView
                    } else {
                        // show otherImageView but set the image property
                    }
                
                default:
                    break
            }
        }
    }
    
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

    func resetIcons() {
        rightIcon.center = rightIconOrigin
        rightIcon.image = UIImage(named: "later_icon.png")
        rightIcon.alpha = 0
        leftIcon.center = leftIconOrigin
        leftIcon.image = UIImage(named: "archive_icon.png")
        leftIcon.alpha = 0
    }
    
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
    
    func resetMessage() {
        self.msgView.center = CGPoint(x: self.msgViewOrigin.x, y: msgViewOrigin.y - 86)
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            // code
            self.msgView.center = self.msgViewOrigin

        })
        feedShift(false)
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
