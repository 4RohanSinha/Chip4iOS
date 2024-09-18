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
