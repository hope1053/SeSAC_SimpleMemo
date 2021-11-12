//
//  WalkThroughViewController.swift
//  SeSAC_SimpleMemo
//
//  Created by 최혜린 on 2021/11/12.
//

import UIKit

class WalkThroughViewController: UIViewController {

    @IBOutlet var background: UIView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var okButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateBackgroundView()
        updateButtonUI()
        updateWelcomeLabel()
    }
    
    func updateBackgroundView() {
        view.backgroundColor = .clear
        view.isOpaque = false
        
        background.backgroundColor = .black
        background.layer.opacity = 0.5
        
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = 20
    }
    
    func updateWelcomeLabel() {
        welcomeLabel.numberOfLines = 0
        welcomeLabel.text = """
                      처음 오셨군요!
                      환영합니다 :)
                      
                      당신만의 메모를 작성하고
                      관리해보세요!
                      """
        welcomeLabel.font = .systemFont(ofSize: 19, weight: .heavy)
    }
    
    func updateButtonUI() {
        okButton.setTitle("확인", for: .normal)
        okButton.backgroundColor = .orange
        okButton.layer.cornerRadius = 10
        okButton.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func okButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
