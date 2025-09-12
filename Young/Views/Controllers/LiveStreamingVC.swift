import UIKit
import Mediasoup
import AVFoundation
import WebRTC
import Alamofire
import MobileVLCKit

class LiveStreamingVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var localVideoContainer: UIView!
    @IBOutlet weak var remoteVideoContainer: UIView!
    @IBOutlet weak var endLeaveBtn: UIButton!
    @IBOutlet weak var recordedStreamPlayerView: UIView!
    
    // MARK: Variables
    fileprivate var socketIO = SocketIOUtil()
    
    fileprivate let peerConnectionFactory = RTCPeerConnectionFactory()
    fileprivate var peerConnection: RTCPeerConnection?
    
    fileprivate var mediaStream: RTCMediaStream?
    fileprivate var audioTrack: RTCAudioTrack?
    fileprivate var videoTrack: RTCVideoTrack?
    
    fileprivate var sendTransport: SendTransport?
    fileprivate var receiveTransport: ReceiveTransport?
    fileprivate var receiveTransportVideo: ReceiveTransport?
    fileprivate var receiveTransportAudio: ReceiveTransport?
    
    fileprivate var audioProducer: Producer?
    fileprivate var audioProducerID: String = ""
    
    fileprivate var videoProducer: Producer?
    fileprivate var videoProducerID: String = ""
    
    fileprivate var device: Device?
    
    fileprivate var localVideoView: RTCMTLVideoView?
    fileprivate var remoteVideoView: RTCMTLVideoView?
    fileprivate var videoCapturer: RTCCameraVideoCapturer?
    
    fileprivate var remoteConsumerID = ""
    
    fileprivate var videoConsumer: Consumer?
    fileprivate var audioConsumer: Consumer?
    
    fileprivate var audioSession: AVAudioSession?
    fileprivate var audioEngine: AVAudioEngine?
    fileprivate var playerNode: AVAudioPlayerNode?
    fileprivate var volumeNode: AVAudioMixerNode?
    
    fileprivate var mediaPlayer = VLCMediaPlayer()
    
    var isProducer = true
    var roomName = "room_Young_251"
    var recordedStreamURL: String = ""
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        endLeaveBtn.isHidden = false
        if isProducer {
            endLeaveBtn.setTitle("End Streaming", for: .normal)
            localVideoContainer.isHidden = false
            remoteVideoContainer.isHidden = true
            recordedStreamPlayerView.isHidden = true
        } else {
            endLeaveBtn.setTitle("Leave the Stream", for: .normal)
            localVideoContainer.isHidden = true
            remoteVideoContainer.isHidden = false
            recordedStreamPlayerView.isHidden = true
        }
        
        if !recordedStreamURL.isEmpty {
            endLeaveBtn.isHidden = true
            localVideoContainer.isHidden = true
            remoteVideoContainer.isHidden = true
            recordedStreamPlayerView.isHidden = false
            playMKVVideo(urlString: recordedStreamURL)
        }
        
        //   RTCSetMinDebugLogLevel(.info)
        
        //        let config = RTCConfiguration()
        //        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        //
        //        self.peerConnection = peerConnectionFactory.peerConnection(
        //            with: config,
        //            constraints: constraints,
        //            delegate: self  // 🎯 This is essential!
        //        )
        
        if recordedStreamURL.isEmpty {
            requestMediaPermissions { granted in
                if granted {
                    if self.isProducer == true {
                        // Set up Metal video view (for rendering) FIRST
                        
                        self.localVideoView = RTCMTLVideoView(frame: self.localVideoContainer.bounds)
                        self.localVideoView?.videoContentMode = .scaleAspectFill
                        self.localVideoView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        
                        if let localView = self.localVideoView {
                            self.localVideoContainer.addSubview(localView)
                            // Now set frame and visibility
                            DispatchQueue.main.async {
                                localView.frame = self.localVideoContainer.bounds
                                localView.isHidden = false
                            }
                        }
                    } else {
                        // Set up Metal video view (for rendering) FIRST
                        self.remoteVideoView = RTCMTLVideoView(frame: self.remoteVideoContainer.bounds)
                        self.remoteVideoView?.videoContentMode = .scaleAspectFill
                        self.remoteVideoView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        self.remoteVideoView?.delegate = self
                        if let remoteView = self.remoteVideoView {
                            self.remoteVideoContainer.addSubview(remoteView)
                            // Now set frame and visibility
                            DispatchQueue.main.async {
                                remoteView.frame = self.remoteVideoContainer.bounds
                                remoteView.isHidden = false
                            }
                        }
                    }
                    
                    self.joinRoom()
                    
                } else {
                    self.showPermissionAlert()
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        localVideoView?.frame = localVideoContainer.bounds
        remoteVideoView?.frame = remoteVideoContainer.bounds
    }
    
    // MARK: IB Actions
    @IBAction func back(_ sender: UIButton) {
        if recordedStreamURL.isEmpty {
            endLeaveStreaming()
        } else {
            navigationController?.popViewController(animated: false)
        }
    }
    
    @IBAction func endStreaming(_ sender: UIButton) {
        endLeaveStreaming()
    }
    
    // MARK: Shared Methods
    func playMKVVideo(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        mediaPlayer.media = VLCMedia(url: url)
        mediaPlayer.delegate = self
        let playerView = UIView(frame: recordedStreamPlayerView.bounds)
        playerView.backgroundColor = .black
        recordedStreamPlayerView.addSubview(playerView)
        mediaPlayer.drawable = playerView
        mediaPlayer.play()
    }
    
    fileprivate func requestMediaPermissions(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { videoGranted in
            AVCaptureDevice.requestAccess(for: .audio) { audioGranted in
                DispatchQueue.main.async {
                    completion(videoGranted && audioGranted)
                }
            }
        }
    }
    
    fileprivate func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Permissions Required",
            message: "Please enable Camera and Microphone permissions in Settings to continue.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    fileprivate func endLeaveStreaming(isConcludedByHost: Bool = false) {
        sendTransport?.close()
        receiveTransportVideo?.close()
        receiveTransportAudio?.close()
        audioProducer?.close()
        videoProducer?.close()
        var msg = ""
        if isConcludedByHost {
            msg = "The Stream has been concluded by the host."
        } else {
            msg = "Live Stream will be ended. Are you sure?"
        }
        
        PopupUtil.popupAlert(title: "Young",
                             message: msg,
                             actionTitles: isConcludedByHost ? ["Ended"] : ["Yes", "No"],
                             actions: [ { [weak self] _, _ in
            self?.socketIO.disconnect()
            self?.navigationController?.popToRootViewController(animated: false)
            //self?.navigationController?.popToViewController(ofClass: ExchangeVC.self, animated: false)
        }])
    }
    
    fileprivate func joinRoom() {
        socketIO.establishConnection(params: [:]) { _ in
            self.socketIO.socketIOEvents = self
            self.socketIO.joinRoom(params: ["roomName": self.roomName])
            { rtpCapabilities, videoProducerID, audioProducerID in
                self.audioProducerID = audioProducerID ?? ""
                self.videoProducerID = videoProducerID ?? ""
                if let rtpCapabilities {
                    if let dict = rtpCapabilities as? [String: Any] {
                        let capabilities = dictToJSONString(dict) ?? ""
                        self.createDevice(capabilities: capabilities)
                        if self.isProducer == true {
                            self.producerSetUp()
                        } else {
                            self.consumerSetUp()
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func createDevice(capabilities: String) {
        do {
            let device = Device()
            try device.load(with: capabilities)
            self.device = device
        } catch { }
    }
    
    fileprivate func producerSetUp() {
        createWebRtcTransportAtProducer()
    }
    
    fileprivate func consumerSetUp() {
        createWebRtcTransportAtConsumer(for: .video)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.createWebRtcTransportAtConsumer(for: .audio)
        }
    }
    
    fileprivate func createWebRtcTransportAtProducer() {
        socketIO.createWebRtcTransport(params: ["consumer": false]) { transportParams in
            if let params = transportParams as? [String: Any] {
                let videoSource = self.peerConnectionFactory.videoSource()
                self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
                self.videoTrack = self.peerConnectionFactory.videoTrack(with: videoSource, trackId: "video0")
                self.videoTrack?.isEnabled = true
                if let camera = RTCCameraVideoCapturer.captureDevices().first(where: { $0.position == .front }),
                   let format = RTCCameraVideoCapturer.supportedFormats(for: camera).first(where: { CMFormatDescriptionGetMediaSubType($0.formatDescription) == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange }),
                   let fpsRange = format.videoSupportedFrameRateRanges.first {
                    let fps = min(30, fpsRange.maxFrameRate)
                    self.videoCapturer?.startCapture(with: camera, format: format, fps: Int(fps))
                }
                
                // Create audio track
                let audioSource = self.peerConnectionFactory.audioSource(with: RTCMediaConstraints(mandatoryConstraints: nil,
                                                                                                   optionalConstraints: nil))
                self.audioTrack = self.peerConnectionFactory.audioTrack(with: audioSource, trackId: "audio0")
                self.createAudioVideoProducer(transportParams: params)
            }
        }
    }
    
    fileprivate func createAudioVideoProducer(transportParams: [String: Any]) {
        do {
            let id = transportParams["id"] as? String ?? ""
            let iceParameters = dictToJSONString(transportParams["iceParameters"] as! [String : Any])
            let iceCandidates = dictToJSONString(transportParams["iceCandidates"] as! [[String : Any]])
            let dtlsParameters = dictToJSONString(transportParams["dtlsParameters"] as! [String : Any])
            
            let createdSendTransport = try device?.createSendTransport(
                id: id,
                iceParameters: iceParameters ?? "",
                iceCandidates: iceCandidates ?? "",
                dtlsParameters: dtlsParameters ?? "",
                sctpParameters: nil,
                iceTransportPolicy: .all,
                appData: nil)
            
            sendTransport = createdSendTransport
            sendTransport?.delegate = self
            
            guard let sendTransport = self.sendTransport,
                  let audioTrack = self.audioTrack,
                  let videoTrack = self.videoTrack
            else { return }
            
            let audioEncoding = RTCRtpEncodingParameters()
            audioEncoding.maxBitrateBps = NSNumber(value: 64_000)
            
            let audioProducer = try sendTransport.createProducer(
                for: audioTrack,
                encodings: [audioEncoding],
                codecOptions: nil,
                codec: nil,
                appData: nil
            )
            
            self.audioProducer = audioProducer
            self.audioProducer?.delegate = self
            
            let encoding = RTCRtpEncodingParameters()
            encoding.maxBitrateBps = NSNumber(value: 500_000) // 500 kbps
            encoding.minBitrateBps = NSNumber(value: 100_000) // 100 kbps
            
            let videoProducer = try sendTransport.createProducer(
                for: videoTrack,
                encodings: [encoding],
                codecOptions: nil,
                codec: nil,
                appData: nil
            )
            
            if let videoView = self.localVideoView { videoTrack.add(videoView) }
            
            self.videoProducer = videoProducer
            self.videoProducer?.delegate = self
            
        } catch let error as MediasoupError {
            switch error {
            case let .unsupported(message):
                LogHandler.debugLog("unsupported: \(message)")
            case let .invalidState(message):
                LogHandler.debugLog("invalid state: \(message)")
            case let .invalidParameters(message):
                LogHandler.debugLog("invalid parameters: \(message)")
            case let .mediasoup(underlyingError):
                LogHandler.debugLog("mediasoup: \(underlyingError)")
            case .unknown(let underlyingError):
                LogHandler.debugLog("unknown: \(underlyingError)")
            @unknown default:
                LogHandler.debugLog("unknown")
            }
        } catch {
            LogHandler.debugLog("Error loading device: \(error.localizedDescription)")
        }
    }
    
    fileprivate func createWebRtcTransportAtConsumer(for kind: ConsumeKind) {
        socketIO.createWebRtcTransport(params: ["consumer": true]) { transportParams in
            if let params = transportParams as? [String: Any] {
                self.remoteConsumerID = params["id"] as? String ?? ""
                self.consumeAudioVideo(params: params, kind: kind)
            }
        }
    }
    
    func consumeAudioVideo(params: [String: Any], kind: ConsumeKind) {
        do {
            let rtpCapabilities = try device?.rtpCapabilities() ?? ""
            let id = params["id"] as? String ?? ""
            let iceParameters = dictToJSONString(params["iceParameters"] as! [String : Any])
            let iceCandidates = dictToJSONString(params["iceCandidates"] as! [[String : Any]])
            let dtlsParameters = dictToJSONString(params["dtlsParameters"] as! [String : Any])
            do {
                let createdRecvTransport = try device?.createReceiveTransport(
                    id: id,
                    iceParameters: iceParameters ?? "",
                    iceCandidates: iceCandidates ?? "",
                    dtlsParameters: dtlsParameters ?? "",
                    sctpParameters: nil,
                    appData: nil
                )
                
                if kind == .audio {
                    receiveTransportAudio = createdRecvTransport
                    receiveTransportAudio?.delegate = self
                } else {
                    receiveTransportVideo = createdRecvTransport
                    receiveTransportVideo?.delegate = self
                }
                
                //                if receiveTransport == nil {
                //                    receiveTransport = createdRecvTransport
                //                    receiveTransport?.delegate = self
                //                }
                
                if let dict = jsonStringToDict(rtpCapabilities) {
                    let consumeParams = ["rtpCapabilities": dict,
                                         "remoteProducerId": kind == .audio ? audioProducerID : videoProducerID,
                                         "serverConsumerTransportId": id] as [String : Any]
                    
                    self.socketIO.consume(params: consumeParams) { consumeParams, consumerId, kind in
                        let consumseKind = ConsumeKind(rawValue: kind ?? ConsumeKind.audio.rawValue)
                        switch consumseKind {
                        case .audio:
                            do {
                                if let rtpDict = consumeParams,
                                   let rtpParamsString = dictToJSONString(rtpDict) {
                                    let audioConsumer = try self.receiveTransportAudio?.consume(
                                        consumerId: id,
                                        producerId: self.audioProducerID,
                                        kind: .audio,
                                        rtpParameters: rtpParamsString,
                                        appData: nil
                                    )
                                    
                                    if let audioTrack = audioConsumer?.track as? RTCAudioTrack {
                                        audioTrack.isEnabled = true
                                        self.socketIO.consumerResume(params: ["serverConsumerId": consumerId ?? ""]) { success in
                                            if let audioConsumer {
                                                self.setupAudioTrack(with: audioConsumer)
                                            }
                                        }
                                    }
                                }
                            } catch {
                                LogHandler.debugLog("❌ Error creating RecvTransport: \(error)")
                            }
                            
                        case .video:
                            do {
                                if let rtpDict = consumeParams,
                                   let rtpParamsString = dictToJSONString(rtpDict) {
                                    let videoConsumer = try self.receiveTransportVideo?.consume(
                                        consumerId: id,
                                        producerId: self.videoProducerID,
                                        kind: .video,
                                        rtpParameters: rtpParamsString,
                                        appData: nil
                                    )
                                    
                                    if let videoTrack = videoConsumer?.track as? RTCVideoTrack {
                                        videoTrack.isEnabled = true
                                        self.socketIO.consumerResume(params: ["serverConsumerId": consumerId ?? ""]) { success in
                                            if let videoConsumer {
                                                self.setupVideoTrack(with: videoConsumer)
                                            }
                                        }
                                    }
                                }
                            } catch {
                                LogHandler.debugLog("❌ Error creating RecvTransport: \(error)")
                            }
                            
                        default: break
                        }
                    }
                }
            } catch {
                LogHandler.debugLog("❌ Error creating RecvTransport: \(error)")
            }
        } catch let error as MediasoupError {
            switch error {
            case let .unsupported(message):
                LogHandler.debugLog("unsupported: \(message)")
            case let .invalidState(message):
                LogHandler.debugLog("invalid state: \(message)")
            case let .invalidParameters(message):
                LogHandler.debugLog("invalid parameters: \(message)")
            case let .mediasoup(underlyingError):
                LogHandler.debugLog("mediasoup: \(underlyingError)")
            case .unknown(let underlyingError):
                LogHandler.debugLog("unknown: \(underlyingError)")
            @unknown default:
                LogHandler.debugLog("unknown")
            }
        } catch {
            LogHandler.debugLog("Error loading device: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Audio Track Setup
    func setupAudioTrack(with consumer: Consumer) {
        guard let audioTrack = consumer.track as? RTCAudioTrack else {
            LogHandler.debugLog("❌ Consumer track is not an audio track")
            return
        }
        
        // Setup audio session FIRST
        guard setupAudioSession() else {
            LogHandler.debugLog("❌ Audio session setup failed")
            return
        }
        
        // Configure consumer and track
        self.audioConsumer = consumer
        self.audioTrack = audioTrack
        
        // Enable the audio track
        audioTrack.isEnabled = true
        
        // Resume consumer if paused
        if consumer.paused {
            consumer.resume()
            LogHandler.debugLog("▶️ Consumer resumed")
        }
        
        LogHandler.debugLog("✅ Audio track setup completed")
        LogHandler.debugLog("📊 Audio Consumer stats - Closed: \(consumer.closed), Paused: \(consumer.paused)")
        LogHandler.debugLog("🎵 Audio track enabled: \(audioTrack.isEnabled)")
        
        // **IMPORTANT: Add this debug check**
        checkAudioOutput()
    }
    
    private func setupAudioSession() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            // Simple WebRTC audio configuration - no custom engine
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .allowAirPlay])
            try audioSession.setActive(true)
            
            // **FORCE AUDIO TO SPEAKER**
            try audioSession.overrideOutputAudioPort(.speaker)
            
            LogHandler.debugLog("✅ Audio session configured:")
            LogHandler.debugLog("  - Category: \(audioSession.category.rawValue)")
            LogHandler.debugLog("  - Mode: \(audioSession.mode.rawValue)")
            LogHandler.debugLog("  - Active: \(audioSession.isOtherAudioPlaying)")
            
            return true
            
        } catch {
            LogHandler.debugLog("❌ Failed to setup audio session: \(error)")
            return setupAlternativeAudioSession()
        }
    }
    
    private func checkAudioOutput() {
        let audioSession = AVAudioSession.sharedInstance()
        
        LogHandler.debugLog("🔍 Audio Output Debug:")
        LogHandler.debugLog("  - Current route: \(audioSession.currentRoute)")
        LogHandler.debugLog("  - Available inputs: \(audioSession.availableInputs?.count ?? 0)")
        LogHandler.debugLog("  - Output volume: \(audioSession.outputVolume)")
        LogHandler.debugLog("  - Category: \(audioSession.category)")
        LogHandler.debugLog("  - Mode: \(audioSession.mode)")
        
        // Check if audio is going to speaker or headphones
        for output in audioSession.currentRoute.outputs {
            LogHandler.debugLog("  - Output: \(output.portType.rawValue) - \(output.portName)")
        }
    }
    
    private func setupAlternativeAudioSession() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            // Try simpler configuration
            try audioSession.setCategory(.ambient)
            try audioSession.setActive(true)
            // **FORCE AUDIO TO SPEAKER**
            try audioSession.overrideOutputAudioPort(.speaker)
            
            LogHandler.debugLog("✅ Alternative audio session configured")
            return true
            
        } catch {
            LogHandler.debugLog("❌ Alternative audio session failed: \(error)")
            return false
        }
    }
}

// MARK: Delegates and DataSources
extension LiveStreamingVC: SendTransportDelegate {
    
    func onProduceData(transport: Mediasoup.Transport, sctpParameters: String, label: String, protocol dataProtocol: String, appData: String, callback: @escaping (String?) -> Void) {
        LogHandler.debugLog("sctpParameters: \(sctpParameters)")
    }
    
    func onConnect(transport: Mediasoup.Transport, dtlsParameters: String) {
        LogHandler.debugLog("dtlsParameters: \(dtlsParameters)")
        
        // Try to parse the string into a dictionary
        guard let data = dtlsParameters.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            LogHandler.debugLog("❌ Failed to parse dtlsParameters")
            return
        }
        
        let params: [String: Any] = [
            "type": "connect-transport",
            "transportId": transport.id,
            "dtlsParameters": json
        ]
        
        if isProducer {
            // 🔁 Send to your signaling server via WebSocket or any signaling layer
            socketIO.transportConnect(params: params) { success in
                if success {
                    LogHandler.debugLog("✅ Transport connected")
                    
                    // ✅ Safely resume producers
                    if let audioProducer = self.audioProducer {
                        audioProducer.resume()
                        LogHandler.debugLog("🎤 Audio producer resumed")
                    }
                    
                    if let videoProducer = self.videoProducer {
                        videoProducer.resume()
                        LogHandler.debugLog("🎥 Video producer resumed")
                    }
                } else {
                    LogHandler.debugLog("❌ Failed to connect transport on server")
                }
            }
        } else {
            let transportRecvConnectParams = ["dtlsParameters": json, "serverConsumerTransportId": remoteConsumerID] as [String : Any]
            self.socketIO.transportRecvConnect(params: transportRecvConnectParams) { success in
                LogHandler.debugLog("✅ transportRecvConnect: \(success)")
            }
        }
    }
    
    func onConnectionStateChange(transport: any Mediasoup.Transport, connectionState: TransportConnectionState) {
        LogHandler.debugLog("SendTransport state changed to: \(connectionState)")
    }
    
    func onProduce(transport: Mediasoup.Transport, kind: MediaKind, rtpParameters: String, appData: String, callback: @escaping (String?) -> Void) {
        let kindString: String
        switch kind {
        case .audio: kindString = "audio"
        case .video: kindString = "video"
        default: kindString = "unknown"
        }
        
        //        guard let producerId = handleOnProduce(transportId: transport.id, kind: kindString, rtpParameters: rtpParameters)
        //        else {
        //            callback(nil)
        //            return
        //        }
        //        callback(producerId)
        
        
        // Store callback for later use
        let fakeId = UUID().uuidString
        callback(fakeId) // call immediately to unblock Mediasoup
        guard let data = rtpParameters.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            LogHandler.debugLog("❌ Failed to parse RTP parameters")
            callback(nil)
            return
        }
        
        let params: [String: Any] = ["kind": kindString, "rtpParameters": json]
        socketIO.transportProduce(params: params) { transportProduceID in
            if let transportProduceID {
                LogHandler.debugLog("✅ Received Producer ID: \(transportProduceID)")
                //ProducerIdMapper.shared.store(fakeId: fakeId, realId: id)
                LogHandler.debugLog("🔁 Mapped fake ID \(fakeId) → real ID \(transportProduceID)")
            } else {
                LogHandler.debugLog("❌ Failed to get valid Producer ID")
            }
        }
    }
}

