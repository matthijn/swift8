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
    static let MemorySize = 0x1000
    static let RegisterSize = 0xF
    static let StackSize = 0xF
    
    // Will hold the memory
    var memory = [Int](count: Chip8.MemorySize, repeatedValue: 0)
    
    // The register (last item in the register (VF) doubles as carry flag)
    var V = [Int](count: Chip8.RegisterSize, repeatedValue: 0)
    
    // The address register
    var I : Int = 0
    
    // The stack
    var stack = [Int](count: Chip8.StackSize, repeatedValue: 0)

    // Points to the current item in the stack
    var sp : Int = 0
    
    // The program counter (e.g holds current executing memory address)
    var pc : Int = 0
    
    // Used for delaying things, counts down from any non zero number at 60hz
    var delayTimer : Int = 0
    
    // Used for sounding a beep when it is non zero, counts down at 60hz
    var soundTimer : Int = 0
    
    // Flag to stop looping if needed
    var isLooping = false
    
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

    lazy var mapping : [Int: ((Int) -> Void)] = {
        
        return [
            
            // CLS (clear the display)
            0x00E0: { arg in
                print("Clear \(arg)")
            },
            
            // RET (return from a subroutine)
            0x00EE: { arg in
                // Set the program counter to the current item on the stack
                self.pc = self.stack[self.sp]
                
                // Decrement stack pointer
                self.sp--
            },
            
            // JP_ADDR (jump to a memory address)
            0x1000: { arg in
                self.pc = arg
            },
            
            // CALL_ADDR (call address on subroutine)
            0x2000: { arg in
                // Place current address on top of stack
                self.sp++
                self.stack[self.sp] = self.pc
            },
            
            // SE_V_BYTE (skip next instruction if register equals value)
            0x3000: { arg in
                let register = arg & 0x100
                let value = arg & 0x011

                if(self.V[register] == value)
                {
                    self.pc++
                }
            },
            
            // SNE_V_BYTE (skip next instruction if register does not equals value)
            0x4000: { arg in
                let registerX = arg & 0x100
                let value = arg & 0x11
                
                if(self.V[registerX] != value)
                {
                    self.pc++
                }
            },
            
            // SE_V_V (skip next instruction if register equals other register)
            0x5000: { arg in
                let registerX = arg & 0x10
                let registerY = arg & 0x1

                if(self.V[registerX] == self.V[registerY])
                {
                    self.pc++
                }
            },
            
            // LD_V_BYTE (set register with value)
            0x6000: { arg in
                let registerX = arg & 0x100
                let value = arg & 0x11

                self.V[registerX] = value;
            },
            
            // ADD_V_BYTE (add value to register v)
            0x7000: { arg in
                let registerX = arg & 0x100
                let value = arg & 0x11
                let currentValue = self.V[registerX]
                
                // Adding the value, but wrapping around since we can't store more in a byte
                self.V[registerX] = (currentValue + value) % 256
            },
            
            // OR_V_V (OR two registers and store result in first register)
            0x8001: { arg in
                let registerX = arg & 0x10
                let registerY = arg & 0x1
                
                let valueX = self.V[registerX]
                let valueY = self.V[registerY]
                
                self.V[registerX] = valueX | valueY
            },
            
            // AND_V_V (AND two registers and store result in first register)
            0x8002: { arg in
                let registerX = arg & 0x10
                let registerY = arg & 0x1
                
                let valueX = self.V[registerX]
                let valueY = self.V[registerY]
                
                self.V[registerX] = valueX & valueY
            },
            
            // XOR_V_V (XOR two registers and store result in first register)
            0x8003: { arg in
                let registerX = arg & 0x10
                let registerY = arg & 0x1
                
                let valueX = self.V[registerX]
                let valueY = self.V[registerY]
                
                self.V[registerX] = valueX ^ valueY
            },
            
            // ADD_V_V (Add two registers and store result in first register carry flag is set)
            0x8004: { arg in
                let registerX = arg & 0x10
                let registerY = arg & 0x1
                
                let valueX = self.V[registerX]
                let valueY = self.V[registerY]
                
                // Determine overflowed value
                let sum = valueX + valueY
                
                // Set the flag if needed
                self.V[0xF] = (sum > 255) ? 1 : 0
                
                // Store wrapped value
                self.V[registerX] = sum % 256
            },
            
            // SUB_V_V (Subtract the second register from the first and store result in first register, borrow flag is set when there is no borrow)
            0x8005: { arg in
                let registerX = arg & 0x10
                let registerY = arg & 0x1
                
                let valueX = self.V[registerX]
                let valueY = self.V[registerY]
                
                let result = valueX - valueY
                
                self.V[0xF] = (result < 0) ? 0 : 1
                
                self.V[registerX] = result % 256
            },
            
            // SHR_V (Shift the first register right by one the flag will contain the LSB before the shift (last nibble is ignored in opcode))
            0x8006: { arg in
                let registerX = arg & 0x10
                let valueX = self.V[registerX]
                
                // Set the flag
                let lsb = valueX & 0x1
                self.V[0xF] = lsb
                
                // Shift
                self.V[registerX] = valueX >> 1
            },
            
            // SUBN_V_V (Subtract the first register from the second register and store the result in the first register, borrow flag is set when there is no borrow)
            0x8007: { arg in
                let registerX = arg & 0x10
                let registerY = arg & 0x1
                
                let valueX = self.V[registerX]
                let valueY = self.V[registerY]
                
                let result = valueY - valueX
                
                self.V[0xF] = (result < 0) ? 0 : 1
                
                self.V[registerX] = result % 256
            },
            
            // SHL_V (Shift the first register left by one the flag will containt the MSB before the shift (last nibble is ignored in opcode))
            0x800E: { arg in
                let registerX = arg & 0x10
                let valueX = self.V[registerX]
                
                // Set the flag
                let msb = valueX & 0b10000000
                self.V[0xF] = msb
                
                // Shift
                self.V[registerX] = valueX << 1
            },
            
            // LD_V_V (copy register to another register)
            0x8000: { arg in
                let registerX = arg & 0x10
                let registerY = arg & 0x1
                
                self.V[registerX] = self.V[registerY]
            },            
            
            // SNE_V_V (Skip next instruction if the first register does not match the second register)
            0x9000: { arg in
                let registerX = arg & 0x10
                let registerY = arg & 0x1
                
                let valueX = self.V[registerX]
                let valueY = self.V[registerY]
                
                if(valueX != valueY)
                {
                    self.pc++
                }
            },
            
            // LD_I_ADDR (The I register is set with the ADDR)
            0xA000: { arg in
                self.I = arg
            },

            // JP_V0_ADDR (Jump to the address of ADDR + V0)
            0xB000: { arg in
                let value0 = self.V[0];
                self.pc = value0 + arg
            },
            
            // RND_V_BYTE (Generates a random byte value which then AND is applied to that value based on the byte parameter and placed in the register V)
            0xC000: { arg in
                let random = Int(arc4random_uniform(256))
                
                let registerX = arg & 0x100
                let value = arg & 0x11
                
                self.V[registerX] = random & value
            },
            
            // DRW_V_V_N (Draw sprite of length N on memory address I on coordinates of the passed registers VF is set on collision)
            0xD000: { arg in
                
            },
          
            // SKP_V (Skips the next instruction if the key which represents the value in register V is pressed)
            0xE09E: { arg in
                
            },
            
            // SKNP_V (Skips the next instruction if the key which represents the valine in register V is not pressed)
            0xE0A1: { arg in
                
            },
            
            // LD_V_DT (Set the register V to the value in dt)
            0xF007: { arg in
                let registerX = arg & 0x1
                self.V[registerX] = self.delayTimer
            },
            
            // LD_V_K  (Set the register V to the value of the keypress by the keyboard (will wait for keypress))
            0xF00A: { arg in
                
            },
            
            // LD_DT_V (Set the delayTimer to the value in register V)
            0xF015: { arg in
                let registerX = arg & 0x1
                self.delayTimer = self.V[registerX]
            },
            
            // LD_ST_V (Set the soundTimer to the value in register V)
            0xF018: { arg in
                let registerX = arg & 0x1
                self.soundTimer = self.V[registerX]
            },
            
            // ADD_I_V (I and the register are added and stored in I)
            0xF01E: { arg in
                let registerX = arg & 0x1
                self.I = self.I + self.V[registerX]
            },
            
            // LD_F_V (I is set to the address of the corresponding font block representing the value in register V)
            0xF029: { arg in
                
            },
            
            // LD_B_V (Stores the binary decimal representation of the value of register V in I)
            0xF033: { arg in
                
            },
            
            // LD_I_V (Stores the registers v0 to v(x) starting in memory beginning at location I)
            0xF055: { arg in
                
            },
            
            // LD_V_I (Reads from memory location I and stores it in registers V0 to V(x))
            0xF066: { arg in
                
            }
        ]
    }()

    // Hooks up the peripherals to the Chip8 system
    init(graphics: Graphics, sound: Sound, keyboard: Keyboard)
    {
        self.graphics = graphics
        self.sound = sound
        self.keyboard = keyboard

        self.resest()
    }
    
    /**
     * Resets everything to the beginning state
     */
    func resest()
    {
        // Make sure the loop is stopped
        self.stopLoop()
        
        // And reset
        self.memory = [Int](count: Chip8.MemorySize, repeatedValue: 0)
        self.V = [Int](count: Chip8.RegisterSize, repeatedValue: 0)
        self.I = 0
        self.stack = [Int](count: Chip8.StackSize, repeatedValue: 0)
        self.sp = self.stack.count - 1
        self.sp = 0
        self.pc = 0
        self.delayTimer = 0
        self.soundTimer = 0
    }
    
    /**
     * Starts the main loop
     */
    func startLoop()
    {
        self.isLooping = true
        
        // Putting some stuff in memory
        self.memory[0] = 0x00
        self.memory[1] = 0xE0
        self.memory[2] = 0x00
        self.memory[3] = 0xEE
        self.memory[4] = 0x11
        self.memory[5] = 0x00


        self.loop()
    }
    
    /**
    * Stops the loop
    */
    func stopLoop()
    {
        self.isLooping = false
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
//        if(self.isLooping)
        if(self.pc < 6)
        {
            // Delaying one 60th of a second
            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(1/60 * Double(NSEC_PER_SEC)))
            
            // And call self recursively after that delay
            dispatch_after(delay, dispatch_get_main_queue(), self.loop)
        }
    }
    
    /**
     * Counts the timers in the system down
     */
    private func tickInstruction()
    {
        // Get current block from memory everything is stored in blocks of two bytes where the first part is the opcode and the second part the parameters. The opcode can be multiple nibbles long
        let memoryBlock = self.memory[self.pc] << 8 | self.memory[self.pc + 1]

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
                
                // Remove the opcode from the memory block so we only pass the "arguments" to the correct function
                let arguments = memoryBlock ^ opcode
                
                print("Arguments are \(String(arguments, radix: 16))")
                
                // Call the closure
                closure(arguments)

                // No need to check further
                break
            }
        }
    }

    /**
     * Determines if the attached sound perpherals should make noise
     */
    private func makeNoise()
    {
        if(self.soundTimer > 0)
        {
            self.sound.bleep()
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