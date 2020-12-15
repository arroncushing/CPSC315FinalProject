//
//  Player.swift
//  FinalProjectTwinstick
//
//  Created by Cushing, Arron C on 12/12/20.
//

import Foundation
import SpriteKit
import GameplayKit

class Player: SKSpriteNode {
    var maxHealth : Int = 5
    var currentHealth : Int = 5
    var attackDamage: Int = 3
    var attackedRecently: Bool = false
    
    init() {
        let texture = SKTexture(imageNamed: "player")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("player initialization error")
    }
}
