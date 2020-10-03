//
//  ListViewController.swift
//  FinFil
//
//  Created by 张桀硕 on 2020/10/1.
//  Copyright © 2020年 jieshuo.zhang. All rights reserved.
//

import Foundation
import UIKit

class MovieInfoCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
}

class ListViewController: UIViewController {
    
    @IBOutlet weak var tabelView: UITableView!
    var moviesInfo: [MovieInfo] = []
    
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
        
        refreshViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ListToDetails" {
            if let viewController = segue.destination as? ShowDetailsViewController {
                if sender != nil {
                    viewController.movieDetail = sender as? MovieDetail
                }
            }
        }
    }
}

extension ListViewController {
    
    func prepareData() {
        print(moviesInfo)
    }
    
    func setupViews() {
        tabelView.delegate = self
        tabelView.dataSource = self
    }
    
    func refreshViews() {}
}

// MARK:- UITableViewDelegate, UITableViewDataSource
extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moviesInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        // init the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieInfoCell", for: indexPath) as! MovieInfoCell
        cell.contentView.backgroundColor = UIColor.clear
        
        // set datas
        let movie = moviesInfo[row]
        cell.titleLabel.text = movie.originalTitle
        cell.dateLabel.text = movie.releaseDate
        cell.overviewLabel.text = movie.overview
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let movieID = moviesInfo[row].movieID

        tableView.deselectRow(at: indexPath, animated: true)
        
        Network().get_details_request(
            controller: self,
            movieID: movieID,
            block: { movie in
                print(movie)
                if !movie.movieID.isEmpty {
                    self.performSegue(withIdentifier: "ListToDetails", sender: movie)
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
