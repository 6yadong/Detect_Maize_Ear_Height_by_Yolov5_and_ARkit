//
//  CIImage+Additions.swift
//  ExampleARKitApp
//
//  Created by John Sanderson on 13/09/2017.
//  Copyright © 2017 The App Business. All rights reserved.
//

import Foundation
import ARKit
import Vision

import Foundation
import Vision
import ARKit

public extension CIImage {
    
  var rotate: CIImage {
    get {
      return self.oriented(UIDevice.current.orientation.cameraOrientation())
    }
  }
}

private extension UIDeviceOrientation {
  func cameraOrientation() -> CGImagePropertyOrientation {
    switch self {
    case .landscapeLeft: return .up
    case .landscapeRight: return .down
    case .portraitUpsideDown: return .left
    default: return .right
    }
  }
}

extension CIImage {
func normalized() -> [Float32]? {
    guard let cgImage = self.cgImage else {
        return nil
    }
    let w = cgImage.width
    let h = cgImage.height
    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * w
    let bitsPerComponent = 8
    var rawBytes: [UInt8] = [UInt8](repeating: 0, count: w * h * 4)
    rawBytes.withUnsafeMutableBytes { ptr in
        if let cgImage = self.cgImage,
            let context = CGContext(data: ptr.baseAddress,
                                    width: w,
                                    height: h,
                                    bitsPerComponent: bitsPerComponent,
                                    bytesPerRow: bytesPerRow,
                                    space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
            let rect = CGRect(x: 0, y: 0, width: w, height: h)
            context.draw(cgImage, in: rect)
        }
    }
    var normalizedBuffer: [Float32] = [Float32](repeating: 0, count: w * h * 3)
    for i in 0 ..< w * h {
        normalizedBuffer[i] = Float32(rawBytes[i * 4 + 0]) / 255.0
        normalizedBuffer[w * h + i] = Float32(rawBytes[i * 4 + 1]) / 255.0
        normalizedBuffer[w * h * 2 + i] = Float32(rawBytes[i * 4 + 2]) / 255.0
    }
    return normalizedBuffer
}
}
