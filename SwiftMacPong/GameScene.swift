//
//  GameScene.swift
//  SwiftMacPong
//
//  Created by Haris Amin on 6/14/14.
//  Copyright (c) 2014 Haris Amin. All rights reserved.
//

import SpriteKit
//import Paddle

class GameScene: SKScene, SKPhysicsContactDelegate{
    var cpuPaddle:Paddle
    var playerPaddle:Paddle
    var ball:SKSpriteNode
    
    var playerScoreLabel:SKLabelNode
    var cpuScoreLabel:SKLabelNode
    var pauseLabel:SKLabelNode
    
    var fadeOutAction:SKAction
    var fadeInAction:SKAction
    var soundEffectAction:SKAction
    
    var gamePaused:Bool
    var gameStarted:Bool
    var moveUp:Bool = false
    var moveDown:Bool = false
    var bounceUp:Bool = false
    var bounceLeft:Bool = false
    
    var previousLocation:CGPoint=CGPointZero
    var currentLocation:CGPoint=CGPointZero
    
    var ballVelocityX:CGFloat=0
    var ballVelocityY:CGFloat=0
    var cpuPaddleVelocityY:CGFloat=0
    var initialPlayerPositionX:CGFloat=0
    var initialCpuPositionX:CGFloat=0
    var ballVelocityModifier:CGFloat=0
    
    var playerScore:Int=0{
    didSet{
        self.playerScoreLabel.text = "\(self.playerScore)"
    }
    }
    var cpuScore:Int=0{
    didSet{
        self.cpuScoreLabel.text = "\(self.cpuScore)"
    }
    }
    var hitCounter:Int=0
    
    let paddleCategory: UInt32 = 0
    let edgeCategory: UInt32 = 1
    let ballCategory: UInt32 = 2
    
    let pongPaddleSize:CGSize = CGSizeMake(35, 150)
    
    override init(size: CGSize){
        
        self.fadeOutAction = SKAction.fadeOutWithDuration(0.75)
        self.fadeInAction = SKAction.fadeInWithDuration(0.75)
        
        self.playerScoreLabel = SKLabelNode(fontNamed:"Helvetica")
        self.playerScoreLabel.fontSize = 45
        
        self.cpuScoreLabel = SKLabelNode(fontNamed:"Helvetica")
        self.cpuScoreLabel.fontSize = 45

        
        self.playerPaddle = Paddle(color: SKColor.whiteColor(), size: CGSizeMake(35, 150))
        self.cpuPaddle = Paddle(color: SKColor.whiteColor(), size: CGSizeMake(35, 150))
        

        self.ball = SKSpriteNode(imageNamed:"Ball")
        self.ball.name = "Ball"
        self.ball.color = SKColor.whiteColor()
        self.ball.physicsBody = SKPhysicsBody(circleOfRadius:26)
        self.ball.physicsBody.categoryBitMask = self.ballCategory
        self.ball.physicsBody.contactTestBitMask = self.paddleCategory
        self.ball.physicsBody.friction = 0.0
        self.ball.physicsBody.mass = 0.0
        self.ball.physicsBody.velocity = CGVectorMake(0, 0)
        
        
        self.pauseLabel = SKLabelNode(fontNamed:"Helvetica")
        self.pauseLabel.fontSize = 70
        self.pauseLabel.text = nil
        
        self.gameStarted = false;
        self.gamePaused = false;
        
        self.soundEffectAction = SKAction.playSoundFileNamed("beep.wav", waitForCompletion: false)

        
        super.init(size: size)
        self.backgroundColor = SKColor(red:0.15, green:0.15, blue:0.15, alpha:1)
        
        self.addChild(self.playerScoreLabel)
        self.addChild(self.cpuScoreLabel)
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        
        self.addChild(self.playerPaddle)
        self.addChild(self.cpuPaddle)
        
        self.addChild(self.ball)
        
        self.addChild(self.pauseLabel)
        
        
        self.pauseLabel.position = CGPointMake(self.frame.width/2, self.frame.height/2)
        
        self.playerScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame) + 100, CGRectGetMaxY(self.frame) - 85)
        self.cpuScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame) - 100, CGRectGetMaxY(self.frame) - 85);
        
        self.initialPlayerPositionX = CGFloat(CGRectGetMaxX(self.frame) - pongPaddleSize.width/2) - CGFloat(LED_PONG_PADDING);
        self.initialCpuPositionX = CGFloat(CGRectGetMinX(self.frame) + pongPaddleSize.width/2) + CGFloat(LED_PONG_PADDING);
        
    }

    required init(coder: NSCoder!) {
        super.init(coder: coder)
    }
    
