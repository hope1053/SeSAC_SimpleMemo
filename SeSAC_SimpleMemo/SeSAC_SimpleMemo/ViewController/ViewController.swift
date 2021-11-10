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
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            title = "\(numberFormatter.string(for: memos.count) ?? "0")개의 메모"
            
            fixedMemo = memos.filter("isFixed == true").sorted(byKeyPath: "writtenDate", ascending: false)
            notFixedMemo = memos.filter("isFixed == false").sorted(byKeyPath: "writtenDate", ascending: false)
            numOfFixedMemo = fixedMemo?.count ?? 0
        }
    }
    var fixedMemo: Results<Memo>?
    var notFixedMemo: Results<Memo>?
    var filteredMemo: Results<Memo>?
    
    var numOfFixedMemo: Int = 0
    
    var isFiltering: Bool {
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let doesSearchBarHasText = searchController?.searchBar.text?.isEmpty == false
        return isActive && doesSearchBarHasText
    }
    
    @IBOutlet var memoTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memos = localRealm.objects(Memo.self).sorted(byKeyPath: "writtenDate", ascending: false)
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
        
        print("Realm is located at:", localRealm.configuration.fileURL!)
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
        memoTableView.keyboardDismissMode = .onDrag
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "검색"
        searchController.searchResultsUpdater = self
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
        return self.isFiltering ? 1 : numOfFixedMemo == memos.count ? 1 : numOfFixedMemo > 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFiltering {
            return filteredMemo?.count ?? 0
        } else {
            if numOfFixedMemo == 0 || numOfFixedMemo == memos.count {
                return memos.count
            } else {
                return section == 0 ? numOfFixedMemo : memos.count - numOfFixedMemo
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.isFiltering {
            return "\(self.filteredMemo?.count ?? 0)개 찾음"
        } else {
            if numOfFixedMemo == 0 {
                return nil
            } else if numOfFixedMemo == memos.count {
                return "고정된 메모"
            } else {
                return section == 0 ? "고정된 메모" : "메모"
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemoTableViewCell.identifier, for: indexPath) as? MemoTableViewCell else {
            return UITableViewCell()
        }
        
        if self.isFiltering {
            
            let memo = filteredMemo?[indexPath.row]
            let title = memo!.memoTitle
            let content = memo!.memoContent ?? ""
            
            let changeColor = UIColor.orange
            let attributedTitleStr = NSMutableAttributedString(string: title)
            let attributedContentStr = NSMutableAttributedString(string: content)
            
            attributedTitleStr.addAttribute(.foregroundColor, value: changeColor, range: (title as NSString).range(of: self.navigationItem.searchController?.searchBar.text ?? ""))
            attributedContentStr.addAttribute(.foregroundColor, value: changeColor, range: (content as NSString).range(of: self.navigationItem.searchController?.searchBar.text ?? ""))

            cell.backgroundColor = .white
//            cell.titleLabel.text = memo?.memoTitle
//            cell.contentLabel.text = memo?.memoContent
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy.MM.dd."
            cell.titleLabel.attributedText = attributedTitleStr
            cell.contentLabel.attributedText = attributedContentStr
            cell.dateLabel.text = detectDate(memo!.writtenDate)
        } else {
            if numOfFixedMemo == 0 {
                let memo = memos[indexPath.row]

                cell.backgroundColor = .white
                cell.titleLabel.text = memo.memoTitle
                cell.contentLabel.text = memo.memoContent
    //            let formatter = DateFormatter()
    //            formatter.dateFormat = "yyyy.MM.dd."
                cell.dateLabel.text = detectDate(memo.writtenDate)
            } else {
                if indexPath.section == 0 {
                    let memo = fixedMemo![indexPath.row]

                    cell.backgroundColor = .white
                    cell.titleLabel.text = memo.memoTitle
                    cell.contentLabel.text = memo.memoContent
    //                let formatter = DateFormatter()
    //                formatter.dateFormat = "yyyy.MM.dd."
                    cell.dateLabel.text = detectDate(memo.writtenDate)
                } else {
                    let memo = notFixedMemo![indexPath.row]

                    cell.backgroundColor = .white
                    cell.titleLabel.text = memo.memoTitle
                    cell.contentLabel.text = memo.memoContent
    //                let formatter = DateFormatter()
    //                formatter.dateFormat = "yyyy.MM.dd."
                    cell.dateLabel.text = detectDate(memo.writtenDate)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        var memo = Memo()
        if self.numOfFixedMemo > 0 {
            memo = indexPath.section == 0 ? self.fixedMemo![indexPath.row] : self.notFixedMemo![indexPath.row]
        } else {
            memo = self.memos[indexPath.row]
        }
        
        vc.currentMemo = memo
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height / 14
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "delete") { action, view, completion in
            var memo = Memo()
            if self.numOfFixedMemo > 0 {
                memo = indexPath.section == 0 ? self.fixedMemo![indexPath.row] : self.notFixedMemo![indexPath.row]
            } else {
                memo = self.memos[indexPath.row]
            }
            
            let alertController = UIAlertController(title: "삭제하시겠습니까?", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "확인", style: .default) { _ in
                try! self.localRealm.write {
                    self.localRealm.delete(memo)
                }
                
                self.memos = self.localRealm.objects(Memo.self)
                self.memoTableView.reloadData()
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alertController.addAction(ok)
            alertController.addAction(cancel)
            
            self.present(alertController, animated: true, completion: nil)
        }
        action.image = UIImage(systemName: "trash.fill")
        
        let config = UISwipeActionsConfiguration(actions: [action])
        return config
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "fix") { action, view, completion in
            var memo = Memo()
            if self.numOfFixedMemo > 0 {
                memo = indexPath.section == 0 ? self.fixedMemo![indexPath.row] : self.notFixedMemo![indexPath.row]
            } else {
                memo = self.memos[indexPath.row]
            }
            
            if self.numOfFixedMemo >= 5 && memo.isFixed == false {
                self.showAlert(title: "고정 메모는 5개까지만 가능합니다.", message: nil)
                return
            }
            
            try! self.localRealm.write {
                memo.isFixed = !memo.isFixed
            }
            self.memos = self.localRealm.objects(Memo.self).sorted(byKeyPath: "writtenDate", ascending: false)
            print(self.memos)
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
        if self.isFiltering {
            return UIScreen.main.bounds.height / 19
        } else {
            if numOfFixedMemo > 0 {
                return UIScreen.main.bounds.height / 19
            } else {
                return 0
            }
        }
    }
    
    func detectDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "a hh:mm"
        } else if Calendar.current.isDayInCurrentWeek(date: date)! {
            formatter.dateFormat = "EEEE"
        } else {
            formatter.dateFormat = "yyyy. MM. dd a hh:mm"
        }
        
        return formatter.string(from: date)
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {return}
        self.filteredMemo = self.memos.filter("totalContent CONTAINS[c] '\(text)'")
        self.memoTableView.reloadData()
    }
}

