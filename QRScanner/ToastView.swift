//
//  ToastView.swift
//  JCH VCC
//
//  Created by Sami on 1/30/19.
//  Copyright © 2019 Sami. All rights reserved.
//

import UIKit
import Foundation

@objc open class ToastView: NSObject {
    
    var overlayView = UIView()
    var backView = UIView()
    var lbl = UILabel()
    var warnlbl = UILabel()
    
    @objc class var shared: ToastView {
        struct Static {
            static let instance: ToastView = ToastView()
        }
        return Static.instance
    }
    
    @objc func setup(_ view: UIView,txt_msg:String)
    {
        let white = UIColor ( red: 1/255, green: 0/255, blue:0/255, alpha: 0.0 )
        
        backView.frame = CGRect(x: 0, y: 0, width: view.frame.width , height: view.frame.height)
        backView.center = view.center
        backView.backgroundColor = white
        view.addSubview(backView)
        
        overlayView.frame = CGRect(x: 0, y: 0, width: view.frame.width - 40  , height: 50)
        overlayView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height - 80)
        overlayView.backgroundColor = UIColor.black
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 25
        overlayView.alpha = 0
        
        lbl.frame = CGRect(x: 0, y: 0, width: overlayView.frame.width, height: 50)
        lbl.numberOfLines = 0
        lbl.textColor = .white
        lbl.center = overlayView.center
        lbl.text = txt_msg
        lbl.textAlignment = .center
        lbl.center = CGPoint(x: overlayView.bounds.width / 2, y: overlayView.bounds.height / 2)
        overlayView.addSubview(lbl)
        
        view.addSubview(overlayView)
    }
    
    @objc func warnSetup(_ view: UIView,txt_msg:String, show: String)
    {
        
        warnlbl.frame = CGRect(x: 0, y: 0, width: view.frame.width - 50, height: 50)
        warnlbl.numberOfLines = 0
        warnlbl.font = UIFont(name: "Aclonica", size: 14.0)
        warnlbl.textColor = .red
        warnlbl.center = overlayView.center
        warnlbl.text = txt_msg
        warnlbl.textAlignment = .center
        warnlbl.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height - 80)
        if show == "show" {
            warnlbl.isHidden = false
        } else {
           warnlbl.isHidden = true
        }
        view.addSubview(warnlbl)
    }
    
    @objc open func short(_ view: UIView?, txt_msg:String?) {
        if let view = view, let txt_msg = txt_msg {
            self.setup(view,txt_msg: txt_msg)
            //Animation
            UIView.animate(withDuration: 1, animations: {
                self.overlayView.alpha = 1
            }) { (true) in
                UIView.animate(withDuration: 1, animations: {
                    self.overlayView.alpha = 0
                }) { (true) in
                    UIView.animate(withDuration: 1, animations: {
                        DispatchQueue.main.async(execute: {
                            self.overlayView.alpha = 0
                            self.lbl.removeFromSuperview()
                            self.overlayView.removeFromSuperview()
                            self.backView.removeFromSuperview()
                        })
                    })
                }
            }
        }
    }
    
    @objc open func warn(_ view: UIView?, txt_msg:String?, show: String?) {
        if let view = view, let txt_msg = txt_msg, let show = show {
            self.warnSetup(view,txt_msg: txt_msg, show: show)
            
        }
    }
    
   @objc open func shortWithCompletion(_ view: UIView,txt_msg:String,completion: @escaping (_ success: String) -> Void) {
        self.setup(view,txt_msg: txt_msg)
        //Animation
        UIView.animate(withDuration: 1, animations: {
            self.overlayView.alpha = 1
        }) { (true) in
            UIView.animate(withDuration: 1, animations: {
                self.overlayView.alpha = 0
            }) { (true) in
                UIView.animate(withDuration: 1, animations: {
                    DispatchQueue.main.async(execute: {
                        self.overlayView.alpha = 0
                        self.lbl.removeFromSuperview()
                        self.overlayView.removeFromSuperview()
                        self.backView.removeFromSuperview()
                        completion("success")
                    })
                })
            }
        }
    }
    
    
    @objc open func long(_ view: UIView?, txt_msg:String) {
        if let view = view {
            self.setup(view,txt_msg: txt_msg)
            //Animation
            UIView.animate(withDuration: 2, animations: {
                self.overlayView.alpha = 1
                self.lbl.alpha = 1
            }) { (true) in
                UIView.animate(withDuration: 2, animations: {
                    self.overlayView.alpha = 0
                    self.lbl.alpha = 1
                }) { (true) in
                    UIView.animate(withDuration: 2, animations: {
                        DispatchQueue.main.async(execute: {
                            self.overlayView.alpha = 0
                            self.lbl.removeFromSuperview()
                            self.overlayView.removeFromSuperview()
                            self.backView.removeFromSuperview()
                        })
                    })
                }
            }
        }
    }
    
    @objc open func longWithCompletion(_ view: UIView, txt_msg:String, completion: @escaping (_ success: String) -> Void) {
        
        self.setup(view,txt_msg: txt_msg)
        //Animation
        UIView.animate(withDuration: 1, animations: {
            self.overlayView.alpha = 1
        }) { (true) in
            UIView.animate(withDuration: 1, animations: {
                self.overlayView.alpha = 0
            }) { (true) in
                UIView.animate(withDuration: 1, animations: {
                    DispatchQueue.main.async(execute: {
                        self.overlayView.alpha = 0
                        self.lbl.removeFromSuperview()
                        self.overlayView.removeFromSuperview()
                        self.backView.removeFromSuperview()
                        completion("success")
                    })
                })
            }
        }
    }
}
