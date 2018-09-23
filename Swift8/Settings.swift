//
//  Settings.swift
//  Swift8
//
//  Created by Matthijn Dijkstra on 14/11/15.
//  Copyright © 2015 Matthijn Dijkstra. All rights reserved.
//

import Cocoa

enum Setting : String
{
    case BackgroundColor = "backgroundColor"
    case ForegroundColor = "foregroundColor"
    case RenderSpeed = "renderSpeed"
    case PlaySound = "playSound"
    case DidSetDefaultValues = "didSetDefaultValues"
}

class Settings
{
    // Defaulting to standardUserDefaults and defaultCenter to save and broadcast the settings information
    static let sharedSettings = Settings(defaults: UserDefaults.standard)

    // Using NSUserdefaults to store the information
    let defaults : UserDefaults

    init(defaults: UserDefaults)
    {
        self.defaults = defaults
        
        self.checkDefaultValues()
    }
    
    // MARK: The settings

    var theme : Theme {
        get {
            let backgroundColor = self.defaults.color(for: Setting.BackgroundColor.rawValue)
            let foregroundColor = self.defaults.color(for: Setting.ForegroundColor.rawValue)
        
            return Theme(name: "Settings", backgroundColor: backgroundColor!, foregroundColor: foregroundColor!)
        }
        set {
            self.defaults.setColor(color: newValue.backgroundColor, forKey: Setting.BackgroundColor.rawValue)
            self.defaults.setColor(color: newValue.foregroundColor, forKey: Setting.ForegroundColor.rawValue)
            self.defaults.synchronize()
        }
    }

    var renderSpeed : Double {
        get {
            return self.defaults.double(forKey: Setting.RenderSpeed.rawValue)
        }
        set
        {
            self.defaults.set(newValue, forKey: Setting.RenderSpeed.rawValue)
            self.defaults.synchronize()
        }
    }
    
    var playSound : Bool {
        get {
            return self.defaults.bool(forKey: Setting.PlaySound.rawValue)
        }
        set {
            self.defaults.set(newValue, forKey: Setting.PlaySound.rawValue)
            self.defaults.synchronize()
        }
    }
    
    // MARK Handling default values
    
    // Checks if we set initial default values, if not we will
    fileprivate func checkDefaultValues()
    {
        if !self.defaults.bool(forKey: Setting.DidSetDefaultValues.rawValue)
        {
            self.setDefaultValues()
            self.defaults.set(true, forKey: Setting.DidSetDefaultValues.rawValue)
        }
    }
    
    // Sets the initial default values
    fileprivate func setDefaultValues()
    {
        self.theme = Themes.defaultTheme
        self.renderSpeed = 0.5
        self.playSound = true
    }

}
