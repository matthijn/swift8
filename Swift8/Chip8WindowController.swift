//
//  Chip8Window.swift
//  Swift8
//
//  Created by Matthijn Dijkstra on 15/11/15.
//  Copyright © 2015 Matthijn Dijkstra. All rights reserved.
//

import Cocoa

class Chip8WindowController : NSWindowController, NSWindowDelegate
{
    
    // A quick way to get to the chip8 view controller
    var chip8ViewController : Chip8ViewController {
        get {
            return self.contentViewController as! Chip8ViewController
        }
    }
    
    // MARK: User interaction
    
    func onLoadButton(sender: AnyObject)
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
                // Show the window
                self.showWindow(self)
                
                // Try to load the rome
                if let rom = NSData(contentsOfFile:file.path!)
                {
                    // Update the title
                    self.window!.title = "Swift8 - " + file.absoluteString.componentsSeparatedByString("/").last!
                    
                    // And load the rom
                    self.chip8ViewController.loadRom(rom, autostart: true)
                }
                    // Something went wrong, show an alert
                else
                {
                    let alert = NSAlert()
                    alert.addButtonWithTitle("OK")
                    alert.messageText = "Could not read the selected file."
                    alert.alertStyle = .WarningAlertStyle
                    alert.beginSheetModalForWindow(self.window!, completionHandler: nil)
                }
            }
        }
    }
    
    func onResetButton(sender: AnyObject)
    {
        self.chip8ViewController.resetRom()
    }
    
    func onIncreaseSpeedButton(sender: AnyObject)
    {
        self.chip8ViewController.increaseSpeed()
    }
    
    func onDecreaseSpeedButton(sender: AnyObject)
    {
        self.chip8ViewController.decreaseSpeed()
    }
    
    func onThemeButton(sender: AnyObject)
    {
        let theme = sender.representedObject as! Theme
        self.chip8ViewController.changeTheme(theme)
    }

}