//
//  Settings.swift
//  Swift8
//
//  Created by Matthijn Dijkstra on 14/11/15.
//  Copyright © 2015 Matthijn Dijkstra. All rights reserved.
//

import Cocoa

class Settings
{
    // Defaulting to standardUserDefaults and defaultCenter to save and broadcast the settings information
    let sharedSettings = Settings(defaults: NSUserDefaults.standardUserDefaults(), notificationCenter: NSNotificationCenter.defaultCenter())

    // Using NSUserdefaults to store the information
    let defaults : NSUserDefaults

    // And a notification center to broadcast changes
    let notificationCenter : NSNotificationCenter
    
    init(defaults: NSUserDefaults, notificationCenter: NSNotificationCenter)
    {
        self.defaults = defaults
        self.notificationCenter = notificationCenter
    }
    
    // MARK: The settings

    var theme : Theme {
        get {
            return self.getSetting("theme", type: "object") as! Theme
        }
        set {
            self.setSetting("theme", value: newValue, type: "object")
        }
    }

    var renderSpeed : Double {
        get {
            return self.getSetting("renderSpeed", type: "double") as! Double
        }
        set
        {
            self.setSetting("renderSpeed", value: newValue, type: "double")
        }
    }
    
    // MARK: Saving and Fetching
    
    /**
     * Fetches a setting from the defaults
     */
    private func getSetting(key: String, type: String) -> AnyObject
    {
        let fetchSelector = Selector("\(type)ForKey:")
        return self.defaults.performSelector(fetchSelector, withObject: key).takeUnretainedValue()
    }
    
    /**
     * Saves a setting in the defaults and notifies the app of the change
     */
    private func setSetting(key: String, value: AnyObject, type: String)
    {
        // Save
        let saveSelector = Selector("set\(type.upperCaseFirst)ForKey:")
        self.defaults.performSelector(saveSelector, withObject: value)
        
        // Synchronize
        self.defaults.synchronize();
        
        // Broadcast change
        self.broadcastChange(key, newValue: value)
    }
    
    /**
     * Notify the app of the change
     */
    private func broadcastChange(key: String, newValue: AnyObject)
    {
        self.notificationCenter.postNotificationName(key, object: self, userInfo: newValue as? [NSObject : AnyObject])
    }
    
}