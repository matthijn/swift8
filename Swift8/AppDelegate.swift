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
    lazy var windowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "MainWindowController") as! Chip8WindowController

    // Don't show the initial open file screen if we opened through double clicking a file
    var didOpenWithFile = false
    
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        // Setup theme menu
        self.setupThemes()
        
        // Update the menu reflecting the sound state
        self.setSoundState(with: Settings.sharedSettings.playSound)
        
        // Show the initial open screen
        
        if !self.didOpenWithFile
        {
            self.onOpenButton(with: self)
        }
    }

    @IBOutlet weak var themeMenu: NSMenu!
    
    @IBOutlet weak var emulateSoundMenuItem: NSMenuItem!

    func setupThemes()
    {
        self.themeMenu.autoenablesItems = false
        
        // Iterate over all themes and create a menu item for them
        for theme in Themes.availableThemes
        {
            // Create the menu item
            let menuItem = NSMenuItem(title: theme.name, action: #selector(AppDelegate.onThemeButton(with:)), keyEquivalent: String(theme.name[theme.name.startIndex]))
            
            menuItem.isEnabled = true
            menuItem.target = self
            menuItem.representedObject = theme
            
            // And add to the menu
            self.themeMenu.addItem(menuItem)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification)
    {
        // Insert code here to tear down your application
    }

    // MARK: Menu items
    
    // MARK: Rendering
    
    @IBAction func onIncreaseSpeedButton(with sender: AnyObject)
    {
        self.windowController.onIncreaseSpeedButton(with: sender)
    }
    
    @IBAction func onDecreaseSpeedButton(with sender: AnyObject)
    {
        self.windowController.onDecreaseSpeedButton(with: sender)
    }
    
    func onThemeButton(with sender: AnyObject)
    {
        self.windowController.onThemeButton(with: sender)
    }
    
    @IBAction func onFullScreenButton(with sender: AnyObject)
    {
        self.windowController.onFullScreenButton(with: sender)
    }
    
    
    @IBAction func onEmulateSoundButton(with sender: AnyObject)
    {
        self.setSoundState(with: !Settings.sharedSettings.playSound)
    }
    
    fileprivate func setSoundState(with newState: Bool)
    {
        Settings.sharedSettings.playSound = newState
        let imageState = (newState) ? 1 : 0
        self.emulateSoundMenuItem.state = imageState
    }
    
    // MARK: File Menu
    
    @IBAction func onOpenButton(with sender: AnyObject)
    {
        self.windowController.onLoadButton(with: sender)
    }
    
    @IBAction func onResetButton(with sender: AnyObject)
    {
        self.windowController.onResetButton(with: self)
    }

    func application(_ sender: NSApplication, openFile filename: String) -> Bool
    {
        let url = URL(fileURLWithPath: filename)
        
        if url.pathExtension == "ch8"
        {
            self.didOpenWithFile = true
            self.windowController.loadPath(of: url)
            return true
        }

        NSAlert.showSimpleWarning(message: "Cannot open this type of file.", inWindow: self.windowController.window!)
        return false
    }

}

