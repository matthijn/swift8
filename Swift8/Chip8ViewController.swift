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
 
    var chip : Chip8?
    
    var chip8View : Chip8View {
        get {
            return self.view as! Chip8View
        }
    }
    
    var loadedRom : NSData?
    
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
        // Show a file dialog
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.allowsMultipleSelection = false

        if openPanel.runModal() == NSModalResponseOK
        {
            // Make sure a file is selected
            if let file = openPanel.URLs.first
            {
                // Try to read the file
                self.loadedRom = NSData(contentsOfFile:file.path!)

                if let rom = self.loadedRom
                {
                    // Update the title
                    self.view.window?.title = "Swift8 - " + file.absoluteString.componentsSeparatedByString("/").last!

                    // And load the data
                    self.chip?.load(rom, autostart: true)
                }
                // Something went wrong, show an alert
                else
                {
                    let alert = NSAlert()
                    alert.addButtonWithTitle("OK")
                    alert.messageText = "Could not read the selected file."
                    alert.alertStyle = .WarningAlertStyle
                    alert.beginSheetModalForWindow(self.view.window!, completionHandler: nil)
                }
            }
        }
    }

    @IBAction func onResetButton(sender: AnyObject)
    {
        if let rom = self.loadedRom
        {
            self.chip?.load(rom, autostart: true)
        }
    }
    
    @IBAction func onSliderChange(sender: NSSlider)
    {
        self.chip?.changeSpeed(sender.doubleValue)
    }
    
}

