//
//  Enemy.swift
//  FinalProjectTwinstick
//
//  Created by Cushing, Arron C on 12/13/20.
//

import Foundation
import SpriteKit
import GameplayKit

class Enemy : SKSpriteNode {
    var maxHealth: Int = 10
    var currHealth: Int = 10
    var attackDamage: Int = 1
    var charSpeed: CGFloat = 1.0
    
    
    init() {
        let texture = SKTexture(imageNamed: "enemy")
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("error in initializing enemy")
    }
    
    func chasePlayer(_ player: Player) {
        let point = player.position
        let dx = point.x - self.position.x
        let dy = point.y - self.position.y
        let angle = atan2(dy, dx)
        
        let action = SKAction.moveBy(x: (charSpeed * cos(angle)), y: (charSpeed * sin(angle)), duration: 1.0/60.0)
        self.run(action)
    }
    
}
