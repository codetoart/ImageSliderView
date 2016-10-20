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
    func didTapImage(index: Int)
}

public protocol ImageSliderViewDataSource: class {
    func numberOfImages() -> Int?
    func imageURLFor(index: Int) -> NSURL?
}

public class ImageSliderView: UIView {

    public var viewMode: UIViewContentMode = .ScaleAspectFit
    public var allowFullscreenOnTap = true
    public var font: UIFont = UIFont.systemFontOfSize(15)
    public weak var dataSource: ImageSliderViewDataSource?
    public weak var delegate: ImageSliderViewDelegate?
    
    private var scrollView: UIScrollView?
    private var pageControl: UIPageControl?
    private var imageURLArray = Array<NSURL>()
    
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
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications()
    }
    
    public func setPageIndicatorTintColor(tintColor: UIColor) {
        self.pageControl?.pageIndicatorTintColor = tintColor
    }
    
    public func setCurrentPageIndicatorTintColor(tintColor: UIColor) {
        self.pageControl?.currentPageIndicatorTintColor = tintColor
    }
    
    public func reloadData() {
        if let numImages = self.dataSource?.numberOfImages()
             where numImages > 0 {
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
        self.backgroundColor = UIColor.blackColor()
        createScrollViewIfRequired()
        createPageControlIffRequired()
        reloadData()
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ImageSliderView.orientationChanged), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    private func createScrollViewIfRequired() {
        if self.scrollView == nil {
            self.scrollView = UIScrollView()
            self.scrollView?.showsHorizontalScrollIndicator = false
            self.scrollView?.pagingEnabled = true
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
            self.pageControl?.currentPageIndicatorTintColor = UIColor.whiteColor()
            self.pageControl?.tintColor = UIColor.blackColor()
            self.addSubview(self.pageControl!)
            self.pageControl?.snp_makeConstraints(closure: { (make) in
                make.centerX.equalTo(self.snp_centerX)
                make.bottom.equalTo(self.snp_bottom).offset(-8)
            })
        }
    }
    
    private func layoutImages() {
        for sv in self.scrollView!.subviews {
            sv.removeFromSuperview()
        }
        let width = CGRectGetWidth(self.bounds)
        let height = CGRectGetHeight(self.bounds)
        var index = 0
        for imageURL in self.imageURLArray {
            let imageView = AsyncImageView(frame: CGRectMake(width*CGFloat(index), 0, width, height))
            imageView.contentMode = viewMode
            imageView.backgroundColor = UIColor.blackColor()
            imageView.showActivityIndicator = true
            imageView.activityIndicatorColor = UIColor.whiteColor()
            imageView.activityIndicatorStyle = .White
            imageView.imageURL = imageURL
            imageView.userInteractionEnabled = allowFullscreenOnTap
            if allowFullscreenOnTap {
                let tgr = UITapGestureRecognizer(
                    target: self,
                    action: #selector(ImageSliderView.imageTapped(_:))
                )
                imageView.addGestureRecognizer(tgr)
            }
            self.scrollView?.addSubview(imageView)
            index += 1
        }
        self.scrollView?.contentSize = CGSizeMake(width*CGFloat(self.imageURLArray.count), height)
        self.scrollView?.contentOffset = CGPointZero
        self.bringSubviewToFront(self.pageControl!)
        self.pageControl?.numberOfPages = self.imageURLArray.count
    }
    
    @objc private func orientationChanged() {
        if let numImages = self.dataSource?.numberOfImages() where numImages > 0 {
            let imageViews = self.scrollView?.subviews.map{$0 as? AsyncImageView}
            let width = CGRectGetWidth(self.bounds)
            let height = CGRectGetHeight(self.bounds)
            for index in 0...numImages-1 {
                if let imageView = imageViews?[index] {
                    imageView.frame = CGRectMake(width*CGFloat(index), 0, width, height)
                }
            }
            self.scrollView?.contentSize = CGSizeMake(CGFloat(numImages)*width, height)
            self.scrollView?.contentOffset = CGPointMake(CGFloat(self.pageControl!.currentPage)*width, 0)
        }
    }
    
    @objc private func imageTapped(sender: AsyncImageView) {
        if let parentVC = getParentViewController() {
            let fullScreenController = ImageSliderFullScreenController()
            fullScreenController.images = self.imageURLArray
            fullScreenController.font = self.font
            fullScreenController.tintColor = self.tintColor
            parentVC.presentViewController(fullScreenController, animated: true, completion: { 
                
            })
        }
    }
    
    private func getParentViewController() -> UIViewController? {
        var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil) {
            topVC = topVC!.presentedViewController
        }
        
        return topVC
    }

}

extension ImageSliderView: UIScrollViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        let width = CGRectGetWidth(self.bounds)
        self.pageControl?.currentPage = Int(scrollView.contentOffset.x/width)
    }
}
