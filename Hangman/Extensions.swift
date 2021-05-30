//
//  Extensions.swift
//  Hangman
//
//  Created by Azat Kaiumov on 30.05.2021.
//

import Foundation
import UIKit

extension UIFont {
    static func prefferedFont(for style: TextStyle, weight: Weight) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let font = UIFont.systemFont(ofSize: descriptor.pointSize, weight: weight)
        return metrics.scaledFont(for: font)
    }
}
