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
        self.themeMenu.autoenablesItems = false
        
        // Iterate over all themes and create a menu item for them
        for theme in Themes.availableThemes
        {
            // Create the menu item
            let menuItem = NSMenuItem(title: theme.name, action: Selector("onThemeButton:"), keyEquivalent: String(theme.name[theme.name.startIndex]))
            
            menuItem.enabled = true
            menuItem.target = self
            menuItem.representedObject = theme
            
            // And add to the menu
            self.themeMenu.addItem(menuItem)
        }
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
    
    func onThemeButton(sender: AnyObject)
    {
        self.windowController.onThemeButton(sender)
    }
    
    @IBAction func onFullScreenButton(sender: AnyObject)
    {
        self.windowController.onFullScreenButton(sender)
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

