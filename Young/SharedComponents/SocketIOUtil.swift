import UIKit
import Foundation
import SocketIO

class SocketIOUtil {
    
    static var shared = SocketIOUtil()
    weak var socketIOEvents: SocketIOEvents?
    fileprivate var manager: SocketManager?
    fileprivate var socket: SocketIOClient?
    fileprivate var timer: Timer?
    
    func establishConnection(params: [String: String], _ completion: @escaping (_ result: [String: Any]) -> Void) {
        guard let url = URL(string: SocketEndpoints.host.urlComponent()) else { return }
        // set authorization type and it's value in header
        //let bearerToken = APIRequestAuthorizationType.value(type: .bearerToken) ?? ""
        
        let bearerToken = UserDefaults.standard[.accessToken] ?? ""
        
        manager = SocketManager(socketURL: url, config: [.log(true),
                                                         .compress,
                                                         .extraHeaders(["token": bearerToken])])
        guard let socket = manager?.defaultSocket else { return }
        socket.manager?.reconnects = true
        // Connection established.
        socket.once(clientEvent: .connect) { [weak self] (data, _) in
            switch socket.status {
            case .connected:
                LogHandler.reportLogOnConsole(nil, "socket connected..")
                socket.removeAllHandlers()
                self?.receiveMessage()
                self?.receiveVaultMessage()
                self?.adminDisconnected()
                // Connection disconected.
                socket.on(clientEvent: .disconnect) { (_, _) in
                    LogHandler.reportLogOnConsole(nil, "socket disconnect \n")
                }
                completion([:])
            default: break
            }
        }
        
        // Error in connection.
        socket.once(clientEvent: .error) { (data, _) in
            LogHandler.reportLogOnConsole(nil, "connection error \n")
            LogHandler.reportLogOnConsole(nil, "data is: \(data)")
        }
        socket.connect()
    }
    
    func sendMessage(params: [String: Any], _ completion: @escaping (_ success: Bool) -> Void) {
        guard let socket = manager?.defaultSocket else { return }
        socket.emit( SocketEndpoints.sendMessage.urlComponent(), params) {
            completion(true)
        }
    }
    
    func joinVault(params: [String: Any], _ completion: @escaping (_ success: Bool) -> Void) {
        guard let socket = manager?.defaultSocket else { return }
        socket.emit( SocketEndpoints.joinVault.urlComponent(), params) {
            completion(true)
        }
    }
    
    func sendMessageInVault(params: [String: Any], _ completion: @escaping (_ success: Bool) -> Void) {
        guard let socket = manager?.defaultSocket else { return }
        socket.emit( SocketEndpoints.messageInVault.urlComponent(), params) {
            completion(true)
        }
    }
    