// OS X EVENT HANDLING
    func handleKeyEvent(theEvent: NSEvent, isKeyDown:Bool) {
        
        if (theEvent.keyCode == CUnsignedShort(LED_PONG_MOVE_SPACEBAR)) {
            self.togglePause();
        }
        
        if (theEvent.keyCode == CUnsignedShort(LED_PONG_MOVE_UP) || theEvent.keyCode == CUnsignedShort(LED_PONG_MOVE_UP_ALT)) {
            self.moveUp = isKeyDown;
        } else if (theEvent.keyCode == CUnsignedShort(LED_PONG_MOVE_DOWN) || theEvent.keyCode == CUnsignedShort(LED_PONG_MOVE_DOWN_ALT)) {
            self.moveDown = isKeyDown;
        }
    }
    
    override func keyUp(theEvent: NSEvent!) {
        self.handleKeyEvent(theEvent, isKeyDown: false)
    }
    
    override func keyDown(theEvent: NSEvent!) {
        self.handleKeyEvent(theEvent, isKeyDown: true)
    }
    
    
    func startGame(){
        self.gameStarted = true;
        
        self.playerScore = 0;
        self.cpuScore = 0;
        self.hitCounter = 0;
        
        self.ballVelocityModifier = CGFloat( tanf( Float(self.randomAngle()) ) );
        
        self.playerPaddle.position = CGPointMake(self.initialPlayerPositionX, CGRectGetMidY(self.frame));
        self.cpuPaddle.position    = CGPointMake(self.initialCpuPositionX, CGRectGetMidY(self.frame));
        
        self.resetPositions()

    }

    func resetPositions(){
        self.ballVelocityX = CGRectGetMidX(self.frame);
        self.ballVelocityY = CGRectGetMidY(self.frame);
        self.ball.position = CGPointMake(self.ballVelocityX, self.ballVelocityY);
    
        self.bounceUp   = (arc4random_uniform(2) + 1) % 2 == 0;
        self.bounceLeft = (arc4random_uniform(2) + 1) % 2 == 0;
        
        self.hitCounter = 0;
    }
    
    func pauseGame(){
        self.gamePaused = true;
    
//        if (!self.pauseLabel.text) {
            self.pauseLabel.text = "Paused"
//        }
        self.pauseLabel.runAction(self.fadeInAction)
    }
    
    func unpauseGame(){
        self.gamePaused = false
        self.pauseLabel.runAction(self.fadeOutAction)
    }
    
    func togglePause(){
        if(self.gamePaused){
            self.unpauseGame()
        }else{
            self.pauseGame()
        }
    }
    
    

    func randomAngle() -> CGFloat{
        var uintValue = self.randomNumberFrom(25, to: 35)
        return CGFloat(uintValue) * CGFloat(M_PI / 180)
    }
    
    func randomNumberFrom(low:UInt32, to:UInt32) -> UInt32{
        return low +  ( arc4random() % (to - low + 1) )
    }
    
    func randomPercentageFrom(low:UInt32, to:UInt32) -> CGFloat{
        var uintValue = self.randomNumberFrom(low, to: to)
        return CGFloat(uintValue) / 100.0
    }

    func reachedBottom(paddle:Paddle) -> Bool{
        return CGRectGetMinY(self.frame) > (paddle.position.y - paddle.size.height/2 + 7)
    }
    
    func reachedTop(paddle:Paddle) -> Bool{
        return CGRectGetMaxY(self.frame) <= (paddle.position.y + paddle.size.height/2 + 7)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if (!self.gameStarted){
            self.startGame()
        }
        
        
        if (self.gamePaused){
            return
        }
        
        // NOTICE: Just reset paddle's position.x when it collides with ball
        self.playerPaddle.position = CGPointMake(self.initialPlayerPositionX, self.playerPaddle.position.y);
        self.cpuPaddle.position    = CGPointMake(self.initialCpuPositionX, self.cpuPaddle.position.y);
        
        var speedBoost = Double(self.hitCounter) * 0.20
        
        // Move Paddle but prevent them from going too high or low
        
        var currentPosition:CGPoint = self.playerPaddle.position;
        if (self.moveUp && !self.reachedTop(self.playerPaddle)) {
            self.playerPaddle.position = CGPointMake(currentPosition.x, currentPosition.y + CGFloat(LED_PONG_PADDLE_SPEED) );
        } else if (self.moveDown && !self.reachedBottom(self.playerPaddle)) {
            self.playerPaddle.position = CGPointMake(currentPosition.x, currentPosition.y - CGFloat(LED_PONG_PADDLE_SPEED));
        }
        
        // Move CPU Paddle
        // FIXME: CPU Paddle cheats by passing bounds
        self.cpuPaddle.position = CGPointMake(self.cpuPaddle.position.x, (self.ballVelocityY *  0.845) + CGFloat(speedBoost));
        
        // Ball's next movement when it hits top or bottom
        if (self.ballVelocityY >= self.frame.size.height - self.ball.size.height/2) {
            self.bounceUp = false;
            self.ballVelocityModifier = tan(self.randomAngle());
        } else if (self.ballVelocityY <= self.ball.size.height/2) {
            self.bounceUp = true;
            self.ballVelocityModifier = tan(self.randomAngle());
        }
        
        // When ball touches the sides
        if (self.ballVelocityX >= self.frame.size.width + self.ball.size.width * 2) {
            self.cpuScore++;
            self.resetPositions();
        } else if (self.ballVelocityX < self.ball.size.width/10) {
            self.playerScore++;
            self.resetPositions();
        }
        
        // Move Ball
        var currentBallVelocityY = CGFloat( CGFloat(LED_PONG_BALL_SPEED) * self.ballVelocityModifier ) + CGFloat(speedBoost);
        var speedDifference = (CGFloat(LED_PONG_BALL_SPEED) - currentBallVelocityY) + CGFloat(speedBoost);
        
        if (self.bounceUp){
            self.ballVelocityY += currentBallVelocityY;
        }else{
            self.ballVelocityY -= currentBallVelocityY;
        }
        
        
        if (self.bounceLeft){
            self.ballVelocityX -= (CGFloat(LED_PONG_BALL_SPEED) + CGFloat(speedDifference));
        }else{
            self.ballVelocityX += (CGFloat(LED_PONG_BALL_SPEED) + CGFloat(speedDifference));
        }
        
        
        self.ball.position = CGPointMake(self.ballVelocityX, self.ballVelocityY);
    }
    
    func didBeginContact(contact:SKPhysicsContact){
        var ballTouched = contact.bodyA.categoryBitMask == self.paddleCategory
        var paddleTouched = contact.bodyB.categoryBitMask == self.ballCategory
        
        if (ballTouched && paddleTouched) {
            ++self.hitCounter
            
            //Apply some force
            if(self.moveUp){
                self.bounceUp = true
            }else if (self.moveDown){
                self.bounceUp = false
            }
            
            self.bounceLeft = !self.bounceLeft
            self.ballVelocityModifier = CGFloat( tanf( Float(self.randomAngle()) ) );
            
            self.runAction(self.soundEffectAction)
        }
    }
}
