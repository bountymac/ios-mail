import SafariServices

protocol ConversationCoordinatorProtocol: AnyObject {
    var viewController: ConversationViewController? { get set }
    var conversation: Conversation { get }
    var pendingActionAfterDismissal: (() -> Void)? { get set }

    func start(openFromNotification: Bool)
    func handle(navigationAction: ConversationNavigationAction)
}

class ConversationCoordinator: CoordinatorDismissalObserver, ConversationCoordinatorProtocol {

    weak var viewController: ConversationViewController?

    private let labelId: String
    private let navigationController: UINavigationController
    let conversation: Conversation
    private let user: UserManager
    private let targetID: String?
    private let internetStatusProvider: InternetConnectionStatusProvider
    var pendingActionAfterDismissal: (() -> Void)?

    init(labelId: String,
         navigationController: UINavigationController,
         conversation: Conversation,
         user: UserManager,
         internetStatusProvider: InternetConnectionStatusProvider,
         targetID: String? = nil) {
        self.labelId = labelId
        self.navigationController = navigationController
        self.conversation = conversation
        self.user = user
        self.targetID = targetID
        self.internetStatusProvider = internetStatusProvider
    }

    func start(openFromNotification: Bool = false) {
        let viewModel = ConversationViewModel(
            labelId: labelId,
            conversation: conversation,
            user: user,
            openFromNotification: openFromNotification,
            contextProvider: CoreDataService.shared,
            internetStatusProvider: internetStatusProvider,
            isDarkModeEnableClosure: { [weak self] in
                if #available(iOS 12.0, *) {
                    return self?.viewController?.traitCollection.userInterfaceStyle == .dark
                } else {
                    return false
                }
            },
            targetID: targetID
        )
        let viewController = ConversationViewController(coordinator: self, viewModel: viewModel)
        self.viewController = viewController
        navigationController.pushViewController(viewController, animated: true)
    }

    func handle(navigationAction: ConversationNavigationAction) {
        switch navigationAction {
        case .reply(let message):
            presentCompose(message: message, action: .reply)
        case .draft(let message):
            presentCompose(message: message, action: .openDraft)
        case .addContact(let contact):
            presentAddContacts(with: contact)
        case .composeTo(let contact):
            presentCompose(with: contact)
        case let .attachmentList(message, inlineCIDs):
            presentAttachmentListView(message: message, inlineCIDS: inlineCIDs)
        case .mailToUrl(let url):
            presentCompose(with: url)
        case .replyAll(let message):
            presentCompose(message: message, action: .replyAll)
        case .forward(let message):
            presentCompose(message: message, action: .forward)
        case .viewHeaders(url: let url):
            presentQuickLookView(url: url, subType: .headers)
        case .viewHTML(url: let url):
            presentQuickLookView(url: url, subType: .html)
        case .viewCypher(url: let url):
            presentQuickLookView(url: url, subType: .cypher)
        case .addNewFolder:
            presentCreateFolder(type: .folder)
        case .addNewLabel:
            presentCreateFolder(type: .label)
        case .url(let url):
            presentWebView(url: url)
        case .inAppSafari(let url):
            presentInAppSafari(url: url)
        }
    }

    // MARK: - Private methods

    private func presentCreateFolder(type: PMLabelType) {
        let coreDataService = sharedServices.get(by: CoreDataService.self)
        let folderLabels = user.labelService.getMenuFolderLabels(context: coreDataService.mainContext)
        let viewModel = LabelEditViewModel(user: user, label: nil, type: type, labels: folderLabels)
        let viewController = LabelEditViewController.instance()
        let coordinator = LabelEditCoordinator(services: sharedServices,
                                               viewController: viewController,
                                               viewModel: viewModel,
                                               coordinatorDismissalObserver: self)
        coordinator.start()
        if let navigation = viewController.navigationController {
            self.viewController?.navigationController?.present(navigation, animated: true, completion: nil)
        }
    }

    private func presentQuickLookView(url: URL?, subType: PlainTextViewerViewController.ViewerSubType) {
        guard let fileUrl = url, let text = try? String(contentsOf: fileUrl) else { return }
        let viewer = PlainTextViewerViewController(text: text, subType: subType)
        try? FileManager.default.removeItem(at: fileUrl)
        self.navigationController.pushViewController(viewer, animated: true)
    }

    private func presentCompose(with contact: ContactVO) {
        let viewModel = ContainableComposeViewModel(
            msg: nil,
            action: .newDraft,
            msgService: user.messageService,
            user: user,
            coreDataContextProvider: sharedServices.get(by: CoreDataService.self)
        )
        viewModel.addToContacts(contact)

        presentCompose(viewModel: viewModel)
    }

    private func presentCompose(with mailToURL: URL) {
        let viewModel = ContainableComposeViewModel(
            msg: nil,
            action: .newDraft,
            msgService: user.messageService,
            user: user,
            coreDataContextProvider: sharedServices.get(by: CoreDataService.self)
        )
        viewModel.parse(mailToURL: mailToURL)

        presentCompose(viewModel: viewModel)
    }

    private func presentCompose(message: Message, action: ComposeMessageAction) {
        let viewModel = ContainableComposeViewModel(
            msg: message,
            action: action,
            msgService: user.messageService,
            user: user,
            coreDataContextProvider: sharedServices.get(by: CoreDataService.self)
        )

        presentCompose(viewModel: viewModel)
    }

    private func presentCompose(viewModel: ContainableComposeViewModel) {
        let coordinator = ComposeContainerViewCoordinator(presentingViewController: self.viewController,
                                                          editorViewModel: viewModel)
        coordinator.start()
    }

    private func presentAddContacts(with contact: ContactVO) {
        let board = UIStoryboard.Storyboard.contact.storyboard
        guard let destination = board.instantiateViewController(
                withIdentifier: "UINavigationController-d3P-H0-xNt") as? UINavigationController,
              let viewController = destination.viewControllers.first as? ContactEditViewController else {
            return
        }
        sharedVMService.contactAddViewModel(viewController, user: user, contactVO: contact)
        self.viewController?.present(destination, animated: true)
    }

    private func presentAttachmentListView(message: Message, inlineCIDS: [String]?) {
        let attachments: [AttachmentInfo] = message.attachments.compactMap { $0 as? Attachment }
            .map(AttachmentNormal.init) + (message.tempAtts ?? [])

        let viewModel = AttachmentListViewModel(attachments: attachments,
                                                user: user,
                                                inlineCIDS: inlineCIDS)
        let viewController = AttachmentListViewController(viewModel: viewModel)
        self.navigationController.pushViewController(viewController, animated: true)
    }

    private func presentWebView(url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url,
                                      options: [:],
                                      completionHandler: nil)
        }
    }

    private func presentInAppSafari(url: URL) {
        let safari = SFSafariViewController(url: url)
        self.viewController?.present(safari, animated: true, completion: nil)
    }
}

extension SingleMessageNavigationAction {

    var composeAction: ComposeMessageAction? {
        switch self {
        case .reply:
            return .reply
        case .replyAll:
            return .replyAll
        case .forward:
            return .forward
        default:
            return nil
        }
    }

}
