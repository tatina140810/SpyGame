import Foundation
import MultipeerConnectivity
import UIKit

// MARK: - Models

struct PlayerRole: Codable {
    let isSpy: Bool
    /// `nil` for spies — spies don't see the shared word.
    let word: String?
    let playerNumber: Int
    let totalPlayers: Int
    let spyCount: Int
}

struct GameConfig: Codable {
    let timerDuration: Int
    let totalPlayers: Int
}

/// Sent from host to each guest at game start — bundles role and config in one message.
struct GameStartPayload: Codable {
    let role: PlayerRole
    let config: GameConfig
}

enum MessageType: String, Codable {
    case gameStart
    case playerReady
    case allReadyStartTimer
    case hostLeft
}

struct GameMessage: Codable {
    let type: MessageType
    let payload: Data?
}

enum ConnectionState {
    case idle
    case hosting
    case browsing
    case connected
}

// MARK: - Delegate

protocol MultiplayerSessionDelegate: AnyObject {
    func session(_ session: MultiplayerSession, didChangePeers peers: [MCPeerID])
    func session(_ session: MultiplayerSession, didChangeState state: ConnectionState)
    func session(_ session: MultiplayerSession, didDiscoverPeer peer: MCPeerID, roomCode: String?)
    func session(_ session: MultiplayerSession, didLosePeer peer: MCPeerID)
    func session(_ session: MultiplayerSession, didReceiveGameStart role: PlayerRole, config: GameConfig)
    func session(_ session: MultiplayerSession, didReceivePlayerReady peer: MCPeerID)
    func sessionDidReceiveAllReady(_ session: MultiplayerSession)
    func sessionHostDidLeave(_ session: MultiplayerSession)
    func session(_ session: MultiplayerSession, didFailWith error: Error)
}

/// Default no-op implementations so each VC only overrides what it cares about.
extension MultiplayerSessionDelegate {
    func session(_ session: MultiplayerSession, didChangePeers peers: [MCPeerID]) {}
    func session(_ session: MultiplayerSession, didChangeState state: ConnectionState) {}
    func session(_ session: MultiplayerSession, didDiscoverPeer peer: MCPeerID, roomCode: String?) {}
    func session(_ session: MultiplayerSession, didLosePeer peer: MCPeerID) {}
    func session(_ session: MultiplayerSession, didReceiveGameStart role: PlayerRole, config: GameConfig) {}
    func session(_ session: MultiplayerSession, didReceivePlayerReady peer: MCPeerID) {}
    func sessionDidReceiveAllReady(_ session: MultiplayerSession) {}
    func sessionHostDidLeave(_ session: MultiplayerSession) {}
    func session(_ session: MultiplayerSession, didFailWith error: Error) {}
}

// MARK: - Session

final class MultiplayerSession: NSObject {
    static let shared = MultiplayerSession()

    /// Must match `NSBonjourServices` entries in Info.plist (`_spyhunt-v1._tcp/_udp`).
    static let serviceType = "spyhunt-v1"
    private static let discoveryRoomKey = "room"

    let myPeerID: MCPeerID
    private(set) var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    private(set) var connectedPeers: [MCPeerID] = []
    private(set) var connectionState: ConnectionState = .idle
    private(set) var hostingRoomCode: String?

    /// Maximum number of guests the host accepts. Defaults to .max.
    /// Set this from the host UI before calling `startHosting(roomCode:)`.
    var maxAllowedPeers: Int = .max

    weak var delegate: MultiplayerSessionDelegate?

    override init() {
        let deviceName = UIDevice.current.name
        let safeName = deviceName.isEmpty ? "iPhone" : deviceName
        self.myPeerID = MCPeerID(displayName: safeName)
        super.init()
        self.session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        self.session.delegate = self
    }

    // MARK: - Host

