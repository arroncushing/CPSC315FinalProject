//
//  GameScene.swift
//  FinalProjectTwinstick
//
//  Created by Cushing, Arron C on 11/30/20.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = Player()
    let leftControllerBase = SKSpriteNode(imageNamed: "ControllerBase")
    let rightControllerBase = SKSpriteNode(imageNamed: "ControllerBase")
    let leftControlStick = SKSpriteNode(imageNamed: "ControlStick")
    let rightControlStick = SKSpriteNode(imageNamed: "ControlStick")
    let healthLabel = SKLabelNode(text: "")
    let scoreLabel = SKLabelNode(text: "")
    let cameraNode = SKCameraNode()
    var leftJoystickAngle = CGFloat()
    var leftJoystickIsActive = false
    var rightJoystickAngle = CGFloat()
    var rightJoystickIsActive = false
    var timeOfLastAttack: TimeInterval = TimeInterval()
    var enemyTest = Enemy()
    var enemies: [Enemy] = []
    var enemiesDefeated: Int = 0
    var timer: Timer? = nil
    
    
    enum NodeCategory: UInt32{
        case player = 1
        case playerProjectile = 2
        case enemy = 4
        case terrain = 8
    }
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        loadPlayer()
        
        self.addChild(cameraNode)
        camera = cameraNode
        cameraNode.position.x = size.width / 2
        cameraNode.position.y = size.height / 2
        cameraNode.xScale = 0.6
        cameraNode.yScale = 0.6
        
        let background = SKSpriteNode(imageNamed: "gamebg")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = size
        background.zPosition = -1
        addChild(background)
        
        initializeEnemies()
        initializeWalls()
        loadControlSticks()
        loadLabels()
        setupTimer()

    }
    
    func loadPlayer() {
        player.position.x = size.width / 2
        player.position.y = size.height / 2
        player.size = CGSize(width: 36, height: 36)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = NodeCategory.player.rawValue
        player.physicsBody?.contactTestBitMask = NodeCategory.enemy.rawValue
        player.physicsBody?.collisionBitMask = NodeCategory.terrain.rawValue
        
        
        self.addChild(player)
    }

    func loadControlSticks() {
        cameraNode.addChild(leftControllerBase)
        leftControllerBase.position.x = -400
        leftControllerBase.position.y = -200
        leftControllerBase.zPosition = 10
        leftControllerBase.alpha = 0.5
        leftControllerBase.size = CGSize(width: 120, height: 120)
        
        cameraNode.addChild(leftControlStick)
        leftControlStick.position = leftControllerBase.position
        leftControlStick.zPosition = 10
        leftControlStick.size = CGSize(width: 60, height: 60)
        
        cameraNode.addChild(rightControllerBase)
        rightControllerBase.position.x = 400
        rightControllerBase.position.y = -200
        rightControllerBase.zPosition = 10
        rightControllerBase.alpha = 0.5
        rightControllerBase.size = CGSize(width: 120, height: 120)
        
        cameraNode.addChild(rightControlStick)
        rightControlStick.position = rightControllerBase.position
        rightControlStick.zPosition = 10
        rightControlStick.size = CGSize(width: 60, height: 60)
    }
    
    func initializeEnemies() {
        
        for _ in 1...3 {
            let enemy = Enemy()
            enemy.position = selectRandomPositionOffCamera()
            enemy.size = CGSize(width: 40, height: 40)
            enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width / 2)
            enemy.physicsBody?.affectedByGravity = false
            enemy.physicsBody?.categoryBitMask = NodeCategory.enemy.rawValue
            enemy.physicsBody?.contactTestBitMask = NodeCategory.player.rawValue | NodeCategory.playerProjectile.rawValue
            enemy.physicsBody?.collisionBitMask = NodeCategory.terrain.rawValue
            enemies.append(enemy)
            self.addChild(enemy)
        }
        
    }
    
    func resetControlSticks() {
        leftControllerBase.removeFromParent()
        leftControlStick.removeFromParent()
        rightControllerBase.removeFromParent()
        rightControlStick.removeFromParent()
        loadControlSticks()
    }
    
    func loadLabels() {
        healthLabel.text = "Health: \(player.currentHealth)/\(player.maxHealth)"
        healthLabel.fontName = "AvenirNext-Bold"
        healthLabel.fontSize = 32
        healthLabel.zPosition = 10
        healthLabel.color = .white
        healthLabel.position = CGPoint(x: frame.minX + 200, y: frame.maxY - 50)
        cameraNode.addChild(healthLabel)
        
        scoreLabel.text = "Enemies Defeated: \(enemiesDefeated)"
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 32
        scoreLabel.zPosition = 10
        scoreLabel.color = .white
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        cameraNode.addChild(scoreLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if player.attackedRecently {
            player.attackedRecently = false
            timeOfLastAttack = currentTime
        }
        if leftJoystickIsActive {
            let action = SKAction.moveBy(x: 5 * cos(leftJoystickAngle), y: 5 * sin(leftJoystickAngle), duration: (1.0/60.0))
            player.run(action)
        }
        if rightJoystickIsActive {
            if currentTime - timeOfLastAttack >= 0.75 {
                launchAttack()
                player.attackedRecently = true
            }
        }
        cameraNode.position = player.position
        if player.currentHealth <= 0 {
            gameOver()
        }
        handleEnemies()
        
    }
    
    func initializeWalls(){
        let horizontalBarrier = SKTexture(imageNamed: "horizontalrockborder")
        let verticalBarrier = SKTexture(imageNamed: "verticalrockborder")
        
        let topBarrier = SKSpriteNode(imageNamed: "horizontalrockborder")
        topBarrier.position = CGPoint(x: size.width / 2, y: size.height)
        topBarrier.physicsBody = SKPhysicsBody(texture: horizontalBarrier, size: horizontalBarrier.size())
        topBarrier.physicsBody?.affectedByGravity = false
        topBarrier.physicsBody?.categoryBitMask = NodeCategory.terrain.rawValue
        topBarrier.physicsBody?.mass = 255
        self.addChild(topBarrier)
        
        let bottomBarrier = SKSpriteNode(imageNamed: "horizontalrockborder")
        bottomBarrier.position = CGPoint(x: size.width / 2, y: 0)
        bottomBarrier.physicsBody = SKPhysicsBody(texture: horizontalBarrier, size: horizontalBarrier.size())
        bottomBarrier.physicsBody?.affectedByGravity = false
        bottomBarrier.physicsBody?.categoryBitMask = NodeCategory.terrain.rawValue
        bottomBarrier.physicsBody?.mass = 255
        self.addChild(bottomBarrier)
        
        let leftBarrier = SKSpriteNode(imageNamed: "verticalrockborder")
        leftBarrier.position = CGPoint(x: 0, y: size.height / 2)
        leftBarrier.physicsBody = SKPhysicsBody(texture: verticalBarrier, size: verticalBarrier.size())
        leftBarrier.physicsBody?.affectedByGravity = false
        leftBarrier.physicsBody?.categoryBitMask = NodeCategory.terrain.rawValue
        leftBarrier.physicsBody?.mass = 255
        self.addChild(leftBarrier)
        
        let rightBarrier = SKSpriteNode(imageNamed: "verticalrockborder")
        rightBarrier.position = CGPoint(x: size.width, y: size.height / 2)
        rightBarrier.physicsBody = SKPhysicsBody(texture: verticalBarrier, size: verticalBarrier.size())
        rightBarrier.physicsBody?.affectedByGravity = false
        rightBarrier.physicsBody?.categoryBitMask = NodeCategory.terrain.rawValue
        rightBarrier.physicsBody?.mass = 255
        self.addChild(rightBarrier)
    }
    
    func handleEnemies() {
        var index: Int = 0
        for enemy in enemies {
            enemy.chasePlayer(player)
            if enemy.currHealth <= 0 {
                enemy.removeFromParent()
                enemiesDefeated += 1
                updateLabels()
                enemies.remove(at: index)
            }
            index += 1
        }
    }
    
    func updateLabels() {
        cameraNode.removeChildren(in: [scoreLabel, healthLabel])
        healthLabel.text = "Health: \(player.currentHealth)/\(player.maxHealth)"
        scoreLabel.text = "Enemies Defeated: \(enemiesDefeated)"
        cameraNode.addChild(healthLabel)
        cameraNode.addChild(scoreLabel)
    }
    
    func selectRandomPositionOffCamera() -> CGPoint{
        var randX = 0
        var randY = 0
        if(cameraNode.position.x >= size.width / 2) {
            randX = Int(arc4random_uniform(UInt32(cameraNode.position.x)))
        }
        else {
            randX = Int(arc4random_uniform(UInt32(size.width - cameraNode.position.x))) + Int(cameraNode.position.x)
        }
        
        if(cameraNode.position.y >= size.width / 2) {
            randY = Int(arc4random_uniform(UInt32(cameraNode.position.y)))
        }
        else {
            randY = Int(arc4random_uniform(UInt32(size.height - cameraNode.position.y))) + Int(cameraNode.position.y)
        }
        return CGPoint(x: randX, y: randY)
    }
    
    func gameOver() {
        let menuScene = MenuScene(size: size, score: enemiesDefeated)
        let transition = SKTransition.doorway(withDuration: 1)
        view?.presentScene(menuScene, transition: transition)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == NodeCategory.player.rawValue || contact.bodyB.categoryBitMask == NodeCategory.player.rawValue {
            if contact.bodyA.categoryBitMask == NodeCategory.enemy.rawValue || contact.bodyB.categoryBitMask == NodeCategory.enemy.rawValue { // player collided with enemy
                player.currentHealth -= 1
                updateLabels()
            }
        }
        
        if contact.bodyA.categoryBitMask == NodeCategory.playerProjectile.rawValue || contact.bodyB.categoryBitMask == NodeCategory.playerProjectile.rawValue {
            if contact.bodyA.categoryBitMask == NodeCategory.enemy.rawValue || contact.bodyB.categoryBitMask == NodeCategory.enemy.rawValue {
                if contact.bodyA.categoryBitMask == NodeCategory.enemy.rawValue {
                    guard let enemy = contact.bodyA.node as? Enemy else {
                        return
                    }
                    enemy.currHealth -= 3
                }
                else {
                    guard let enemy = contact.bodyB.node as? Enemy else {
                        return
                    }
                    enemy.currHealth -= 3
                }
                contact.bodyA.categoryBitMask == NodeCategory.playerProjectile.rawValue ? contact.bodyA.node?.removeFromParent() : contact.bodyB.node?.removeFromParent()
            }
            else if contact.bodyA.categoryBitMask == NodeCategory.terrain.rawValue || contact.bodyB.categoryBitMask == NodeCategory.terrain.rawValue {
                contact.bodyA.categoryBitMask == NodeCategory.playerProjectile.rawValue ? contact.bodyA.node?.removeFromParent() : contact.bodyB.node?.removeFromParent()
            }
        }
    }
    
    func setupTimer(){
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { (timer) in self.generateEnemy()})
        
    }
    
    func generateEnemy(){
        let enemy = Enemy()
        enemy.position = selectRandomPositionOffCamera()
        enemy.size = CGSize(width: 40, height: 40)
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width / 2)
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = NodeCategory.enemy.rawValue
        enemy.physicsBody?.contactTestBitMask = NodeCategory.player.rawValue | NodeCategory.playerProjectile.rawValue
        enemy.physicsBody?.collisionBitMask = NodeCategory.terrain.rawValue
        enemies.append(enemy)
        switch (enemiesDefeated % 10) {
        case 0: // normal, < 10 defeated
            enemy.maxHealth = 10
        case 1: // >= 10 and < 20 defeated
            enemy.charSpeed = 2
            enemy.maxHealth = 15
        case 2:
            enemy.charSpeed = 2
            enemy.maxHealth = 18
        case 3:
            enemy.charSpeed = 3
            enemy.maxHealth = 18
        case 4:
            enemy.charSpeed = 3
            enemy.maxHealth = 21
        default: //>= 50 defeated
            enemy.charSpeed = 4
            enemy.maxHealth = 21
        }
        enemy.currHealth = enemy.maxHealth
        self.addChild(enemy)
    }
    
    
    func launchAttack() {
        let projectile = SKSpriteNode(imageNamed: "PlayerProjectile")
        self.addChild(projectile)
        projectile.position = player.position
        projectile.size = CGSize(width: player.size.width * 0.5, height: player.size.height * 0.5)
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width / 2)
        projectile.physicsBody?.categoryBitMask = NodeCategory.playerProjectile.rawValue
        projectile.physicsBody?.contactTestBitMask = NodeCategory.enemy.rawValue | NodeCategory.terrain.rawValue
        projectile.physicsBody?.affectedByGravity = false
        let launch = SKAction.applyImpulse(CGVector(dx: 3 * cos(rightJoystickAngle), dy: 3 * sin(rightJoystickAngle)), duration: 3)
        let remove = SKAction.removeFromParent()
        let action = SKAction.sequence([launch, remove])
        projectile.run(action)
        
    }
}