    func receiveMessage() {
        guard let socket = manager?.defaultSocket else { return }
        socket.on(SocketEndpoints.receiveMessage.urlComponent()) { (resp, _) in
            if let responseObject = resp.first as? [String: Any] {
                do {
                    let payloadData = try JSONSerialization.data(withJSONObject: responseObject)
                    let model = try JSONDecoder().decode(Chat.self, from: payloadData)
                    self.socketIOEvents?.receivedNewMessage(message: model)
                } catch let error {
                    LogHandler.debugLog("error is: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func receiveVaultMessage() {
        guard let socket = manager?.defaultSocket else { return }
        socket.on(SocketEndpoints.vaultMessage.urlComponent()) { (resp, _) in
            if let responseObject = resp.first as? [String: Any] {
                do {
                    let payloadData = try JSONSerialization.data(withJSONObject: responseObject)
                    let model = try! JSONDecoder().decode(Comment.self, from: payloadData)
                    self.socketIOEvents?.receivedNewVaultMessage(comment: model)
                } catch let error {
                    LogHandler.debugLog("error is: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func disconnect() {
        guard let socket = manager?.defaultSocket else { return }
        LogHandler.reportLogOnConsole(nil, "Socket current status before disconnect: \(socket.status)")
        
        // Optional: prevent future auto-reconnects
        socket.manager?.reconnects = false
        
        // Remove all handlers to prevent residual events
        //socket.removeAllHandlers()
        
        // Disconnect socket
        socket.disconnect()
        
        // Optional manual callback if needed (generally unnecessary)
        socket.manager?.didDisconnect(reason: "Manually disconnected")
        
        socket.on(clientEvent: .disconnect) { (_, _) in
            LogHandler.reportLogOnConsole(nil, "socket disconnect \n")
        }
    }
    
    func socketStatus() -> Bool? {
        return socket?.status.active
    }
    
    func jsonData(from object: Any) -> Data? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else { return nil }
        return data
    }
}

// MARK: - SocketIOEvents
protocol SocketIOEvents: AnyObject {
    func receivedNewMessage(message: Chat)
    func receivedNewVaultMessage(comment: Comment)
    func adminDisconnected()
}

func decodeSocketResponse<T: Decodable>(_ jsonObject: [String: Any]?, _ model: T.Type) -> T? {
    if let responseObject = jsonObject {
        do {
            let payloadData = try JSONSerialization.data(withJSONObject: responseObject as Any)
            let model  = try JSONDecoder().decode(T.self, from: payloadData)
            return model
        } catch let error {
            LogHandler.debugLog("error is: \(error.localizedDescription)")
        }
    }
    return nil
}

extension SocketIOUtil {
    func joinRoom(params: [String: Any],
                  completion: @escaping (_ rtpCapabilities: Any?,
                                         _ videoProducerID: String?,
                                         _ audioProducerID: String?) -> Void) {
        guard let socket = manager?.defaultSocket else { return }
        LogHandler.debugLog("joinRoom: \(params)")
        socket.emitWithAck(SocketEndpoints.joinRoom.urlComponent(), params).timingOut(after: 5) { response in
            LogHandler.debugLog("joinRoom: \(response)")
            if let res = response.first as? [String: Any],
               let rtpCapabilities = res["rtpCapabilities"] {
                let roomProducers = res["roomProducers"] as? NSDictionary ?? [:]
                let videoProducerID = roomProducers["videoProducer"] as? String ?? ""
                let audioProducerID = roomProducers["audioProducer"] as? String ?? ""
                
                completion(rtpCapabilities, videoProducerID, audioProducerID)
            } else {
                completion(nil, nil, nil)
            }
        }
    }
    
    func createWebRtcTransport(params: [String: Any],
                               completion: @escaping (_ transportParams: Any?) -> Void) {
        guard let socket = manager?.defaultSocket else { return }
        socket.emitWithAck(SocketEndpoints.createWebRtcTransport.urlComponent(), params).timingOut(after: 5) { response in
            if let res = response.first as? [String: Any],
               let params = res["params"] {
                completion(params)
            } else {
                completion(nil)
            }
        }
    }
    
    func consume(params: [String: Any],
                 completion: @escaping (_ consumeParams: Any?,
                                        _ consumerId: String?,
                                        _ kind: String?) -> Void) {
        guard let socket = manager?.defaultSocket else { return }
        socket.emitWithAck(SocketEndpoints.consume.urlComponent(), params).timingOut(after: 5) { response in
            if let res = response.first as? [String: Any],
               let params = res["params"] as? [String: Any],
               let rtpParameters = params["rtpParameters"] as? [String: Any] {
                let consumerId = params["serverConsumerId"] as? String ?? ""
                let kind = params["kind"] as? String ?? ""
                LogHandler.debugLog("rtpParameters: \(rtpParameters) and serverConsumerId: \(consumerId) and consumerSideKind: \(kind)")
                completion(rtpParameters, consumerId, kind)
            } else {
                completion(nil, nil, nil)
            }
        }
    }
    
    func transportProduce(params: [String: Any],
                          completion: @escaping (_ params: String?) -> Void) {
        guard let socket = manager?.defaultSocket else { return }
        socket.emitWithAck(SocketEndpoints.transportProduce.urlComponent(), params).timingOut(after: 5) { response in
            if let res = response.first as? [String: Any],
               let transportProduceID = res["id"] as? String {
                completion(transportProduceID)
            } else {
                completion(nil)
            }
        }
    }
    
    func adminDisconnected() {
        guard let socket = manager?.defaultSocket else { return }
        socket.on(SocketEndpoints.adminDisconnected.urlComponent()) { (resp, _) in
            if let _ = resp.first as? [String: Any] {
                self.socketIOEvents?.adminDisconnected()
            }
        }
    }
    
    func transportConnect(params: [String: Any], _ completion: @escaping (_ success: Bool) -> Void) {
        guard let socket = manager?.defaultSocket else { return }
        socket.emit( SocketEndpoints.transportConnect.urlComponent(), params) {
            completion(true)
        }
    }
    
    func consumerResume(params: [String: Any], _ completion: @escaping (_ success: Bool) -> Void) {
        guard let socket = manager?.defaultSocket else { return }
        socket.emit( SocketEndpoints.consumerResume.urlComponent(), params) {
            completion(true)
        }
    }
    
    func transportRecvConnect(params: [String: Any], _ completion: @escaping (_ success: Bool) -> Void) {
        guard let socket = manager?.defaultSocket else { return }
        socket.emit( SocketEndpoints.transportRecvConnect.urlComponent(), params) {
            completion(true)
        }
    }
    
    func emitLeaveRoom(params: [String: Any], _ completion: @escaping (_ success: Bool) -> Void) {
        guard let socket = manager?.defaultSocket else { return }
        socket.emit( SocketEndpoints.leaveRoom.urlComponent(), params) {
            completion(true)
        }
    }
}

enum SocketEndpoints: String, Codable, CaseIterable {
    case host
    case sendMessage
    case receiveMessage
    case joinRoom
    case createWebRtcTransport
    case transportConnect
    case consume
    case transportRecvConnect
    case transportProduce
    case consumerResume
    case leaveRoom
    case adminDisconnected
    case error
    case unspecified
    case messageInVault
    case vaultMessage
    case joinVault
    
    func urlComponent() -> String {
        switch self {
        case .host: return APISharedMethods.shared.socketHostURL()
        case .sendMessage: return "sendMessage"
        case .receiveMessage: return "newMessage"
        case .joinRoom: return "joinRoom"
        case .createWebRtcTransport: return "createWebRtcTransport"
        case .transportConnect: return "transport-connect"
        case .consume: return "consume"
        case .transportRecvConnect: return "transport-recv-connect"
        case .transportProduce: return "transport-produce"
        case .consumerResume: return "consumer-resume"
        case .leaveRoom: return "leaveRoom"
        case .adminDisconnected: return "admin-disconnected"
        case .error: return "error"
        case .unspecified: return ""
        case .messageInVault: return "messageInVault"
        case .vaultMessage: return "vaultMessage"
        case .joinVault: return "joinVault"
        }
    }
}
