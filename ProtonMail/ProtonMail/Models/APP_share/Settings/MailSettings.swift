// Copyright (c) 2023 Proton Technologies AG
//
// This file is part of Proton Mail.
//
// Proton Mail is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Mail is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Mail. If not, see https://www.gnu.org/licenses/.

import ProtonCore_DataModel

struct MailSettings: Parsable, Equatable {
    private(set) var nextMessageOnMove: NextMessageOnMove
    private(set) var hideSenderImages: Bool
    private(set) var showMoved: ShowMoved

    enum CodingKeys: String, CodingKey {
        case nextMessageOnMove = "NextMessageOnMove"
        case hideSenderImages = "HideSenderImages"
        case showMoved = "ShowMoved"
    }

    init(
        nextMessageOnMove: NextMessageOnMove = DefaultValue.nextMessageOnMove,
        hideSenderImages: Bool = DefaultValue.hideSenderImages,
        showMoved: ShowMoved = DefaultValue.showMoved
    ) {
        self.nextMessageOnMove = nextMessageOnMove
        self.hideSenderImages = hideSenderImages
        self.showMoved = showMoved
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nextMessageOnMoveValue = try container.decodeIfPresent(Int.self, forKey: .nextMessageOnMove)
        nextMessageOnMove = NextMessageOnMove(rawValue: nextMessageOnMoveValue)
        hideSenderImages = container.decodeIfPresentBoolOrIntToBool(
            forKey: .hideSenderImages,
            defaultValue: DefaultValue.hideSenderImages
        )
        let showMovedValue = try container.decodeIfPresent(Int.self, forKey: .showMoved)
        showMoved = ShowMoved(rawValue: showMovedValue)
    }

    mutating func update(key: CodingKeys, to newValue: Bool) {
        switch key {
        case .nextMessageOnMove:
            nextMessageOnMove = newValue ? .explicitlyEnabled : .explicitlyDisabled
        case .hideSenderImages:
            hideSenderImages = newValue
        case .showMoved:
            assertionFailure("Not suitable for this key")
        }
    }

    struct DefaultValue {
        static let nextMessageOnMove = NextMessageOnMove.implicitlyDisabled
        static let hideSenderImages = false
        static let showMoved = ShowMoved.doNotKeep
    }
}

// sourcery: mock
protocol MailSettingsHandler: AnyObject {
    var mailSettings: MailSettings { get set }
    var userInfo: UserInfo { get }
}

extension UserManager: MailSettingsHandler {}
