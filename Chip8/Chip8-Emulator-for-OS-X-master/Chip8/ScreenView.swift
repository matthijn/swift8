//    The MIT License (MIT)
//
//    Copyright (c) 2015 Krzysztof Rossa
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Cocoa


class ScreenView: NSView {

    var myPoint: NSPoint = NSZeroPoint
    var drawDebug = false
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        drawScreenRect(myPoint)
    }
    
    let pixelHeight = 10
    
    func drawScreenRect(point: NSPoint){
      
        let bottomMarginPx = 0
        let leftMarginPx = 0
        let height = self.bounds.height - 50
        let width = self.bounds.width - 80
        
        let ratio = width / height

        var pixelHeight : Int = 1
        if ratio > 2.0 {
            pixelHeight = Int(height / 32)
        } else {
            pixelHeight = Int(width / 64)
        }
        
        let SCREEN_HEIGHT = 32 * pixelHeight
        let SCREEN_WIDTH = 64 * pixelHeight

        

        let bacgroundRect: NSRect = NSMakeRect(CGFloat(leftMarginPx),
            CGFloat(bottomMarginPx),
            CGFloat(SCREEN_WIDTH),
            CGFloat(SCREEN_HEIGHT))
        
        NSColor.blackColor().set()
        NSRectFill(bacgroundRect)
        
        
        NSColor.whiteColor().set()


        for x in 0..<64 {
            for y in 0..<32 {
                let margin = 0
                var mySimpleRect: NSRect = NSMakeRect(CGFloat(pixelHeight * x + margin + leftMarginPx),
                    CGFloat(SCREEN_HEIGHT - pixelHeight * (y+1) + margin + bottomMarginPx ),
                    CGFloat(pixelHeight - margin),
                    CGFloat(pixelHeight + margin))
                
                let index = (y * 64) + x
                if let cpuTemp = self.cpu {
                    let screen = cpuTemp.screen
                    if index<screen.count && screen[index]>0 {
                        NSRectFill(mySimpleRect)
                    }
                }
            }
        }
        
        if drawDebug {
            drawDebugInfo()
        }
    }

    func drawDebugInfo() {

        let fontSize : CGFloat = 18.0
        let font = NSFont(name: "Menlo", size: fontSize)

        let textRect: NSRect = NSMakeRect(5, 3, 125, 18)
        let textStyle = NSMutableParagraphStyle()
        //textStyle.alignment = NSTextAlignment.LeftTextAlignment
        textStyle.alignment = NSTextAlignment.Left
        textStyle.firstLineHeadIndent = 15.0
        textStyle.paragraphSpacingBefore = 10.0

        let textColor = NSColor(calibratedRed: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)

        let textFontAttributes = [
                NSFontAttributeName : font!,
                NSForegroundColorAttributeName: textColor,
                NSParagraphStyleAttributeName: textStyle
        ]

        let startX = CGFloat(pixelHeight*32)
        if let cpuTemp = self.cpu {
            for var i=0; i<16; i++ {
                let register = String(NSString(format:"%1X", i))
                let registerValue = String(NSString(format:"%2X", cpuTemp.V[i]))
                let text : NSString = "V[\(register)] = \(registerValue)"
                let windowHight = self.bounds.height
                let point : NSPoint = NSPoint(x: 10, y: startX - CGFloat((Int(fontSize)*(i+2)))  )
                text.drawAtPoint(point, withAttributes: textFontAttributes)
            }

            let posX : CGFloat = CGFloat(140)
            let pcHex = String(NSString(format:"%4X", cpuTemp.PC))
            var text : NSString = "PC = \(pcHex)"
            var point : NSPoint = NSPoint(x: posX, y: self.bounds.height - CGFloat(fontSize))
            text.drawAtPoint(point, withAttributes: textFontAttributes)


            let IHex = String(NSString(format:"%4X", cpuTemp.I))
            text = "I  = \(IHex)"
            point = NSPoint(x: posX, y: startX - CGFloat(fontSize * 2))
            text.drawAtPoint(point, withAttributes: textFontAttributes)



            var SPHex = "   0"
            if let stackValue = cpuTemp.stack.last {
                SPHex = String(NSString(format:"%4X", stackValue))
            }
            text = "SP = \(SPHex)"
            point = NSPoint(x: posX, y: startX - CGFloat(fontSize * 3))
            text.drawAtPoint(point, withAttributes: textFontAttributes)

            let DTHex = String(NSString(format:"%4X", cpuTemp.delayTimer))
            text = "DT = \(DTHex)"
            point = NSPoint(x: posX, y: startX - CGFloat(fontSize * 4))
            text.drawAtPoint(point, withAttributes: textFontAttributes)

            let ISTHex = String(NSString(format:"%4X", cpuTemp.soundTimer))
            text = "ST = \(ISTHex)"
            point = NSPoint(x: posX, y: startX - CGFloat(fontSize * 5))
            text.drawAtPoint(point, withAttributes: textFontAttributes)

            let optoHex = String(NSString(format:"%4X", cpuTemp.optocode))
            text = "OPTO = \(optoHex)"
            point = NSPoint(x: 250, y: startX - CGFloat(fontSize * 5))
            text.drawAtPoint(point, withAttributes: textFontAttributes)

        }
        
    }
    
    override func keyUp(theEvent: NSEvent) {
        let keyCode : UInt16 = theEvent.keyCode

        updateKeyboard(keyCode, pressed: false)
    }

    override func keyDown(theEvent: NSEvent) {
        let keyCode : UInt16 = theEvent.keyCode

        updateKeyboard(keyCode, pressed: true)
    }

    func updateKeyboard(keyCode:UInt16, pressed:Bool) {
        var value : UInt8
        if pressed {
            value = 1
        } else {
            value = 0
        }

        switch keyCode {
        case 18: // 1
            print("1")
            keys[1] = value

        case 19: // 2
            print("2")
            keys[2] = value

        case 20: // 3
            print("3")
            keys[3] = value

        case 21: // 4
            print("4")
            keys[0xC] = value
            
        case 12: // q
            print("q")
            keys[4] = value

        case 13: // w
            print("w")
            keys[5] = value

        case 14: // e
            print("e")
            keys[6] = value
            
        case 15: // r
            print("r")
            keys[0xD] = value

        case 0: // a
            print("a")
            keys[7] = value

        case 1: // s
            print("s")
            keys[8] = value

        case 2: // d
            print("d")
            keys[9] = value
            
        case 3: // f
            print("f")
            keys[0xE] = value

        case 6: // z
            print("z")
            keys[0xA] = value

        case 7: // x
            print("x")
            keys[0] = value

        case 8: // c
            print("c")
            keys[0xB] = value
            
        case 9: // v
            print("v")
            keys[0xF] = value

        default:
            print("default")
        }
    }
    
    var keys : [UInt8] = [0,0,0,0,
                          0,0,0,0,
                          0,0,0,0,
                          0,0,0,0]
    weak var cpu : CPU?

    func getKeys() -> [UInt8] {
        return self.keys
    }
    
    func setCPU(cpu : CPU) {
        self.cpu = cpu
    }
    
    func setNeedsDisplay(){
        // println("setNeedsDisplay")
        self.needsDisplay = true
    }
    
    func setDrawDebugInfo(drawDebugInfo : Bool) {
        self.drawDebug = drawDebugInfo
    }
    
}
