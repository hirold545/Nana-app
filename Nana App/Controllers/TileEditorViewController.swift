import PhotosUI
import UIKit

/// The New tile / Edit tile screen: name, words, color, photo and voice. Nothing is saved until
/// "Save tile" is tapped, so Cancel throws the changes away.
/// (Controller: it connects the views on screen with the Tile model, TileStore and AudioManager.)
final class TileEditorViewController: UIViewController {
    // MARK: Model and services
    private let tile: Tile
    private let isNew: Bool
    private let store = TileStore.shared
    private let audio = AudioManager.shared

    // MARK: Draft values (changes live here until Save)
    private var colorIndex: Int
    private var photo: UIImage?
    private var photoTouched = false
    private var hasAudio: Bool
    private var newAudio: URL?
    private var recordingHere = false

    // MARK: Views
    private let preview = TileFaceView().prepared()
    private let titleField = UITextField()
    private let wordsField = UITextField()
    private let swatchRow: ColorSwatchRow
    private let voiceCard = VoiceCardView()
    private let removePhotoButton = UIButton(type: .system)
    private var saveButton: UIButton!
    private let messageLabel = UILabel()

    /// A temporary file for a new recording. It only replaces the saved voice when you tap Save.
    private var tempURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("\(tile.id)_new.m4a")
    }

    /// Creates the screen using the tile's current values as the starting point for editing.
    init(tile: Tile, isNew: Bool) {
        self.tile = tile
        self.isNew = isNew
        colorIndex = tile.colorIndex
        hasAudio = tile.hasAudio
        photo = TileStore.shared.image(tile.photoFile)
        swatchRow = ColorSwatchRow(colors: Palette.tile, names: Palette.tileNames)
        super.init(nibName: nil, bundle: nil)
    }

    /// Required by UIKit for storyboard loading. We build everything in code, so this is never
    /// used.
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: Layout

    /// Builds the whole form: Cancel, title, live preview, text fields, color swatches, photo
    /// buttons, voice card, Delete (when editing) and the Save bar, then lays everything out.
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.bg

        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 18
        content.prepared()

        // Cancel button and heading
        var cancelConfig = UIButton.Configuration.plain()
        cancelConfig.title = "Cancel"
        cancelConfig.image = UIImage(systemName: "chevron.left")
        cancelConfig.imagePadding = 4
        cancelConfig.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 12)
        let cancel = UIButton(configuration: cancelConfig)
        cancel.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        let cancelRow = UIStackView(arrangedSubviews: [cancel, UIView()])

        let heading = UILabel()
        heading.text = isNew ? "New tile" : "Edit tile"
        heading.font = Fonts.make(26, .medium, style: .title1)
        heading.textColor = Palette.text
        heading.accessibilityTraits = .header

        // Live preview next to the two text fields
        preview.widthAnchor.constraint(equalToConstant: 150).isActive = true
        preview.heightAnchor.constraint(equalToConstant: 150).isActive = true
        for (field, placeholder, text) in [(titleField, "Name or title", tile.name),
                                           (wordsField, "Words on the tile", tile.words)] {
            field.placeholder = placeholder
            field.text = text
            field.borderStyle = .roundedRect
            field.font = Fonts.make(17)
            field.returnKeyType = .done
            field.delegate = self
            field.clearButtonMode = .whileEditing
            field.addTarget(self, action: #selector(fieldChanged), for: .editingChanged)
        }
        let fields = UIStackView(arrangedSubviews: [titleField, wordsField])
        fields.axis = .vertical
        fields.spacing = 12
        fields.distribution = .fillEqually
        fields.heightAnchor.constraint(equalToConstant: 100).isActive = true
        let topRow = UIStackView(arrangedSubviews: [preview, fields])
        topRow.spacing = 14
        topRow.alignment = .top

        // Color swatches
        swatchRow.onSelect = { [weak self] index in
            self?.colorIndex = index
            self?.updateUI()
        }

        // Photo buttons
        removePhotoButton.setTitle("Remove photo", for: .normal)
        removePhotoButton.titleLabel?.font = Fonts.make(15)
        removePhotoButton.addTarget(self, action: #selector(removePhoto), for: .touchUpInside)
        let photoHeader = UIStackView(arrangedSubviews: [sectionLabel("Photo"), removePhotoButton])
        let cameraButton = Buttons.make(title: "Take photo", icon: "camera", fill: nil,
                                        foreground: Palette.primary, stroke: Palette.outline)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        cameraButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        let chooseButton = Buttons.make(title: "Choose", icon: "photo", fill: nil,
                                        foreground: Palette.primary, stroke: Palette.outline)
        chooseButton.addTarget(self, action: #selector(choosePhoto), for: .touchUpInside)
        let photoRow = UIStackView(arrangedSubviews: [cameraButton, chooseButton])
        photoRow.spacing = 10
        photoRow.distribution = .fillEqually

        // Voice card (a View; the controller only listens to its buttons)
        voiceCard.onRecord = { [weak self] in self?.recordTapped() }
        voiceCard.onPlay = { [weak self] in self?.playTapped() }

        messageLabel.font = Fonts.make(15)
        messageLabel.textColor = Palette.danger
        messageLabel.numberOfLines = 0

        [cancelRow, heading, topRow, sectionLabel("Color"), swatchRow, photoHeader, photoRow,
         sectionLabel("Voice"), voiceCard, messageLabel].forEach(content.addArrangedSubview)

        if !isNew {
            let delete = UIButton(type: .system)
            delete.setTitle("Delete tile", for: .normal)
            delete.setTitleColor(Palette.danger, for: .normal)
            delete.titleLabel?.font = Fonts.make(17, .medium)
            delete.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
            content.addArrangedSubview(UIStackView(arrangedSubviews: [delete, UIView()]))
        }

        // Scrolling form + Save bar pinned above the keyboard
        let scroll = UIScrollView().prepared()
        scroll.keyboardDismissMode = .interactive
        scroll.alwaysBounceVertical = true
        saveButton = Buttons.make(title: "Save tile", fill: Palette.primary, foreground: .white,
                                  height: 58, fontSize: 20)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        let bar = UIView().prepared()
        bar.backgroundColor = Palette.bg
        bar.addSubview(saveButton)

        view.addSubview(scroll)
        view.addSubview(bar)
        scroll.addSubview(content)
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: safe.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: bar.topAnchor),

            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 4),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -20),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 20),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -20),

            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bar.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            saveButton.topAnchor.constraint(equalTo: bar.topAnchor, constant: 10),
            saveButton.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -10),
            saveButton.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -20)
        ])

        NotificationCenter.default.addObserver(self, selector: #selector(audioChanged),
                                               name: .audioStateChanged, object: nil)
        updateUI()
    }

    /// Stops listening for notifications when this screen is removed from memory.
    deinit { NotificationCenter.default.removeObserver(self) }

    /// Makes a small gray heading such as "Color" or "Photo".
    private func sectionLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = Fonts.make(15)
        l.textColor = Palette.muted
        return l
    }

    // MARK: State -> screen

    /// Refreshes everything on screen from the current state: preview tile, selected color,
    /// Remove photo button, the voice card, and whether Save is allowed (it needs a name and no
    /// recording in progress).
    private func updateUI() {
        preview.configure(color: Palette.tile[colorIndex], words: wordsField.text ?? "",
                          title: titleField.text ?? "", photo: photo, badge: nil)
        swatchRow.select(colorIndex)
        removePhotoButton.isHidden = photo == nil
        voiceCard.render(isRecording: audio.isRecording, hasAudio: hasAudio, seconds: audio.seconds)

        let canSave = !(titleField.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty && !audio.isRecording
        saveButton.isEnabled = canSave
        saveButton.alpha = canSave ? 1 : 0.4
    }

    // MARK: Actions

    /// Called after each typed letter so the preview updates live.
    @objc private func fieldChanged() { updateUI() }

    /// Removes the photo from the tile (applied when you save).
    @objc private func removePhoto() {
        photo = nil
        photoTouched = true
        updateUI()
    }

    /// Opens the camera.
    @objc private func takePhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }

    /// Opens the photo library picker (one image).
    @objc private func choosePhoto() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    /// Record/Stop button. If recording, it stops. Otherwise it asks for microphone permission
    /// and, if allowed, starts recording into a temporary file.
    private func recordTapped() {
        if audio.isRecording {
            audio.stopRecording()
            return
        }
        audio.requestPermission { [weak self] granted in
            guard let self else { return }
            guard granted else {
                self.messageLabel.text = "Allow microphone access in Settings, then try again."
                return
            }
            self.messageLabel.text = nil
            self.recordingHere = true
            self.audio.startRecording(to: self.tempURL)
        }
    }

    /// Called whenever recording or playing changes. When a recording we started has just ended,
    /// remember its temporary file so Save can keep it.
    @objc private func audioChanged() {
        if !audio.isRecording && recordingHere {
            recordingHere = false
            newAudio = tempURL
            hasAudio = true
        }
        updateUI()
    }

    /// Plays the new recording if there is one, otherwise the voice already saved for the tile.
    private func playTapped() {
        audio.play(url: newAudio ?? store.audioURL(tile.id), id: nil)
    }

    /// Closes the screen without saving.
    @objc private func cancelTapped() {
        audio.stopAll()
        dismiss(animated: true)
    }

    /// Saves the tile with the values on screen, then closes the screen.
    @objc private func saveTapped() {
        audio.stopAll()
        var t = tile
        t.name = (titleField.text ?? "").trimmingCharacters(in: .whitespaces)
        t.words = (wordsField.text ?? "").trimmingCharacters(in: .whitespaces)
        t.colorIndex = colorIndex
        t.hasAudio = hasAudio
        store.commit(t, newAudio: newAudio,
                     newPhoto: photoTouched ? photo : nil,
                     photoRemoved: photoTouched && photo == nil)
        dismiss(animated: true)
    }

    /// Asks "Delete this tile?" and, if confirmed, removes the tile and closes the screen.
    @objc private func deleteTapped() {
        let alert = UIAlertController(title: "Delete this tile?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.audio.stopAll()
            self.store.delete(self.tile)
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }

    /// Stores a newly picked photo (shrunk to 900 px) and updates the preview.
    private func setPhoto(_ image: UIImage) {
        photo = image.resized(maxSide: 900)
        photoTouched = true
        updateUI()
    }
}

/// Lets the Return key close the keyboard.
extension TileEditorViewController: UITextFieldDelegate {
    /// Called when Return is pressed: hide the keyboard.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

/// Receives the result of the camera.
extension TileEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /// Called after a photo is taken: close the camera and use the photo.
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage { setPhoto(image) }
    }

    /// Called if the camera is cancelled.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

/// Receives the result of the photo library picker.
extension TileEditorViewController: PHPickerViewControllerDelegate {
    /// Called after choosing a photo: loads the image in the background, then uses it on the main
    /// thread.
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async { self?.setPhoto(image) }
        }
    }
}
