//
//  VecOps.swift
//  DL4S
//
//  Created by Palle Klewitz on 26.02.19.
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

fileprivate struct ReshapeOperation<Element: NumericType, Device: DeviceType>: UnaryTensorOperation {
    var source: Tensor<Element, Device>
    
    func fillSourceGradients(fromResultGradients vector: Tensor<Element, Device>) {
        guard let sourceGradient = source.gradient, let vectorGradient = vector.gradient else {
            return
        }
        if !Tensor.sameIdentity(source, vector) {
            Device.Engine.vAdd(lhs: vectorGradient, rhs: sourceGradient, result: sourceGradient, count: source.count)
        }
    }
    
    var symbol: String {
        return "reshape"
    }
}

public extension Tensor {
    func view(as shape: Int...) -> Tensor<Element, Device> {
        return view(as: shape)
    }
    
    func view(as shape: [Int]) -> Tensor<Element, Device> {
        precondition(shape.count(where: {$0 == -1}) <= 1, "The size of at most one dimension can be unknown (-1).")
        precondition(shape.allSatisfy {$0 >= -1}, "All dimensions must be greater than or equal to -1.")
        precondition(shape.contains(-1) || shape.reduce(1, *) == self.count, "Number of elements in result must be equal to number of elements in source")
        
        var shape = shape
        if let idx = shape.firstIndex(of: -1) {
            let remaining = count / shape.lazy.filter {$0 >= 0}.reduce(1, *)
            shape[idx] = remaining
        }
        
        return Tensor(
            values: values,
            gradient: gradient,
            shape: shape,
            parent: self,
            context: requiresGradient ? ReshapeOperation(source: self).asAny() : nil
        )
    }
    
    func viewAsScalar() -> Tensor<Element, Device> {
        precondition(count == 1, "Only vectors with exactly one element can be viewed as a scalar.")
        
        return Tensor(values: values, gradient: gradient, shape: [], parent: self, context: ReshapeOperation(source: self).asAny())
    }
}

fileprivate struct ReplaceOperation<Element: NumericType, Device: DeviceType>: UnaryTensorOperation {
    var source: Tensor<Element, Device>
    let location: [Int?]
    
    func fillSourceGradients(fromResultGradients vector: Tensor<Element, Device>) {
        fatalError("\(#function) is not implemented.")
    }
    
    var symbol: String {
        return "IndexReplace"
    }
}

fileprivate struct SelectOperation<Element: NumericType, Device: DeviceType>: UnaryTensorOperation {
    var source: Tensor<Element, Device>
    
    let location: [Int?]
    
    func fillSourceGradients(fromResultGradients vector: Tensor<Element, Device>) {
        guard let vectorGradient = vector.gradient else {
            return
        }
        guard let (buffer, isCopy, _) = source.gradient(from: location) else {
            return
        }
        Device.Engine.vAdd(lhs: buffer, rhs: vectorGradient, result: buffer, count: vector.count)
        
        if isCopy {
            source.setGradient(at: location, source: buffer, sourceShape: vector.shape)
        }
    }
    
    var symbol: String {
        return "IndexSelect"
    }
}

fileprivate struct RangeReplaceOperation<Element: NumericType, Device: DeviceType>: UnaryTensorOperation {
    var source: Tensor<Element, Device>
    let location: [Range<Int>?]
    
    func fillSourceGradients(fromResultGradients vector: Tensor<Element, Device>) {
        fatalError("\(#function) is not implemented.")
    }
    
    var symbol: String {
        return "RangeReplace"
    }
}

