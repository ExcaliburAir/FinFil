//
//  SearchViewController.swift
//  FinFil
//
//  Created by 张桀硕 on 2020/9/30.
//  Copyright © 2020年 jieshuo.zhang. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    
    // MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareData()
        setupViews()
        addTapGesture()
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
        if segue.identifier == "SearchToList" {
            if let viewController = segue.destination as? ListViewController {
                if sender != nil {
                    viewController.moviesInfo = sender as! [MovieInfo]
                }
            }
        }
    }
}

extension SearchViewController {
    
    func prepareData() {
        infoLabel.text = NSLocalizedString("Search_Movies", comment: "")
    }
    
    func setupViews() {
        textField.delegate = self
        
        // 背景渐变色
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        self.view.layer.addSublayer(gradientLayer)
        //
        let colerTop: UIColor = UIColor.colorWith(hexString: "#396D9B")
        let colerBottom: UIColor = UIColor.colorWith(hexString: "#2C3D4D")
        gradientLayer.colors = [colerTop.cgColor, colerBottom.cgColor]
        //
        let gradientLocations: [NSNumber] = [0.0, 1.0]
        gradientLayer.locations = gradientLocations
        gradientLayer.startPoint = CGPoint.init(x: 0.4, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 0.6, y: 1)
        
        self.view.addSubview(infoLabel)
        self.view.addSubview(textField)
    }
    
    func refreshViews() {
        textField.text = ""
        textField.resignFirstResponder()
    }
    
    // Menu按键
    @IBAction func tapSideMenuButton(_ sender: UIBarButtonItem) {
        // 调用侧边栏
        sideMenuController?.revealMenu()
    }
    
    // 添加点击事件
    func addTapGesture() {
        // 设置添加手势识别器
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(sender:)))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        
        // 附加识别器到视图
        self.view.addGestureRecognizer(gesture)
    }
    
    // 相应点击事件
    @objc func tapGestureAction(sender: UITapGestureRecognizer) {
        // 取消textfield的焦点
        textField.resignFirstResponder()
    }
}

extension SearchViewController: UITextFieldDelegate {
    // 输入框询问是否可以编辑 true 可以编辑  false 不能编辑
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    // 该方法代表输入框已经可以开始编辑,进入编辑状态
    func textFieldDidBeginEditing(_ textField: UITextField) {}
    
    // 输入框将要将要结束编辑
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    // 输入框结束编辑状态
    func textFieldDidEndEditing(_ textField: UITextField) {
        // 取消textfield的焦点
        textField.resignFirstResponder()
    }
    
    // 文本框是否可以清除内容
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    // 输入框按下键盘 return 收回键盘
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 取消textfield的焦点
        textField.resignFirstResponder()
        
        Network().get_search_request(
            controller: self,
            queryString: textField.text!,
            block: { movies in
                print(movies)
                if movies.count >= 1 {
                    self.performSegue(withIdentifier: "SearchToList", sender: movies)
                }
                else {
                    Utils().okButtonAlertView(
                        title: NSLocalizedString("Network_noResult_tryOther", comment: ""),
                        controller: self,
                        block: nil)
                }
        })
        
        return true
    }
    
    // 该方法当文本框内容出现变化时 及时获取文本最新内容
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
