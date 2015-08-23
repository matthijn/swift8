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
        let chip = Chip8(graphics: graphics, sound: Sound(), keyboard: keyboard)
        
        // And start the loop
        chip.startLoop();
    }
    

    override var representedObject: AnyObject?
    {
        didSet
        {
            print(self.view.window)
            // Update the view, if already loaded.
        }
    }

    // MARK: User interaction
    
    @IBAction func onLoadButton(sender: AnyObject)
    {
    
    }


    @IBAction func onResetButton(sender: AnyObject)
    {
    
    }
    
    @IBAction func onPauseButton(sender: AnyObject)
    {
    
    }

}

