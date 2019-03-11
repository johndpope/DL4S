//
//  VecOps.swift
//  DL4S
//
//  Created by Palle Klewitz on 26.02.19.
//

import Foundation

fileprivate struct ReshapeOperation<Element: NumericType, DeviceType: Device>: UnaryTensorOperation {
    var source: Tensor<Element, DeviceType>
    
    func fillSourceGradients(fromResultGradients vector: Tensor<Element, DeviceType>) {
        guard let sourceGradient = source.gradient, let vectorGradient = vector.gradient else {
            return
        }
        if !Tensor.sameIdentity(source, vector) {
            DeviceType.EngineType.vAdd(lhs: vectorGradient, rhs: sourceGradient, result: sourceGradient, count: source.count)
        }
    }
    
    var symbol: String {
        return "reshape"
    }
}

public extension Tensor {
    func view(as shape: Int...) -> Tensor<Element, DeviceType> {
        return view(as: shape)
    }
    
    func view(as shape: [Int]) -> Tensor<Element, DeviceType> {
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
    
    func viewAsScalar() -> Tensor<Element, DeviceType> {
        precondition(count == 1, "Only vectors with exactly one element can be viewed as a scalar.")
        
        return Tensor(values: values, gradient: gradient, shape: [], parent: self, context: ReshapeOperation(source: self).asAny())
    }
}

fileprivate struct ReplaceOperation<Element: NumericType, DeviceType: Device>: UnaryTensorOperation {
    var source: Tensor<Element, DeviceType>
    let location: [Int?]
    
    func fillSourceGradients(fromResultGradients vector: Tensor<Element, DeviceType>) {
        
    }
    
    var symbol: String {
        return "IndexReplace"
    }
}

fileprivate struct SelectOperation<Element: NumericType, DeviceType: Device>: UnaryTensorOperation {
    var source: Tensor<Element, DeviceType>
    
    let location: [Int?]
    
    func fillSourceGradients(fromResultGradients vector: Tensor<Element, DeviceType>) {
        guard let vectorGradient = vector.gradient else {
            return
        }
        guard let (buffer, isCopy, _) = source.gradient(from: location) else {
            return
        }
        DeviceType.EngineType.vAdd(lhs: buffer, rhs: vectorGradient, result: buffer, count: vector.count)
        
        if isCopy {
            source.setGradient(at: location, source: buffer.immutable, sourceShape: vector.shape)
        }
    }
    
    var symbol: String {
        return "IndexSelect"
    }
}

fileprivate struct RangeReplaceOperation<Element: NumericType, DeviceType: Device>: UnaryTensorOperation {
    var source: Tensor<Element, DeviceType>
    let location: [Range<Int>?]
    
    func fillSourceGradients(fromResultGradients vector: Tensor<Element, DeviceType>) {
        
    }
    
    var symbol: String {
        return "RangeReplace"
    }
}

fileprivate struct RangeSelectOperation<Element: NumericType, DeviceType: Device>: UnaryTensorOperation {
    var source: Tensor<Element, DeviceType>
    
    let location: [Range<Int>?]
    
    func fillSourceGradients(fromResultGradients vector: Tensor<Element, DeviceType>) {
        guard let vectorGradient = vector.gradient else {
            return
        }
        guard let (buffer, isCopy, _) = source.gradient(from: location) else {
            return
        }
        DeviceType.EngineType.vAdd(lhs: buffer, rhs: vectorGradient, result: buffer, count: vector.count)
        
        if isCopy {
            source.setGradient(at: location, source: buffer, sourceShape: vector.shape)
        }
    }
    
    var symbol: String {
        return "RangeSelect"
    }
}

public extension Tensor {
    subscript(index: [Int?]) -> Tensor<Element, DeviceType> {
        get {
            let index = zip(index, shape).map { idx, dim -> Int? in
                if let idx = idx, idx < 0 {
                    return dim + idx
                } else {
                    return idx
                }
            }
            let (val, isCopy, shape) = DeviceType.MemoryOperatorType.get(slice: index, of: values, with: self.shape)
            let grad: Buffer<Element, DeviceType>?
            if let gradient = self.gradient {
                let (g, _, _) = DeviceType.MemoryOperatorType.get(slice: index, of: gradient, with: self.shape)
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
            
            DeviceType.MemoryOperatorType.set(slice: index, of: values, with: shape, from: slice.values, with: slice.shape)
            if let gradient = self.gradient, let sliceGradient = slice.gradient {
                DeviceType.MemoryOperatorType.set(slice: index, of: gradient, with: shape, from: sliceGradient, with: slice.shape)
            }
            self.context = ReplaceOperation(source: slice, location: index).asAny()
        }
    }
    
    subscript(index: Int?...) -> Tensor<Element, DeviceType> {
        get {
            return self[index]
        }
        set (slice) {
            self[index] = slice
        }
    }
}


public extension Tensor {
    subscript(index: [Range<Int>?]) -> Tensor<Element, DeviceType> {
        get {
            let (val, isCopy, shape) = DeviceType.MemoryOperatorType.get(slice: index, of: values, with: self.shape)
            let grad: Buffer<Element, DeviceType>?
            if let gradient = self.gradient {
                let (g, _, _) = DeviceType.MemoryOperatorType.get(slice: index, of: gradient, with: self.shape)
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
            
            DeviceType.MemoryOperatorType.set(slice: index, of: values, with: shape, from: slice.values, with: slice.shape)
            if let gradient = self.gradient, let sliceGradient = slice.gradient {
                DeviceType.MemoryOperatorType.set(slice: index, of: gradient, with: shape, from: sliceGradient, with: slice.shape)
            }
            self.context = RangeReplaceOperation(source: slice, location: index).asAny()
        }
    }
    
    subscript(index: Range<Int>?...) -> Tensor<Element, DeviceType> {
        get {
            return self[index]
        }
        set (slice) {
            self[index] = slice
        }
    }
}


public extension Tensor {
    func squeeze() -> Tensor<Element, DeviceType> {
        return self.view(as: shape.filter {$0 != 1})
    }
    
    func unsqueeze(at index: Int) -> Tensor<Element, DeviceType> {
        var newShape = shape
        newShape.insert(1, at: index)
        
        return self.view(as: newShape)
    }
}
