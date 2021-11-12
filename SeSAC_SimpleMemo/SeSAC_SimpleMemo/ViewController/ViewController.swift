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
            updateTitle(memos.count)
            
            fixedMemo = memos.filter("isFixed == true").sorted(byKeyPath: "writtenDate", ascending: false)
            notFixedMemo = memos.filter("isFixed == false").sorted(byKeyPath: "writtenDate", ascending: false)
            numOfFixedMemo = fixedMemo?.count ?? 0
        }
    }
    
    var isFiltering: Bool {
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let doesSearchBarHasText = searchController?.searchBar.text?.isEmpty == false
        return isActive && doesSearchBarHasText
    }
    
    var fixedMemo: Results<Memo>?
    var notFixedMemo: Results<Memo>?
    var numOfFixedMemo: Int = 0
    var filteredMemo: Results<Memo>?
    
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
        
        detectFirstLaunch()
        
        let nibName = UINib(nibName: MemoTableViewCell.identifier, bundle: nil)
        memoTableView.register(nibName, forCellReuseIdentifier: MemoTableViewCell.identifier)
        updateUI()
    }
    
    func updateTitle(_ numOfMemo: Int?) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        title = "\(numberFormatter.string(for: numOfMemo) ?? "0")개의 메모"
    }
    
    func detectFirstLaunch() {
        let isFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunch")
        if !isFirstLaunch {
            UserDefaults.standard.set(true, forKey: "isFirstLaunch")
            
            let storyboard = UIStoryboard(name: "Walkthrough", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "WalkThroughViewController") as! WalkThroughViewController
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
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
    
    // 날짜 format 변경
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
    
    // 새 메모 작성
    @IBAction func writeNewMemoTapped(_ sender: UIBarButtonItem) {
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
        // 검색 중 일 때 tableView update
        if self.isFiltering {
            let memo = filteredMemo?[indexPath.row]
            let title = memo!.memoTitle
            let content = memo!.memoContent
            let searchKeyword = self.navigationItem.searchController?.searchBar.text ?? ""
            
            let changeColor = UIColor.orange
            let attributedTitleStr = NSMutableAttributedString(string: title)
            let attributedContentStr = NSMutableAttributedString(string: content)
            
            attributedTitleStr.addAttribute(.foregroundColor, value: changeColor, range: (title as NSString).range(of: searchKeyword))
            attributedContentStr.addAttribute(.foregroundColor, value: changeColor, range: (content as NSString).range(of: searchKeyword))

            cell.titleLabel.attributedText = attributedTitleStr
            cell.contentLabel.attributedText = attributedContentStr
            cell.dateLabel.text = detectDate(memo!.writtenDate)
            
        // 검색하지 않을 때 tableView update
        } else {
            var memo: Memo = Memo()
            if numOfFixedMemo == 0 {
                memo = memos[indexPath.row]
            } else {
                if indexPath.section == 0 {
                    memo = fixedMemo![indexPath.row]
                } else {
                    memo = notFixedMemo![indexPath.row]
                }
            }
            
            cell.titleLabel.text = memo.memoTitle
            cell.contentLabel.text = memo.memoContent
            cell.dateLabel.text = detectDate(memo.writtenDate)
        }
        
        cell.backgroundColor = .white
        
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
            let ok = UIAlertAction(title: "확인", style: .destructive) { _ in
                try! self.localRealm.write {
                    self.localRealm.delete(memo)
                }
                
                self.memos = self.localRealm.objects(Memo.self)
                self.memoTableView.reloadData()
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in
                self.memoTableView.setEditing(false, animated: true)
            }
            
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
                self.showAlert(title: "고정 메모는 5개까지만 가능합니다.", message: nil) { _ in
                    self.memoTableView.setEditing(false, animated: true)
                }
                return
            }
            
            try! self.localRealm.write {
                memo.isFixed = !memo.isFixed
            }
            self.memos = self.localRealm.objects(Memo.self).sorted(byKeyPath: "writtenDate", ascending: false)
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
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {return}
        self.filteredMemo = self.memos.filter("totalContent CONTAINS[c] '\(text)'").sorted(byKeyPath: "writtenDate", ascending: false)
        self.memoTableView.reloadData()
    }
}