fileprivate struct RangeSelectOperation<Element: NumericType, Device: DeviceType>: UnaryTensorOperation {
    var source: Tensor<Element, Device>
    
    let location: [Range<Int>?]
    
    func fillSourceGradients(fromResultGradients vector: Tensor<Element, Device>) {
        guard let vectorGradient = vector.gradient else {
            return
        }
        guard let (buffer, isCopy, _) = source.gradient(from: location) else {
            return
        }
        Device.Engine.vAdd(lhs: buffer, rhs: vectorGradient, result: buffer, count: vector.count)
        
        if isCopy {
            source.setGradient(at: location, source: buffer, sourceShape: vector.shape)
        }
    }
    
    var symbol: String {
        return "RangeSelect"
    }
}

public extension Tensor {
    subscript(index: [Int?]) -> Tensor<Element, Device> {
        get {
            let index = zip(index, shape).map { idx, dim -> Int? in
                if let idx = idx, idx < 0 {
                    return dim + idx
                } else {
                    return idx
                }
            }
            let (val, isCopy, shape) = Device.Memory.get(slice: index, of: values, with: self.shape)
            let grad: Buffer<Element, Device>?
            if let gradient = self.gradient {
                let (g, _, _) = Device.Memory.get(slice: index, of: gradient, with: self.shape)
                grad = g
            } else {
                grad = nil
            }
            return Tensor(
                values: val,
                gradient: grad,
                shape: shape,
                parent: isCopy ? nil : self,
                context: requiresGradient ? SelectOperation(source: self, location: index).asAny() : nil
            )
        }
        set (slice) {
            let index = zip(index, shape).map { idx, dim -> Int? in
                if let idx = idx, idx < 0 {
                    return dim + idx
                } else {
                    return idx
                }
            }
            if slice.dim == 0 && dim - index.filter({$0 != nil}).count > 0 {
                fatalError("Assigning from a single value not supported yet.")
            }
            
            Device.Memory.set(slice: index, of: values, with: shape, from: slice.values, with: slice.shape)
            if let gradient = self.gradient, let sliceGradient = slice.gradient {
                Device.Memory.set(slice: index, of: gradient, with: shape, from: sliceGradient, with: slice.shape)
            }
            self.context = ReplaceOperation(source: slice, location: index).asAny()
        }
    }
    
    subscript(index: Int?...) -> Tensor<Element, Device> {
        get {
            return self[index]
        }
        set (slice) {
            self[index] = slice
        }
    }
}


public extension Tensor {
    subscript(index: [Range<Int>?]) -> Tensor<Element, Device> {
        get {
            let (val, isCopy, shape) = Device.Memory.get(slice: index, of: values, with: self.shape)
            let grad: Buffer<Element, Device>?
            if let gradient = self.gradient {
                let (g, _, _) = Device.Memory.get(slice: index, of: gradient, with: self.shape)
                grad = g
            } else {
                grad = nil
            }
            return Tensor(
                values: val,
                gradient: grad,
                shape: shape,
                parent: isCopy ? nil : self,
                context: requiresGradient ? RangeSelectOperation(source: self, location: index).asAny() : nil
            )
        }
        set (slice) {
            if slice.dim == 0 && dim - index.filter({$0 != nil}).count > 0 {
                fatalError("Assigning from a single value not supported yet.")
            }
            
            Device.Memory.set(slice: index, of: values, with: shape, from: slice.values, with: slice.shape)
            if let gradient = self.gradient, let sliceGradient = slice.gradient {
                Device.Memory.set(slice: index, of: gradient, with: shape, from: sliceGradient, with: slice.shape)
            }
            self.context = RangeReplaceOperation(source: slice, location: index).asAny()
        }
    }
    
    subscript(index: Range<Int>?...) -> Tensor<Element, Device> {
        get {
            return self[index]
        }
        set (slice) {
            self[index] = slice
        }
    }
}


public extension Tensor {
    func squeeze() -> Tensor<Element, Device> {
        return self.view(as: shape.filter {$0 != 1})
    }
    
    func unsqueeze(at index: Int) -> Tensor<Element, Device> {
        var newShape = shape
        newShape.insert(1, at: index)
        
        return self.view(as: newShape)
    }
}
