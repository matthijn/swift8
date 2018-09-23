//
//  Sound.swift
//  Swift8
//
//  Created by Matthijn Dijkstra on 18/08/15.
//  Copyright © 2015 Matthijn Dijkstra. All rights reserved.
//

import Foundation
import AVFoundation

class Sound
{
    // Keep track if we should be playing if we repeat
    var shouldBePlaying = false
    
    // The sound to play (I'd rather generate the sound on the fly, but that requires more code than I'd like)
    let soundPath = URL(fileURLWithPath: Bundle.main.path(forResource: "sound", ofType: "wav")!)
    
    // And the player
    let player : AVPlayer
    
    init()
    {
        // Setup the player
        self.player = AVPlayer(url: self.soundPath)

        // Listen to the player ending so we can loop if needed
        NotificationCenter.default.addObserver(self, selector: "playbackEnded", name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player)
    }
    
    // Tells the system to start making noise
    func startBeep()
    {
        if Settings.sharedSettings.playSound
        {
            self.shouldBePlaying = true
            self.restartPlayback()
        }
    }
    
    // And tells the system to stop making noise
    func stopBeep()
    {
        self.shouldBePlaying = false
        self.player.pause()
        
    }
    
    // Resume playback when finished if needed
    fileprivate func playbackEnded()
    {
        if self.shouldBePlaying
        {
            self.restartPlayback()
        }
    }
    
    // Restart playing from the start
    fileprivate func restartPlayback()
    {
        self.player.seek(to: CMTime.zero)
        self.player.play()
    }

    // Clean up
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
}
