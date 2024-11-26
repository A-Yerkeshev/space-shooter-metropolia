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

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let background = SKSpriteNode(imageNamed: "stars-background")
    var player = SKSpriteNode()
    var playerFire = SKSpriteNode()
    var enemy = SKSpriteNode()
    
    var score = 0
    var scoreLabel = SKLabelNode()
    
    var fireTimer = Timer()
    var enemyTimer = Timer()
    
    struct CBitmask {
        static let playerShip: UInt32 = 0b1 //1
        static let playerFire: UInt32 = 0b10 //2
        static let enemyShip: UInt32 = 0b100 //4
        static let bossOne: UInt32 = 0b1000 //8
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        scene?.size = CGSize(width: 750, height: 1335)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.setScale(2.1)
        background.zPosition = 1
        addChild(background)
        
        makePlayer(playerCh: 1)
        
        fireTimer = .scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(playerFireFunction), userInfo: nil, repeats: true)
        
        enemyTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(makeEnemy), userInfo: nil, repeats: true)
    
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontName = "Chalkduster"
        scoreLabel.fontSize = 50
        scoreLabel.fontColor = .red
        scoreLabel.zPosition = 99
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 1.2)
        addChild(scoreLabel)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("Contact detected: \(contact.bodyA.categoryBitMask) with \(contact.bodyB.categoryBitMask)")

        let contactA : SKPhysicsBody
        let contactB : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            contactA = contact.bodyA
            contactB = contact.bodyB
        } else {
            contactA = contact.bodyB
            contactB = contact.bodyA
        }
        
        // Player hits the enemy
        if contactA.categoryBitMask == CBitmask.playerFire && contactB.categoryBitMask == CBitmask.enemyShip {
            
            updateScore()
            
            playerFireHitEnemy(fires: contactA.node as! SKSpriteNode, enemys: contactB.node as! SKSpriteNode)
            
        }
        
        if contactA.categoryBitMask == CBitmask.playerShip && contactB.categoryBitMask == CBitmask.enemyShip {
            
            playerHitEnemy(players: contactA.node as! SKSpriteNode, enemys: contactB.node as! SKSpriteNode)
            
        }
    }
    
    func playerHitEnemy(players: SKSpriteNode, enemys: SKSpriteNode) {
        players.removeFromParent()
        enemys.removeFromParent()

        let explo = SKEmitterNode(fileNamed: "ExplosionOne")
        explo?.position = players.position
        explo?.zPosition = 5
        addChild(explo!)
    }

    func playerFireHitEnemy(fires: SKSpriteNode, enemys: SKSpriteNode) {
        fires.removeFromParent()
        enemys.removeFromParent()

        let explo = SKEmitterNode(fileNamed: "ExplosionOne")
        explo?.position = enemys.position
        explo?.zPosition = 5
        addChild(explo!)
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
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = CBitmask.playerShip
        player.physicsBody?.contactTestBitMask = CBitmask.enemyShip
        player.physicsBody?.collisionBitMask = CBitmask.enemyShip
        addChild(player)
    }
    
    @objc func playerFireFunction() {
        playerFire = .init(imageNamed: "shot")
        playerFire.position = player.position
        playerFire.zPosition = 3
        playerFire.physicsBody = SKPhysicsBody(rectangleOf: playerFire.size)
        playerFire.physicsBody?.affectedByGravity = false
        playerFire.physicsBody?.categoryBitMask = CBitmask.playerFire
        playerFire.physicsBody?.contactTestBitMask = CBitmask.enemyShip
        playerFire.physicsBody?.collisionBitMask = CBitmask.enemyShip
        
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
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = CBitmask.enemyShip
        enemy.physicsBody?.contactTestBitMask = CBitmask.playerShip | CBitmask.playerFire
        enemy.physicsBody?.collisionBitMask = CBitmask.playerShip | CBitmask.playerFire
        addChild(enemy)
        
        let moveAction = SKAction.moveTo(y: -100, duration: 3)
        let deleteAction = SKAction.removeFromParent()
        let combine = SKAction.sequence([moveAction, deleteAction])
        
        enemy.run(combine)
    }
    
    func updateScore() {
        score += 1
        print("Score updated: \(score)")
        scoreLabel.text = "Score: \(score)"
        
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
