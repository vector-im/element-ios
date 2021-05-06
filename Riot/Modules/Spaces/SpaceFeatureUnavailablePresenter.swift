// 
// Copyright 2021 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit

/// SpaceFeatureUnavailablePresenter enables to present modals for unavailable space features
@objcMembers
final class SpaceFeatureUnavailablePresenter: NSObject {
    
    // MARK: - Constants
    
    // MARK: - Properties
    
    private let webAppURL: URL
            
    // MARK: Private
    
    private weak var presentingViewController: UIViewController?
    
    // MARK: - Setup
    
    override init() {
        guard let webAppURL = URL(string: BuildSettings.applicationWebAppUrlString) else {
            fatalError("webAppURL is invalid")
        }
        self.webAppURL = webAppURL
        super.init()
    }
        
    // MARK: - Public
    
    func presentUnavailableFeature(with viewData: SpaceFeatureUnavailableViewData,
                                   from presentingViewController: UIViewController,
                                   animated: Bool) {
        
        let spaceFeatureUnavailableVC = SpaceFeatureUnaivableViewController.instantiate(with: viewData)
        
        let navigationVC = RiotNavigationController(rootViewController: spaceFeatureUnavailableVC)
        
        spaceFeatureUnavailableVC.navigationItem.rightBarButtonItem = MXKBarButtonItem(title: Bundle.mxk_localizedString(forKey: "ok"), style: .plain, action: { [weak navigationVC] in
            navigationVC?.dismiss(animated: true)
        })
                        
        navigationVC.modalPresentationStyle = .formSheet
        presentingViewController.present(navigationVC, animated: animated, completion: nil)
    }
    
    func presentInvitesUnavailable(from presentingViewController: UIViewController, animated: Bool) {
        let viewData = SpaceFeatureUnavailableViewData(informationText: VectorL10n.spaceFeatureUnavailableInviteInfo, shareLink: self.webAppURL)
        
        self.presentUnavailableFeature(with: viewData, from: presentingViewController, animated: animated)
    }
    
    func presentSpaceLinkUnavailable(with spaceLinkURL: URL, from presentingViewController: UIViewController, animated: Bool) {
        
        let viewData = SpaceFeatureUnavailableViewData(informationText: VectorL10n.spaceFeatureUnavailableSpaceLinkInfo, shareLink: spaceLinkURL)
        
        self.presentUnavailableFeature(with: viewData, from: presentingViewController, animated: animated)
    }
    
    func presentOpenSpaceUnavailable(from presentingViewController: UIViewController, animated: Bool) {
        let viewData = SpaceFeatureUnavailableViewData(informationText: VectorL10n.spaceFeatureUnavailableOpenSpace, shareLink: self.webAppURL)
        
        self.presentUnavailableFeature(with: viewData, from: presentingViewController, animated: animated)
    }
}