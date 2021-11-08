//
//  MemoTableViewCell.swift
//  SeSAC_SimpleMemo
//
//  Created by 최혜린 on 2021/11/08.
//

import UIKit

class MemoTableViewCell: UITableViewCell {

    static let identifier = "MemoTableViewCell"
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
