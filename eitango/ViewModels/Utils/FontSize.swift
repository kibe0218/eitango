import Foundation

func EnfontSize(_ i: String) -> Int {
    if i.count > 15 { return 30 }
    else if i.count > 11 { return 40 }
    else { return 50 }
}

func JpfontSize(_ i: String) -> Int {
    if i.count > 7 { return 30 } else { return 40 }
}
