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
    
    func load(rom: Data, autostart: Bool)
    {
        self.chip?.load(rom, autostart: true)
    }
    
    func resetRom()
    {
        self.chip?.resetRom(true)
    }
    
    func increaseSpeed()
    {
        self.setSpeed(with: min(self.currentSpeed + 0.1, 1))
    }
    
    func decreaseSpeed()
    {
        self.setSpeed(with: max(self.currentSpeed - 0.1, 0.1))
    }
    
    func changeTheme(with theme: Theme)
    {
        // Save the new theme in settings
        Settings.sharedSettings.theme = theme
        
        // Apply the theme
        self.canvasView.theme = theme
    }
    
    fileprivate func setSpeed(with speed: Double)
    {
        self.chip?.speed = speed
        Settings.sharedSettings.renderSpeed = speed
    }
    
    fileprivate func applySettings()
    {
        // Default to the settings speed
        self.chip?.speed = Settings.sharedSettings.renderSpeed
        
        // And start with the correct theme
        self.canvasView.theme = Settings.sharedSettings.theme
    }

}

