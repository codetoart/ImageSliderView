//
//  ImageSliderFullScreenController.swift
//  UpcomingMovies
//
//  Created by Mahavir Jain on 17/10/16.
//  Copyright © 2016 CodeToArt. All rights reserved.
//

import UIKit
import SnapKit

class ImageSliderFullScreenController: UIViewController {
    
    var images: Array<URL>?
    var tintColor: UIColor = UIColor.blue
    var font: UIFont = UIFont.systemFont(ofSize: 15)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.black
        let imageSliderView = ImageSliderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        imageSliderView.allowFullscreenOnTap = false
        imageSliderView.dataSource = self
        self.view.addSubview(imageSliderView)
        imageSliderView.snp_remakeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        imageSliderView.reloadData()
        
        let closeBtn = UIButton()
        closeBtn.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)
        closeBtn.backgroundColor = tintColor
        closeBtn.titleLabel?.font = self.font
        self.view.addSubview(closeBtn)
        closeBtn.snp_remakeConstraints { (make) in
            make.leading.equalTo(self.view.snp_leading).offset(8)
            make.top.equalTo(self.view.snp_top).offset(8)
            make.height.equalTo(32)
            make.width.equalTo(60)
        }
        self.view.layoutIfNeeded()
        closeBtn.layer.cornerRadius = 5
        closeBtn.clipsToBounds = true
        closeBtn.layer.borderWidth = 1.0
        closeBtn.layer.borderColor = UIColor.white.cgColor
        closeBtn.addTarget(self, action: #selector(closeBtnTapped), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func prefersStatusBarHidden() -> Bool {
//        return true
//    }
    
    func closeBtnTapped() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension ImageSliderFullScreenController: ImageSliderViewDataSource {
    func numberOfImages() -> Int? {
        return self.images?.count
    }
    
    func imageURLFor(_ index: Int) -> URL? {
        return self.images?[index]
    }
}
