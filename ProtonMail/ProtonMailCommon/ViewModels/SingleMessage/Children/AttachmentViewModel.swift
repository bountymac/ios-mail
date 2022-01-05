//
//  AttachmentViewModel.swift
//  ProtonMail
//
//
//  Copyright (c) 2021 Proton Technologies AG
//
//  This file is part of ProtonMail.
//
//  ProtonMail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonMail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonMail.  If not, see <https://www.gnu.org/licenses/>.

import Foundation

class AttachmentViewModel {
    private(set) var attachments: [AttachmentInfo] = [] {
        didSet {
            reloadView?()
        }
    }
    var reloadView: (() -> Void)?

    var numberOfAttachments: Int {
        return attachments.count
    }

    var totalSizeOfAllAttachments: Int {
        let attachmentSizes = attachments.map({ $0.size })
        let totalSize = attachmentSizes.reduce(0) { result, value -> Int in
            return result + value
        }
        return totalSize
    }

    init (attachments: [AttachmentInfo]) {
        self.attachments = attachments.filter { ($0.att?.inline() ?? false) == false }
    }

    func messageHasChanged(message: Message) {
        let files: [AttachmentInfo] = message.attachments
            .compactMap { $0 as? Attachment }
            .map(AttachmentNormal.init) + (message.tempAtts ?? [])
        self.attachments = files.filter { $0.att?.inline() == false }
    }
}
