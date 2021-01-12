//
//  Missile.swift
//  Shaky Rocket
//
//  Created by macbook on 1/17/20.
//  Copyright © 2020 example. All rights reserved.
//

import SpriteKit

class MissileSprite: SKSpriteNode {
    var fireEmitter: SKEmitterNode!
    
    func configure(at position: CGPoint) {
        
        self.position = position
        
        self.size = CGSize(width: 14, height: 40.8)
        self.name = "missile"
        self.zRotation = -(CGFloat.pi / 2)
        let move = SKAction.moveBy(x: 65, y: 0, duration: 0.3857)
        let bigmove = SKAction.moveBy(x: 630, y: 0, duration: 2.6143)
        let givePhysics = SKAction.run {
            [weak self] in
            self?.physicsBody = SKPhysicsBody(rectangleOf: self!.size)
            self?.physicsBody?.affectedByGravity = false
            self?.physicsBody?.linearDamping = 0
            self?.physicsBody?.categoryBitMask = UInt32(0)
            self?.physicsBody?.collisionBitMask = UInt32(1)
            self?.physicsBody?.contactTestBitMask = self!.physicsBody!.collisionBitMask
        }
        let remove = SKAction.run {
            [weak self] in
            self?.removeFromParent()
        }
        let sequence = SKAction.sequence([move, givePhysics, bigmove, remove])
        self.run(sequence)
        
        fireEmitter = SKEmitterNode(fileNamed: "MissileFire")
        fireEmitter.position = CGPoint(x: 0, y: -20)
        addChild(fireEmitter)
    }
}
