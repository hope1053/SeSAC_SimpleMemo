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
    
    var memos: Results<Memo>! {
        didSet {
            title = "\(memos?.count ?? 0)개의 메모"
            fixedMemo = memos.filter("isFixed == true")
            notFixedMemo = memos.filter("isFixed == false")
            numOfFixedMemo = fixedMemo?.count ?? 0
            print("fixed:", fixedMemo)
            print("notfixed:", notFixedMemo)
            print("numOfFixed:" ,numOfFixedMemo)
        }
    }
    var fixedMemo: Results<Memo>?
    var notFixedMemo: Results<Memo>?
    
    var numOfFixedMemo: Int = 0
    
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
        return numOfFixedMemo == memos.count ? 1 : numOfFixedMemo > 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if numOfFixedMemo == 0 || numOfFixedMemo == memos.count {
            return memos.count
        } else {
            return section == 0 ? numOfFixedMemo : memos.count - numOfFixedMemo
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if numOfFixedMemo == 0 {
            return nil
        } else if numOfFixedMemo == memos.count {
            return "고정된 메모"
        } else {
            return section == 0 ? "고정된 메모" : "메모"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemoTableViewCell.identifier, for: indexPath) as? MemoTableViewCell else {
            return UITableViewCell()
        }
        
        if numOfFixedMemo == 0 {
            let memo = memos?[indexPath.row]

            cell.backgroundColor = .white
            cell.titleLabel.text = memo?.memoTitle
            cell.contentLabel.text = memo?.memoContent
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd."
            cell.dateLabel.text = formatter.string(from: memo?.writtenDate ?? Date())
        } else {
            if indexPath.section == 0 {
                let memo = fixedMemo![indexPath.row]

                cell.backgroundColor = .white
                cell.titleLabel.text = memo.memoTitle
                cell.contentLabel.text = memo.memoContent
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy.MM.dd."
                cell.dateLabel.text = formatter.string(from: memo.writtenDate )
            } else {
                let memo = notFixedMemo![indexPath.row]

                cell.backgroundColor = .white
                cell.titleLabel.text = memo.memoTitle
                cell.contentLabel.text = memo.memoContent
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy.MM.dd."
                cell.dateLabel.text = formatter.string(from: memo.writtenDate )
            }
        }
        
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
            if self.numOfFixedMemo >= 5 {
                self.showAlert(title: "고정 메모는 5개까지만 가능합니다.", message: nil)
                return
            }
            var memo = Memo()
            if self.numOfFixedMemo > 0 {
                memo = indexPath.section == 0 ? self.fixedMemo![indexPath.row] : self.notFixedMemo![indexPath.row]
            } else {
                memo = self.memos[indexPath.row]
            }
            
            try! self.localRealm.write {
                memo.isFixed = !memo.isFixed
            }
            self.memos = self.localRealm.objects(Memo.self)
            self.memoTableView.reloadData()
        }
        
        if numOfFixedMemo == 0 {
            action.image = UIImage(systemName: "pin.fill")
        } else {
            if indexPath.section == 0 {
                action.image = UIImage(systemName: "pin.slash.fill")
            } else {
                action.image = UIImage(systemName: "pin.fill")
            }
        }

        action.backgroundColor = .orange
        
        let config = UISwipeActionsConfiguration(actions: [action])
        return config
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        header.textLabel?.textColor = UIColor.black
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if numOfFixedMemo > 0 {
            return UIScreen.main.bounds.height / 19
        } else {
            return 0
        }
    }
}

extension ViewController: UISearchBarDelegate {
    
}

