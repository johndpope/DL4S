//
//  Dense.swift
//  DL4S
//
//  Created by Palle Klewitz on 01.03.19.
//

import Foundation

public class Dense<Element: RandomizableType, DeviceType: Device>: Layer, Codable {
    public typealias Input = Element
    
    let w: Tensor<Element, DeviceType>
    let b: Tensor<Element, DeviceType>
    
    public var parameters: [Tensor<Element, DeviceType>] {
        return trainable ? [w, b] : []
    }
    
    public var trainable: Bool = true
    
    public var inputFeatures: Int {
        return w.shape[0]
    }
    
    public var outputFeatures: Int {
        return w.shape[1]
    }
    
    public init(inputFeatures: Int, outputFeatures: Int) {
        w = Tensor(repeating: 0.5, shape: [inputFeatures, outputFeatures], requiresGradient: true)
        b = Tensor(repeating: 0, shape: [outputFeatures], requiresGradient: true)
        
        Random.fillNormal(w, mean: 0, stdev: (2 / Element(inputFeatures)).sqrt())
        
        w.tag = "W"
        b.tag = "b"
    }
    
    public func forward(_ inputs: [Tensor<Element, DeviceType>]) -> Tensor<Element, DeviceType> {
        precondition(inputs.count == 1)
        let out = mmul(inputs[0], w) + b
        // print(out)
        return out
    }
}
