//
//  ContentView.swift
//  SpaceShooter
//
//  Created by Arman Yerkeshev on 25.11.2024.
//
import SwiftUI
import SpriteKit
import GameKit
import SwiftData

class GameScene: SKScene, SKPhysicsContactDelegate, ObservableObject {
    
    var modelContext: ModelContext?
    
    let background = SKSpriteNode(imageNamed: "stars-background")
    var player = SKSpriteNode()
    var playerFire = SKSpriteNode()
    var enemy = SKSpriteNode()
    var bossOne = SKSpriteNode()
    var bossOneFire = SKSpriteNode()
    var playerLives = 3
    var enemiesDestroyed = 0
    var bossNumber = 1
    
    @Published var gameOver = false
    
    var score = 0
    var scoreLabel = SKLabelNode()
    var livesArray = [SKSpriteNode]()
    
    var fireTimer = Timer()
    var enemyTimer = Timer()
    var bossOneFireTimer = Timer()
    var bossOneLives = 15
    
    var isPlayerInvulnerable = false
    
    
    struct CBitmask {
        static let playerShip: UInt32 = 0b1 // 1
        static let playerFire: UInt32 = 0b10 // 2
        static let enemyShip: UInt32 = 0b100 // 4
        static let bossOne: UInt32 = 0b1000 // 8
        static let bossFire: UInt32 = 0b10000 // 16
    }
    
    func saveScore(playerName: String, context: ModelContext) {
        let newScore = BestScore(name: playerName, score: score, date: Date())
        context.insert(newScore)
        
        do {
            try context.save()
        } catch {
            print("Failed to save the score: \(error)")
        }
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        scene?.size = CGSize(width: 750, height: 1335)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.setScale(2.1)
        background.zPosition = 1
        background.alpha = 0.6
        addChild(background)
        
        makePlayer(playerCh: shipChoice.integer(forKey: "playerChoice"))
        
        fireTimer = .scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(playerFireFunction), userInfo: nil, repeats: true)
        
        enemyTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(makeEnemy), userInfo: nil, repeats: true)
        
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontName = "Chalkduster"
        scoreLabel.fontSize = 50
        scoreLabel.fontColor = .red
        scoreLabel.zPosition = 10
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 1.2)
        addChild(scoreLabel)
        
        addLives(lives: playerLives)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let contactA : SKPhysicsBody
        let contactB : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            contactA = contact.bodyA
            contactB = contact.bodyB
        } else {
            contactA = contact.bodyB
            contactB = contact.bodyA
        }
        
        // Ignore collisions if the player is invulnerable
        if isPlayerInvulnerable &&
            (contactA.categoryBitMask == CBitmask.playerShip || contactB.categoryBitMask == CBitmask.playerShip) {
            return
        }
        
        // Player shoots the enemy
        if contactA.categoryBitMask == CBitmask.playerFire && contactB.categoryBitMask == CBitmask.enemyShip {
            updateScore()
            playerFireHitEnemy(fires: contactA.node as! SKSpriteNode, enemys: contactB.node as! SKSpriteNode)
            
            if score == 5 {
                makeBossOne()
                enemyTimer.invalidate()
                bossOneFireTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(bossOneFireFunc), userInfo: nil, repeats: true)
            }
        }
        
        // Enemy hits the player
        if contactA.categoryBitMask == CBitmask.playerShip && contactB.categoryBitMask == CBitmask.enemyShip {
            handlePlayerDamage(contactB: contactB)
        }
        
        // Boss fire hits the player
        if contactA.categoryBitMask == CBitmask.playerShip && contactB.categoryBitMask == CBitmask.bossFire {
            handlePlayerDamage(contactB: contactB)
        }
        
        // Player shoots the boss
        if contactA.categoryBitMask == CBitmask.playerFire && contactB.categoryBitMask == CBitmask.bossOne {
            let explo = SKEmitterNode(fileNamed: "ExplosionOne")
            explo?.position = contactA.node!.position
            explo?.zPosition = 5
            addChild(explo!)
            
            contactA.node?.removeFromParent()
            
            bossOneLives -= 1
            
            if bossOneLives == 0 {
                let explo = SKEmitterNode(fileNamed: "ExplosionOne")
                explo?.position = contactB.node!.position
                explo?.zPosition = 5
                explo?.setScale(2)
                addChild(explo!)
                
                contactB.node?.removeFromParent()
                bossOneFireTimer.invalidate()
                
                enemyTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(makeEnemy), userInfo: nil, repeats: true)
                
                
                if livesArray.count < 3 {
                    addLives(lives: 1)
                }
                
                bossNumber += 1
            }
        }
    }
    
    
    func updatePhysicsMasks() {
        // Update the player's physics body
        if let playerBody = player.physicsBody {
            if isPlayerInvulnerable {
                playerBody.collisionBitMask = 0 // Disable physical collisions for the player
                playerBody.contactTestBitMask = 0 // Disable contact detection for the player
                
            } else {
                playerBody.collisionBitMask = CBitmask.enemyShip | CBitmask.bossOne | CBitmask.bossFire
                playerBody.contactTestBitMask = CBitmask.enemyShip | CBitmask.bossOne | CBitmask.bossFire
            }
        }
        // Update all enemies
        for node in children {
            if let enemyNode = node as? SKSpriteNode, enemyNode.physicsBody?.categoryBitMask == CBitmask.enemyShip {
                enemyNode.physicsBody?.isDynamic = !isPlayerInvulnerable
                if isPlayerInvulnerable {
                    enemyNode.physicsBody?.contactTestBitMask = 0
                    enemyNode.physicsBody?.collisionBitMask = 0
                    enemyNode.physicsBody?.isDynamic = false // Ensure enemies do not react to collisions
                } else {
                    enemyNode.physicsBody?.contactTestBitMask = CBitmask.playerShip | CBitmask.playerFire
                    enemyNode.physicsBody?.collisionBitMask = CBitmask.playerShip | CBitmask.playerFire
                    enemyNode.physicsBody?.isDynamic = true
                    
                }
            }
            
            // Update boss projectiles
            if let projectileNode = node as? SKSpriteNode, projectileNode.physicsBody?.categoryBitMask == CBitmask.bossFire {
                if isPlayerInvulnerable {
                    projectileNode.physicsBody?.contactTestBitMask = 0
                    projectileNode.physicsBody?.collisionBitMask = 0
                    projectileNode.physicsBody?.isDynamic = false // Ensure projectiles are not affected by collisions
                } else {
                    projectileNode.physicsBody?.contactTestBitMask = CBitmask.playerShip
                    projectileNode.physicsBody?.collisionBitMask = CBitmask.playerShip
                    projectileNode.physicsBody?.isDynamic = true
                }
            }
        }
    }
    
    
    func handlePlayerDamage(contactB: SKPhysicsBody) {
        if isPlayerInvulnerable {
            return // Ignore damage while player is invulnerable
        }
        
        isPlayerInvulnerable = true
        updatePhysicsMasks() // Update masks when invulnerability starts
        
        player.run(SKAction.repeat(SKAction.sequence([SKAction.fadeOut(withDuration: 0.1), SKAction.fadeIn(withDuration: 0.1)]), count: 10))
        
        contactB.node?.removeFromParent()
        
        if let lastLife = livesArray.popLast() {
            lastLife.removeFromParent()
        }
        
        if livesArray.isEmpty {
            player.removeFromParent()
            fireTimer.invalidate()
            enemyTimer.invalidate()
            bossOneFireTimer.invalidate()
            gameOverFunc()
        }
        
        // Set a delay of 1 second for invulnerability after loosing a life(colliding with boss/enemy)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isPlayerInvulnerable = false
            self.updatePhysicsMasks()
        }
    }
    
    func playerFireHitEnemy(fires: SKSpriteNode, enemys: SKSpriteNode) {
        fires.removeFromParent()
        enemys.removeFromParent()
        
        let explo = SKEmitterNode(fileNamed: "ExplosionOne")
        explo?.position = enemys.position
        explo?.zPosition = 5
        addChild(explo!)
        
        enemiesDestroyed += 1
        updateScore()
        checkForBossSpawn()
    }
    func checkForBossSpawn() {
        let enemiesPerBoss = 10

        if enemiesDestroyed >= enemiesPerBoss {
            enemiesDestroyed = 0
            spawnBoss()
            enemyTimer.invalidate()
        }
    }

    func spawnBoss() {
        bossOneLives = 15 + (bossNumber * 5)
        makeBossOne()
        bossOneFireTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(bossOneFireFunc), userInfo: nil, repeats: true)
    }
    
    func addLives(lives: Int) {
        for _ in 1...lives {
            let life = SKSpriteNode(imageNamed: "heart")
            life.size = CGSize(width: 100.0, height: 70.0)
            life.setScale(0.6)
            // Calculate the position based on the current count of livesArray to add when boss destroyed
            life.position = CGPoint(
                x: CGFloat(livesArray.count + 1) * life.size.width + 25,
                y: size.height - life.size.height - 50
            )
            life.zPosition = 10
            livesArray.append(life)
            
            addChild(life)
        }
    }
    
    func makePlayer(playerCh: Int) {
        var shipName = ""
        
        switch playerCh {
        case 1:
            shipName = "ship_1"
        case 2:
            shipName = "ship_4"
        case 3:
            shipName = "ship_6"
        default:
            shipName = "ship_5"
        }
        
        player = .init(imageNamed: shipName)
        player.position = CGPoint(x: size.width / 2, y: 120)
        player.zPosition = 10
        player.setScale(2.8)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = false // set to false to keep the ships on the screen.
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = CBitmask.playerShip
        player.physicsBody?.contactTestBitMask = CBitmask.enemyShip | CBitmask.bossOne | CBitmask.bossFire // Detect collision with enemies, boss, and boss fire
        player.physicsBody?.collisionBitMask = CBitmask.enemyShip | CBitmask.bossOne | CBitmask.bossFire // Allow collision with enemies, boss, and boss fire
        addChild(player)
    }

    func makeBossOne() {
        bossOne = .init(imageNamed: "ship_2")
        bossOne.position = CGPoint(x: size.width / 2, y: size.height + bossOne.size.height)
        bossOne.zPosition = 10
        bossOne.setScale(5)
        bossOne.zRotation = .pi
        let customPhysicsBodySize = CGSize(width: 170, height: 220) // Perfect size for boss ship_2
        bossOne.physicsBody = SKPhysicsBody(rectangleOf: customPhysicsBodySize)
        bossOne.physicsBody?.affectedByGravity = false
        bossOne.physicsBody?.allowsRotation = false
        bossOne.physicsBody?.isDynamic = false
        bossOne.physicsBody?.categoryBitMask = CBitmask.bossOne
        bossOne.physicsBody?.contactTestBitMask = CBitmask.playerShip | CBitmask.playerFire
        bossOne.physicsBody?.collisionBitMask = CBitmask.playerShip | CBitmask.playerFire

        let move1 = SKAction.moveTo(y: size.height / 1.3, duration: 2)
        let move2 = SKAction.moveTo(x: size.width - bossOne.size.width / 2, duration: 2)
        let move3 = SKAction.moveTo(x: 0 + bossOne.size.width / 2, duration: 2)
        let move4 = SKAction.moveTo(x: size.width / 2, duration: 1.5)
        let move5 = SKAction.fadeOut(withDuration: 0.2)
        let move6 = SKAction.fadeIn(withDuration: 0.2)
        let move7 = SKAction.moveTo(y: 0 + bossOne.size.height / 2, duration: 2)
        let move8 = SKAction.moveTo(y: size.height / 1.3, duration: 2)

        let action = SKAction.repeat(SKAction.sequence([move5, move6]), count: 6)
        let repeatForever = SKAction.repeatForever(SKAction.sequence([move2, move3, move4, action, move7, move8]))
        let sequence = SKAction.sequence([move1, repeatForever])

        bossOne.run(sequence)

        addChild(bossOne)
    }
    
    @objc func bossOneFireFunc() {
        bossOneFire = .init(imageNamed: "turbo_blue")
        bossOneFire.position = bossOne.position
        bossOneFire.zPosition = 5
        bossOneFire.setScale(1.5)
        bossOneFire.zRotation = .pi
        bossOneFire.physicsBody = SKPhysicsBody(rectangleOf: bossOneFire.size)
        bossOneFire.physicsBody?.affectedByGravity = false
        bossOneFire.physicsBody?.allowsRotation = false // Prevent rotation
        bossOneFire.physicsBody?.isDynamic = true // Ensure the projectile moves
        bossOneFire.physicsBody?.categoryBitMask = CBitmask.bossFire // New bitmask for boss fire
        
        // Adjust physics based on player's invulnerability state
        if isPlayerInvulnerable {
            bossOneFire.physicsBody?.contactTestBitMask = 0
            bossOneFire.physicsBody?.collisionBitMask = 0
        } else {
            bossOneFire.physicsBody?.contactTestBitMask = CBitmask.playerShip // Detect collision with player
            bossOneFire.physicsBody?.collisionBitMask = CBitmask.playerShip   // Allow collision with player
        }

        let move1 = SKAction.moveTo(y: 0 - bossOneFire.size.height, duration: 1.5)
        let removeAction = SKAction.removeFromParent()

        let sequence = SKAction.sequence([move1, removeAction])
        bossOneFire.run(sequence)

        addChild(bossOneFire)
    }
    
    @objc func playerFireFunction() {
        playerFire = .init(imageNamed: "shot")
        playerFire.position = player.position
        playerFire.zPosition = 3
        playerFire.physicsBody = SKPhysicsBody(rectangleOf: playerFire.size)
        playerFire.physicsBody?.affectedByGravity = false
        playerFire.physicsBody?.categoryBitMask = CBitmask.playerFire
        playerFire.physicsBody?.contactTestBitMask = CBitmask.enemyShip | CBitmask.bossOne
        playerFire.physicsBody?.collisionBitMask = CBitmask.enemyShip | CBitmask.bossOne
        
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
        enemy.physicsBody?.allowsRotation = false
        enemy.physicsBody?.categoryBitMask = CBitmask.enemyShip
        
        // Adjust physics based on player's invulnerability state (for newly spawned enemies)
        if isPlayerInvulnerable {
            enemy.physicsBody?.isDynamic = false
            enemy.physicsBody?.contactTestBitMask = 0
            enemy.physicsBody?.collisionBitMask = 0
        } else {
            enemy.physicsBody?.isDynamic = true
            enemy.physicsBody?.contactTestBitMask = CBitmask.playerShip | CBitmask.playerFire
            enemy.physicsBody?.collisionBitMask = CBitmask.playerShip | CBitmask.playerFire
        }
        addChild(enemy)
        
        let moveAction = SKAction.moveTo(y: -100, duration: 3)
        let deleteAction = SKAction.removeFromParent()
        let combine = SKAction.sequence([moveAction, deleteAction])
        
        enemy.run(combine)
    }
    
    func updateScore() {
        score += 1
        scoreLabel.text = "Score: \(score)"
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            player.position.x = location.x
        }
    }
    
    func gameOverFunc() {
        removeAllChildren()
        gameOver = true
        
        let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "Game Over"
        gameOverLabel.position = CGPoint(x: size.width / 2, y: (size.height / 2) + 75)
        gameOverLabel.fontSize = 80
        gameOverLabel.fontColor = UIColor.red
        
        addChild(gameOverLabel)
        
        
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var scene = GameScene()
    var onGameOver: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
                
                if scene.gameOver {
                    GameOverView(score: scene.score) { playerName in
                        scene.saveScore(playerName: playerName, context: context)
                        presentationMode.wrappedValue.dismiss()
                        onGameOver()
                    }
                }
            }
            .onAppear {
                scene.modelContext = context
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ContentView(onGameOver: {})
}