// MARK: - Video Track Setup
extension LiveStreamingVC: RTCVideoViewDelegate {
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        LogHandler.debugLog("📱 Video size changed: \(size)")
        
        DispatchQueue.main.async {
            // Update video view size if needed
            if size.width > 0 && size.height > 0 {
                self.updateVideoViewSize(size)
            }
        }
    }
    
    private func updateVideoViewSize(_ size: CGSize) {
        guard let videoView = remoteVideoView else { return }
        
        // Calculate aspect ratio
        let aspectRatio = size.width / size.height
        let maxWidth: CGFloat = 320
        let maxHeight: CGFloat = 240
        
        var newWidth: CGFloat
        var newHeight: CGFloat
        
        if aspectRatio > maxWidth / maxHeight {
            newWidth = maxWidth
            newHeight = maxWidth / aspectRatio
        } else {
            newHeight = maxHeight
            newWidth = maxHeight * aspectRatio
        }
        
        // Update frame
        var frame = videoView.frame
        frame.size.width = newWidth
        frame.size.height = newHeight
        videoView.frame = frame
        
        LogHandler.debugLog("📐 Updated video view size: \(newWidth) x \(newHeight)")
    }
    
    func setupVideoTrack(with consumer: Consumer) {
        guard let videoTrack = consumer.track as? RTCVideoTrack else {
            LogHandler.debugLog("❌ Consumer track is not a video track")
            return
        }
        
        self.videoConsumer = consumer
        self.videoTrack = videoTrack
        
        // Enable the video track
        videoTrack.isEnabled = true
        
        // Resume consumer if paused
        if consumer.paused {
            consumer.resume()
        }
        
        // Check consumer state
        LogHandler.debugLog("📊 Consumer stats - Closed: \(consumer.closed), Paused: \(consumer.paused)")
        LogHandler.debugLog("🎥 Video track enabled: \(videoTrack.isEnabled)")
        
        // Setup video view on main thread
        DispatchQueue.main.async {
            self.createVideoView(for: videoTrack)
        }
    }
    
    //    private func createVideoView(for videoTrack: RTCVideoTrack) {
    //        // Remove existing video view if any
    //        removeVideoView()
    //
    //        // Create new video view
    //        let staticFrame = CGRect(x: 0, y: 0, width: 320, height: 240)
    //        let videoView = RTCMTLVideoView(frame: staticFrame)
    //
    //        // Configure video view
    //        videoView.videoContentMode = .scaleAspectFit
    //        videoView.delegate = self
    //        videoView.backgroundColor = .white
    //        videoView.layer.borderWidth = 0
    //        videoView.layer.borderColor = UIColor.red.cgColor
    //        //videoView.layer.cornerRadius = 8
    //
    //        // Add to view hierarchy
    //        self.view.addSubview(videoView)
    //
    //        // Add renderer to video track
    //        videoTrack.add(videoView)
    //
    //        // Store reference
    //        self.remoteVideoView = videoView
    //
    //        LogHandler.debugLog("📐 Created remoteVideoView with frame: \(videoView.frame)")
    //
    //        // Add constraints for better layout (optional)
    //        setupVideoViewConstraints(videoView)
    //    }
    
    private func createVideoView(for videoTrack: RTCVideoTrack) {
        // Remove existing video view if any
        removeVideoView()
        
        // Create new video view
        let videoView = RTCMTLVideoView()
        
        // Configure video view
        videoView.videoContentMode = .scaleAspectFill
        videoView.delegate = self
        videoView.backgroundColor = .white
        videoView.layer.borderWidth = 0
        videoView.layer.borderColor = UIColor.red.cgColor
        
        // Disable autoresizing mask
        videoView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to view hierarchy
        self.remoteVideoContainer.addSubview(videoView)
        
        // **FILL THE ENTIRE CONTAINER (CENTERED)**
        NSLayoutConstraint.activate([
            videoView.topAnchor.constraint(equalTo: remoteVideoContainer.topAnchor),
            videoView.leadingAnchor.constraint(equalTo: remoteVideoContainer.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: remoteVideoContainer.trailingAnchor),
            videoView.bottomAnchor.constraint(equalTo: remoteVideoContainer.bottomAnchor)
        ])
        
        // Add renderer to video track
        videoTrack.add(videoView)
        
        // Store reference
        self.remoteVideoView = videoView
        
        LogHandler.debugLog("📐 Created remoteVideoView filling container")
    }
    
    private func removeVideoView() {
        if let existingVideoView = remoteVideoView {
            // Remove renderer from video track
            videoTrack?.remove(existingVideoView)
            
            // Remove from view hierarchy
            existingVideoView.removeFromSuperview()
            
            // Clear reference
            remoteVideoView = nil
        }
    }
    
    private func setupVideoViewConstraints(_ videoView: RTCMTLVideoView) {
        videoView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            videoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            videoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            videoView.widthAnchor.constraint(equalToConstant: 320),
            videoView.heightAnchor.constraint(equalToConstant: 240)
        ])
    }
}

