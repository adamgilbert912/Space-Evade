//
//  WheelSprite.swift
//  Shaky Rocket
//
//  Created by macbook on 5/13/20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation
import SpriteKit

class WheelSprite: SKShapeNode {
    var isMoving = false
    
    func configure(ship: String?) {
        self.fillColor = .white
        self.zPosition = 2
        self.name = "whiteBackground"
        
        if let shipString = ship {
            let spriteShip = SKSpriteNode(imageNamed: shipString)
            spriteShip.name = shipString
            if shipString != "spaceRockets_003" {
                spriteShip.size = CGSize(width: spriteShip.size.width*(0.5), height: spriteShip.size.height*(0.5))
            }
            spriteShip.zPosition = 3
            if shipString.hasPrefix("spaceRockets") || shipString.hasPrefix("playerShip") {
                spriteShip.zRotation = -CGFloat.pi / 2
            } else if shipString.hasPrefix("spaceShips") {
                spriteShip.zRotation = CGFloat.pi / 2
            }
            addChild(spriteShip)
        } else {
            let number = Int.random(in: 1...11)
            var spriteShip = SKSpriteNode()
            
            if number == 1 {
                spriteShip = SKSpriteNode(imageNamed: "playerShip1_blue")
                spriteShip.name = "playerShip1_blue"
                spriteShip.size = CGSize(width: spriteShip.size.width*(0.5), height: spriteShip.size.height*(0.5))
                spriteShip.zRotation = -CGFloat.pi / 2
            } else if number == 2 {
                spriteShip = SKSpriteNode(imageNamed: "playerShip1_green")
                spriteShip.name = "playerShip1_green"
                spriteShip.size = CGSize(width: spriteShip.size.width*(0.5), height: spriteShip.size.height*(0.5))
                spriteShip.zRotation = -CGFloat.pi / 2
            } else if number == 3 {
                spriteShip = SKSpriteNode(imageNamed: "playerShip3_blue")
                spriteShip.name = "playerShip3_blue"
                spriteShip.size = CGSize(width: spriteShip.size.width*(0.5), height: spriteShip.size.height*(0.5))
                spriteShip.zRotation = -CGFloat.pi / 2
            } else if number == 4 {
                spriteShip = SKSpriteNode(imageNamed: "playerShip3_green")
                spriteShip.name = "playerShip3_green"
                spriteShip.size = CGSize(width: spriteShip.size.width*(0.5), height: spriteShip.size.height*(0.5))
                spriteShip.zRotation = -CGFloat.pi / 2
            } else if number == 5 {
                spriteShip = SKSpriteNode(imageNamed: "spaceRockets_001")
                spriteShip.name = "spaceRockets_001"
                spriteShip.size = CGSize(width: spriteShip.size.width*(0.21), height: spriteShip.size.height*(0.21))
                spriteShip.zRotation = -CGFloat.pi / 2
            } else if number == 6 {
                spriteShip = SKSpriteNode(imageNamed: "spaceRockets_003")
                spriteShip.name = "spaceRockets_003"
                spriteShip.zRotation = -CGFloat.pi / 2
            } else if number == 7 {
                spriteShip = SKSpriteNode(imageNamed: "spaceRockets_004")
                spriteShip.name = "spaceRockets_004"
                spriteShip.size = CGSize(width: spriteShip.size.width*(0.214), height: spriteShip.size.height*(0.214))
                spriteShip.zRotation = -CGFloat.pi / 2
            } else if number == 8 {
                spriteShip = SKSpriteNode(imageNamed: "spaceShips_002")
                spriteShip.name = "spaceShips_002"
                spriteShip.size = CGSize(width: spriteShip.size.width*(0.5), height: spriteShip.size.height*(0.5))
                spriteShip.zRotation = CGFloat.pi / 2
            } else if number == 9 {
                spriteShip = SKSpriteNode(imageNamed: "spaceShips_004")
                spriteShip.name = "spaceShips_004"
                spriteShip.size = CGSize(width: spriteShip.size.width*(0.5), height: spriteShip.size.height*(0.5))
                spriteShip.zRotation = CGFloat.pi / 2
            } else if number == 10 {
                spriteShip = SKSpriteNode(imageNamed: "spaceShips_006")
                spriteShip.name = "spaceShips_006"
                spriteShip.size = CGSize(width: spriteShip.size.width*(0.5), height: spriteShip.size.height*(0.5))
                spriteShip.zRotation = (CGFloat.pi / 2)
            } else if number == 11 {
                spriteShip = SKSpriteNode(imageNamed: "spaceShips_007")
                spriteShip.name = "spaceShips_007"
                spriteShip.size = CGSize(width: spriteShip.size.width*(0.5), height: spriteShip.size.height*(0.5))
                spriteShip.zRotation = (CGFloat.pi / 2)
            }
            
            spriteShip.zPosition = 3
            addChild(spriteShip)
        }
    }
}
