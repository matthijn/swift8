//
//  ViewController.swift
//  Swift8
//
//  Created by Matthijn Dijkstra on 16/08/15.
//  Copyright © 2015 Matthijn Dijkstra. All rights reserved.
//

import Cocoa

class ViewController: NSViewController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let chip = Chip8(graphics: Graphics(), sound: Sound(), keyboard: Keyboard())
        chip.startLoop();

    }

    override var representedObject: AnyObject?
    {
        didSet
        {
            // Update the view, if already loaded.
        }
    }


}

