//
//  Chip8.swift
//  Swift8
//
//  Created by Matthijn Dijkstra on 18/08/15.
//  Copyright © 2015 Matthijn Dijkstra. All rights reserved.
//  Based on technical documentation found on http://devernay.free.fr/hacks/chip8/C8TECH10.HTM#00E0

import Foundation

class Chip8 : NSObject // Using performSelector to map opcodes to methods
{
    
    // Will hold the memory
    var memory = [Int](count: 0x1000, repeatedValue: 0)
    
    // The register (last item in the register (VF) doubles as carry flag)
    var V = [UInt8](count: 0xF, repeatedValue: 0)
    
    // The address register
    var I : UInt16 = 0
    
    // The stack
    var stack = [UInt16](count: 0xF, repeatedValue: 0)

    // Points to the current item in the stack
    var sp : UInt8 = 0
    
    // The program counter (e.g holds current executing memory address)
    var pc : Int = 0
    
    // Used for delaying things, counts down from any non zero number at 60hz
    var delayTimer : UInt8 = 0
    
    // Used for sounding a beep when it is non zero, counts down at 60hz
    var soundtimer : UInt8 = 0
    
    // Flag to stop looping if needed
    var isLooping = false
    
    // The peripherals
    let graphics : Graphics;
    let sound : Sound;
    let keyboard : Keyboard;
    
    // Mapping the opcodes to methods here
    
    // Using the following info in the naming of the methods, the first part is the assembly name that would happen, after the underscore what is being moved, copied or checked
    // addr - A 12-bit value, the lowest 12 bits of the instruction
    // n or nibble - A 4-bit value, the lowest 4 bits of the instruction
    // x - A 4-bit value, the lower 4 bits of the high byte of the instruction
    // y - A 4-bit value, the upper 4 bits of the low byte of the instruction
    // kk or byte - An 8-bit value, the lowest 8 bits of the instruction
    // v - a register
    // byte - a byte
    // i - the I (address) register
    // dt - delay timer
    // st - sound timer
    // k - keyboard button
    // f - Reference to the hexidecimal font in memory
    
    // Since we are checking on the AND value, order here is important

    let mapping = [
        0x00E0: "cls", // clear the display
        0x00EE: "ret", // return from subroutine
        0x0000: "sys", // Todo: (not required it seems)
        0x1000: "jp_addr", // jump to memory address
        0x2000: "call_addr", // call address as subroutine
        0x3000: "se_v_byte", // skip next instruction if register equals value
        0x4000: "sne_v_byte", // skip next instruction if register not equals value
        0x5000: "se_v_v", // skip next instruction if register equals other register
        0x6000: "ld_v_byte", // set register with value
        0x7000: "add_v_byte", // add value to register v
        0x8001: "or_v_v", // OR two registers and store result in first register
        0x8002: "and_v_v", // AND two registers and store result in first register
        0x8003: "xor_v_v", // XOR two registers and store result in first register
        0x8004: "add_v_v", // Add two registers and store result in first register carry flag is set
        0x8005: "sub_v_v", // Subtract the second register from the first and store result in first register, borrow flag is set when there is no borrow
        0x8006: "shr_v", // Shift the first register right by one the flag will contain the LSB before the shift (last nibble is ignored in opcode)
        0x8007: "subn_v_v", // Subtract the first register from the second register and store the result in the first register, borrow flag is set when there is no borrow
        0x800E: "shl_v", // Shift the first register left by one the flag will containt the RSB before the shift (last nibble is ignored in opcode)
        0x8000: "ld_v_v", // copy register to another register
        0x9000: "sne_v_v", // Skip next instruction if the first register does not match the second register
        0xA000: "ld_i_addr", // The I register is set with the address
        0xB000: "jp_v0_addr", // Jump to the address of addr + v0
        0xC000: "rnd_v_byte", // Generates a random byte value which then AND is applied to that value based on the byte parameter and placed in the register v
        0xD000: "drw_v_v_n", // Draw sprite of length n on memory address I on coordinates of the passed registers VF is set on collision
        0xE09E: "skp_v", // Skips the next instruction if the key which represents the value in register v is pressed
        0xE0A1: "sknp_v", // Skips the next instruction if the key which represents the valine in register v is not pressed
        0xF007: "ld_v_dt", // Set the register v to the value in dt
        0xF00A: "ld_v_k", // Set the register v to the value of the keypress by the keyboard (will wait for keypress)
        0xF015: "ld_dt_v", // Set the delay timer to the value in register v
        0xF018: "ld_st_v", // Set the sound timer to the value in register v
        0xF01E: "add_i_v", // The results of I and v are added and stored in i
        0xF029: "ld_f_v", // I is set to the address of the corresponding font block representing the value in register v
        0xF033: "ld_b_v", // Stores the binary decimal representation of the value of register v in I
        0xF055: "ld_i_v", // Stores the registers v0 to v(x) starting in memory location i,
        0xF066: "ld_v_i" // Reads from memory location i and stores it in registers V0 to v(x)
    ]
    
