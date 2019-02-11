//
//  ViewController.swift
//  Pipopipette
//
//  Created by Thomas Lagrange on 2/2/19.
//  Copyright © 2019 Thomas Lagrange. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    @IBOutlet weak var MainMenuLabel: NSTextField!
    @IBOutlet weak var DotsPerSideInput: NSTextField!
    @IBOutlet weak var PlyInput: NSTextField!
    @IBOutlet weak var PlayButton: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func playButtonWasPressed(_ sender: NSButton) {
        if let view = self.skView {
            // Retrieve inputs from menu
            let dotsPerSide = DotsPerSideInput.integerValue
            let ply         = PlyInput.integerValue

            // Delete menu items from view
            MainMenuLabel.isHidden    = true
            DotsPerSideInput.isHidden = true
            PlyInput.isHidden         = true
            PlayButton.isHidden       = true
            
            // Load the GameScene that the human will use to play the AI
            if let scene = GameScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                scene.setParamaters(to: dotsPerSide, and: ply)
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
        }
    }
    
}

