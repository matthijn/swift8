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

import Foundation
import AppKit

protocol CPUProtocol {
    func onOptocodeExecuted()
    func setNeedDisplay()
    func playSound()
}

class CPU : NSObject {
    
    let fontset : [UInt8] = [
        0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
        0x20, 0x60, 0x20, 0x20, 0x70, // 1
        0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
        0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
        0x90, 0x90, 0xF0, 0x10, 0x10, // 4
        0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
        0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
        0xF0, 0x10, 0x20, 0x40, 0x40, // 7
        0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
        0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
        0xF0, 0x90, 0xF0, 0x90, 0x90, // A
        0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
        0xF0, 0x80, 0x80, 0x80, 0xF0, // C
        0xE0, 0x90, 0x90, 0x90, 0xE0, // D
        0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
        0xF0, 0x80, 0xF0, 0x80, 0x80  // F
    ];
    
    // registers UInt8 or Int8
    typealias register = UInt8
    
    let MEMORY_COUNT = 4096
    
    var V : [UInt8] = [0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0]
    
    // Address Register
    var I : UInt16 = 0
    // program counter
    var PC : UInt16 = 0
    
    var memory : [UInt8] = []
    var stack : [UInt16] = []
    
    var delayTimer : UInt8 = 0
    var soundTimer : UInt8 = 0
    
    var screen : [UInt8] = []
    var keys : [UInt8] = [] // 0 - KEY_RELEASED 1 - KEY_PRESSED
    
    func initScreen(){
        let size = 64*32;
        
        screen = [UInt8](count: size, repeatedValue: 0)

    }
    
    func allocMemory() {
        // create array of appropriate length:
        memory = [UInt8](count: MEMORY_COUNT, repeatedValue: 0)
    }
    
    func setKeyboard(keys : [UInt8]){
        self.keys = keys
    }
    
    func zeroAllMemory() {
        for i in 0..<MEMORY_COUNT {
            memory[i] = 0x0
        }
    }
    
    func loadFontset() {
        for var i=0; i<fontset.count; i++ {
            memory[i] = fontset[i]
        }
    }
    
    func initKeyboard() {
        keys = [UInt8](count: 16, repeatedValue: 0)
    }
    
    override init () {
        super.init()

        reset()
    }

    var stop = false
    func stopRuning() {
        stop = true
    }

    func reset() {

        initScreen()
        initKeyboard()
        allocMemory()
        loadFontset()
    }

    func startProgram() {
        print("START program")
        stop = false
        // start program
        PC = 0x200

        var next : Bool
        repeat {
            if self.stop {
                return
            }
            
            let start : CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
            next = decodeOptocode()

            let end : CFAbsoluteTime = CFAbsoluteTimeGetCurrent()

            let delta = end - start// in seconds
            //println("delta = \(delta)")
            let deletaInMs = useconds_t(delta*1000_000)
            //println("deletaInMs = \(deletaInMs)")
            let timeToSleep = 0.001 - delta

            if (timeToSleep > 0) {
                let timeToSleepMicroSec = useconds_t(timeToSleep * 100_0000)
                //println("timeToSleepMicroSec = \(timeToSleepMicroSec)")
                usleep(useconds_t(timeToSleepMicroSec))
            }
        } while (next)
        
        print("END")
    }

    
    func updateTimers() {
        if self.delayTimer > 0 {
            self.delayTimer--
        }
        
        if (self.delayTimer > 0) {

            self.delayTimer--;
            if let ob = self.observer {
                ob.playSound()
            }
        }
    }

    var observer: CPUProtocol!
    func setListner(observer : CPUProtocol) {
        self.observer = observer
    }

