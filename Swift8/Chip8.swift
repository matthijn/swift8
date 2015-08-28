//
//  Chip8.swift
//  Swift8
//
//  Created by Matthijn Dijkstra on 18/08/15.
//  Copyright © 2015 Matthijn Dijkstra. All rights reserved.
//  Based on technical documentation found on http://devernay.free.fr/hacks/chip8/C8TECH10.HTM#00E0

import Foundation

class Chip8
{
    // Total memory size
    static let MemorySize = 0x1000
    
    // Total register size
    static let RegisterSize = 0xF
    
    // Total stack size
    static let StackSize = 0xF

    // The location from where the fonts are going to be stored in memory
    static let FontMemoryLocation : UInt16 = 0
    
    // The location from where roms are loaded
    static let RomLocation : UInt16 = 511
    
    // Will hold the memory
    var memory = [UInt8](count: Chip8.MemorySize, repeatedValue: 0)
    
    // The register (last item in the register (VF) doubles as carry flag)
    var V = [UInt8](count: Chip8.RegisterSize, repeatedValue: 0)
    
    // The address register
    var I : UInt16 = 0
    
    // The stack
    var stack = [UInt16](count: Chip8.StackSize, repeatedValue: 0)

    // Points to the current item in the stack
    var sp : UInt8 = 0
    
    // The program counter (e.g holds current executing memory address)
    var pc : UInt16 = 0
    
    // Used for delaying things, counts down from any non zero number at 60hz
    var delayTimer : UInt8 = 0
    
    // Used for sounding a beep when it is non zero, counts down at 60hz
    var soundTimer : UInt8 = 0
    
    // Flag to stop looping if needed
    var isRunning = false
    
    // The peripherals
    let graphics : Graphics
    let sound : Sound
    let keyboard : Keyboard
    
    // Mapping every opcode to a closure
    
    // Using the following info in the naming of the methods, the first part is the assembly name that would happen, after the underscore what is being moved, copied or checked
    // ADDR - A 12-bit value, the lowest 12 bits of the instruction
    // N  - A nibble (4-bit) value
    // BYTE a byte
    // V - a register
    // I - the I (address) register
    // DT - delay timer
    // ST - sound timer
    // K - keyboard button
    // F - Reference to the hexidecimal font in memory
    
    // Since we are checking on the AND value, order here is important

    lazy var mapping : [UInt16: ((UInt16) -> Void)] = {
        
        return [
            
            // CLS (clear the display)
            0x00E0: { arg in
                self.graphics.clear()
            },
            
            // RET (return from a subroutine)
            0x00EE: { arg in
                // Set the program counter to the current item on the stack
                self.pc = self.stack[Int(self.sp)]

                // Decrement stack pointer
                self.sp--
            },
            
            // JP_ADDR (jump to a memory address)
            0x1000: { arg in
                self.pc = arg & 0x0FFF
            },
            
            // CALL_ADDR (call address on subroutine)
            0x2000: { arg in
                // Place current address on top of stack
                self.sp++
                self.stack[Int(self.sp)] = self.pc
            },
            
            // SE_V_BYTE (skip next instruction if register equals value)
            0x3000: { arg in
                let register = Int(arg & 0x0F00) >> 8
                let value = UInt8(arg & 0x00FF)

                if(self.V[register] == value)
                {
                    self.pc++
                }
            },
            
            // SNE_V_BYTE (skip next instruction if register does not equals value)
            0x4000: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                let value = UInt8(arg & 0x00FF)
                
                if(self.V[registerX] != value)
                {
                    self.pc++
                }
            },
            
            // SE_V_V (skip next instruction if register equals other register)
            0x5000: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                let registerY = Int(arg & 0x00F0)

                if(self.V[registerX] == self.V[registerY])
                {
                    self.pc++
                }
            },
            
            // LD_V_BYTE (set register with value)
            0x6000: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                let value = UInt8(arg & 0x00FF)

