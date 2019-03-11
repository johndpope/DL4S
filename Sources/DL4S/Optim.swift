//
//  Optim.swift
//  DL4S
//
//  Created by Palle Klewitz on 27.02.19.
//

import Foundation


public protocol Optimizer {
    associatedtype Element: NumericType
    associatedtype DeviceType: Device
    
    var parameters: [Tensor<Element, DeviceType>] { get }
    
    func step()
    func reset()
    func zeroGradient()
}

public class SGDOptimizer<Element: NumericType, DeviceType: Device>: Optimizer {
    public var learningRate: Element
    public var regularizationL2: Element = 0
    
    public let parameters: [Tensor<Element, DeviceType>]
    
    public init(parameters: [Tensor<Element, DeviceType>], learningRate: Element) {
        self.learningRate = learningRate
        self.parameters = parameters
    }
    
    public func step() {
        for parameter in self.parameters {
            guard let gradient = parameter.gradient else {
                continue
            }
            DeviceType.EngineType.vsMulVAdd(lhs: gradient, rhs: -self.learningRate, add: parameter.values, result: parameter.values, count: parameter.count)
        }
    }
    
    public func zeroGradient() {
        for parameter in self.parameters {
            parameter.zeroGradient()
        }
    }
    
    public func reset() {
        // noop
    }
}


public class MomentumOptimizer<Element: NumericType, DeviceType: Device>: Optimizer {
    public var learningRate: Element
    public var momentum: Element
    
    public let parameters: [Tensor<Element, DeviceType>]
    private let momentumParams: [Buffer<Element, DeviceType>]
    
    public init(parameters: [Tensor<Element, DeviceType>], learningRate: Element, momentum: Element = 0.8) {
        self.learningRate = learningRate
        self.momentum = momentum
        self.parameters = parameters
        self.momentumParams = parameters.map {DeviceType.MemoryOperatorType.allocateBuffer(withCapacity: $0.count, type: Element.self)}
        
        for m in self.momentumParams {
            DeviceType.EngineType.fill(value: 0, result: m, count: m.count)
        }
    }
    
    deinit {
        self.momentumParams.forEach(DeviceType.MemoryOperatorType.free)
    }
    
    public func reset() {
        for m in self.momentumParams {
            DeviceType.EngineType.fill(value: 0, result: m, count: m.count)
        }
    }
    
    public func step() {
        for (param, momentumParam) in zip(parameters, momentumParams) {
            guard let gradient = param.gradient else {
                continue
            }
            // m = momentum * m
            DeviceType.EngineType.vsMul(lhs: momentumParam, rhs: self.momentum, result: momentumParam, count: param.count)
            // m = lr * grad + m = lr * grad + momentum * m
            DeviceType.EngineType.vsMulVAdd(lhs: gradient, rhs: self.learningRate, add: momentumParam, result: momentumParam, count: param.count)
            // values = values - m
            DeviceType.EngineType.vSub(lhs: param.values, rhs: momentumParam, result: param.values, count: param.count)
        }
    }
    
    public func zeroGradient() {
        for parameter in self.parameters {
            parameter.zeroGradient()
        }
    }
}


public class Adam<Element: NumericType, DeviceType: Device>: Optimizer {
    public let parameters: [Tensor<Element, DeviceType>]
    
    public var learningRate: Element
    public var beta1: Element
    public var beta2: Element
    public var epsilon: Element
    
    private var beta1t: Element
    private var beta2t: Element
    
    private let firstMoment: [Buffer<Element, DeviceType>]
    private let secondMoment: [Buffer<Element, DeviceType>]
    private let cache: [Buffer<Element, DeviceType>]
    private let cache2: [Buffer<Element, DeviceType>]
    
    public private(set) var iteration: Int = 0
    
