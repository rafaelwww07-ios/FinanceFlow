//
//  FinanceFlowWidgetBundle.swift
//  FinanceFlowWidget
//
//  Created by Rafael Mukhametov on 26.11.2025.
//

import WidgetKit
import SwiftUI

@main
struct FinanceFlowWidgetBundle: WidgetBundle {
    var body: some Widget {
        FinanceFlowWidget()
        FinanceFlowWidgetControl()
        FinanceFlowWidgetLiveActivity()
    }
}
