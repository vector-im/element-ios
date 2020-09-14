// File created from ScreenTemplate
// $ createScreen.sh Modal2/RoomCreation RoomCreationEventsModal
/*
 Copyright 2020 New Vector Ltd
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

final class RoomCreationEventsModalViewModel: RoomCreationEventsModalViewModelType {
    
    // MARK: - Properties
    
    // MARK: Private

    private let session: MXSession
    private let bubbleData: MXKRoomBubbleCellDataStoring
    private let roomState: MXRoomState
    private var currentOperation: MXHTTPOperation?
    private lazy var eventFormatter: EventFormatter = {
        return EventFormatter(matrixSession: self.session)
    }()
    private var events: [MXEvent] = []
    
    // MARK: Public

    weak var viewDelegate: RoomCreationEventsModalViewModelViewDelegate?
    weak var coordinatorDelegate: RoomCreationEventsModalViewModelCoordinatorDelegate?
    
    var numberOfRows: Int {
        return events.count
    }
    func rowViewModel(at indexPath: IndexPath) -> RoomCreationEventRowViewModel? {
        let event = events[indexPath.row]
        let formatterError = UnsafeMutablePointer<MXKEventFormatterError>.allocate(capacity: 1)
        return RoomCreationEventRowViewModel(title: eventFormatter.attributedString(from: event, with: roomState, error: formatterError))
    }
    var roomName: String? {
        if let name = roomState.name, name.count > 0 {
            return name
        }
        if let aliases = roomState.aliases, aliases.count > 0 {
            return aliases.first
        }
        return nil
    }
    var roomInfo: String? {
        guard let creationEvent = events.first(where: { $0.eventType == .roomCreate }) else {
            return nil
        }
        let timestamp = creationEvent.originServerTs
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp/1000))
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    func setAvatar(in avatarImageView: MXKImageView) {
        let avatarImage = AvatarGenerator.generateAvatar(forMatrixItem: roomState.roomId, withDisplayName: roomName)
        
        if let avatarUrl = roomState.avatar {
            avatarImageView.enableInMemoryCache = true

            avatarImageView.setImageURI(avatarUrl,
                                        withType: nil,
                                        andImageOrientation: .up,
                                        toFitViewSize: avatarImageView.frame.size,
                                        with: MXThumbnailingMethodCrop,
                                        previewImage: avatarImage,
                                        mediaManager: session.mediaManager)
        } else {
            avatarImageView.image = avatarImage
        }
    }
    
    // MARK: - Setup
    
    init(session: MXSession, bubbleData: MXKRoomBubbleCellDataStoring, roomState: MXRoomState) {
        self.session = session
        self.bubbleData = bubbleData
        self.roomState = roomState
        
        //  shape-up events
        events.append(contentsOf: bubbleData.events)
        var nextBubbleData = bubbleData.nextCollapsableCellData
        while nextBubbleData != nil {
            events.append(contentsOf: nextBubbleData!.events)
            nextBubbleData = nextBubbleData?.nextCollapsableCellData
        }
    }
    
    deinit {
        self.cancelOperations()
    }
    
    // MARK: - Public
    
    func process(viewAction: RoomCreationEventsModalViewAction) {
        switch viewAction {
        case .loadData:
            self.loadData()
        case .close:
            self.coordinatorDelegate?.roomCreationEventsModalViewModelDidTapClose(self)
        case .cancel:
            self.cancelOperations()
        }
    }
    
    // MARK: - Private
    
    private func loadData() {

        self.update(viewState: .loading)

    }
    
    private func update(viewState: RoomCreationEventsModalViewState) {
        self.viewDelegate?.roomCreationEventsModalViewModel(self, didUpdateViewState: viewState)
    }
    
    private func cancelOperations() {
        self.currentOperation?.cancel()
    }
}