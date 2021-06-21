//
//  CropButton.swift
//  ImageEditor
//
//  Created by Hussein Jaber on 17/06/2021.
//

import UIKit

protocol CropButtonDelegate: AnyObject {
    func didChangeFrame(for button: CropButton, position: CropButton.Position)
}

class CropButton: UIButton {
    
    enum Position {
        case topLeft
        case topRight
        case bottomRight
        case bottomLeft
    }
    
    override var frame: CGRect {
        didSet {
            delegate?.didChangeFrame(for: self, position: position)
        }
    }
    
    weak var delegate: CropButtonDelegate?
    
    private (set) var position: Position
    
    init(position: Position, frame: CGRect) {
        self.position = position
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
