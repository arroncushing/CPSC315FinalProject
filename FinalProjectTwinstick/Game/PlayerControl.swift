//
//  PlayerControl.swift
//  FinalProjectTwinstick
//
//  Created by Cushing, Arron C on 12/1/20.
//

import Foundation
import SpriteKit

extension GameScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: cameraNode)

            if location.x <= 0 {
                leftControllerBase.position = location
                leftControlStick.position = leftControllerBase.position
            }
            else {
                rightControllerBase.position = location
                rightControlStick.position = rightControllerBase.position
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        for touch in touches {
            let location = touch.location(in: cameraNode)
            if location.x <= 0 {
                leftJoystickIsActive = true
                leftJoystickAngle = handleJoystickMotion(leftControlStick, leftControllerBase, location)
            }
            else {
                rightJoystickIsActive = true
                rightJoystickAngle = handleJoystickMotion(rightControlStick, rightControllerBase, location)
            }
        }
    }
    
    func handleJoystickMotion(_ joystick: SKSpriteNode, _ base: SKSpriteNode, _ location: CGPoint) -> CGFloat{
        
        let dx = location.x - base.position.x
        let dy = location.y - base.position.y
        let angle = atan2(dy, dx)
    
        let radius = leftControllerBase.frame.size.height / 2
        let xDistance = cos(angle) * radius
        let yDistance = sin(angle) * radius
    
        if base.frame.contains(location) {
            joystick.position = location
        }
        else {
            joystick.position = CGPoint(x: base.position.x + xDistance, y: base.position.y + yDistance)
        }
        return angle
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch.location(in: cameraNode).x <= 0 {
                leftJoystickIsActive = false
                handleTouchEnd(leftControlStick, leftControllerBase)
            }
            else {
                rightJoystickIsActive = false
                handleTouchEnd(rightControlStick, rightControllerBase)
            }
        }
    }
    
    func handleTouchEnd(_ joystick: SKSpriteNode, _ base: SKSpriteNode) {
        let returnAction = SKAction.move(to: base.position, duration: 0.2)
        returnAction.timingMode = .easeOut
        
        joystick.run(returnAction)
    }
    
}
