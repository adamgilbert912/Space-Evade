//
//  OptionsMenu.swift
//  Shaky Rocket
//
//  Created by macbook on 4/11/20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class OptionsMenu: SKShapeNode {
    
    func configure(color: UIColor, menuSize: CGSize, soundFXOn: Bool, musicOn: Bool) {
        self.fillColor = color
        
        let exitOutline = SKShapeNode(circleOfRadius: 12)
        exitOutline.fillColor = .white
        exitOutline.zPosition = 4
        exitOutline.position = CGPoint(x: menuSize.width/2, y: menuSize.height/2)
        exitOutline.name = "exitOutline"
        addChild(exitOutline)
        
        let exitCoverColor = SKShapeNode(circleOfRadius: 11)
        exitCoverColor.fillColor = color
        exitCoverColor.zPosition = 5
        exitOutline.addChild(exitCoverColor)
        
        let exitSymbol1 = SKShapeNode(rectOf: CGSize(width: 15, height: 4), cornerRadius: 3)
        exitSymbol1.fillColor = .white
        exitSymbol1.zRotation = CGFloat.pi/4
        exitSymbol1.zPosition = 6
        exitOutline.addChild(exitSymbol1)
        
        let exitSymbol2 = SKShapeNode(rectOf: CGSize(width: 15, height: 4), cornerRadius: 3)
        exitSymbol2.fillColor = .white
        exitSymbol2.zRotation = CGFloat.pi * (3/4)
        exitSymbol2.zPosition = 6
        exitOutline.addChild(exitSymbol2)
        
        let soundEffectsLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        soundEffectsLabel.text = "Sound FX:"
        soundEffectsLabel.color = .white
        soundEffectsLabel.fontSize = 32
        soundEffectsLabel.horizontalAlignmentMode = .right
        soundEffectsLabel.position = CGPoint(x: -menuSize.width/20, y: menuSize.height/5)
        soundEffectsLabel.zPosition = 4
        addChild(soundEffectsLabel)
        
        let musicLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        musicLabel.text = "Music:"
        musicLabel.color = .white
        musicLabel.fontSize = 32
        musicLabel.horizontalAlignmentMode = .right
        musicLabel.position = CGPoint(x: -menuSize.width/20, y: -menuSize.height/5)
        musicLabel.zPosition = 4
        addChild(musicLabel)
        
        let soundFXButton = SKSpriteNode(imageNamed: "element_grey_square_glossy")
        soundFXButton.size = CGSize(width: 64, height: 64)
        soundFXButton.position = CGPoint(x: menuSize.width/4, y: soundEffectsLabel.position.y + 10)
        soundFXButton.zPosition = 4
        soundFXButton.name = "soundFXButton"
        addChild(soundFXButton)
        
        let musicButton = SKSpriteNode(imageNamed: "element_grey_square_glossy")
        musicButton.size = soundFXButton.size
        musicButton.position = CGPoint(x: soundFXButton.position.x, y: musicLabel.position.y + 10)
        musicButton.zPosition = 4
        musicButton.name = "musicButton"
        addChild(musicButton)
                
        let greenShape1 = SKSpriteNode(color: .init(red: 0.3, green: 0.85, blue: 0.3, alpha: 1), size: CGSize(width: 29, height: 29))
        greenShape1.zPosition = 1
        greenShape1.name = "greenShape1"
        if !soundFXOn {
            greenShape1.position = CGPoint(x: -30, y: 0)
        }
        
        let whiteShape1 = SKSpriteNode(color: .white, size: greenShape1.size)
        
        let greenShape2 = SKSpriteNode(color: greenShape1.color, size: greenShape1.size)
        greenShape2.zPosition = 1
        greenShape2.name = "greenShape2"
        if !musicOn {
            greenShape2.position = CGPoint(x: -30, y: 0)
        }
        
        let whiteShape2 = SKSpriteNode(color: whiteShape1.color, size: whiteShape1.size)
        
        let maskNode = CheckMark()
        maskNode.configure()
        
        let cropNode1 = SKCropNode()
        cropNode1.maskNode = maskNode
        cropNode1.zPosition = 6
        cropNode1.name = "cropNode1"
        cropNode1.addChild(greenShape1)
        cropNode1.addChild(whiteShape1)
        
        soundFXButton.addChild(cropNode1)
        
        let cropNode2 = SKCropNode()
        cropNode2.maskNode = maskNode
        cropNode2.zPosition = 6
        cropNode2.name = "cropNode2"
        cropNode2.addChild(greenShape2)
        cropNode2.addChild(whiteShape2)
        
        musicButton.addChild(cropNode2)
    }
}
