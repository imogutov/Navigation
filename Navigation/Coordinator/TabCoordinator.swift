
import UIKit

private enum LocalizedKeys: String {
    case feed = "feed"
    case profile = "profile"
    case creatingPost = "creatingPost"
}

enum TabBarPage {
    case feed
    case profile
    case createPost

    init?(index: Int) {
        switch index {
        case 0:
            self = .feed
        case 1:
            self = .profile
        case 2:
            self = .createPost
        default:
            return nil
        }
    }
    
    func pageTitleValue() -> String {
        switch self {
        case .feed:
            return ~LocalizedKeys.feed.rawValue
        case .profile:
            return ~LocalizedKeys.profile.rawValue
        case .createPost:
            return ~LocalizedKeys.creatingPost.rawValue
        }
    }

    func pageOrderNumber() -> Int {
        switch self {
        case .feed:
            return 0
        case .profile:
            return 1
        case .createPost:
            return 2
        }
    }
    
    func pageImageSystemName() -> String {
        switch self {
        case .feed:
            return "list.bullet.rectangle"
        case .profile:
            return "person.crop.rectangle"
        case .createPost:
            return "plus.rectangle"
        }
    }
}


protocol TabCoordinatorProtocol: Coordinator {
    var tabBarController: UITabBarController { get set }
    
    func selectPage(_ page: TabBarPage)
    
    func setSelectedIndex(_ index: Int)
    
    func currentPage() -> TabBarPage?
}

class TabCoordinator: NSObject, Coordinator {
    
    weak var finishDelegate: CoordinatorFinishDelegate?
        
    var childCoordinators: [Coordinator] = []

    var navigationController: UINavigationController
    
    var tabBarController: UITabBarController

    var type: CoordinatorType { .tab }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.tabBarController = .init()
    }

    func start() {
        let pages: [TabBarPage] = [ .profile, .feed, .createPost]
            .sorted(by: { $0.pageOrderNumber() < $1.pageOrderNumber() })
        
        let controllers: [UINavigationController] = pages.map({ getTabController($0) })
        
        prepareTabBarController(withTabControllers: controllers)
    }
    
    deinit {
        print("TabCoordinator deinit")
    }
    
    private func prepareTabBarController(withTabControllers tabControllers: [UIViewController]) {
        tabBarController.delegate = self
        tabBarController.setViewControllers(tabControllers, animated: true)
        tabBarController.selectedIndex = TabBarPage.feed.pageOrderNumber()
        tabBarController.tabBar.isTranslucent = false
        let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = tabBarController.tabBar.standardAppearance

        navigationController.viewControllers = [tabBarController]
    }
      
    private func getTabController(_ page: TabBarPage) -> UINavigationController {
        let navController = UINavigationController()
        navController.setNavigationBarHidden(false, animated: false)
        
        navController.tabBarItem = UITabBarItem.init(title: page.pageTitleValue(),
                                                     image: UIImage(systemName: page.pageImageSystemName()),
                                                     tag: page.pageOrderNumber())

        switch page {
        case .feed:
            // If needed: Each tab bar flow can have it's own Coordinator.
            let feedVC = FeedViewController()
                        
            navController.pushViewController(feedVC, animated: true)
        case .profile:
            let profileVC = ProfileViewController()
            profileVC.didSendEventClosure = { [weak self] event in
                switch event {
                case .logout:
                    self?.finish()
                case .createPost:
                    self?.selectPage(.createPost)
                }
            }
            navController.pushViewController(profileVC, animated: true)
        case .createPost:
            let createPostVC = CreatePostViewController()
            createPostVC.didSendEventClosure = { [weak self] event in
                switch event {
                case .creatingDone:
                    self?.selectPage(.profile)
                }
            }
            navController.pushViewController(createPostVC, animated: true)
        }
        
        return navController
    }
    
    func currentPage() -> TabBarPage? { TabBarPage.init(index: tabBarController.selectedIndex) }

    func selectPage(_ page: TabBarPage) {
        tabBarController.selectedIndex = page.pageOrderNumber()
    }
    
    func setSelectedIndex(_ index: Int) {
        guard let page = TabBarPage.init(index: index) else { return }
        
        tabBarController.selectedIndex = page.pageOrderNumber()
    }
}

// MARK: - UITabBarControllerDelegate
extension TabCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        // Some implementation
    }
}

