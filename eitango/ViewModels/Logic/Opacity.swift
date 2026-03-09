import Foundation

class Opacity {
    
    func Enopacity(isFlipped: Bool, reverse: Bool) -> Double {
        return isFlipped ? (reverse ? 1 : 0) : (reverse ? 0 : 1)
    }

    func Jpopacity(isFlipped: Bool, reverse: Bool) -> Double {
        return isFlipped ? (reverse ? 0 : 1) : (reverse ? 1 : 0)
    }

}
