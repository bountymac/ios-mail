//
//  ModulusEndpoint.swift
//  ProtonCore-Authentication - Created on 09.12.2020.
//
//  Copyright (c) 2022 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import ProtonCore_Networking

extension AuthService {
    public struct ModulusEndpointResponse: Codable, Equatable {
        public let modulus: String
        public let modulusID: String
        public let code: Int
    }

    struct ModulusEndpoint: Request {
        var path: String {
            return "/auth/modulus"
        }
        var method: HTTPMethod {
            return .get
        }

        var isAuth: Bool {
            return false
        }
    }
}
