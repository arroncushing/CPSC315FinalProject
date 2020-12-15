//
//  MenuScene.swift
//  FinalProjectTwinstick
//
//  Created by Cushing, Arron C on 12/14/20.
//

import Foundation
import SpriteKit

class MenuScene: SKScene {
    var score: Int = 0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    init(size: CGSize,score: Int){
        self.score = score
        super.init(size: size)
        scaleMode = .aspectFill
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(white: 0, alpha: 1)
        
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = "TrebuchetMS-Bold"
        gameOverLabel.fontSize = 60
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY * 1.5)
        addChild(gameOverLabel)
        
        let scoreLabel = SKLabelNode(text: "Final Score: \(score)")
        scoreLabel.fontName = "TrebuchetMS-Bold"
        scoreLabel.fontSize = 50
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(scoreLabel)
        
        let label = SKLabelNode(text: "Tap anywhere to play again")
        label.fontName = "TrebuchetMS-Bold"
        label.fontSize = 36
        label.fontColor = .white
        label.position = CGPoint(x: frame.midX, y: 72)
        addChild(label)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let gameScene = GameScene(fileNamed: "GameScene") else {
            fatalError("game scene not found")
        }
        let transition = SKTransition.fade(with: .black, duration: 1)
        gameScene.scaleMode = .aspectFill
        view?.presentScene(gameScene, transition: transition)
    }
}
