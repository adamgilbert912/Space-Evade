//
//  CheckMark.swift
//  Shaky Rocket
//
//  Created by macbook on 4/12/20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation
import SpriteKit

class CheckMark: SKNode {
    
    func configure() {
        
        let checkMark11 = SKSpriteNode(color: .init(red: 0.3, green: 0.85, blue: 0.3, alpha: 1), size: CGSize(width: 16.8, height: 6))
        checkMark11.position = CGPoint(x: -7.5, y: -7)
        checkMark11.zRotation = -CGFloat.pi/4
        
        let checkMark12 = SKSpriteNode(color: checkMark11.color, size: CGSize(width: 25, height: 6))
        checkMark12.position = CGPoint(x: 4.5, y: -2.5)
        checkMark12.zRotation = CGFloat.pi/4
        
        addChild(checkMark11)
        addChild(checkMark12)
    }
}
