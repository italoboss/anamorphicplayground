//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Provides supporting functions for setting up a live view.
//

import UIKit
import PlaygroundSupport

public func instantiatePageOneLiveView() -> PlaygroundLiveViewable {
    if #available(iOS 11.0, *) {
        return LiveViewController()
    } else {
        // Fallback on earlier versions
        return instantiateNoARLiveView()
    }
}

public func instantiatePageTwoLiveView() -> PlaygroundLiveViewable {
    if #available(iOS 11.0, *) {
        return PageTwoLiveViewController()
    } else {
        // Fallback on earlier versions
        return instantiateNoARLiveView()
    }
}

public func instantiatePageThreeLiveView() -> PlaygroundLiveViewable {
    if #available(iOS 11.0, *) {
        return PageThreeLiveViewController()
    } else {
        // Fallback on earlier versions
        return instantiateNoARLiveView()
    }
}

public func instantiateNoARLiveView() -> PlaygroundLiveViewable {
    return NoARLiveViewController()
}

public func instantiateAboutMeLiveView() -> PlaygroundLiveViewable {
    return AboutMeLiveViewController()
}
