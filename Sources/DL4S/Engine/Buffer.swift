//
//  Buffer.swift
//  DL4S
//
//  Created by Palle Klewitz on 10.03.19.
//  Copyright (c) 2019 - Palle Klewitz
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation


public struct Buffer<Element: NumericType, Device: DeviceType>: Hashable {
    let memory: Device.Memory.RawBuffer
    
    var count: Int {
        return Device.Memory.getSize(of: self)
    }
    
    var pointee: Element {
        get {
            return Device.Memory.getValue(from: self)
        }
        
        nonmutating set (newValue) {
            Device.Engine.fill(value: newValue, result: self, count: 1)
        }
    }
    
    func advanced(by offset: Int) -> Buffer<Element, Device> {
        return Device.Memory.advance(buffer: self, by: offset)
    }
    
    subscript(index: Int) -> Element {
        get {
            return advanced(by: index).pointee
        }
        nonmutating set {
            advanced(by: index).pointee = newValue
        }
    }
}

extension Buffer: CustomLeafReflectable {
    public var customMirror: Mirror {
        let b = UnsafeMutableBufferPointer<Element>.allocate(capacity: self.count)
        defer {
            b.deallocate()
        }
        Device.Memory.assign(from: self, to: b, count: self.count)
        let a = Array(b)
        return Mirror(self, unlabeledChildren: a, displayStyle: .collection)
    }
}
