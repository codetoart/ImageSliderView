//
//  ImageSliderView.swift
//  UpcomingMovies
//
//  Created by Mahavir Jain on 17/10/16.
//  Copyright © 2016 CodeToArt. All rights reserved.
//

import UIKit
import SnapKit
import AsyncImageView

public protocol ImageSliderViewDelegate: class {
    func didTapImage(_ index: Int)
}

public protocol ImageSliderViewDataSource: class {
    func numberOfImages() -> Int?
    func imageURLFor(_ index: Int) -> URL?
}

open class ImageSliderView: UIView {

    open var viewMode: UIViewContentMode = .scaleAspectFit
    open var allowFullscreenOnTap = true
    open var font: UIFont = UIFont.systemFont(ofSize: 15)
    open weak var dataSource: ImageSliderViewDataSource?
    open weak var delegate: ImageSliderViewDelegate?
    
    fileprivate var scrollView: UIScrollView?
    fileprivate var pageControl: UIPageControl?
    fileprivate var imageURLArray = Array<URL>()
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    
    public func setPageIndicatorTintColor(tintColor: UIColor) {
        self.pageControl?.pageIndicatorTintColor = tintColor
    }
    
    public func setCurrentPageIndicatorTintColor(tintColor: UIColor) {
        self.pageControl?.currentPageIndicatorTintColor = tintColor
    }
    
    public func reloadData() {
        if let numImages = self.dataSource?.numberOfImages(), numImages > 0 {
            // remove all subviews
            self.imageURLArray = (0...numImages-1).filter({
                self.dataSource?.imageURLFor($0) != nil
            }).map({
                self.dataSource!.imageURLFor($0)!
            })
            self.layoutImages()
        }
    }
    
    
    
    private func setup() {
        self.backgroundColor = UIColor.black
        createScrollViewIfRequired()
        createPageControlIffRequired()
        reloadData()
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(ImageSliderView.orientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    private func createScrollViewIfRequired() {
        if self.scrollView == nil {
            self.scrollView = UIScrollView()
            self.scrollView?.showsHorizontalScrollIndicator = false
            self.scrollView?.isPagingEnabled = true
            self.scrollView?.delegate = self
            self.addSubview(self.scrollView!)
            self.scrollView!.snp_makeConstraints { (make) -> Void in
                make.edges.equalTo(self)
            }
        }
    }
    
    private func createPageControlIffRequired() {
        if self.pageControl == nil {
            self.pageControl = UIPageControl()
            self.pageControl?.hidesForSinglePage = true
            self.pageControl?.currentPageIndicatorTintColor = UIColor.white
            self.pageControl?.tintColor = UIColor.black
            self.addSubview(self.pageControl!)
            self.pageControl?.snp_makeConstraints({ (make) in
                make.centerX.equalTo(self.snp_centerX)
                make.bottom.equalTo(self.snp_bottom).offset(-8)
            })
        }
    }
    
    private func layoutImages() {
        for sv in self.scrollView!.subviews {
            sv.removeFromSuperview()
        }
        let width = self.bounds.width
        let height = self.bounds.height
        var index = 0
        
        for imageURL in self.imageURLArray {
            let imageView = AsyncImageView(frame: CGRect(x: width*CGFloat(index), y: 0, width: width, height: height))
            imageView.contentMode = viewMode
            imageView.backgroundColor = UIColor.black
            imageView.showActivityIndicator = true
            imageView.activityIndicatorColor = UIColor.white
            imageView.activityIndicatorStyle = .white
            imageView.imageURL = imageURL as URL
            imageView.isUserInteractionEnabled = allowFullscreenOnTap
            if allowFullscreenOnTap {
                let tgr = UITapGestureRecognizer(
                    target: self,
                    action: #selector(ImageSliderView.imageTapped)
                )
                imageView.addGestureRecognizer(tgr)
            }
            self.scrollView?.addSubview(imageView)
            index += 1
        }
        
        self.scrollView?.contentSize = CGSize(width: width*CGFloat(self.imageURLArray.count), height: height)
        self.scrollView?.contentOffset = .zero
        self.bringSubview(toFront: self.pageControl!)
        self.pageControl?.numberOfPages = self.imageURLArray.count
    }
    
    @objc private func orientationChanged() {
        if let numImages = self.dataSource?.numberOfImages(), numImages > 0 {
            let imageViews = self.scrollView?.subviews.map{$0 as? AsyncImageView}
            let width = self.bounds.width
            let height = self.bounds.height
            for index in 0...numImages-1 {
                if let imageView = imageViews?[index] {
                    imageView.frame = CGRect(x: width*CGFloat(index),y: 0,width: width,height: height)
                }
            }
            
            self.scrollView?.contentSize = CGSize(width: CGFloat(numImages)*width,height: height)
            self.scrollView?.contentOffset = CGPoint(x: CGFloat(self.pageControl!.currentPage)*width,y: 0)
        }
    }
    
    @objc private func imageTapped(sender: AsyncImageView) {
        if let parentVC = getParentViewController() {
            let fullScreenController = ImageSliderFullScreenController()
            fullScreenController.images = self.imageURLArray
            fullScreenController.font = self.font
            fullScreenController.tintColor = self.tintColor
            parentVC.present(fullScreenController, animated: true, completion: {
                
            })
        }
    }
    
    private func getParentViewController() -> UIViewController? {
        var topVC = UIApplication.shared.keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil) {
            topVC = topVC!.presentedViewController
        }
        
        return topVC
    }

}

extension ImageSliderView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = self.bounds.width
        self.pageControl?.currentPage = Int(scrollView.contentOffset.x/width)
    }
}
