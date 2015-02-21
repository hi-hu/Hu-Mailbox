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
    @IBOutlet weak var laterIcon: UIImageView!
    @IBOutlet weak var archiveIcon: UIImageView!
    @IBOutlet weak var deleteIcon: UIImageView!
    @IBOutlet weak var listIcon: UIImageView!

    var msgViewOrigin: CGPoint! // original center point of msgView
    var msgPanCenter: CGPoint! // current center point of msgView
    
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
        listIcon.alpha = 0
        deleteIcon.alpha = 0
        
        bgGrey = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1)
        bgGreen = UIColor(red: 0.3843, green: 0.85, blue: 0.3843, alpha: 1)
        bgRed = UIColor(red: 0.9372, green: 0.3294, blue: 0.047, alpha: 1)
        bgYellow = UIColor(red: 1, green: 0.8274, blue: 0.1254, alpha: 1)
        bgBrown = UIColor(red: 0.847, green: 0.65, blue: 0.4588, alpha: 1)

        msgViewOrigin = msgView.center
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPanMessage(sender: UIPanGestureRecognizer) {
        
        var position = sender.locationInView(view)
        var translation = sender.translationInView(view)
        var velocity = sender.velocityInView(view)
        
        if(sender.state == UIGestureRecognizerState.Began) {
            // set the center
            msgPanCenter = msgView.center
            
        } else if(sender.state == UIGestureRecognizerState.Changed) {
            // change the msgView center
            msgView.center = CGPoint(x: msgPanCenter.x + translation.x, y: msgPanCenter.y)

//            println("translation: \(translation)    velocity: \(velocity)    center: \(msgView.center)")
            
            // change background color and icon based on translation
            var rangeX = Int(checkXTranslationRange(translation.x))

            switch rangeX {
                case 2:
                    msgContainerView.backgroundColor = bgBrown
                    laterIcon.alpha = 0
                    listIcon.alpha = 1
                case 1:
                    msgContainerView.backgroundColor = bgGreen
                    archiveIcon.alpha = 1
                    deleteIcon.alpha = 0
                case 0:
                    msgContainerView.backgroundColor = bgGrey
                case -1:
                    msgContainerView.backgroundColor = bgYellow
                    laterIcon.alpha = 1
                    listIcon.alpha = 0
                    // move icons
                    laterIcon.center.x = laterIcon.center.x + translation.x + 60
                
                case -2:
                    msgContainerView.backgroundColor = bgRed
                    archiveIcon.alpha = 0
                    deleteIcon.alpha = 1
                default:
                    break
            }
            
        } else if(sender.state == UIGestureRecognizerState.Ended) {
            // move msgView back to origin
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 20, options: nil, animations: { () -> Void in
                // code
                self.msgView.center = self.msgViewOrigin
                
            }, completion: { (Bool) -> Void in
                // code
            })
        }
    }
    
    func checkXTranslationRange(tX: CGFloat) -> Int {
        // check translation value and map it to a range
        if(190 >= tX && tX > 60 ) {
            return 1
        }
        if(-60 >= tX && tX > -190 ) {
            return -1
        }
        if(-190 >= tX) {
            return 2
        }
        if(tX > 190 ) {
            return -2
        }
        if(60 >= tX  && tX < -60) {
            return 0
        }
        return 0
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