    func startHosting(roomCode: String) {
        stopBrowsing()
        hostingRoomCode = roomCode
        let info = [Self.discoveryRoomKey: roomCode]
        let adv = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: info, serviceType: Self.serviceType)
        adv.delegate = self
        adv.startAdvertisingPeer()
        advertiser = adv
        updateState(.hosting)
    }

    func stopHosting() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
        hostingRoomCode = nil
        if connectionState == .hosting {
            updateState(.idle)
        }
    }

    /// Sends each peer their personalised role + the shared game config.
    /// The host's own role is NOT in `roles` — host keeps it locally.
    func sendGameStartToAll(roles: [MCPeerID: PlayerRole], config: GameConfig) {
        for (peer, role) in roles {
            let payload = GameStartPayload(role: role, config: config)
            send(.gameStart, payload: payload, to: [peer])
        }
    }

    /// Tells all connected guests to push the timer screen — host calls when every player tapped Ready.
    func sendAllReadyStartTimer() {
        sendEncoded(.allReadyStartTimer, payload: nil, to: connectedPeers)
    }

    // MARK: - Guest

    func startBrowsing() {
        stopHosting()
        let b = MCNearbyServiceBrowser(peer: myPeerID, serviceType: Self.serviceType)
        b.delegate = self
        b.startBrowsingForPeers()
        browser = b
        updateState(.browsing)
    }

    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
        if connectionState == .browsing {
            updateState(.idle)
        }
    }

    /// Caller picks a peer whose discovered room code equals `roomCode`. The code is also
    /// sent as `context` so the host can double-check on its side.
    func connect(to peer: MCPeerID, roomCode: String) {
        let context = roomCode.data(using: .utf8)
        browser?.invitePeer(peer, to: session, withContext: context, timeout: 30)
    }

    /// Guest tells the host "I've seen my role".
    func sendPlayerReady() {
        sendEncoded(.playerReady, payload: nil, to: connectedPeers)
    }

    // MARK: - Shared

    func disconnect() {
        // We're the host iff we have an active room code — `connectionState` flips to
        // `.connected` as soon as a guest joins, so we can't rely on it here.
        let amHost = hostingRoomCode != nil
        if amHost && !connectedPeers.isEmpty {
            sendEncoded(.hostLeft, payload: nil, to: connectedPeers)
            // Give MultipeerConnectivity ~0.3 s to flush the .hostLeft packet over the
            // wire before we tear down the session — otherwise guests never receive it
            // and stay stuck on the timer screen.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.tearDownSession()
            }
        } else {
            tearDownSession()
        }
    }

    private func tearDownSession() {
        session.disconnect()
        stopHosting()
        stopBrowsing()
        connectedPeers.removeAll()
        updateState(.idle)
    }

    // MARK: - Private helpers

    private func updateState(_ state: ConnectionState) {
        connectionState = state
        DispatchQueue.main.async {
            self.delegate?.session(self, didChangeState: state)
        }
    }

    private func send<T: Encodable>(_ type: MessageType, payload: T, to peers: [MCPeerID]) {
        let data = try? JSONEncoder().encode(payload)
        sendEncoded(type, payload: data, to: peers)
    }

    private func sendEncoded(_ type: MessageType, payload: Data?, to peers: [MCPeerID]) {
        guard !peers.isEmpty else { return }
        do {
            let envelope = GameMessage(type: type, payload: payload)
            let data = try JSONEncoder().encode(envelope)
            try session.send(data, toPeers: peers, with: .reliable)
        } catch {
            #if DEBUG
            print("[Multiplayer] send failed: \(error)")
            #endif
            DispatchQueue.main.async {
                self.delegate?.session(self, didFailWith: error)
            }
        }
    }

    private func decodePayload<T: Decodable>(_ envelope: GameMessage, as type: T.Type) -> T? {
        guard let data = envelope.payload else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - Static helpers

extension MultiplayerSession {
    static func generateRoomCode() -> String {
        String(format: "%04d", Int.random(in: 0...9999))
    }
}

// MARK: - MCSessionDelegate

extension MultiplayerSession: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                }
                self.updateState(.connected)
            case .notConnected:
                self.connectedPeers.removeAll { $0 == peerID }
                if self.connectedPeers.isEmpty {
                    // Drop back to whatever surface state matches our role.
                    if self.advertiser != nil { self.updateState(.hosting) }
                    else if self.browser != nil { self.updateState(.browsing) }
                    else { self.updateState(.idle) }
                }
            case .connecting:
                break
            @unknown default:
                break
            }
            self.delegate?.session(self, didChangePeers: self.connectedPeers)
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let envelope = try? JSONDecoder().decode(GameMessage.self, from: data) else { return }
        DispatchQueue.main.async {
            switch envelope.type {
            case .gameStart:
                guard let payload = self.decodePayload(envelope, as: GameStartPayload.self) else { return }
                self.delegate?.session(self, didReceiveGameStart: payload.role, config: payload.config)
            case .playerReady:
                self.delegate?.session(self, didReceivePlayerReady: peerID)
            case .allReadyStartTimer:
                self.delegate?.sessionDidReceiveAllReady(self)
            case .hostLeft:
                self.delegate?.sessionHostDidLeave(self)
            }
        }
    }

    // Streams / resources are unused — required by protocol.
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension MultiplayerSession: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Accept only if (a) the guest sent our room code as context, AND
        // (b) we still have a free slot under maxAllowedPeers.
        let invitedCode = context.flatMap { String(data: $0, encoding: .utf8) }
        let codeMatches = hostingRoomCode != nil && invitedCode == hostingRoomCode
        let underLimit = connectedPeers.count < maxAllowedPeers
        invitationHandler(codeMatches && underLimit, codeMatches && underLimit ? session : nil)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        DispatchQueue.main.async {
            self.delegate?.session(self, didFailWith: error)
        }
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MultiplayerSession: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        let roomCode = info?[Self.discoveryRoomKey]
        DispatchQueue.main.async {
            self.delegate?.session(self, didDiscoverPeer: peerID, roomCode: roomCode)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.delegate?.session(self, didLosePeer: peerID)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        DispatchQueue.main.async {
            self.delegate?.session(self, didFailWith: error)
        }
    }
}

// MARK: - Navigation helper

extension UIViewController {
    /// Truncates the navigation stack to end at `self`, then appends `tail`.
    /// Used to start a new multiplayer round without rebuilding the lobby — keeps the
    /// HostRoom / GuestRoom in the stack and replaces only the per-round screens.
    func multiplayerResetStack(to tail: [UIViewController], animated: Bool) {
        guard let nav = navigationController else { return }
        guard let idx = nav.viewControllers.firstIndex(of: self) else { return }
        let base = Array(nav.viewControllers.prefix(through: idx))
        nav.setViewControllers(base + tail, animated: animated)
    }
}
