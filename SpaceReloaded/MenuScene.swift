//
//  MenuScene.swift
//  SpaceReloaded
//
//  Created by Rani on 2/4/19.
//  Copyright © 2019 rani. All rights reserved.
//

import SpriteKit
import UIKit


class MenuScene: SKScene {
   private var starfield: SKEmitterNode!
   private var newGameButtonNode: SKSpriteNode!
   private var difficultyButton: SKSpriteNode!
   private var difficultyLabelNode: SKLabelNode!
    
    override func didMove(to view: SKView) {
        starfield = self.childNode(withName: String.StarFieldName) as? SKEmitterNode
        starfield.advanceSimulationTime(10)
        starfield.isUserInteractionEnabled = false
        
        newGameButtonNode = self.childNode(withName: String.NewGameButtonName) as? SKSpriteNode
        
        difficultyButton = self.childNode(withName: String.DifficultyButtonName) as? SKSpriteNode
        difficultyButton.texture = SKTexture(imageNamed: String.DifficultyLevelImageName)
        
        difficultyLabelNode = self.childNode(withName: String.DifficultyLabelName) as? SKLabelNode
        
        setDifficultyLevelText()
    }
    
    private func setDifficultyLevelText() {
        difficultyLabelNode.text = isHardLevel ? "Hard" : "Easy"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let nodesArray = nodes(at: location)
            if nodesArray.last?.name == String.NewGameButtonName {
                startNewGame()
            } else if nodesArray.last?.name == String.DifficultyButtonName {
                changeDifficultyLevel()
            }
        }
    }
    
   private func startNewGame() {
        let transition = SKTransition.flipVertical(withDuration: 0.75)
        let gameScene = GameScene(size: self.size)
        self.view?.presentScene(gameScene, transition: transition)
    }
    
    
    var isHardLevel: Bool {
        return UserDefaults.standard.bool(forKey: String.HardKey)
    }
    
   private func changeDifficultyLevel() {
        UserDefaults.standard.set(!isHardLevel, forKey: String.HardKey)
        UserDefaults.standard.synchronize()
        setDifficultyLevelText()
    }
}

extension String {
    static let NewGameButtonName    : String = "newGameButton"
    static let DifficultyButtonName : String = "difficultyButton"
    static let DifficultyLabelName  : String = "difficultyLabelNode"
    static let StarFieldName        : String = "starfield"
    static let DifficultyLevelImageName      = "DifficultyLevelButton"
    static let HardKey      = "hard"
    static let HighestScoreKey = "highestScoreKey"
    static let HardText     = "Hard"
    static let EasyText     = "Easy"
    
}