    // Hooks up the peripherals to the Chip8 system
    init(graphics: Graphics, sound: Sound, keyboard: Keyboard)
    {
        self.graphics = graphics;
        self.sound = sound;
        self.keyboard = keyboard;
    }
    
    /**
     * Resets everything to the beginning state
     */
    func resest()
    {
        // Make sure the loop is stopped
        self.stopLoop()
        
        // And reset
        
    }
    
    /**
     * Starts the main loop
     */
    func startLoop()
    {
        self.isLooping = true
        self.loop()
    }
    
    /**
    * Stops the loop
    */
    func stopLoop()
    {
        self.isLooping = false;
    }
    
    /**
     * The main loop
     */
    func loop()
    {
        // Handle the next instruction
        self.tickInstruction()
        
        // Make sure the timers countdown
        self.countdownTimers()
        
        // Make sound if needed
        self.makeNoise()
        
        // And update the screen with the correct graphics
        self.drawGraphics()
        
        // Determine if we should continue the loop
        if(self.isLooping)
        {
            // Delaying one 60th of a second
            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(60 * NSEC_PER_SEC))
            
            // And call self recursively after that delay
            dispatch_after(delay, dispatch_get_main_queue(), self.loop)
        }
    }
    
    /**
     * Counts the timers in the system down
     */
    func tickInstruction()
    {
        // Get current block from memory everything is stored in blocks of two bytes where the first part is the opcode and the second part the parameters. The opcode can be multiple nibbles long
        let memoryblock = self.memory[self.pc] << 8 | self.memory[self.pc + 1];

        // Increment the program counter
        self.pc+=2;
        
        // Try every possible opcode to see if the current memory block hold that opcode
        for (opcode, method) in self.mapping
        {
            // Determine if the current opcode matches with the information in the memory block
            if (memoryblock & opcode) == opcode
            {
                // Remove the opcode from the memory block so we only pass the "arguments" to the correct function
                let arguments = memoryblock ^ opcode
                
                // Call the correct method with only the argument information, stripping the opcode
                self.performSelector(method, withObject: arguments);
                
                // No need to check further
                break;
            }
        }
    }

    /**
     * Determines if the attached sound perpherals should make noise
     */
    func makeNoise()
    {
        if(self.soundtimer > 0)
        {
            self.sound.bleep();
        }
    }
    
    func drawGraphics()
    {
        // Draw the graphics
    }
    
    /**
     * Counts the timers in the system down
     */
    func countdownTimers()
    {
        // Decrement the delay timer
        if(self.delayTimer > 0)
        {
            self.delayTimer--
        }
        
        // And the sound timer
        if(self.soundtimer > 0)
        {
            self.soundtimer--
        }
    }

}