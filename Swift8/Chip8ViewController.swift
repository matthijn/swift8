//
//  ViewController.swift
//  Swift8
//
//  Created by Matthijn Dijkstra on 16/08/15.
//  Copyright © 2015 Matthijn Dijkstra. All rights reserved.
//

import Cocoa

class Chip8ViewController: NSViewController
{
 
    // Holds the chip 8 emulator system
    var chip : Chip8?
    
    // Limiting how fast the emulator can run
    let minSpeed = 50.0
    let maxSpeed = 1000.0
    
    let speedStep = 50.0
    
    // Current speed at which the emulator runs
    var currentSpeed : Double {
        get {
            return (self.chip?.speed)!
        }
    }
    
    var chip8View : Chip8View {
        get {
            return self.view as! Chip8View
        }
    }
    
    var canvasView : CanvasView {
        get {
            return self.chip8View.canvasView
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // The UIView is the first responder, so hooking the keyboard up from there
        let keyboard = self.chip8View.keyboard;
        
        // Creating graphics through the UIView
        let graphics = Graphics(graphicsDelegate: self.chip8View.canvasView)
        
        // Create the chip system
        self.chip = Chip8(graphics: graphics, sound: Sound(), keyboard: keyboard)
    
        // Applying the default settings
        self.applySettings()
    }
    
    func loadRom(rom: NSData, autostart: Bool)
    {
        self.chip?.load(rom, autostart: true)
    }
    
    func resetRom()
    {
        self.chip?.resetRom(true)
    }
    
    func increaseSpeed()
    {
        self.setSpeed(min(self.currentSpeed + self.speedStep, self.maxSpeed))
    }
    
    func decreaseSpeed()
    {
        self.setSpeed(max(self.currentSpeed - 100, self.minSpeed))
    }
    
    func changeTheme(theme: Theme)
    {
        // Save the new theme in settings
        Settings.sharedSettings.theme = theme
        
        // Apply the theme
        self.canvasView.theme = theme
    }
    
    private func setSpeed(speed: Double)
    {
        self.chip?.speed = speed
        Settings.sharedSettings.renderSpeed = speed
    }
    
    private func applySettings()
    {
        // Default to the settings speed
        self.chip?.speed = Settings.sharedSettings.renderSpeed
        
        // And start with the correct theme
        self.canvasView.theme = Settings.sharedSettings.theme
    }

}

