//
//  LikedViewController.swift
//  FinFil
//
//  Created by 张桀硕 on 2020/9/30.
//  Copyright © 2020年 jieshuo.zhang. All rights reserved.
//

import Foundation
import UIKit

class LikedViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tabelView: UITableView!
    @IBOutlet weak var infoLabel: UILabel!
    
    var likedMovieInfos: [LikedMovieInfo] = []
    
    // MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        prepareData()
        refreshViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FavoriteToDetails" {
            if let viewController = segue.destination as? ShowDetailsViewController {
                if sender != nil {
                    viewController.movieDetail = sender as? MovieDetail
                }
            }
        }
    }
}

extension LikedViewController {
    
    func prepareData() {
        likedMovieInfos = MovieInfoRealmTool.getAll()
    }
    
    func setupViews() {
        tabelView.delegate = self
        tabelView.dataSource = self
        
        infoLabel.text = NSLocalizedString("Seach_Before_Favorite", comment: "")
        tabelView.isHidden = true
        infoLabel.isHidden = true
    }
    
    func refreshViews() {
        if likedMovieInfos.count >= 1 {
            tabelView.isHidden = false
            infoLabel.isHidden = true
            tabelView.reloadData()
        }
        else {
            tabelView.isHidden = true
            infoLabel.isHidden = false
        }
    }
    
    // Menu按键
    @IBAction func tapSideMenuButton(_ sender: UIBarButtonItem) {
        // 调用侧边栏
        sideMenuController?.revealMenu()
    }
}

// MARK:- UITableViewDelegate, UITableViewDataSource
extension LikedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likedMovieInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        // init the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieInfoCell", for: indexPath) as! MovieInfoCell
        cell.contentView.backgroundColor = UIColor.clear
        
        // set datas
        let movie = likedMovieInfos[row]
        cell.titleLabel.text = movie.originalTitle
        cell.dateLabel.text = movie.releaseDate
        cell.overviewLabel.text = movie.overview
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let movieID = String(likedMovieInfos[row].movieIdInt)
        
        // 取消选中状态
        tableView.deselectRow(at: indexPath, animated: true)
        
        Network().get_details_request(
            controller: self,
            movieID: movieID,
            block: { movie in
                print(movie)
                if !movie.movieID.isEmpty {
                    self.performSegue(withIdentifier: "FavoriteToDetails", sender: movie)
                }
                else {
                    Utils().okButtonAlertView(
                        title: NSLocalizedString("Network_fails_tryAgain", comment: ""),
                        controller: self,
                        block: nil)
                }
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
