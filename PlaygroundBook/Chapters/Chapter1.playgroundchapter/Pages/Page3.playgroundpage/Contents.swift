//#-hidden-code
import PlaygroundSupport

let selectedStyle: TextStyle
//#-end-hidden-code
/*:
 ## It's time to play with **two planes**.
 
 Until now we have been used one plane to do anamorph. But is it possible to do with two planes or more?
 
 Well, I tell you. **Yeah!**
 
 Imagine you want to draw something on a wall, but in the middle of that wall has a very close column. If we look in front of the wall, we will notice that there are two planes (at least): the wall and the front of the column.
 
 So we have two options: draw using only half the wall or... **Anamorph**! In this case, for the observer, the column is closer than the wall, and from this point of view, the same object drawn in the column will appear larger than on the wall. So, to look like they have the same size, we have to draw smaller in the colun.
 
 Actually, illusions can be more powerful. Now imagine two walls forming a corner. Using the first page principle, we can make drawings on the walls to create the illusion that they are part of the same image. **Let's see this!**
 
 ## It's your time again!
 We have **three** styles (**`.pixel`**, **`.retro`** and **`.comic`**).
 Choose some style for our **anamorphic experience** and "run the code" to see it!
 */

selectedStyle = /*#-editable-code text style*/.pixel/*#-end-editable-code*/

//#-hidden-code
let page = PlaygroundPage.current
let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
proxy?.send(.integer(selectedStyle.rawValue))
//#-end-hidden-code
/*:
 ## Curiosity
 
 In 1533, Hans Holbein painted **The Ambassadors** that has a **anamorphic skull** placed in the bottom center of the composition. To see perfectly the skull, the observer must approach the painting from high on the right side. Pretty like the images we see at this Playground.
 
 ![The Ambassadors](holbein_painting.jpg)
 *Image Source: [Wikipedia](https://en.wikipedia.org/wiki/The_Ambassadors_(Holbein))*
 
 */
