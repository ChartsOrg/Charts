//
//  Platform+Graphics.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

enum Orientation {
    case portrait, landscape
}

extension CGSize {
    var orientation: Orientation { return width > height ? .landscape : .portrait }
}

extension CGRect {
    var orientation: Orientation { size.orientation }
}

// MARK: - UIKit

#if canImport(UIKit)
    import UIKit

    func NSUIGraphicsGetCurrentContext() -> CGContext? {
        return UIGraphicsGetCurrentContext()
    }

    func NSUIGraphicsGetImageFromCurrentImageContext() -> NSUIImage! {
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func NSUIGraphicsPushContext(_ context: CGContext) {
        UIGraphicsPushContext(context)
    }

    func NSUIGraphicsPopContext() {
        UIGraphicsPopContext()
    }

    func NSUIGraphicsEndImageContext() {
        UIGraphicsEndImageContext()
    }

    func NSUIImagePNGRepresentation(_ image: NSUIImage) -> Data? {
        return image.pngData()
    }

    func NSUIImageJPEGRepresentation(_ image: NSUIImage, _ quality: CGFloat = 0.8) -> Data? {
        return image.jpegData(compressionQuality: quality)
    }

    func NSUIGraphicsBeginImageContextWithOptions(_ size: CGSize, _ opaque: Bool, _ scale: CGFloat) {
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
    }
#endif

// MARK: - AppKit

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit

    func NSUIGraphicsGetCurrentContext() -> CGContext? {
        return NSGraphicsContext.current?.cgContext
    }

    func NSUIGraphicsPushContext(_ context: CGContext) {
        let cx = NSGraphicsContext(cgContext: context, flipped: true)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = cx
    }

    func NSUIGraphicsPopContext() {
        NSGraphicsContext.restoreGraphicsState()
    }

    func NSUIImagePNGRepresentation(_ image: NSUIImage) -> Data? {
        image.lockFocus()
        let rep = NSBitmapImageRep(focusedViewRect: NSMakeRect(0, 0, image.size.width, image.size.height))
        image.unlockFocus()
        return rep?.representation(using: .png, properties: [:])
    }

    func NSUIImageJPEGRepresentation(_ image: NSUIImage, _ quality: CGFloat = 0.9) -> Data? {
        image.lockFocus()
        let rep = NSBitmapImageRep(focusedViewRect: NSMakeRect(0, 0, image.size.width, image.size.height))
        image.unlockFocus()
        return rep?.representation(using: .jpeg, properties: [NSBitmapImageRep.PropertyKey.compressionFactor: quality])
    }

    private var imageContextStack: [CGFloat] = []

    func NSUIGraphicsBeginImageContextWithOptions(_ size: CGSize, _ opaque: Bool, _ scale: CGFloat) {
        var scale = scale
        if scale == 0.0 {
            scale = NSScreen.main?.backingScaleFactor ?? 1.0
        }

        let width = Int(size.width * scale)
        let height = Int(size.height * scale)

        if width > 0, height > 0 {
            imageContextStack.append(scale)

            let colorSpace = CGColorSpaceCreateDeviceRGB()

            guard let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * width, space: colorSpace, bitmapInfo: opaque ? CGImageAlphaInfo.noneSkipFirst.rawValue : CGImageAlphaInfo.premultipliedFirst.rawValue)
            else { return }

            ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: CGFloat(height)))
            ctx.scaleBy(x: scale, y: scale)
            NSUIGraphicsPushContext(ctx)
        }
    }

    func NSUIGraphicsGetImageFromCurrentImageContext() -> NSUIImage? {
        if !imageContextStack.isEmpty {
            guard let ctx = NSUIGraphicsGetCurrentContext()
            else { return nil }

            let scale = imageContextStack.last!
            if let theCGImage = ctx.makeImage() {
                let size = CGSize(width: CGFloat(ctx.width) / scale, height: CGFloat(ctx.height) / scale)
                let image = NSImage(cgImage: theCGImage, size: size)
                return image
            }
        }
        return nil
    }

    func NSUIGraphicsEndImageContext() {
        if imageContextStack.last != nil {
            imageContextStack.removeLast()
            NSUIGraphicsPopContext()
        }
    }
#endif
