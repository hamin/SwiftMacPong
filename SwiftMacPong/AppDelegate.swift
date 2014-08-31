//
//  AppDelegate.swift
//  SwiftMacPong
//
//  Created by Haris Amin on 6/14/14.
//  Copyright (c) 2014 Haris Amin. All rights reserved.
//


import Cocoa
import SpriteKit

class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet var window: NSWindow?
    @IBOutlet var skView: SKView?
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        /* Pick a size for the scene */
        let scene = GameScene(size:self.skView!.bounds.size)
        scene.scaleMode = .AspectFill
        
        self.skView!.presentScene(scene)
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        self.skView!.ignoresSiblingOrder = true
        
        self.skView!.showsFPS = true
        self.skView!.showsNodeCount = true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true;
    }
}
