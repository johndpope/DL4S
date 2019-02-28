//
//  Float.swift
//  DL4S
//
//  Created by Palle Klewitz on 27.02.19.
//

import Foundation
import Accelerate


extension Float: NumericType {
    public static func vSquare(values: UnsafeBufferPointer<Float>, result: UnsafeMutableBufferPointer<Float>, count: Int) {
        vDSP_vsq(values.pointer(capacity: count), 1, result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func relu(val: UnsafeBufferPointer<Float>, result: UnsafeMutableBufferPointer<Float>, count: Int) {
        vDSP_vthr(val.pointer(capacity: count), 1, [0.0], result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func tanh(val: UnsafeBufferPointer<Float>, result: UnsafeMutableBufferPointer<Float>, count: Int) {
        vvtanhf(result.pointer(capacity: count), val.pointer(capacity: count), [Int32(count)])
    }
    
    public static func transpose(val: UnsafeBufferPointer<Float>, result: UnsafeMutableBufferPointer<Float>, srcRows: Int, srcCols: Int) {
        vDSP_mtrans(val.pointer(capacity: srcRows * srcCols), 1, result.pointer(capacity: srcRows * srcCols), 1, UInt(srcCols), UInt(srcRows))
    }
    
    public static var one: Float {
        return 1.0
    }
    
    public static func vsAdd(lhs: UnsafeBufferPointer<Float>, rhs: Float, result: UnsafeMutableBufferPointer<Float>, count: Int) {
        vDSP_vsadd(lhs.pointer(capacity: count), 1, [rhs], result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func vsMul(lhs: UnsafeBufferPointer<Float>, rhs: Float, result: UnsafeMutableBufferPointer<Float>, count: Int) {
        vDSP_vsmul(lhs.pointer(capacity: count), 1, [rhs], result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func svDiv(lhs: Float, rhs: UnsafeBufferPointer<Float>, result: UnsafeMutableBufferPointer<Float>, count: Int) {
        vDSP_svdiv([lhs], rhs.pointer(capacity: count), 1, result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func fill(value: Float, result: UnsafeMutableBufferPointer<Float>, count: Int) {
        vDSP_vfill([value], result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func exp(val: UnsafeBufferPointer<Float>, result: UnsafeMutableBufferPointer<Float>, count: Int) {
        vvexpf(result.pointer(capacity: count), val.pointer(capacity: count), [Int32(count)])
    }
    
    public static func log(val: UnsafeBufferPointer<Float>, result: UnsafeMutableBufferPointer<Float>, count: Int) {
        vvlogf(result.pointer(capacity: count), val.pointer(capacity: count), [Int32(count)])
    }
    
    public static func matMul(lhs: UnsafeBufferPointer<Float>, rhs: UnsafeBufferPointer<Float>, result: UnsafeMutableBufferPointer<Float>, lhsRows: Int, lhsCols: Int, rhsCols: Int) {
        vDSP_mmul(lhs.pointer(capacity: lhsRows * lhsCols), 1, rhs.pointer(capacity: lhsCols * rhsCols), 1, result.pointer(capacity: lhsRows * rhsCols), 1, UInt(lhsRows), UInt(rhsCols), UInt(lhsCols))
    }
    
    public static func vAdd(lhs: UnsafeBufferPointer<Float>, rhs: UnsafeBufferPointer<Float>, result: UnsafeMutableBufferPointer<Float>, count: Int) {
        vDSP_vadd(lhs.pointer(capacity: count), 1, rhs.pointer(capacity: count), 1, result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func vNeg(val: UnsafeBufferPointer<Float>, result: UnsafeMutableBufferPointer<Float>, count: Int) {
        vDSP_vneg(val.pointer(capacity: count), 1, result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func vSub(lhs: UnsafeBufferPointer<Float>, rhs: UnsafeBufferPointer<Float>, result: UnsafeMutableBufferPointer<Float>, count: Int) {
        vDSP_vsub(rhs.pointer(capacity: count), 1, lhs.pointer(capacity: count), 1, result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func vMul(lhs: UnsafeBufferPointer<Float>, rhs: UnsafeBufferPointer<Float>, result: UnsafeMutableBufferPointer<Float>, count: Int) {
        vDSP_vmul(lhs.pointer(capacity: count), 1, rhs.pointer(capacity: count), 1, result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func vMA(lhs: UnsafeBufferPointer<Float>, rhs: UnsafeBufferPointer<Float>, add: UnsafeMutableBufferPointer<Float>, result: UnsafeMutableBufferPointer<Float>, count: Int) {
        vDSP_vma(lhs.pointer(capacity: count), 1, rhs.pointer(capacity: count), 1, add.pointer(capacity: count), 1, result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func vDiv(lhs: UnsafeBufferPointer<Float>, rhs: UnsafeBufferPointer<Float>, result: UnsafeMutableBufferPointer<Float>, count: Int) {
        vDSP_vdiv(rhs.pointer(capacity: count), 1, lhs.pointer(capacity: count), 1, result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func sum(val: UnsafeBufferPointer<Float>, count: Int) -> Float {
        var result: Float = 0
        vDSP_sve(val.pointer(capacity: count), 1, &result, UInt(count))
        return result
    }
    
    public static func copysign(values: UnsafeBufferPointer<Float>, signs: UnsafeBufferPointer<Float>, result: UnsafeMutableBufferPointer<Float>, count: Int) {
        vvcopysignf(result.pointer(capacity: count), values.pointer(capacity: count), signs.pointer(capacity: count), [Int32(count)])
    }
    
    public static func dot(lhs: UnsafeBufferPointer<Float>, rhs: UnsafeBufferPointer<Float>, count: Int) -> Float {
        var result: Float = 0
        vDSP_dotpr(lhs.pointer(capacity: count), 1, rhs.pointer(capacity: count), 1, &result, UInt(count))
        return result
    }
    
    public static func vMulSA(lhs: UnsafeBufferPointer<Float>, rhs: UnsafeBufferPointer<Float>, add: Float, result: UnsafeMutableBufferPointer<Float>, count: Int) {
        vDSP_vmsa(lhs.pointer(capacity: count), 1, rhs.pointer(capacity: count), 1, [add], result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func vsMulVAdd(lhs: UnsafeBufferPointer<Float>, rhs: Float, add: UnsafeBufferPointer<Float>, result: UnsafeMutableBufferPointer<Float>, count: Int) {
        vDSP_vsma(lhs.pointer(capacity: count), 1, [rhs], add.pointer(capacity: count), 1, result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func matMulAddInPlace(lhs: UnsafeBufferPointer<Float>, rhs: UnsafeBufferPointer<Float>, result: UnsafeMutableBufferPointer<Float>, lhsShape: (Int, Int), rhsShape: (Int, Int), resultShape: (Int, Int), transposeFirst: Bool = false, transposeSecond: Bool = false) {
        precondition((transposeFirst ? lhsShape.1 : lhsShape.0) == resultShape.0)
        precondition((transposeSecond ? rhsShape.0 : rhsShape.1) == resultShape.1)
        precondition((transposeFirst ? lhsShape.0 : lhsShape.1) == (transposeSecond ? rhsShape.1 : rhsShape.0))
        
        cblas_sgemm(
            CblasRowMajor,
            transposeFirst ? CblasTrans : CblasNoTrans,
            transposeSecond ? CblasTrans : CblasNoTrans,
            Int32(lhsShape.0), // rows in op(lhs)
            Int32(rhsShape.1), // columns in op(rhs)
            Int32(lhsShape.1), // columns in op(lhs) and op(rhs)
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
    
    public func sqrt() -> Float {
        return Foundation.sqrt(self)
    }
    
    public func exp() -> Float {
        return Foundation.exp(self)
    }
    
    public func log() -> Float {
        return Foundation.log(self)
    }
    
    public func sin() -> Float {
        return Foundation.sin(self)
    }
    
    public func cos() -> Float {
        return Foundation.cos(self)
    }
    
    public func tan() -> Float {
        return Foundation.tanh(self)
    }
    
    public func sinh() -> Float {
        return Foundation.sinh(self)
    }
    
    public func cosh() -> Float {
        return Foundation.cosh(self)
    }
    
    public func tanh() -> Float {
        return Foundation.tanh(self)
    }
    
    public static func argmax(values: UnsafeBufferPointer<Float>, count: Int) -> (Int, Float) {
        var maxI: UInt = 0
        var maxV: Float = 0
        
        vDSP_maxvi(values.pointer(capacity: count), 1, &maxV, &maxI, UInt(count))
        
        return (Int(maxI), maxV)
    }
}
