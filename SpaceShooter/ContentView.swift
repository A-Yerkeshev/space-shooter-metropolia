//
//  ContentView.swift
//  SpaceShooter
//
//  Created by Arman Yerkeshev on 25.11.2024.
//

import SwiftUI
import SwiftData
import SpriteKit
import GameKit

class GameScene: SKScene {
    let background = SKSpriteNode(imageNamed: "stars-background")
    var player = SKSpriteNode()
    var playerFire = SKSpriteNode()
    var enemy = SKSpriteNode()
    
    var fireTimer = Timer()
    var enemyTimer = Timer()
    
    override func didMove(to view: SKView) {
        scene?.size = CGSize(width: 750, height: 1335)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.setScale(2.1)
        background.zPosition = 1
        addChild(background)
        
        makePlayer(playerCh: 1)
        
        fireTimer = .scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(playerFireFunction), userInfo: nil, repeats: true)
        
        enemyTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(makeEnemy), userInfo: nil, repeats: true)
    }
    
    func makePlayer(playerCh: Int) {
        var shipName = ""
        
        switch playerCh {
        case 1:
            shipName = "ship_1"
        case 2:
            shipName = "ship_5"
        default:
            shipName = "ship_6"
        }
        
        player = .init(imageNamed: shipName)
        player.position = CGPoint(x: size.width / 2, y: 120)
        player.zPosition = 10
        player.setScale(2.8)
        addChild(player)
    }
    
    @objc func playerFireFunction() {
        playerFire = .init(imageNamed: "shot")
        playerFire.position = player.position
        playerFire.zPosition = 3
        
        addChild(playerFire)
        
        let moveAction = SKAction.moveTo(y: 1400, duration: 1)
        let deleteAction = SKAction.removeFromParent()
        let combine = SKAction.sequence([moveAction, deleteAction])
        
        playerFire.run(combine)
    }
    
    @objc func makeEnemy() {
        let randomNumber = GKRandomDistribution(lowestValue: 50, highestValue: 700)
        
        enemy = .init(imageNamed: "ship_3")
        enemy.position = CGPoint(x: randomNumber.nextInt(), y: 1400)
        enemy.zPosition = 5
        enemy.setScale(2.8)
        enemy.zRotation = 3.14159

        addChild(enemy)
        
        let moveAction = SKAction.moveTo(y: -100, duration: 3)
        let deleteAction = SKAction.removeFromParent()
        let combine = SKAction.sequence([moveAction, deleteAction])
        
        enemy.run(combine)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            player.position.x = location.x
        }
    }
}

struct ContentView: View {
    let scene = GameScene()

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
