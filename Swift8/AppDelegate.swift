//
//  AppDelegate.swift
//  Swift8
//
//  Created by Matthijn Dijkstra on 16/08/15.
//  Copyright © 2015 Matthijn Dijkstra. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    // Loading the window controller manually
    lazy var windowController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("MainWindowController") as! Chip8WindowController

    func applicationDidFinishLaunching(aNotification: NSNotification)
    {
        // Setup theme menu
        self.setupThemes()
        
        // Show the initial open screen
        self.onOpenButton(self)
    }

    @IBOutlet weak var themeMenu: NSMenu!
    
    func setupThemes()
    {

    }

    func applicationWillTerminate(aNotification: NSNotification)
    {
        // Insert code here to tear down your application
    }

    // MARK: Menu items
    
    // MARK: Render speed
    
    @IBAction func onIncreaseSpeedButton(sender: AnyObject)
    {
        self.windowController.onIncreaseSpeedButton(sender)
    }
    
    @IBAction func onDecreaseSpeedButton(sender: AnyObject)
    {
        self.windowController.onDecreaseSpeedButton(sender)
    }
    
    // MARK: File Menu
    
    @IBAction func onOpenButton(sender: AnyObject)
    {
        self.windowController.onLoadButton(sender)
    }
    
    @IBAction func onResetButton(sender: AnyObject)
    {
        self.windowController.onResetButton(self)
    }
}