    public init(parameters: [Tensor<Element, DeviceType>], learningRate: Element, beta1: Element = 0.9, beta2: Element = 0.999, epsilon: Element = 1e-8) {
        self.parameters = parameters
        self.learningRate = learningRate
        self.beta1 = beta1
        self.beta2 = beta2
        self.epsilon = epsilon
        
        self.firstMoment = parameters.map {DeviceType.MemoryOperatorType.allocateBuffer(withCapacity: $0.count, type: Element.self)}
        self.secondMoment = parameters.map {DeviceType.MemoryOperatorType.allocateBuffer(withCapacity: $0.count, type: Element.self)}
        self.cache = parameters.map {DeviceType.MemoryOperatorType.allocateBuffer(withCapacity: $0.count, type: Element.self)}
        self.cache2 = parameters.map {DeviceType.MemoryOperatorType.allocateBuffer(withCapacity: $0.count, type: Element.self)}
        
        self.beta1t = beta1
        self.beta2t = beta2
        
        for m in [firstMoment, secondMoment, cache, cache2].joined() {
            //m.assign(repeating: 0)
            DeviceType.EngineType.fill(value: 0, result: m, count: m.count)
        }
    }
    
    deinit {
        [firstMoment, secondMoment, cache, cache2].joined().forEach(DeviceType.MemoryOperatorType.free)
    }
    
    public func reset() {
        beta1t = beta1
        beta2t = beta2
        for m in [firstMoment, secondMoment, cache, cache2].joined() {
            DeviceType.EngineType.fill(value: 0, result: m, count: m.count)
        }
    }
    
    public func step() {
        for (i, param) in parameters.enumerated() {
            guard let g = param.gradient else {
                continue
            }
            
            let m = firstMoment[i]
            let v = secondMoment[i]
            let c = cache[i]
            let c2 = cache2[i]
            
            // cache = (1 - beta1) * gradient
            DeviceType.EngineType.vsMul(lhs: g, rhs: (1 - beta1), result: c, count: param.count)
            // m = beta1 * m + cache = beta1 * m + (1 - beta1) * gradient
            DeviceType.EngineType.vsMulVAdd(lhs: m, rhs: beta1, add: c, result: m, count: param.count)
            
            // cache = gradient ^ 2
            DeviceType.EngineType.vSquare(values: g, result: c, count: param.count)
            // cache = (1 - beta2) * gradient ^ 2
            DeviceType.EngineType.vsMul(lhs: c, rhs: (1 - beta2), result: c, count: param.count)
            // v = beta2 * v + (1 - beta2) * gradient ^ 2
            DeviceType.EngineType.vsMulVAdd(lhs: v, rhs: beta2, add: c, result: v, count: param.count)
            
            // c (m^) = m / (1 - beta1)
            DeviceType.EngineType.vsMul(lhs: m, rhs: 1 / (1 - beta1t), result: c, count: param.count)
            
            // c2 (^v) = v / (1 - beta2)
            DeviceType.EngineType.vsMul(lhs: v, rhs: 1 / (1 - beta2t), result: c2, count: param.count)
            
            // c2 = sqrt(c2)
            DeviceType.EngineType.sqrt(val: c2, result: c2, count: param.count)
            // c2 = c2 + eps
            DeviceType.EngineType.vsAdd(lhs: c2, rhs: epsilon, result: c2, count: param.count)
            // c2 = -lr / c2
            DeviceType.EngineType.svDiv(lhs: -learningRate, rhs: c2, result: c2, count: param.count)
            
            // weights = c * c2 + weights = -lr / (sqrt(c2) + eps) * c + weights
            DeviceType.EngineType.vMA(lhs: c, rhs: c2, add: param.values, result: param.values, count: param.count)
        }
        
        // beta_t = pow(beta_, iteration)
        beta1t = beta1t * beta1
        beta2t = beta2t * beta2
    }
    
    public func zeroGradient() {
        for parameter in self.parameters {
            parameter.zeroGradient()
        }
    }
    
}
