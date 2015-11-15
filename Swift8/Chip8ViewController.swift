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

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // The UIView is the first responder, so hooking the keyboard up from there
        let keyboard = self.chip8View.keyboard;
        
        // Creating graphics through the UIView
        let graphics = Graphics(graphicsDelegate: self.chip8View.canvasView)
        
        // Create the chip system
        self.chip = Chip8(graphics: graphics, sound: Sound(), keyboard: keyboard)
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
        self.chip?.speed = min(self.currentSpeed + self.speedStep, self.maxSpeed)
    }
    
    func decreaseSpeed()
    {
        self.chip?.speed = max(self.currentSpeed - 100, self.minSpeed)
    }

}

