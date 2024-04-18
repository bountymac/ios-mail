//
//  KeychainWrapper.swift
//  Proton Mail - Created on 7/17/17.
//
//
//  Copyright (c) 2019 Proton AG
//
//  This file is part of Proton Mail.
//
//  Proton Mail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Proton Mail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Proton Mail.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import ProtonCoreKeymaker

final class KeychainWrapper: Keychain {

    static let keychain = KeychainWrapper()

    init() {
        let prefix = "2SB5Z68H26."
        let group = prefix + "ch.protonmail.protonmail"
        let service = "ch.protonmail"

        super.init(service: service, accessGroup: group)
    }

    override init(service: String, accessGroup: String, secItemMethodsProvider: SecItemMethodsProvider? = nil) {
        super.init(service: service, accessGroup: accessGroup)
    }
}
