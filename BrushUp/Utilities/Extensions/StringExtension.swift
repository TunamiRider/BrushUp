//
//  StringExtension.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/21/26.
//
import UIKit
extension String {
    func getSize() -> CGFloat{
        let font = UIFont.systemFont(ofSize: 16)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (self as NSString).size(withAttributes: attributes)
        return size.width
    }
}