extension LiveStreamingVC: ProducerDelegate {
    func onTransportClose(in producer: Producer) {
        LogHandler.debugLog("on transport close in \(producer)")
    }
}

extension LiveStreamingVC: ReceiveTransportDelegate { }

extension LiveStreamingVC: ConsumerDelegate {
    func onTransportClose(in consumer: Mediasoup.Consumer) {
        LogHandler.debugLog("on transport close in \(consumer)")
    }
}

extension LiveStreamingVC {
    
    func handleOnProduce(transportId: String, kind: String, rtpParameters: String) -> String? {
        guard let data = rtpParameters.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        else { return nil }
        let queue: DispatchQueue = .init(label: "produce", qos: .userInitiated)
        let globalQueue: DispatchQueue = .global()
        let semaphore: DispatchSemaphore = .init(value: 0)
        let parameters: [String: Any] = ["kind": kind, "rtpParameters": json]
        var producerId: String?
        globalQueue.async {
            let baseURL = SocketEndpoints.host.urlComponent()
            let completeURL = "\(baseURL)/transport-produce"
            AF.request(completeURL,
                       method: .post,
                       parameters: parameters,
                       encoding: JSONEncoding.default).response(queue: queue) { response in
                guard let data = response.data else { return }
                guard let producerIdStr = String.init(data: data, encoding: .utf8) else { return }
                producerId = producerIdStr
                semaphore.signal()
            }
        }
        _ = semaphore.wait(timeout: .now() + 3)
        guard let producerId = producerId else { return nil }
        return producerId
    }
}