    var optocode : UInt16 = 0
    func decodeOptocode() -> Bool {

        let hi : UInt8 = memory[Int(PC)]
        let lo : UInt8 = memory[Int(PC+1)]
        
        optocode = UInt16(hi)<<8 + UInt16(lo)

        let firstByte: UInt16 = (optocode & 0xF000)
        
        let X : Int = Int((optocode & 0x0F00)) >> 8
        let Y : Int = Int((optocode & 0x00F0)) >> 4
        
        var st = String(NSString(format:"%2X", optocode))
        
        // println("optocode = " +  st)

        switch firstByte{
        
        case 0x0000:
            switch optocode{
            case 0x00E0: // Clears the screen.
                clearsTheScreen()
                PC += 2
                
            case 0x00EE: // Returns from a subroutine.
                let returnAddress = stack.removeLast()
                PC = returnAddress
                
            default:
                unknownOptocode(optocode)
                return false
            }
            
        
        case 0x1000: // Jumps to address NNN.
            PC = optocode & 0x0FFF
            
        case 0x2000: // 2NNN Calls subroutine at NNN.
            // save return address to stack
            stack.append(PC + 2)
            PC = optocode & 0x0FFF
            
        
        case 0x3000: // 3XNN Skips the next instruction if VX equals NN.
            let NN : Int = Int((optocode & 0x00FF))
            let VX = V[X]
            if Int(VX) == NN {
                PC += 4
            } else {
                PC += 2
            }
            
        case 0x4000: // 4XNN Skips the next instruction if VX doesn't equal NN.
            let NN : Int = Int((optocode & 0x00FF))
            let VX = V[X]
            if Int(VX) != NN {
                PC += 4
            } else {
                PC += 2
            }
            
        case 0x5000: // 5XY0 Skips the next instruction if VX equals VY.
            let VX = V[X]
            let VY = V[Y]
            if VX == VY {
                PC += 4
            } else {
                PC += 2
            }
            
        case 0x6000: // 6XNN - Sets  VX to NN.
            let NN = UInt8(optocode & 0x00FF)
            V[X] = NN
            PC += 2
            // TODO
            
        case 0x7000: // Adds NN to VX.
            let NN = UInt8(optocode & 0x00FF)
            var result : UInt32 = UInt32(V[X]) + UInt32(NN)
            if result > 255 {
                result -= (255 + 1) // TODO czy ten plus jest potrzebny ??
            }
            V[X] = UInt8(result)
            PC += 2
            
        case 0x8000:
            switch (optocode & 0xF00F){
                case 0x8000: // 8XY0	Sets VX to the value of VY.
                    V[X] = V[Y]
                    PC += 2
                
                case 0x8001: // 8XY1	Sets VX to VX or VY.
                    V[X] = V[X] | V[Y]
                    PC += 2
                
                case 0x8002: // 8XY2	Sets VX to VX and VY.
                    V[X] = V[X] & V[Y]
                    PC += 2
                
                case 0x8003: // 8XY3	Sets VX to VX xor VY.
                    V[X] = V[X] ^ V[Y]
                    PC += 2
                
                case 0x8004: // Adds VY to VX. VF is set to 1 when there's a carry, and to 0 when there isn't.
                    var addResult:Int = Int(V[X]) + Int(V[Y])
                    if addResult > 255 {
                        V[0xF] = 1
                        addResult -= (255 + 1)
                    } else {
                        V[0xF] = 0
                    }
                    V[X] = UInt8(addResult)
                    PC += 2
                
                case 0x8005: //  8XY5 VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
                    let VY = V[Y]
                    let VX = V[X]
                    var result = Int(VX) - Int(VY)
                    if result<0 {
                        V[0xF] = 0
                        result += 256
                    } else {
                        V[0xF] = 1
                    }
                    
                    V[X] = UInt8(result)
                    PC += 2
                
                case 0x8006:
                    V[0xF] = V[X] & 0x01
                    V[X] = V[X] >> 1
                    PC += 2
                
                case 0x8007: // Sets VX to VY minus VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
                    let VY = V[Y]
                    let VX = V[X]
                    var result = Int(VY) - Int(VX)
                    if result<0 {
                        V[0xF] = 0
                        result += 256
                    } else {
                        V[0xF] = 1
                    }
                    
                    V[X] = UInt8(result)
                    PC += 2
                    return false
                
                case 0x800E: // Shifts VX left by one. VF is set to the value of the most significant bit of VX before the shift.
                    V[0xF] = V[X] & 0x80
                    V[X] = V[X] << 1
                    PC += 2
                
                
            default:
                unknownOptocode(optocode)
                return false
            }
            
        case 0x9000: // 9XY0 Skips the next instruction if VX doesn't equal VY.
            if (PC > 0x300) {
                var i=0;
                i++
            }
            let VY = V[Y]
            let VX = V[X]
            
            if VX != VY {
                PC += 4
            } else {
                PC += 2
            }
            
        case 0xA000: // ANNN - Sets I to the address NNN.
            I = (optocode & 0x0FFF)
            PC += 2
            
        case 0xB000: // BNNN - Jumps to the address NNN plus V0.
            PC = (optocode & 0x0FFF) + UInt16(V[0])
        
            
        case 0xC000: // CXNN Sets VX to a random number, masked by NN.
            let NN = UInt8(optocode & 0x00FF)
            let randomValue = UInt8(arc4random_uniform(255)) & NN
            V[X] = randomValue
            PC += 2

        case 0xD000:
            // 0xDXYN Sprites stored in memory at location in index register (I), maximum 8bits wide.
            // Draws a sprite at coordinate (VX, VY) that has a width of 8 pixels and a height of N pixels.
            // Each row of 8 pixels is read as bit-coded starting from memory location I;
            // I value doesn’t change after the execution of this instruction.
            // As described above, VF is set to 1 if any screen pixels are flipped from set to unset
            // when the sprite is drawn, and to 0 if that doesn’t happen.

          V[0xF] = 0
          //println("I = \(I)")
          let nPixels : Int = Int((optocode & 0x000F))
          for var yline=0; yline<nPixels; yline++ {
            let index = Int(I + UInt16(yline))
            let pixel = memory[index]
            
            for var xline=0; xline<8; xline++ {
                
                if (pixel & UInt8(0x80 >> xline)) != 0 {
                    let VX = Int(V[X])
                    let VY = Int(V[Y])

                    let pixelX = Int(VX) + xline
                    let pixelY = Int(VY) + yline

//                    if (pixelX >= 64) {
//                        pixelX -= 64;
//                    } else
//                    if (pixelX < 0) {
//                        pixelX += 64;
//                    }
//
//                    if (pixelY >= 32) {
//                        pixelY -= 32;
//                    } else
//                    if (pixelY < 0) {
//                        pixelY += 32;
//                    }

                    //var pixelIndex = Int(x) + xline  + Int(y + yline) * 64
                    let pixelIndex = pixelX  + pixelY * 64

                    //println("  VX=\(VX), YX = \(VY) pixelX=\(pixelX) pixelY=\(pixelY)")

                    //println("  pixelIndex = \(pixelIndex)")
                    if (pixelIndex < 2048) {
                        if (screen[pixelIndex] == 1) {
                            V[0xF] = 1
                        }

                        screen[pixelIndex] ^= 1
                    }
                }
            }
          }
            if let obs = self.observer {
                obs.setNeedDisplay()
            }
          PC += 2
            
        case 0xE000:
            switch optocode & 0x00FF {
                
                case 0x009E: // EX9E Skips the next instruction if the key stored in VX is pressed.
                    let keyIndex = Int(V[X])
                    if keys[keyIndex] == 1 {
                        PC += 4
                    } else {
                        PC += 2
                    }
                    
                case 0x00A1: // EXA1 Skips the next instruction if the key stored in VX isn't pressed.
                    let keyIndex = Int(V[X])
                    if keys[keyIndex] == 0 {
                        PC += 4
                    } else {
                        PC += 2
                    }

                default:
                    unknownOptocode(optocode)
                    return false
            }

        case 0xF000:

            switch optocode & 0x00FF{
                
            case 0x007:
                V[X] = self.delayTimer
                PC += 2
                
            case 0x000A: // A key press is awaited, and then stored in VX.
                for var i=0; i<16; i++ {
                    if self.keys[i] > 0 {
                        V[X] = UInt8(i)
                        PC += 2;
                    }
                }
                
            case 0x0015: // FX15	Sets the delay timer to VX.
                self.delayTimer = V[X]
                PC += 2
                
            case 0x0018: // FX18	Sets the sound timer to VX
                self.soundTimer = V[X]
                PC += 2
                
            case 0x001E: // FX1E Adds VX to I. set VF if buffer overflow
                let result = Int(I) + Int(V[X])
                
                if result > 0xFFF{
                    V[0xF] = 1
                    I = UInt16(result - Int(0xFFF + 1))
                } else {
                    V[0xF] = 0
                    I = UInt16(result)
                }
                
                PC += 2
                
            case 0x029: // FX29 Sets I to the location of the sprite for the character in VX. Characters 0-F (in hexadecimal) are represented by a 4x5 font.
                I = UInt16(V[X] * 5)
                PC += 2

            // Stores the Binary-coded decimal representation of VX,
            // with the most significant of three digits at the address in I,
            // the middle digit at I plus 1, and the least significant digit at I plus 2.
            // (In other words, take the decimal representation of VX, place the hundreds digit in memory at location in I,
            // the tens digit at location I+1, and the ones digit at location I+2.)
            case 0x0033:
                var number = V[X]

                for var i = 3; i > 0; i-- {
                    let value = number % 10
                    let index = Int(I) + Int(i - 1)
                    self.memory[index] = value
                    // this.memory[this.i + i - 1] = parseInt(number % 10);
                    number /= 10;
                }
                PC += 2

            case 0x0055: // FX55 Stores V0 to VX in memory starting at address I.[4]
                
                for var i=0; i<=X; i++ {
                    let index : Int = Int(I + UInt16(i))
                    self.memory[index] = V[i]
                }
                PC += 2
            
            case 0x0065: // FX65 Fills V0 to VX with values from memory starting at address I.[4]
                for var i=0; i<=X; i++ {
                    let index : Int = Int(I + UInt16(i))
                    V[i] = self.memory[index]
                }
                PC += 2
                
            default:
                unknownOptocode(optocode)
                return false
            }
  
        default:
            unknownOptocode(optocode)
            return false
        }
        
        if let obs = self.observer {
            obs.onOptocodeExecuted()
        }
        
        //var pcHex = String(NSString(format:"%3X", PC))
        //println("PC= " + pcHex)
        
        return true
    }
    
    func unknownOptocode(let optocode: UInt16) {
        let optocodeInHex = String(optocode, radix: 16)
        print("UNKNOWN OPTOCODE: \(optocodeInHex)")
    }
    
    func clearsTheScreen(){
        print("clearsTheScreen")

        for var i=0; i<screen.count; i++ {
            screen[i] = 0
        }
    }

    func loadProgramFromFile(filePath : String){
        let data = NSData(contentsOfFile : filePath)

        if let dataNS = data {
            
            let ptr = UnsafePointer<UInt8>(dataNS.bytes)
            let bytes = UnsafeBufferPointer<UInt8>(start:ptr, count:dataNS.length)
            let length = dataNS.length
            
            dataNS.getBytes((&memory + 0x200), length: length)
        }
    }
}
