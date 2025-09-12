import UIKit
import MobileVLCKit

class RecordedStreamPlayerVC: UIViewController, VLCMediaPlayerDelegate {
    var mediaPlayer = VLCMediaPlayer()
    var videoURL: URL!

    private var playerView: UIView!
    private var playPauseButton: UIButton!
    private var closeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        playMKVVideo(url: videoURL)
    }

    private func setupUI() {
        view.backgroundColor = .black

        // Video view
        playerView = UIView(frame: view.bounds)
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(playerView)

        // Play/Pause button
        playPauseButton = UIButton(type: .system)
        playPauseButton.frame = CGRect(x: 20, y: view.bounds.height - 80, width: 100, height: 40)
        playPauseButton.setTitle("Pause", for: .normal)
        playPauseButton.setTitleColor(.white, for: .normal)
        playPauseButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        view.addSubview(playPauseButton)

        // Close button
        closeButton = UIButton(type: .system)
        closeButton.frame = CGRect(x: view.bounds.width - 100, y: 40, width: 80, height: 40)
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.addTarget(self, action: #selector(closePlayer), for: .touchUpInside)
        view.addSubview(closeButton)
    }

    func playMKVVideo(url: URL) {
        mediaPlayer.delegate = self
        mediaPlayer.drawable = playerView
        mediaPlayer.media = VLCMedia(url: url)
        mediaPlayer.play()
    }

    @objc private func togglePlayPause() {
        if mediaPlayer.isPlaying {
            mediaPlayer.pause()
            playPauseButton.setTitle("Play", for: .normal)
        } else {
            mediaPlayer.play()
            playPauseButton.setTitle("Pause", for: .normal)
        }
    }

    @objc private func closePlayer() {
        mediaPlayer.stop()
        dismiss(animated: true, completion: nil)
    }
}
