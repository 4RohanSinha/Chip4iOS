// The Swift Programming Language
// https://docs.swift.org/swift-book

import Chip8GNU
import Foundation

public class Emulator {
    private var emulator: chip_8
    
    public var pc: UInt16 {
        return emulator.pc
    }
    
    public var index: UInt16 {
        return emulator.index
    }
    
    public var registers: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) {
        return emulator.registers
    }
    
    
    public var keypad: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) {
        return emulator.keypad
    }
    
    public var stack: [UInt16] {
        let mirror = Mirror(reflecting: emulator.stack)
        return mirror.children.compactMap { child in
            if let value = child.value as? UInt16 {
                return value
            } else {
                return nil
            }
        }
    }
    
    public var video: [[Int]] {
        
        let video_arr = Mirror(reflecting: emulator.video).children.map({ $0.value }) as! [UInt32]
        
        return (0..<32).map { row in
            (0..<64).map { col in
                return Int(video_arr[row*64 + col])
            }
        }
    }
    
    public var delayTimer: UInt8 {
        return emulator.delayTimer
    }
    
    public var soundTimer: UInt8 {
        return emulator.soundTimer
    }
    
    public var sp: UInt8 {
        return emulator.sp
    }
    
    public var memory: [UInt8] {
        let mirror = Mirror(reflecting: emulator.memory)
        return mirror.children.compactMap { child in
            if let value = child.value as? UInt8 {
                return value
            } else {
                return nil
            }
        }
    }
    
    convenience public init?(url: URL?) {
        if let url = url, let content = try? Data(contentsOf: url) {
            self.init(bytes: content)
        } else {
            return nil
        }
    }
    
    public init(bytes: Data) {
        emulator = chip_8()
        withUnsafeMutablePointer(to: &emulator) { emulator_ptr in
            ch_initialize(emulator_ptr)
            
            let cString = UnsafeMutablePointer<UInt8>.allocate(capacity: bytes.count + 1)
            bytes.copyBytes(to: cString, count: bytes.count)
            cString[bytes.count] = 0
            
            ch_loadBytes(emulator_ptr, cString, bytes.count)
            cString.deallocate()
        }
    }
    
    public init(codableEmulator: CodableEmulator) {
        emulator = chip_8()
        
        withUnsafeMutablePointer(to: &emulator) { emulator_ptr in
            ch_initialize(emulator_ptr)
            
            codableEmulator.memory.withUnsafeBytes { mem_ptr in
                ch_loadMemory(emulator_ptr, mem_ptr.baseAddress, codableEmulator.memory.count)
            }
        }
        
        
        withUnsafeMutablePointer(to: &emulator.registers) { reg_ptr in
            reg_ptr.withMemoryRebound(to: UInt8.self, capacity: codableEmulator.registers.count) { dest_reg_array_ptr in
                codableEmulator.registers.withUnsafeBufferPointer { saved_reg_array_ptr in
                    memcpy(dest_reg_array_ptr, saved_reg_array_ptr.baseAddress, codableEmulator.registers.count)
                }
            }
        }
        
        withUnsafeMutablePointer(to: &emulator.keypad) { keypad_ptr in
            keypad_ptr.withMemoryRebound(to: UInt8.self, capacity: codableEmulator.keypad.count) { dest_key_array_ptr in
                codableEmulator.keypad.withUnsafeBufferPointer { saved_key_array_ptr in
                    memcpy(dest_key_array_ptr, saved_key_array_ptr.baseAddress, codableEmulator.keypad.count)
                }
            }
        }
        
        withUnsafeMutablePointer(to: &emulator.stack) { stack_ptr in
            stack_ptr.withMemoryRebound(to: UInt16.self, capacity: codableEmulator.stack.count) { dest_stack_array_ptr in
                codableEmulator.stack.withUnsafeBufferPointer { saved_stack_array_ptr in
                    memcpy(dest_stack_array_ptr, saved_stack_array_ptr.baseAddress, codableEmulator.stack.count*MemoryLayout<UInt16>.size)
                }
            }
        }
        
        let flattenedVideo = codableEmulator.video.flatMap { $0 }
        let uint32Video = flattenedVideo.map { UInt32($0) }
        withUnsafeMutablePointer(to: &emulator.video) { video_ptr in
            video_ptr.withMemoryRebound(to: UInt32.self, capacity: flattenedVideo.count) { dest_video_ptr in
                
                uint32Video.withUnsafeBufferPointer { src_video_ptr in
                    memcpy(dest_video_ptr, src_video_ptr.baseAddress, flattenedVideo.count*MemoryLayout<UInt32>.size)
                }
            }
            
        }
        
        
        emulator.pc = codableEmulator.pc
        emulator.sp = codableEmulator.sp
        emulator.delayTimer = codableEmulator.delayTimer
        emulator.soundTimer = codableEmulator.soundTimer
        emulator.index = codableEmulator.index
        
    }
    
    public func loadURL(url: URL?) {
        if let url = url, let content = try? Data(contentsOf: url) {
            loadBytes(bytes: content)
        }
    }
    
    public func loadBytes(bytes: Data) {
        withUnsafeMutablePointer(to: &emulator) { emulator_ptr in
            ch_initialize(emulator_ptr)
            
            let cString = UnsafeMutablePointer<UInt8>.allocate(capacity: bytes.count + 1)
            bytes.copyBytes(to: cString, count: bytes.count)
            cString[bytes.count] = 0
            
            ch_loadBytes(emulator_ptr, cString, bytes.count)
            cString.deallocate()
        }
    }
    
    public func runNextInstruction() {
        withUnsafeMutablePointer(to: &emulator) { emulator_ptr in
            ch_cycle(emulator_ptr)
        }
    }
    
    public func keyDown(key: Int32) {
        withUnsafeMutablePointer(to: &emulator) { emulator_ptr in
            ch_keyDown(emulator_ptr, key)
        }
    }
    
    public func keyUp(key: Int32) {
        withUnsafeMutablePointer(to: &emulator) { emulator_ptr in
            ch_keyUp(emulator_ptr, key)
        }
    }
}
