//
//  Double.swift
//  DL4S
//
//  Created by Palle Klewitz on 27.02.19.
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
import Accelerate


extension Double: NumericType {
    public func toUInt8() -> UInt8 {
        return UInt8(self)
    }
    
    public static func fill(value: Double, result: UnsafeMutableBufferPointer<Double>, stride: Int, count: Int) {
        vDSP_vfillD([value], result.pointer(capacity: count), stride, UInt(count))
    }
    
    public static func vSquare(values: UnsafeBufferPointer<Double>, result: UnsafeMutableBufferPointer<Double>, count: Int) {
        vDSP_vsqD(values.pointer(capacity: count), 1, result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func relu(val: UnsafeBufferPointer<Double>, result: UnsafeMutableBufferPointer<Double>, count: Int) {
        vDSP_vthrD(val.pointer(capacity: count), 1, [0.0], result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func tanh(val: UnsafeBufferPointer<Double>, result: UnsafeMutableBufferPointer<Double>, count: Int) {
        vvtanh(result.pointer(capacity: count), val.pointer(capacity: count), [Int32(count)])
    }
    
    public static func transpose(val: UnsafeBufferPointer<Double>, result: UnsafeMutableBufferPointer<Double>, srcRows: Int, srcCols: Int) {
        vDSP_mtransD(val.pointer(capacity: srcRows * srcCols), 1, result.pointer(capacity: srcRows * srcCols), 1, UInt(srcCols), UInt(srcRows))
    }
    
    public static func sqrt(val: UnsafeBufferPointer<Double>, result: UnsafeMutableBufferPointer<Double>, count: Int) {
        vvsqrt(result.pointer(capacity: count), val.pointer(capacity: count), [Int32(count)])
    }
    
    public static var one: Double {
        return 1.0
    }
    
    public static func pow(base: Double, exponent: Double) -> Double {
        return Foundation.pow(base, exponent)
    }
    
    public static func vsAdd(lhs: UnsafeBufferPointer<Double>, rhs: Double, result: UnsafeMutableBufferPointer<Double>, count: Int) {
        vDSP_vsaddD(lhs.pointer(capacity: count), 1, [rhs], result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func vsMul(lhs: UnsafeBufferPointer<Double>, rhs: Double, result: UnsafeMutableBufferPointer<Double>, count: Int) {
        vDSP_vsmulD(lhs.pointer(capacity: count), 1, [rhs], result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func svDiv(lhs: Double, rhs: UnsafeBufferPointer<Double>, result: UnsafeMutableBufferPointer<Double>, count: Int) {
        vDSP_svdivD([lhs], rhs.pointer(capacity: count), 1, result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func fill(value: Double, result: UnsafeMutableBufferPointer<Double>, count: Int) {
        vDSP_vfillD([value], result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func exp(val: UnsafeBufferPointer<Double>, result: UnsafeMutableBufferPointer<Double>, count: Int) {
        vvexp(result.pointer(capacity: count), val.pointer(capacity: count), [Int32(count)])
    }
    
    public static func log(val: UnsafeBufferPointer<Double>, result: UnsafeMutableBufferPointer<Double>, count: Int) {
        vvlog(result.pointer(capacity: count), val.pointer(capacity: count), [Int32(count)])
    }
    
    public static func matMul(lhs: UnsafeBufferPointer<Double>, rhs: UnsafeBufferPointer<Double>, result: UnsafeMutableBufferPointer<Double>, lhsRows: Int, lhsCols: Int, rhsCols: Int) {
        vDSP_mmulD(lhs.pointer(capacity: lhsRows * lhsCols), 1, rhs.pointer(capacity: rhsCols * lhsCols), 1, result.pointer(capacity: lhsRows * rhsCols), 1, UInt(lhsRows), UInt(rhsCols), UInt(lhsCols))
    }
    
    public static func vAdd(lhs: UnsafeBufferPointer<Double>, rhs: UnsafeBufferPointer<Double>, result: UnsafeMutableBufferPointer<Double>, count: Int) {
        vDSP_vaddD(lhs.pointer(capacity: count), 1, rhs.pointer(capacity: count), 1, result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func vNeg(val: UnsafeBufferPointer<Double>, result: UnsafeMutableBufferPointer<Double>, count: Int) {
        vDSP_vnegD(val.pointer(capacity: count), 1, result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func vSub(lhs: UnsafeBufferPointer<Double>, rhs: UnsafeBufferPointer<Double>, result: UnsafeMutableBufferPointer<Double>, count: Int) {
        vDSP_vsubD(rhs.pointer(capacity: count), 1, lhs.pointer(capacity: count), 1, result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func vMul(lhs: UnsafeBufferPointer<Double>, rhs: UnsafeBufferPointer<Double>, result: UnsafeMutableBufferPointer<Double>, count: Int) {
        vDSP_vmulD(lhs.pointer(capacity: count), 1, rhs.pointer(capacity: count), 1, result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func vMA(lhs: UnsafeBufferPointer<Double>, rhs: UnsafeBufferPointer<Double>, add: UnsafeBufferPointer<Double>, result: UnsafeMutableBufferPointer<Double>, count: Int) {
        vDSP_vmaD(lhs.pointer(capacity: count), 1, rhs.pointer(capacity: count), 1, add.pointer(capacity: count), 1, result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func vDiv(lhs: UnsafeBufferPointer<Double>, rhs: UnsafeBufferPointer<Double>, result: UnsafeMutableBufferPointer<Double>, count: Int) {
        vDSP_vdivD(rhs.pointer(capacity: count), 1, lhs.pointer(capacity: count), 1, result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func sum(val: UnsafeBufferPointer<Double>, count: Int) -> Double {
        var result: Double = 0
        vDSP_sveD(val.pointer(capacity: count), 1, &result, UInt(count))
        return result
    }
    
    public static func copysign(values: UnsafeBufferPointer<Double>, signs: UnsafeBufferPointer<Double>, result: UnsafeMutableBufferPointer<Double>, count: Int) {
        vvcopysign(result.pointer(capacity: count), values.pointer(capacity: count), signs.pointer(capacity: count), [Int32(count)])
    }
    
    public static func dot(lhs: UnsafeBufferPointer<Double>, rhs: UnsafeBufferPointer<Double>, count: Int) -> Double {
        var result: Double = 0
        vDSP_dotprD(lhs.pointer(capacity: count), 1, rhs.pointer(capacity: count), 1, &result, UInt(count))
        return result
    }
    
    public static func vMulSA(lhs: UnsafeBufferPointer<Double>, rhs: UnsafeBufferPointer<Double>, add: Double, result: UnsafeMutableBufferPointer<Double>, count: Int) {
        vDSP_vmsaD(lhs.pointer(capacity: count), 1, rhs.pointer(capacity: count), 1, [add], result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func vsMulVAdd(lhs: UnsafeBufferPointer<Double>, rhs: Double, add: UnsafeBufferPointer<Double>, result: UnsafeMutableBufferPointer<Double>, count: Int) {
        vDSP_vsmaD(lhs.pointer(capacity: count), 1, [rhs], add.pointer(capacity: count), 1, result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func matMulAddInPlace(lhs: UnsafeBufferPointer<Double>, rhs: UnsafeBufferPointer<Double>, result: UnsafeMutableBufferPointer<Double>, lhsShape: (Int, Int), rhsShape: (Int, Int), resultShape: (Int, Int), transposeFirst: Bool = false, transposeSecond: Bool = false) {
        precondition((transposeFirst ? lhsShape.1 : lhsShape.0) == resultShape.0)
        precondition((transposeSecond ? rhsShape.0 : rhsShape.1) == resultShape.1)
        precondition((transposeFirst ? lhsShape.0 : lhsShape.1) == (transposeSecond ? rhsShape.1 : rhsShape.0))
        
        cblas_dgemm(
            CblasRowMajor,
            transposeFirst ? CblasTrans : CblasNoTrans,
            transposeSecond ? CblasTrans : CblasNoTrans,
            Int32(lhsShape.0), // rows in lhs
            Int32(rhsShape.1), // columns in rhs
            Int32(lhsShape.1), // columns in lhs and result
            1, // Scale for product of lhs and rhs
            lhs.pointer(capacity: lhsShape.0 * lhsShape.1),
            Int32(lhsShape.0), // Size of first dimension of lhs
            rhs.pointer(capacity: rhsShape.0 * rhsShape.1),
            Int32(rhsShape.0), // Size of first dimension of rhs
            1, // Scale for addition of result
            result.pointer(capacity: resultShape.0 * resultShape.1),
            Int32(resultShape.0) // Size of first dimension of result
        )
    }
    
    public func sqrt() -> Double {
        return Foundation.sqrt(self)
    }
    
    public func exp() -> Double {
        return Foundation.exp(self)
    }
    
    public func log() -> Double {
        return Foundation.log(self)
    }
    
    public func sin() -> Double {
        return Foundation.sin(self)
    }
    
    public func cos() -> Double {
        return Foundation.cos(self)
    }
    
    public func tan() -> Double {
        return Foundation.tanh(self)
    }
    
    public func sinh() -> Double {
        return Foundation.sinh(self)
    }
    
    public func cosh() -> Double {
        return Foundation.cosh(self)
    }
    
    public func tanh() -> Double {
        return Foundation.tanh(self)
    }
    
    public static func argmax(values: UnsafeBufferPointer<Double>, count: Int) -> (Int, Double) {
        var maxI: UInt = 0
        var maxV: Double = 0
        
        vDSP_maxviD(values.pointer(capacity: count), 1, &maxV, &maxI, UInt(count))
        
        return (Int(maxI), maxV)
    }
    
    public static func conv2d(input: UnsafeBufferPointer<Double>, filter: UnsafeBufferPointer<Double>, result: UnsafeMutableBufferPointer<Double>, width: Int, height: Int, kernelWidth: Int, kernelHeight: Int, kernelDepth: Int, kernelCount: Int) {
        let kernelElementCount = kernelWidth * kernelHeight * kernelDepth
        let planeElementCount = width * height
        
        for k in 0 ..< kernelCount {
            let kernel = filter.advanced(by: k * kernelElementCount)
            let outputPlane = result.advanced(by: k * planeElementCount)
            
            for d in 0 ..< kernelDepth {
                let inputPlane = input.advanced(by: d * planeElementCount)
                
                vDSP_imgfirD(inputPlane.pointer(capacity: planeElementCount), UInt(height), UInt(width), kernel.pointer(capacity: kernelElementCount), outputPlane.pointer(capacity: planeElementCount), UInt(kernelHeight), UInt(kernelWidth))
            }
        }
    }
}

