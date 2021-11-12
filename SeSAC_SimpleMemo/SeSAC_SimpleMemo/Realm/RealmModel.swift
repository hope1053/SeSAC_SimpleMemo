//
//  RealmModel.swift
//  SeSAC_SimpleMemo
//
//  Created by 최혜린 on 2021/11/08.
//

import Foundation
import RealmSwift

class Memo: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var isFixed: Bool // 고정 여부(필수)
    @Persisted var memoTitle: String // 제목(필수)
    @Persisted var memoContent: String // 내용(필수)
    @Persisted var totalContent: String // 제목 + 내용(필수)
    @Persisted var writtenDate = Date() // 날짜(필수)
    
    convenience init(totalContent: String, memoTitle: String, memoContent: String, writtenDate: Date) {
        self.init()
        
        self.isFixed = false
        self.totalContent = totalContent
        self.memoTitle = memoTitle
        self.memoContent = memoContent
        self.writtenDate = writtenDate
    }
}
