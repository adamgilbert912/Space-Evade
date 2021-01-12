//
//  Coin.swift
//  Shaky Rocket
//
//  Created by macbook on 2/5/20.
//  Copyright © 2020 example. All rights reserved.
//

import SpriteKit

class Coin: SKSpriteNode {
    func configure(starting position: CGPoint, velocity: CGVector?) {
        self.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        self.physicsBody?.angularDamping = 0
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.angularVelocity = CGFloat.random(in: -2...2)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = UInt32(0)
        self.physicsBody?.collisionBitMask = UInt32(1)
        self.zPosition = 1
        self.size = CGSize(width: 15, height: 15)
        self.position = position
        self.name = "Coin"
        
        if let startingVelocity = velocity {
            self.physicsBody?.velocity = startingVelocity
        } else {
            let moveLeft = SKAction.moveTo(x: -55, duration: 15)
            self.run(moveLeft)
        }
    }
}
