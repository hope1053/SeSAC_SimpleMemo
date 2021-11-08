//
//  DetailViewController.swift
//  SeSAC_SimpleMemo
//
//  Created by 최혜린 on 2021/11/08.
//

import UIKit
import RealmSwift

class DetailViewController: UIViewController {

    let localRealm = try! Realm()
    var currentMemo: Memo?
    
    @IBOutlet var memoTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoTextView.delegate = self
        
        if currentMemo != nil {
            memoTextView.text = currentMemo?.totalContent
        } else {
            memoTextView.becomeFirstResponder()
            addBarButtonItem()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if currentMemo == nil {
            addMemo()
        } else {
            reviseMemo()
        }
    }
    
    func addMemo() {
        if !memoTextView.text.isEmpty {
            var memo: Memo?
            let separatedArray: [String] = memoTextView.text.components(separatedBy: "\n").filter{$0 != ""}
            
            if separatedArray.count < 2 {
                memo = Memo(totalContent: memoTextView.text, memoTitle: separatedArray[0], memoContent: "추가 텍스트 없음", writtenDate: Date())
            } else {
                memo = Memo(totalContent: memoTextView.text, memoTitle: separatedArray[0], memoContent: separatedArray[1], writtenDate: Date())
            }
            try! localRealm.write {
                localRealm.add(memo!)
            }
        }
    }
    
    func reviseMemo() {
        if !memoTextView.text.isEmpty {
            let separatedArray: [String] = memoTextView.text.components(separatedBy: "\n").filter{$0 != ""}

            if separatedArray.count < 2 {
                try! localRealm.write {
                    currentMemo?.totalContent = memoTextView.text
                    currentMemo?.memoTitle = separatedArray[0]
                    currentMemo?.memoContent = "추가 데이터 없음"
                    currentMemo?.writtenDate = Date()
                }
            } else {
                try! localRealm.write {
                    currentMemo?.totalContent = memoTextView.text
                    currentMemo?.memoTitle = separatedArray[0]
                    currentMemo?.memoContent = separatedArray[1]
                    currentMemo?.writtenDate = Date()
                }
            }
        } else {
            try! localRealm.write {
                localRealm.delete(currentMemo!)
            }
        }
    }
    
    func addBarButtonItem() {
        self.navigationItem.rightBarButtonItems = [ UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(doneButtonTapped)), UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareButtonTapped))]
    }
    
    @objc func doneButtonTapped() {
        memoTextView.resignFirstResponder()
        self.navigationItem.rightBarButtonItems = nil
    }
    
    @objc func shareButtonTapped() {
        
    }
}

extension DetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        addBarButtonItem()
    }
}
