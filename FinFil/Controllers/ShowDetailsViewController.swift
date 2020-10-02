//
//  ShowDetailsViewController.swift
//  FinFil
//
//  Created by 张桀硕 on 2020/10/1.
//  Copyright © 2020年 jieshuo.zhang. All rights reserved.
//

import Foundation
import UIKit

class ShowDetailsViewController: UIViewController {
    
    @IBOutlet weak var titelLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var voteAverageLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var likedButton: UIButton!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backView: UIView!
    
    var movieDetail: MovieDetail?
    
    // MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareData()
        setupViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print( NSStringFromClass(self.classForCoder) + " deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // stop reading the overview
        Utils().getAppDelegate().cancleSpeek()
    }
    
    override func viewDidLayoutSubviews() {
        resizeViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {}
}

extension ShowDetailsViewController {
    
    func prepareData() {
        Network().getImageFromWeb(movieDetail!.posterPath) { (image) in
            self.posterImage.image = image
        }
        titelLabel.text = movieDetail!.originalTitle
        timeLabel.text = movieDetail!.runtime
        dateLabel.text = movieDetail!.releaseDate
        voteAverageLabel.text = movieDetail!.voteAverage
        voteCountLabel.text = movieDetail!.voteCount
        languageLabel.text = movieDetail!.originalLanguage
        overviewLabel.text = movieDetail!.overview
    }
    
    func setupViews() {
        likedButton.layer.borderColor = UIColor.blue.cgColor
        likedButton.layer.borderWidth = 0.25
        likedButton.layer.masksToBounds = true
        likedButton.titleLabel?.textAlignment = NSTextAlignment.center
        likedButton.layer.cornerRadius = likedButton.frame.height / 2
        
        setupButtonStatus()
    }
    
    func resizeViews() {
        scrollView.contentSize = backView.frame.size
    }
    
    func setupButtonStatus() {
        if MovieInfoRealmTool.ifInMovieInfoDB(movieIdInt: Int(movieDetail!.movieID)!) {
            likedButton.backgroundColor = .blue
            likedButton.setTitle(NSLocalizedString("Unfavorite", comment: ""), for: .normal)
            likedButton.setTitleColor(.white, for: .normal)
            likedButton.setTitleColor(.blue, for: .highlighted)
        }
        else {
            likedButton.backgroundColor = .white
            likedButton.setTitle(NSLocalizedString("Favorite", comment: ""), for: .normal)
            likedButton.setTitleColor(.blue, for: .normal)
            likedButton.setTitleColor(.white, for: .highlighted)
        }
    }
    
    @IBAction func tapLikedButton(_ sender: UIButton) {
 
        if MovieInfoRealmTool.ifInMovieInfoDB(movieIdInt: Int(movieDetail!.movieID)!) {
            // delete data
            let likedMovieInfos = MovieInfoRealmTool.getMovieInfos()
            for movieInfo in likedMovieInfos {
                if movieInfo.movieIdInt == Int(movieDetail!.movieID) {
                    MovieInfoRealmTool.deleteMovieInfo(movieInfo: movieInfo)
                }
            }
            
            // stop reading the overview
            Utils().getAppDelegate().cancleSpeek()
        }
        else {
            // save data
            let likedMovieInfo = MovieInfoRealmTool.transData(movieDetail!)
            MovieInfoRealmTool.updateMovieInfo(movieInfo: likedMovieInfo)
            
            // read the overview
            if !movieDetail!.overview.isEmpty {
                Utils().getAppDelegate().startSpeek(text: movieDetail!.overview)
            }
        }
        
        setupButtonStatus()
    }

}