extension LiveStreamingVC: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        LogHandler.debugLog("📶 Signaling state changed: \(stateChanged.rawValue)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        LogHandler.debugLog("🎥 Did add stream with \(stream.audioTracks.count) audio tracks and \(stream.videoTracks.count) video tracks")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        LogHandler.debugLog("🗑️ Stream removed")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        LogHandler.debugLog("⚙️ Renegotiation needed")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        LogHandler.debugLog("❄️ ICE connection state changed: \(newState.rawValue)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        LogHandler.debugLog("🧊 ICE gathering state changed: \(newState.rawValue)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        LogHandler.debugLog("📡 New ICE candidate: \(candidate.sdp)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        LogHandler.debugLog("❌ ICE candidates removed: \(candidates.count)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        LogHandler.debugLog("💬 Data channel opened with label: \(dataChannel.label)")
    }
}

extension LiveStreamingVC: SocketIOEvents {
    
    func receivedNewMessage(message: Chat) { }
    
    func receivedNewVaultMessage(comment: Comment) { }
    
    func adminDisconnected() {
        endLeaveStreaming(isConcludedByHost: true)
    }
}

func dictToJSONString(_ obj: Any) -> String? {
    guard JSONSerialization.isValidJSONObject(obj),
          let data = try? JSONSerialization.data(withJSONObject: obj, options: []) else {
        return nil
    }
    return String(data: data, encoding: .utf8)
}

func jsonStringToDict(_ jsonString: String) -> [String: Any]? {
    guard let data = jsonString.data(using: .utf8),
          let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        return nil
    }
    return dictionary
}

enum ConsumeKind: String {
    case audio = "audio"
    case video = "video"
}

extension LiveStreamingVC: VLCMediaPlayerDelegate {
    func mediaPlayerStateChanged(_ aNotification: Notification) {
        LogHandler.debugLog("Player State: \(mediaPlayer.state.rawValue)")
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification) {
        LogHandler.debugLog("Time: \(mediaPlayer.time.stringValue)")
    }
}
