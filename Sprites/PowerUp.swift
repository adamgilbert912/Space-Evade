//
//  File.swift
//  Shaky Rocket
//
//  Created by macbook on 1/16/20.
//  Copyright © 2020 example. All rights reserved.
//

import SpriteKit

class PowerUp: SKNode {
    var missilePowerUp: SKSpriteNode!
    var fastPowerUp: SKSpriteNode!
    var blowUpPowerUp: SKSpriteNode!
    
    func configure(at position: CGPoint) {
        
        self.position = position
        
        let randomNumber = Int.random(in: 1...1)
        
        let move = SKAction.moveTo(x: -100, duration: 15)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([move, remove])
        
        self.run(sequence)
        
        if randomNumber == 0 {
            missilePowerUp = SKSpriteNode(imageNamed: "spaceMissiles_004")
            missilePowerUp.size = CGSize(width: 14, height: 40.8)
            missilePowerUp.zPosition = -1
            
            self.name = "missle"
            
            addChild(missilePowerUp)
            
            let emitter = SKEmitterNode(fileNamed: "MissilePowerUpGlow")!
            addChild(emitter)
            
            //maybe make fast powerup less likely its kinda op
        } else if randomNumber == 1 {
            fastPowerUp = SKSpriteNode(imageNamed: "fire")
            fastPowerUp.size = CGSize(width: 32, height: 45.511)
            fastPowerUp.zPosition = -1
            
            self.name = "fast"
            
            addChild(fastPowerUp)
            
            let emitter = SKEmitterNode(fileNamed: "FastPowerUpGlow")!
            addChild(emitter)
            
        } else if randomNumber == 2 {
            blowUpPowerUp = SKSpriteNode(imageNamed: "Nuclear")
            blowUpPowerUp.zPosition = -1
            
            self.name = "Nuclear"
            
            addChild(blowUpPowerUp)
            
            blowUpPowerUp.addGlow(radius: 20)
        }
    }
    
}

extension SKSpriteNode {
    
    func addGlow(radius: CGFloat) {
        
        let effect = SKEffectNode()
        
        effect.shouldRasterize = true
        addChild(effect)
        
        effect.addChild(SKSpriteNode(texture: texture))
        effect.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": radius])
    }
}

extension SKSpriteNode {
    
    func addGlow2(radius: CGFloat) {
        
        let effect = SKEffectNode()
        
        effect.shouldRasterize = true
        addChild(effect)
        
        effect.addChild(SKSpriteNode(texture: texture))
        effect.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": radius])
    }
}
