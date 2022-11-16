//
//  DashboardTile.swift
//  Zenda
//
//  Created by Simon Fortelny on 5/12/21.
//

import Foundation

enum DashboardTileState {
    case normal, warning, error
}

struct DashboardTile {
    let title, subtitle: String
    let displayBalance: String
    let icon: String
    let state: DashboardTileState
}
