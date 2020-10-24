//
//  AboutMeLiveViewController.swift
//  Book_Sources
//
//  Created by Italo Boss on 23/03/19.
//

import UIKit
import PlaygroundSupport

@objc(Book_Sources_AboutMeLiveViewController)
public class AboutMeLiveViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let pic = UIImage(named: "me.png") else {
            return
        }
        let imageView = UIImageView(image: pic)
        self.view.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute:NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint])
    }
    
    public func receive(_ message: PlaygroundValue) {
        // Implement this method to receive messages sent from the process running Contents.swift.
    }
    
}
