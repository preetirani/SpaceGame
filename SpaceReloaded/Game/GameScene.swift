//
//  GameScene.swift
//  SpaceReloaded
//
//  Created by Rani on 1/31/19.
//  Copyright © 2019 rani. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    private var starfield: SKEmitterNode!
    private var player: SKSpriteNode!
    
    private var scoreLabel: SKLabelNode!
    private var lifesLabel: SKLabelNode!
    private var gameOverLabel: SKLabelNode!
    var gameTimer: Timer!
    var possibleAliens = ["alien", "alien2", "alien3"]
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
            if score > totalLifes {
                alienAnimationDuration = animationDurationIncreaseFactor <= 0 ? 1 : animationDurationIncreaseFactor
            } else if alienAnimationDuration <= 0 {
                alienAnimationDuration = 1
            }
        }
    }
    
    var totalLifes = 4
    var lifes: Int = 10 {
        didSet {
            lifesLabel.text = "Lifes: \(lifes > 0 ? lifes : 0)"
            
            if lifes <= 0 {
                endGame()
            }
        }
    }
    
    let alienCategory:UInt32 = 0x1 << 1
    let photonTorpedoCategory:UInt32 = 0x1 << 0

    var motionManager = CMMotionManager()
    var xAcceleration: CGFloat = 0
    
    var isGameActive: Bool = true
    
    override func didMove(to view: SKView) {
        addStarfield()
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        addPlayer()
        addScoreLabel()
        addLifeLabel()
        
        var timeInterval = 0.75
        if UserDefaults.standard.bool(forKey: String.HardKey) {
            timeInterval = 0.3
        }
        
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
            }
        }
    }

    func addStarfield() {
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.position = CGPoint(x: 0, y: UIScreen.main.nativeBounds.height)
        starfield.advanceSimulationTime(10)
        starfield.zPosition = -1
        starfield.run(SKAction.speed(to: 10, duration: 0))
        self.addChild(starfield)
    }
    
    
    func addPlayer() {
        player = SKSpriteNode(imageNamed: "shuttle")
        player.position = CGPoint(x: self.frame.size.width/2, y: player.frame.height/2 + 20)
        self.addChild(player)
    }
    
    func addScoreLabel() {
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 100, y: self.frame.height - 60)
        scoreLabel.fontSize = 36
        scoreLabel.color = UIColor.white
        self.addChild(scoreLabel)
        score = 0
    }
   
    func addLifeLabel() {
        lifesLabel = SKLabelNode(text: "Lifes: 100")
        lifesLabel.position = CGPoint(x: 100, y: self.frame.height - 100)
        lifesLabel.fontSize = 24
        lifesLabel.color = UIColor.white
        self.addChild(lifesLabel)
        lifes = totalLifes
    }
    
    func addGameOverLabel() {
        gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        gameOverLabel.fontSize = 50
        gameOverLabel.color = UIColor.white
        self.addChild(gameOverLabel)
    }
    
    func endGame() {
        self.removeAllActions()
        self.removeAllChildren()
        addGameOverLabel()
        self.physicsWorld.contactDelegate = nil
        isGameActive = false
        gameTimer.invalidate()
        motionManager.stopAccelerometerUpdates()
    }
    var alienAnimationDuration: TimeInterval = 6 {
        didSet {
            print("score: \(score), ratio: \(animationDurationIncreaseFactor)) alienAnimationDuration: \(alienAnimationDuration)")
        }
    }
    
    var animationDurationIncreaseFactor: Double {
        return 6 - TimeInterval(Float(score)/Float(200))
    }
    
    @objc func addAlien() {
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        let randomAlienPosition = GKRandomDistribution(lowestValue: 0, highestValue: 400)
        let position = CGFloat(randomAlienPosition.nextInt())
        alien.position = CGPoint(x: position, y: self.frame.size.height + alien.frame.height)
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonTorpedoCategory
        alien.physicsBody?.collisionBitMask = 0

        self.addChild(alien)
        
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -alien.size.height), duration: alienAnimationDuration))
        actionArray.append(SKAction.removeFromParent())
        alien.run(SKAction.sequence(actionArray)) {
            self.lifes -= 1
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameActive {
            fireTorpedo()
        }
    }
    
    func fireTorpedo() {
        self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
        torpedoNode.position = player.position
        torpedoNode.position.y += 5
        
        torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width/2)
        torpedoNode.physicsBody?.isDynamic = true
        torpedoNode.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedoNode.physicsBody?.contactTestBitMask = alienCategory
        torpedoNode.physicsBody?.collisionBitMask = 0
        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(torpedoNode)
        
        let animationDuration: TimeInterval = 0.3
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.height + 10), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        torpedoNode.run(SKAction.sequence(actionArray))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & alienCategory) != 0 {
            torpedoDidCollideWithAlien(torpedoNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    func torpedoDidCollideWithAlien (torpedoNode:SKSpriteNode, alienNode:SKSpriteNode) {
        
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = alienNode.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        torpedoNode.removeFromParent()
        alienNode.removeFromParent()
        
        
        self.run(SKAction.wait(forDuration: 2)) {
            explosion.removeFromParent()
        }
        
        score += 5
        
        
    }
    
    override func didSimulatePhysics() {
        
        player.position.x += xAcceleration * 40
        
        if player.position.x < -20 {
            player.position = CGPoint(x: 0, y: player.position.y)
        }else if player.position.x > self.size.width + 20 {
            player.position = CGPoint(x: self.size.width, y: player.position.y)
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
