//
//  CalendarHostingController.swift
//  MedKit
//
//  Created by Ritwik Dev on 13/07/26.
//

import UIKit
import SwiftUI

class CalendarHostingController: UIHostingController<AnyView> {
    var pageDate: Date
    
    init(rootView: AnyView, pageDate: Date) {
        self.pageDate = pageDate
        super.init(rootView: rootView)
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}