//
//  Paddle.swift
//  SwiftMacPong
//
//  Created by Haris Amin on 6/14/14.
//  Copyright (c) 2014 Haris Amin. All rights reserved.
//

import Cocoa
import SpriteKit
import Foundation


//self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:LED_PONG_PADDLE_SIZE];
//self.physicsBody.categoryBitMask = kLEDPaddleCategory;
//self.physicsBody.contactTestBitMask = kLEDEdgeCategory | kLEDBallCategory;
//self.physicsBody.allowsRotation = NO;
//self.physicsBody.friction = 0.0;
//self.physicsBody.mass = 0.0;

class Paddle: SKSpriteNode {
    let paddleCategory: UInt32 = 0
    let edgeCategory: UInt32 = 1
    let ballCategory: UInt32 = 2
    
    override init() {
        super.init(texture: texture, color: SKColor.whiteColor(), size: texture.size())
        self.setUp()
    }
    
    init(texture: SKTexture!) {
        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
        self.setUp()
    }
    
    override init(texture: SKTexture!, color: SKColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.setUp()
    }

    required init(coder: NSCoder!) {
        super.init(coder: coder)
    }
    
    func setUp(){
        name = "Paddle";
//        self.physicsBody = SKPhysicsBody(rectangleOfSize:LED_PONG_PADDLE_SIZE)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(35, 150))
//        self.physicsBody.categoryBitMask = kLEDPaddleCategory
//        self.physicsBody.contactTestBitMask = kLEDEdgeCategory | kLEDBallCategory
        self.physicsBody.categoryBitMask = self.paddleCategory
        self.physicsBody.contactTestBitMask = self.edgeCategory | self.ballCategory
        self.physicsBody.allowsRotation = true
        self.physicsBody.friction = 0.0
        self.physicsBody.mass = 0.0
    }
}
