//
//  MetallicDevice.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/21/17.
//

import MetalKit

struct Metallic {

	let device: MTLDevice
	let commandQueue: MTLCommandQueue
	let library: MTLLibrary?

	private (set) static var shared = Metallic()

	init?() {
		guard let device = MTLCreateSystemDefaultDevice()
			else { print("failed: MTLCreateSystemDefaultDevice()"); return nil }
		guard let commandQueue = device.makeCommandQueue()
			else { print("failed: makeCommandQueue()"); return nil }
		self.device = device
		self.commandQueue = commandQueue
		self.library = device.makeDefaultLibrary()
	}

	//

	var pixelFormat: MTLPixelFormat { return .bgra8Unorm }

	// MARK: -

	private (set) var renderers = NSMapTable<NSString, AnyObject>.strongToWeakObjects()

	func renderer<T: MetallicRenderer>() -> T {
		let key = NSStringFromClass(T.self) as NSString
		if let renderer = renderers.object(forKey: key) {
			return renderer as! T
		}
		else {
			let renderer = T(metallic: self)
			renderers.setObject(renderer, forKey: key)
			return renderer
		}
	}

	// MARK: -
	
	private (set) var kernels = NSMapTable<NSString, AnyObject>.strongToWeakObjects()

	func renderer<T: MetalicKernel>() -> T {
		let key = NSStringFromClass(T.self) as NSString
		if let renderer = renderers.object(forKey: key) {
			return renderer as! T
		}
		else {
			let renderer = T(metallic: self)
			renderers.setObject(renderer, forKey: key)
			return renderer
		}
	}
	
	// MARK: -

	func makeTexture(ciImage: CIImage) -> MTLTexture? {
		//let ciImage = ciImage.transformed(by: CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: ciImage.extent.height))
		let context = CIContext(mtlDevice: self.device)
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let (width, height) = (Int(ciImage.extent.width), Int(ciImage.extent.height))
		let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: self.pixelFormat, width: width, height: height, mipmapped: false)
//		descriptor.resourceOptions = [.storageModeManaged, .storageModeShared]
		descriptor.storageMode = .managed
		descriptor.usage = [.shaderRead, .shaderWrite]
		guard let texture = self.device.makeTexture(descriptor: descriptor) else { return nil }
		context.render(ciImage, to: texture, commandBuffer: nil, bounds: ciImage.extent, colorSpace: colorSpace)
		return texture
	}

	func makeTexture(cgImage: CGImage) -> MTLTexture? {
		let ciImage = CIImage(cgImage: cgImage)
		return self.makeTexture(ciImage: ciImage)
	}

	func makeTexture(named name: String) -> MTLTexture? {
		guard let image = XImage(named: name) else { return nil }
		guard let data = image.tiffRepresentation else { return nil }
		guard let ciImage = CIImage(data: data) else { return nil }
		return makeTexture(ciImage: ciImage)
	}

}
