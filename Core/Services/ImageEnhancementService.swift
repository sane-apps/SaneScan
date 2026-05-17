import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

enum ImageEnhancementService {
    static func cleanedImage(from image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }

        let context = CIContext()
        let filters = ciImage.autoAdjustmentFilters(options: [
            CIImageAutoAdjustmentOption.enhance: true,
            CIImageAutoAdjustmentOption.redEye: false
        ])

        let adjusted = filters.reduce(ciImage) { current, filter in
            filter.setValue(current, forKey: kCIInputImageKey)
            return filter.outputImage ?? current
        }

        let sharpen = CIFilter.sharpenLuminance()
        sharpen.inputImage = adjusted
        sharpen.sharpness = 0.35

        let color = CIFilter.colorControls()
        color.inputImage = sharpen.outputImage ?? adjusted
        color.contrast = 1.08
        color.saturation = 1.02
        color.brightness = 0.01

        guard
            let output = color.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent)
        else {
            return image
        }

        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}
