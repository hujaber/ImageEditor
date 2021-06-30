//
//  CropButton.swift
//  ImageEditor
//
//  Created by Hussein Jaber on 17/06/2021.
//

import UIKit

class CropButton: UIButton {
    
    enum Position {
        case topLeft
        case topRight
        case bottomRight
        case bottomLeft
    }
    
    private (set) var position: Position
    
    init(position: Position, frame: CGRect) {
        self.position = position
        super.init(frame: frame)
        setTitle("X", for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
