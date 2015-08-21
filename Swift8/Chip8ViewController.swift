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

        let chip = Chip8(graphics: Graphics(), sound: Sound(), keyboard: self.chip8View.keyboard)
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



}

