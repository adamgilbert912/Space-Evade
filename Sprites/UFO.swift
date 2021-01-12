//
//  UFO.swift
//  Shaky Rocket
//
//  Created by macbook on 1/15/20.
//  Copyright © 2020 example. All rights reserved.
//

import SpriteKit

class UFO: SKSpriteNode {
    var emitter: SKEmitterNode!
    var isNormalSpeed = true
    var normalSpeed: Double = -30
    var isSlowingDown = false
    
    func configure(at position: CGPoint, move time: TimeInterval) {
        
        self.position = position
        self.size = CGSize(width: 62, height: 29)
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.angularDamping = 0
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = UInt32(1)
        self.physicsBody?.collisionBitMask = UInt32(0) | UInt32(1) | UInt32(4)
        self.physicsBody?.contactTestBitMask = self.physicsBody!.collisionBitMask
        self.physicsBody?.mass = 10000
        self.name = "UFO"
        
        emitter = SKEmitterNode(fileNamed: "UFOStream")!
        emitter.position = CGPoint(x: 0, y: -7)
        emitter.zPosition = -1
        addChild(emitter)
        
        moveUp(move: time)
    }
    
    func moveUp(move time: TimeInterval) {
        if isNormalSpeed {
            normalSpeed = -30
            let moveUp = SKAction.moveBy(x: CGFloat(normalSpeed), y: 75, duration: time)
            self.run(moveUp)
        } else if isSlowingDown {
            normalSpeed *= 0.9222
            let moveUp = SKAction.moveBy(x: CGFloat(normalSpeed), y: 75, duration: time)
            self.run(moveUp)
        } else {
            normalSpeed = -90
            let moveUp = SKAction.moveBy(x: CGFloat(normalSpeed), y: 75, duration: time)
            self.run(moveUp)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            [weak self] in
            self?.moveDown(move: time)
        }
    }
    
    func moveDown(move time: TimeInterval) {
        if isNormalSpeed {
            normalSpeed = -30
            let moveDown = SKAction.moveBy(x: CGFloat(normalSpeed), y: -75, duration: time)
            self.run(moveDown)
        } else if isSlowingDown {
            normalSpeed *= 0.8622
            let moveDown = SKAction.moveBy(x: CGFloat(normalSpeed), y: -75, duration: time)
            self.run(moveDown)
        } else {
            normalSpeed = -90
            let moveDown = SKAction.moveBy(x: CGFloat(normalSpeed), y: -75, duration: time)
            self.run(moveDown)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            [weak self] in
            self?.moveUp(move: time)
        }
    }
    
}
