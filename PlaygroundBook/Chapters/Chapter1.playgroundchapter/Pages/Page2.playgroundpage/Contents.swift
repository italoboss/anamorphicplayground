//#-hidden-code
import UIKit
import PlaygroundSupport

public var revealed = false

public func reveal() {
    revealed = true
}
//#-end-hidden-code
/*:
 ## There are other ways to distorce images and made an Anamorphic Illusion.
 One of them uses the reflection property of the light. To do this we use the same grid with squares to draw the original image and so we transfer to a distorced grid that is made up of concentric circles and radial lines.
 
 ![How to use grid](grids_two.jpg)
 
 The science about that lies in the Law of Reflection. It describes that when light reflects on a surface, it is reflected at the same angle as it entered.
 
 It's simple to imagine this occurring in a flat mirror, right? But things change on a curved surface, where each ray of light reflects in a slightly different direction, because of the curvature of the surface, enough to distort the image again and show it in its original form.
 
 Thus, for the illusion to work in a cylindrical mirror, the distortion of the image must follow the curvature of the cylinder.
 *image-goes-here*
 
 ## Now, let's try it again!
 Select an plane to add the image without revelation and try to figure out what it is.
 
 After that, for this time, we have to code. Use the method `reveal()` and run the code to see the image revealed in *cylinder*.
 */
//#-code-completion(everything, hide)
//#-code-completion(identifier, show, reveal())
//#-editable-code Tap to enter code

//#-end-editable-code
//#-hidden-code
let page = PlaygroundPage.current
let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
proxy?.send(.boolean(revealed))
if revealed {
    page.assessmentStatus = PlaygroundPage.AssessmentStatus.pass(message: "That's right! Now you can see the revealed image in the cylinder.")
}
//#-end-hidden-code