                self.V[registerX] = value;
            },
            
            // ADD_V_BYTE (add value to register v)
            0x7000: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                let value = UInt8(arg & 0x00FF)
                let currentValue = self.V[registerX]
                
                // Adding the value, but wrapping around since we can't store more in a byte
                self.V[registerX] = UInt8(Int((currentValue + value)) % 256)
            },
            
            // OR_V_V (OR two registers and store result in first register)
            0x8001: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                let registerY = Int(arg & 0x00F0)
                
                let valueX = self.V[registerX]
                let valueY = self.V[registerY]
                
                self.V[registerX] = valueX | valueY
            },
            
            // AND_V_V (AND two registers and store result in first register)
            0x8002: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                let registerY = Int(arg & 0x00F0) >> 4
                
                let valueX = self.V[registerX]
                let valueY = self.V[registerY]
                
                self.V[registerX] = valueX & valueY
            },
            
            // XOR_V_V (XOR two registers and store result in first register)
            0x8003: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                let registerY = Int(arg & 0x00F0) >> 4
                
                let valueX = self.V[registerX]
                let valueY = self.V[registerY]
                
                self.V[registerX] = valueX ^ valueY
            },
            
            // ADD_V_V (Add two registers and store result in first register carry flag is set)
            0x8004: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                let registerY = Int(arg & 0x00F0) >> 4
                
                let valueX = self.V[registerX]
                let valueY = self.V[registerY]
                
                // Determine overflowed value
                let sum = valueX + valueY
                
                // Set the flag if needed
                self.V[0xF] = (sum > 255) ? 1 : 0
                
                // Store wrapped value
                self.V[registerX] = UInt8(Int(sum) % 256)
            },
            
            // SUB_V_V (Subtract the second register from the first and store result in first register, borrow flag is set when there is no borrow)
            0x8005: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                let registerY = Int(arg & 0x00F0) >> 4
                
                let valueX = self.V[registerX]
                let valueY = self.V[registerY]
                
                let result = valueX - valueY
                
                self.V[0xF] = (result < 0) ? 0 : 1
                
                self.V[registerX] = UInt8(Int(result) % 256)
            },
            
            // SHR_V (Shift the first register right by one the flag will contain the LSB before the shift
            0x8006: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                let valueX = self.V[registerX]
                
                // Set the flag
                let lsb = valueX & 0b1
                self.V[0xF] = lsb
                
                // Shift
                self.V[registerX] = valueX >> 1
            },
            
            // SUBN_V_V (Subtract the first register from the second register and store the result in the first register, borrow flag is set when there is no borrow)
            0x8007: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                let registerY = Int(arg & 0x00F0) >> 4
                
                let valueX = self.V[registerX]
                let valueY = self.V[registerY]
                
                let result = valueY - valueX
                
                self.V[0xF] = (result < 0) ? 0 : 1
                
                self.V[registerX] = UInt8(Int(result) % 256)
            },
            
            // SHL_V (Shift the first register left by one the flag will containt the MSB before the shift
            0x800E: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                let valueX = self.V[registerX]
                
                // Set the flag
                let msb = valueX & 0b10000000
                self.V[0xF] = msb
                
                // Shift
                self.V[registerX] = valueX << 1
            },
            
            // LD_V_V (copy register to another register)
            0x8000: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                let registerY = Int(arg & 0x00F0) >> 4
                
                self.V[registerX] = self.V[registerY]
            },            
            
            // SNE_V_V (Skip next instruction if the first register does not match the second register)
            0x9000: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                let registerY = Int(arg & 0x00F0) >> 4
                
                let valueX = self.V[registerX]
                let valueY = self.V[registerY]
                
                if(valueX != valueY)
                {
                    self.pc++
                }
            },
            
            // LD_I_ADDR (The I register is set with the ADDR)
            0xA000: { arg in
                self.I = arg & 0x0FFF
            },

            // JP_V0_ADDR (Jump to the address of ADDR + V0)
            0xB000: { arg in
                let value0 = self.V[0];
                self.pc = UInt16(value0) + (arg & 0x0FFF)
            },
            
            // RND_V_BYTE (Generates a random byte value which then AND is applied to that value based on the byte parameter and placed in the register V)
            0xC000: { arg in
                let random = UInt8(arc4random_uniform(256))
                
                let registerX = Int(arg & 0x0F00) >> 8
                let value = UInt8(arg & 0x00FF)
                
                self.V[registerX] = random & value
            },
            
            // DRW_V_V_N (Draw sprite of length N on memory address I on coordinates of the passed registers VF is set on collision)
            0xD000: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                let registerY = Int(arg & 0x00F0) >> 4
                
                let valueX = self.V[registerX]
                let valueY = self.V[registerY]
                
                let spriteSize = UInt16(arg & 0x000F)
                
                let start = Int(self.I)
                let end = Int(self.I + spriteSize)
                
                // Get the part of the memory with the sprite
                let memorySlice = self.memory[start...end]
                
                // Draw the graphics
                
                // Returns wether the "cleared a pixel while drawing" flag should be true
                if self.graphics.draw(memorySlice, x: valueX, y: valueY)
                {
                    self.V[0xF] = 1
                }
                else
                {
                    self.V[0xF] = 0
                }
            },
          
            // SKP_V (Skips the next instruction if the key which represents the value in register V is pressed)
            0xE09E: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                let valueX = Int8(self.V[registerX])
                
                if valueX == self.keyboard.currentKey
                {
                    self.pc++
                }
            },
            
            // SKNP_V (Skips the next instruction if the key which represents the valine in register V is not pressed)
            0xE0A1: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                let valueX = Int8(self.V[registerX])
                
                if valueX != self.keyboard.currentKey
                {
                    self.pc++
                }
            },
            
            // LD_V_DT (Set the register V to the value in dt)
            0xF007: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                self.V[registerX] = self.delayTimer
            },
            
            // LD_V_K  (Set the register V to the value of the keypress by the keyboard (will wait for keypress))
            0xF00A: { arg in
                
                let registerX = Int(arg & 0x0F00) >> 8

                repeat
                {
                    if(self.keyboard.currentKey != -1)
                    {
                        self.V[registerX] = UInt8(self.keyboard.currentKey)
                    }
                }
                while(self.keyboard.currentKey == -1)

            },
            
            // LD_DT_V (Set the delayTimer to the value in register V)
            0xF015: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                self.delayTimer = self.V[registerX]
            },
            
            // LD_ST_V (Set the soundTimer to the value in register V)
            0xF018: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                self.soundTimer = self.V[registerX]
            },
            
            // ADD_I_V (I and the register are added and stored in I)
            0xF01E: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                self.I = self.I + UInt16(self.V[registerX])
            },
            
            // LD_F_V (I is set to the address of the corresponding font block representing the value in register V)
            0xF029: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                let valueX = self.V[registerX]
                
                // Get the memory offset for this hex number (a single font consists of 5 bytes)
                let memoryOffset = Chip8.FontMemoryLocation + UInt16(valueX * 5)
                
                // And point to the beginning of the font
                self.I = memoryOffset
            },
            
            // LD_B_V (Stores the binary decimal representation of the value of register V in I)
            0xF033: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                var valueX = self.V[registerX]
                
                // With the binary decimal representation (unpacked) every single digit of a number is stored in a seperate byte
                // Number can be max three digits long (8 bits)
                for var i = 2; i >= 0; i--
                {
                    // Getting the current smallest digit of the whole number
                    let currentValue = valueX % 10
                    
                    // Determine where to store
                    let index = Int(self.I) + i

                    // Store it
                    self.memory[index] = currentValue
                    
                    // Divide by ten zo in the next run the second smallest digit is the new smallest digit
                    valueX /= 10
                }
            },
            
            // LD_I_V (Stores the registers v0 to v(x) starting in memory beginning at location I)
            0xF055: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                
                for var currentRegister = 0; currentRegister <= registerX; currentRegister++
                {
                    // Get byte from register
                    let registerByte = self.V[currentRegister]
                    
                    // Store it in memory
                    self.memory[Int(self.I)] = registerByte
                    
                    self.I++
                }
            },
            
            // LD_V_I (Reads from memory location I and stores it in registers V0 to V(x))
            0xF065: { arg in
                let registerX = Int(arg & 0x0F00) >> 8
                
                for var currentRegister = 0; currentRegister <= registerX; currentRegister++
                {
                    // Get the byte from memory
                    let memoryByte = self.memory[Int(self.I)]
                    
                    // Store it in current register
                    self.V[currentRegister] = memoryByte
                    
                    // And increment the I register memory address
                    self.I++
                }
            }
        ]
    }()

    // Hooks up the peripherals to the Chip8 system
    init(graphics: Graphics, sound: Sound, keyboard: Keyboard)
    {
        self.graphics = graphics
        self.sound = sound
        self.keyboard = keyboard

        self.reset()
    }
    
    /**
     * Load data into memory
     */
    func load(data: NSData, autostart : Bool = true)
    {
        // Change to a state in which we can load
        self.stopLoop()
        self.reset()
        
        // Converting NSData to byte array
        var bytesArray = [UInt8](count: data.length, repeatedValue: 0)
        data.getBytes(&bytesArray, length: data.length)
        
        // Getting each byte and moving it to the correct spot in memory
        for (index, byte) in bytesArray.enumerate()
        {
            let indexInMemory = Chip8.RomLocation + UInt16(index)
            self.memory[Int(indexInMemory)] = byte
        }
        
        if autostart
        {
            self.startLoop()
        }
    }
    
    /**
     * Resets everything to the beginning state
     */
    func reset()
    {
        // Make sure the loop is stopped
        self.stopLoop()
        
        // And reset
        self.memory = [UInt8](count: Chip8.MemorySize, repeatedValue: 0)
        self.V = [UInt8](count: Chip8.RegisterSize, repeatedValue: 0)
        self.I = 0
        self.stack = [UInt16](count: Chip8.StackSize, repeatedValue: 0)
        self.sp = UInt8(self.stack.count - 1)
        self.sp = 0
        self.pc = Chip8.RomLocation
        self.delayTimer = 0
        self.soundTimer = 0
        
        // And load the fonts
        self.loadFonts()
        
        // Clear the screen
        self.graphics.clear()
    }

    /**
     * Starts the main loop
     */
    func startLoop()
    {
        self.isRunning = true
        self.loop()
    }
    
    /**
    * Stops the loop
    */
    func stopLoop()
    {
        self.isRunning = false
    }
    
    /**
     * Loads the font sprite information in memory
     */
    private func loadFonts()
    {
        for (index, fontByte) in Graphics.FontSpriteData.enumerate()
        {
            let indexWithOffset = Int(UInt16(index) + Chip8.FontMemoryLocation)
            self.memory[indexWithOffset] = fontByte
        }
    }
    
    /**
     * The main loop
     */
    private func loop()
    {
        // Handle the next instruction
        self.tickInstruction()

        // Make sure the timers countdown
        self.countdownTimers()
        
        // Make sound if needed
        self.makeNoise()
        
        // Determine if we should continue the loop
        if(self.isRunning)
        {
            // Delaying one 60th of a second
            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0/60.0 * Double(NSEC_PER_SEC)))
            
            // And call self recursively after that delay
            dispatch_after(delay, dispatch_get_main_queue(), self.loop)
        }
    }
    
    /**
     * Counts the timers in the system down
     */
    private func tickInstruction()
    {
        // Get current block to run from memory everything which is stored in blocks of two bytes containing both the opcode and "parameters"
        let memoryBlock = UInt16(self.memory[Int(self.pc)]) << 8 | UInt16(self.memory[Int(self.pc + 1)])

        print("Memory value at PC \(self.pc) \(String(memoryBlock, radix: 16))")
        
        // Increment the program counter
        self.pc+=2
        
        // Try every possible opcode to see if the current memory block hold that opcode
        for (opcode, closure) in self.mapping
        {
            // Determine if the current opcode matches with the information in the memory block
            if (memoryBlock & opcode) == opcode
            {
                
                print("Memory matches opcode \(String(opcode, radix: 16))")

                // Call the closure
                closure(memoryBlock)

                // No need to check further
                break
            }
        }
    }

    /**
     * Determines if the attached sound peripherals should make noise
     */
    private func makeNoise()
    {
        if(self.soundTimer > 0)
        {
            self.sound.beep(1.0/60.0)
        }
    }

    /**
     * Counts the timers in the system down
     */
    private func countdownTimers()
    {
        // Decrement the delay timer
        if(self.delayTimer > 0)
        {
            self.delayTimer--
        }
        
        // And the sound timer
        if(self.soundTimer > 0)
        {
            self.soundTimer--
        }
    }
    
}