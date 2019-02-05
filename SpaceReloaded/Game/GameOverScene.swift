//
//  GameOverScene.swift
//  SpaceReloaded
//
//  Created by Rani on 2/5/19.
//  Copyright © 2019 rani. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    private var starfield: SKEmitterNode!
    private var newGameButton: SKSpriteNode!
    
    private var currentScoreLabelNode: SKLabelNode!
    private var highScoreLabelNode: SKLabelNode!
    
    override func didMove(to view: SKView) {
        starfield = self.childNode(withName: "starfield") as? SKEmitterNode
        starfield.advanceSimulationTime(10)
        
        newGameButton = self.childNode(withName: "newGameButton") as? SKSpriteNode
     
        currentScoreLabelNode = self.childNode(withName: "currentScoreLabelNode") as? SKLabelNode
        highScoreLabelNode = self.childNode(withName: "highScoreLabelNode") as? SKLabelNode
        
        
        
    }
}
