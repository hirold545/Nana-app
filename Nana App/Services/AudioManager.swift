import AVFoundation

/// Records short voice clips (max 10 s) and plays them back.
/// Posts `.audioStateChanged` whenever recording or playing changes.
final class AudioManager: NSObject, AVAudioPlayerDelegate {
    static let shared = AudioManager()

    private(set) var isRecording = false { didSet { announce() } }
    private(set) var seconds = 0 { didSet { announce() } }
    private(set) var playingID: String? { didSet { announce() } }

    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private var timer: Timer?

    /// Sends a notification so any screen can update itself when recording or playing changes.
    private func announce() {
        NotificationCenter.default.post(name: .audioStateChanged, object: nil)
    }

    /// Asks for microphone permission (iOS shows a pop-up the first time). Calls completion(true)
    /// if allowed, always on the main thread.
    func requestPermission(_ completion: @escaping (Bool) -> Void) {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        }
    }

    /// Starts recording the microphone into a file at url. It sets up the audio session, picks
    /// AAC/mono settings, starts a 1-second timer, and stops automatically after 10 seconds.
    func startRecording(to url: URL) {
        stopPlayback()
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
            try? FileManager.default.removeItem(at: url)
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.record()
            seconds = 0
            isRecording = true
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self else { return }
                self.seconds += 1
                if self.seconds >= 10 { self.stopRecording() }
            }
        } catch {
            isRecording = false
        }
    }

    /// Stops the recording and its timer. The finished file stays at the URL given to
    /// startRecording.
    func stopRecording() {
        timer?.invalidate()
        timer = nil
        recorder?.stop()
        recorder = nil
        isRecording = false
    }

    /// Plays the sound file at url. id is the tile being played (so the board can make it grow);
    /// pass nil when previewing in the editor.
    func play(url: URL, id: String?) {
        stopPlayback()
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()
            playingID = id
        } catch {
            playingID = nil
        }
    }

    /// Stops any sound that is currently playing.
    func stopPlayback() {
        player?.stop()
        player = nil
        if playingID != nil { playingID = nil }
    }

    /// Stops both recording and playing. Used when leaving a screen.
    func stopAll() {
        if isRecording { stopRecording() }
        stopPlayback()
    }

    /// Called by iOS when a sound finishes by itself. We clear playingID so the tile shrinks back
    /// to normal size.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { self.playingID = nil }
    }
}
