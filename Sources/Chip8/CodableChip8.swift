//
//  File.swift
//  
//
//  Created by Rohan Sinha on 9/20/24.
//

import Foundation

public struct CodableEmulator: Codable {
    
    internal var pc: UInt16
    internal var index: UInt16
    internal var registers: [UInt8]
    internal var keypad: [UInt8]
    internal var stack: [UInt16]
    internal var video: [[Int]]
    internal var delayTimer: UInt8
    internal var soundTimer: UInt8
    internal var sp: UInt8
    internal var memory: [UInt8]
    
    private enum CodingKeys: String, CodingKey {
        case pc
        case index
        case registers
        case keypad
        case stack
        case video
        case delayTimer
        case soundTimer
        case sp
        case memory
    }
    
    public init(emulator: Emulator) {
        pc = emulator.pc
        index = emulator.index
        registers = (0..<16).map { _ in 0 }
        keypad = (0..<16).map { _ in 0 }
        stack = emulator.stack
        video = emulator.video
        delayTimer = emulator.delayTimer
        soundTimer = emulator.soundTimer
        sp = emulator.sp
        memory = emulator.memory
        
        for i in 0..<16 {
            registers[i] = elementFrom(tuple: emulator.registers, index: i) as? UInt8 ?? 0
            keypad[i] = elementFrom(tuple: emulator.keypad, index: i) as? UInt8 ?? 0
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        pc = UInt16(try container.decode(Int.self, forKey: .pc))
        index = UInt16(try container.decode(Int.self, forKey: .index))
        registers = try container.decode([Int].self, forKey: .registers).map { UInt8($0) }
        keypad = try container.decode([Int].self, forKey: .keypad).map { UInt8($0) }
        stack = try container.decode([Int].self, forKey: .stack).map { UInt16($0) }
        video = try container.decode([[Int]].self, forKey: .video)
        delayTimer = UInt8(try container.decode(Int.self, forKey: .delayTimer))
        soundTimer = UInt8(try container.decode(Int.self, forKey: .soundTimer))
        sp = UInt8(try container.decode(Int.self, forKey: .sp))
        memory = try container.decode([Int].self, forKey: .memory).map { UInt8($0) }
        
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Int(pc), forKey: .pc)
        try container.encode(Int(index), forKey: .index)
        try container.encode(registers.map { Int($0) }, forKey: .registers)
        try container.encode(keypad.map { Int($0) }, forKey: .keypad)
        try container.encode(stack.map { Int($0) }, forKey: .stack)
        try container.encode(video, forKey: .video)
        try container.encode(Int(delayTimer), forKey: .delayTimer)
        try container.encode(Int(soundTimer), forKey: .soundTimer)
        try container.encode(Int(sp), forKey: .sp)
        try container.encode(memory.map { Int($0) }, forKey: .memory)
    }
    
    private func elementFrom<T>(tuple: T, index: Int) -> Any? {
        let mirror = Mirror(reflecting: tuple)
        guard index >= 0 && index < mirror.children.count else { return nil }
        
        let element = mirror.children[mirror.children.index(mirror.children.startIndex, offsetBy: index)].value
        return element
    }
    
    
    
}

