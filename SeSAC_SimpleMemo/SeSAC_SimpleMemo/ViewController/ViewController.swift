//
//  ViewController.swift
//  SeSAC_SimpleMemo
//
//  Created by 최혜린 on 2021/11/08.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {

    let localRealm = try! Realm()
    var memos: Results<Memo>? {
        didSet {
            title = "\(memos?.count ?? 0)개의 메모"
        }
    }
    
    @IBOutlet var memoTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memos = localRealm.objects(Memo.self)
        memoTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoTableView.delegate = self
        memoTableView.dataSource = self
        
        let nibName = UINib(nibName: MemoTableViewCell.identifier, bundle: nil)
        memoTableView.register(nibName, forCellReuseIdentifier: MemoTableViewCell.identifier)
        detectFirstLaunch()
        updateUI()
    }
    
    func detectFirstLaunch() {
        let isFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunch")
        if !isFirstLaunch {
            UserDefaults.standard.set(true, forKey: "isFirstLaunch")
            showAlert(title:
                        """
                      처음 오셨군요!
                      환영합니다 :)
                      
                      당신만의 메모를 작성하고
                      관리해보세요!
                      """)
        }
    }

    func updateUI() {
        view.backgroundColor = .systemGray6
        memoTableView.backgroundColor = .clear
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "검색"
        self.navigationItem.searchController = searchController
    }
    
    @IBAction func writeMemoTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return memos?.filter("isFixed == true").count ?? 0 > 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memos?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemoTableViewCell.identifier, for: indexPath) as? MemoTableViewCell else {
            return UITableViewCell()
        }
        
        let memo = memos?[indexPath.row]
        
        cell.backgroundColor = .white
        cell.titleLabel.text = memo?.memoTitle
        cell.contentLabel.text = memo?.memoContent
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd."
        cell.dateLabel.text = formatter.string(from: memo?.writtenDate ?? Date())
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.currentMemo = memos![indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height / 14
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "delete") { action, view, completion in
            try! self.localRealm.write {
                self.localRealm.delete(self.memos![indexPath.row])
                self.memoTableView.reloadData()
            }
        }
        action.image = UIImage(systemName: "trash.fill")
        
        let config = UISwipeActionsConfiguration(actions: [action])
        return config
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "fix") { action, view, completion in
            print("slide!!")
        }
        action.image = UIImage(systemName: "pin.fill")
        action.backgroundColor = .orange
        
        let config = UISwipeActionsConfiguration(actions: [action])
        return config
    }
}

extension ViewController: UISearchBarDelegate {
    
}

