//
//  NoARViewController.swift
//  Book_Sources
//
//  Created by Italo Boss on 19/03/19.
//

import UIKit
import PlaygroundSupport

@objc(Book_Sources_NoARLiveViewController)
public class NoARLiveViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    public func receive(_ message: PlaygroundValue) {
        // Implement this method to receive messages sent from the process running Contents.swift.
        // This method is *required* by the PlaygroundLiveViewMessageHandler protocol.
        // Use this method to decode any messages sent as PlaygroundValue values and respond accordingly.
    }
}
