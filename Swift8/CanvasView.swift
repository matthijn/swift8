//
//  CanvasView.swift
//  Swift8
//
//  Created by Matthijn Dijkstra on 23/08/15.
//  Copyright © 2015 Matthijn Dijkstra. All rights reserved.
//

import Cocoa

class CanvasView : NSView, Chip8Graphics
{
    // The original Chip8 system colors
    let backgroundColor = NSColor.blackColor()
    let foregroundColor = NSColor.whiteColor()

    // One pixel on the original Chip8 system will be mapped to this number of points in OSX so everything is not super tiny, since original screen was 64x32 pixels
    let pixelSize : CGFloat = 10

    // Every bool will light up one pixel if it is true
    var pixels = [Bool](count: Int(Graphics.ScreenWidth * Graphics.ScreenHeight), repeatedValue: false)
    
    // MARK: Chip8Graphics
    
    /**
    * Clear the screen
    */
    func clear()
    {
        self.pixels = [Bool](count: Int(Graphics.ScreenWidth * Graphics.ScreenHeight), repeatedValue: false)
        
        self.setNeedsDisplayInRect(self.bounds)
    }
    
   /**
    * Storing the data to draw in the correct location
    */
    func draw(spriteData: ArraySlice<UInt8>, x: UInt8, y: UInt8) -> Bool
    {
        var didOverwrite = false
     
        for (index, var spriteByte) in spriteData.enumerate()
        {

            // Every next byte will be drawn one row lower then the previous
            var currentY = y + UInt8(index)
            
            // Wrapping the Y around
            if CGFloat(currentY) >= Graphics.ScreenHeight
            {
                currentY = currentY - UInt8(Graphics.ScreenHeight)
            }
            
            // Every bit in the spritedata byte corresponds to one pixel mapping it to the self.pixels array
            for var bitIndex = 0; bitIndex < 8; bitIndex++
            {
                // Every bit will be drawn on the next column
                var currentX = x &+ UInt8(bitIndex)
                
                // Wrapping the x around
                if CGFloat(currentX) >= Graphics.ScreenWidth
                {
                    currentX = currentX - UInt8(Graphics.ScreenWidth)
                }
                
                // Create a byte with only the  the left most bit from this byte to get the current pixel
                let leftMostBit = spriteByte ^ 0b01111111
                
                // Convert the byte to a boolean
                var currentPixel = (leftMostBit >= 128) ? true : false

                // Shift left so the next round we get the new next bit
                spriteByte = spriteByte << 1
                
                // Determine the index in the pixels array to change to the new pixel
                let pixelPosition = ((Int(currentY) * Int(Graphics.ScreenWidth)) + Int(currentX))
                
                // When drawing on the same spot twice the pixel gets changed to blank if there is a pixel there
                if currentPixel == true && self.pixels[pixelPosition] == true
                {
                    currentPixel = false
                    
                    // Change the didOverwrite flag to reflect that a pixel in this draw session has been overwritten
                    if !didOverwrite
                    {
                        didOverwrite = true
                    }
                }
                
                // Store the new pixel informatio on the correct position
                self.pixels[pixelPosition] = currentPixel
            }
        }
        
        // Todo: Get the rect for the bounds to update for improved performance
        self.setNeedsDisplayInRect(self.bounds)
        
        
        return didOverwrite
    }
    
    // MARK: NSView drawing
    
    /**
     * Draws on the NSView
     */
    override func drawRect(dirtyRect: NSRect)
    {   
        // Todo: Determine which parts need to be drawn for increased performance instead of drawing all

       var colorToDraw = self.backgroundColor
        
        // Iterate over every row
        for var y : CGFloat = 0; y < Graphics.ScreenHeight; y++
        {
            // And column
            for var x : CGFloat = 0; x < Graphics.ScreenWidth; x++
            {
                // Get the state for the current pixel
                let pixelIndex = Int(x + (y * Graphics.ScreenWidth))

                let pixelState = self.pixels[pixelIndex]

                // Determine color to draw for this pixel
                colorToDraw = (pixelState) ? self.foregroundColor : self.backgroundColor
                colorToDraw.set()

                // Determine the NSView location to draw, NSView works from bottom left while Chip8 works from top left
                let canvasX = x * self.pixelSize
                let canvasY = (Graphics.ScreenHeight * self.pixelSize) - (y * self.pixelSize) - self.pixelSize

                let rectToDraw = CGRectMake(canvasX, canvasY, self.pixelSize,
                    self.pixelSize)

                // And draw
                NSRectFill(rectToDraw)
            }
        }
        
    }
    
}
