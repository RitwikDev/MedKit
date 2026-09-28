//
//  ZoomablePhotoView.swift
//  MedKit
//
//  Created by Rishik Dev on 10/06/26.
//

import SwiftUI
import UIKit

public struct ZoomablePhotoView: UIViewRepresentable {
    public let photo: UIImage
    
    public init(photo: UIImage) {
        self.photo = photo
    }
    
    public func makeUIView(context: Context) -> PhotoScrollView {
        let scrollView = PhotoScrollView(image: photo)
        scrollView.delegate = context.coordinator
        return scrollView
    }
    
    public func updateUIView(_ uiView: PhotoScrollView, context: Context) {
        if uiView.imageView.image != photo {
            uiView.update(with: photo)
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    @MainActor
    public class Coordinator: NSObject, UIScrollViewDelegate {
        // Tells the scroll view which layer to apply the pinch-to-zoom matrix to
        public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return (scrollView as? PhotoScrollView)?.imageView
        }
        
        // Ensures the image stays perfectly centred when zoomed out past its physical bounds
        public func scrollViewDidZoom(_ scrollView: UIScrollView) {
            (scrollView as? PhotoScrollView)?.centerImage()
        }
    }
}

// MARK: - Internal UIKit Implementation
public class PhotoScrollView: UIScrollView {
    let imageView = UIImageView()
    private var isConfigured = false
    
    init(image: UIImage) {
        super.init(frame: .zero)
        
        // Configure native physics
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bouncesZoom = true
        self.decelerationRate = .fast
        
        // Configure the image layer
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        self.addSubview(imageView)
        
        // Attach the Double Tap focal gesture
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with image: UIImage) {
        self.imageView.image = image
        self.isConfigured = false
        self.setNeedsLayout()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // Wait until the view has physical dimensions before calculating the initial zoom
        if !isConfigured && bounds.width > 0 && imageView.image != nil {
            configureImageScale()
            isConfigured = true
        }
        centerImage()
    }
    
    private func configureImageScale() {
        guard let image = imageView.image, self.bounds.width > 0 else { return }
        
        // Reset the coordinate space
        imageView.frame = CGRect(origin: .zero, size: image.size)
        self.contentSize = image.size
        
        // Calculate the exact scale needed to fit the image on the screen
        let widthScale = self.bounds.width / image.size.width
        let heightScale = self.bounds.height / image.size.height
        let minScale = min(widthScale, heightScale)
        
        self.minimumZoomScale = minScale
        self.maximumZoomScale = minScale * 5.0 // Allows up to 5x magnification
        self.zoomScale = minScale
    }
    
    func centerImage() {
        let boundsSize = self.bounds.size
        var frameToCenter = imageView.frame
        
        // Pin to centre X if the zoomed image is narrower than the screen
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        
        // Pin to centre Y if the zoomed image is shorter than the screen
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        
        imageView.frame = frameToCenter
    }
    
    @objc private func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if self.zoomScale > self.minimumZoomScale {
            // If already zoomed in, snap back out to see the whole image
            self.setZoomScale(self.minimumZoomScale, animated: true)
        } else {
            // Calculate a rectangle centred exactly on the user's tap
            let tapPoint = sender.location(in: imageView)
            let targetZoom = self.maximumZoomScale
            let zoomSize = CGSize(width: self.bounds.width / targetZoom,
                                  height: self.bounds.height / targetZoom)
            
            let zoomRect = CGRect(x: tapPoint.x - zoomSize.width / 2.0,
                                  y: tapPoint.y - zoomSize.height / 2.0,
                                  width: zoomSize.width,
                                  height: zoomSize.height)
            
            // Execute the native focal zoom
            self.zoom(to: zoomRect, animated: true)
        }
    }
}

#Preview {
    ZoomablePhotoView(photo: UIImage())
}
