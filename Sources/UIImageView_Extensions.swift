import UIKit

extension UIImageView {
    
    // Data holder tap recognizer
    private class TapWithDataRecognizer:UITapGestureRecognizer {
        weak var from:UIViewController?
        var imageDatasource:ImageDataSource?
        var imageDelegate: ImageDelegate?
        var initialIndex:Int = 0
        var options:[ImageViewerOption] = []
    }
    
    private var vc:UIViewController? {
        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController
            else { return nil }
        return rootVC.presentedViewController != nil ? rootVC.presentedViewController : rootVC
    }
    
    public func setupImageViewer(
        delegate: ImageDelegate? = nil,
        options:[ImageViewerOption] = [],
        from:UIViewController? = nil) {
        setup(
            datasource: SimpleImageDatasource(imageItems: [.image(image)]),
            delegate: delegate,
            options: options,
            from: from)
    }
    
    #if canImport(SDWebImage)
    public func setupImageViewer(
        url:URL,
        delegate: ImageDelegate? = nil,
        initialIndex:Int = 0,
        placeholder: UIImage? = nil,
        options:[ImageViewerOption] = [],
        from:UIViewController? = nil) {
        
        let datasource = SimpleImageDatasource(
            imageItems: [url].compactMap {
                ImageItem.url($0, placeholder: placeholder)
        })
        setup(
            datasource: datasource,
            delegate: delegate,
            initialIndex: initialIndex,
            options: options,
            from: from)
    }
    #endif
    
    public func setupImageViewer(
        images:[UIImage],
        delegate: ImageDelegate? = nil,
        initialIndex:Int = 0,
        options:[ImageViewerOption] = [],
        from:UIViewController? = nil) {
        
        let datasource = SimpleImageDatasource(
            imageItems: images.compactMap {
                ImageItem.image($0)
        })
        setup(
            datasource: datasource,
            delegate: delegate,
            initialIndex: initialIndex,
            options: options,
            from: from)
    }
    
    #if canImport(SDWebImage)
    public func setupImageViewer(
        urls:[URL],
        delegate: ImageDelegate? = nil,
        initialIndex:Int = 0,
        options:[ImageViewerOption] = [],
        placeholder: UIImage? = nil,
        from:UIViewController? = nil) {
        
        let datasource = SimpleImageDatasource(
            imageItems: urls.compactMap {
                ImageItem.url($0, placeholder: placeholder)
        })
        setup(
            datasource: datasource,
            delegate: delegate,
            initialIndex: initialIndex,
            options: options,
            from: from)
    }
    #endif
    
    public func setupImageViewer(
        datasource:ImageDataSource,
        delegate: ImageDelegate? = nil,
        initialIndex:Int = 0,
        options:[ImageViewerOption] = [],
        from:UIViewController? = nil) {
        
        setup(
            datasource: datasource,
            delegate: delegate,
            initialIndex: initialIndex,
            options: options,
            from: from)
    }
    
    private func setup(
        datasource:ImageDataSource?,
        delegate: ImageDelegate? = nil,
        initialIndex:Int = 0,
        options:[ImageViewerOption] = [],
        from: UIViewController? = nil) {
        
        var _tapRecognizer:TapWithDataRecognizer?
        gestureRecognizers?.forEach {
            if let _tr = $0 as? TapWithDataRecognizer {
                // if found, just use existing
                _tapRecognizer = _tr
            }
        }
        
        isUserInteractionEnabled = true
        contentMode = .scaleAspectFill
        clipsToBounds = true
        
        if _tapRecognizer == nil {
            _tapRecognizer = TapWithDataRecognizer(
                target: self, action: #selector(showImageViewer(_:)))
            _tapRecognizer!.numberOfTouchesRequired = 1
            _tapRecognizer!.numberOfTapsRequired = 1
        }
        // Pass the Data
        _tapRecognizer!.imageDatasource = datasource
        _tapRecognizer!.initialIndex = initialIndex
        _tapRecognizer!.options = options
        _tapRecognizer!.from = from
        _tapRecognizer!.imageDelegate = delegate
        addGestureRecognizer(_tapRecognizer!)
    }
    
    @objc
    private func showImageViewer(_ sender:TapWithDataRecognizer) {
        guard let sourceView = sender.view as? UIImageView else { return }
        let imageCarousel = ImageCarouselViewController(
            sourceView: sourceView,
            imageDataSource: sender.imageDatasource,
            delegate: sender.imageDelegate,
            options: sender.options,
            initialIndex: sender.initialIndex
        )
        let presentFromVC = sender.from ?? vc
        presentFromVC?.present(imageCarousel, animated: true)
    }
}
