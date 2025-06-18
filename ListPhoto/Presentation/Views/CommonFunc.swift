//
//  CommonFunc.swift
//  ListPhoto
//
//  Created by Phuoc's MAc on 18/6/25.
//
import UIKit

extension String {
    var isBlank: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

//func containsEmoji(_ text: String) -> Bool {
//     for scalar in text.unicodeScalars {
//         switch scalar.value {
//         case 0x1F600...0x1F64F, // emoticons
//              0x1F300...0x1F5FF, // symbols & pictographs
//              0x1F680...0x1F6FF, // transport & map symbols
//              0x2600...0x26FF,   // miscellaneous symbols
//              0x2700...0x27BF,   // dingbats
//              0xFE00...0xFE0F,   // variation selectors
//              0x1F900...0x1F9FF, // supplemental symbols and pictographs
//              0x1F1E6...0x1F1FF: // flags
//             return true
//         default:
//             continue
//         }
//     }
//     return false
// }

func createLoadingView(viewFrame: CGRect) -> UIView {
    let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: viewFrame.width, height: viewFrame.height))
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    activityIndicator.center = loadingView.center
    activityIndicator.startAnimating()
    loadingView.addSubview(activityIndicator)
    return loadingView
}
