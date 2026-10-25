import UIKit

/// One cell in the grid: either a real tile or the "Add a tile" button.
private enum BoardItem {
    case tile(Tile)
    case add
}

/// The soundboard screen: a grid of tiles. Tap one to hear its voice; press and hold "Hold to edit"
/// to change, add or delete tiles.
final class BoardViewController: UIViewController {
    private var editMode: Bool
    private let store = TileStore.shared
    private let audio = AudioManager.shared
    private let layout = UICollectionViewFlowLayout()
    private lazy var collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
    private let subtitle = UILabel()
    private let emptyLabel = UILabel()
    private let hint = PillLabel()

    /// Creates the screen. Pass startEditing: true to open it directly in edit mode.
    init(startEditing: Bool = false) {
        editMode = startEditing
        super.init(nibName: nil, bundle: nil)
    }

    /// Required by UIKit for storyboard loading. We build everything in code, so this is never
    /// used.
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// The cells to show: all tiles in edit mode, only tiles that have a voice in play mode, plus
    /// the Add button when editing.
    private var items: [BoardItem] {
        var list = (editMode ? store.tiles : store.tiles.filter { $0.hasAudio }).map { BoardItem.tile($0) }
        if editMode { list.append(.add) }
        return list
    }

    /// Runs once when the screen loads. Creates and positions the subtitle, grid, empty message,
    /// footer and hint, then starts listening for changes.
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.bg
        title = "Family Soundboard"
        navigationItem.largeTitleDisplayMode = .never

        subtitle.font = Fonts.make(17)
        subtitle.textColor = Palette.muted
        subtitle.numberOfLines = 0
        subtitle.prepared()

        layout.minimumInteritemSpacing = 14
        layout.minimumLineSpacing = 14
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
        collection.backgroundColor = .clear
        collection.dataSource = self
        collection.delegate = self
        collection.register(TileCell.self, forCellWithReuseIdentifier: TileCell.id)
        collection.register(AddCell.self, forCellWithReuseIdentifier: AddCell.id)
        collection.prepared()

        emptyLabel.text = "No sounds yet. Press and hold “Hold to edit”, then tap “Add a tile” to make your first one."
        emptyLabel.font = Fonts.make(18)
        emptyLabel.textColor = Palette.text
        emptyLabel.numberOfLines = 0
        emptyLabel.prepared()

        let footer = UILabel().prepared()
        footer.text = "Recordings stay on this device. Nothing is uploaded."
        footer.font = Fonts.make(13, style: .footnote)
        footer.textColor = Palette.muted
        footer.textAlignment = .center

        hint.text = "Press and hold to edit sounds"
        hint.font = Fonts.make(15)
        hint.backgroundColor = Palette.surface
        hint.textColor = Palette.text
        hint.insets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        hint.alpha = 0
        hint.prepared()

        [subtitle, collection, emptyLabel, footer, hint].forEach(view.addSubview)
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            subtitle.topAnchor.constraint(equalTo: safe.topAnchor, constant: 8),
            subtitle.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            subtitle.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            collection.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 4),
            collection.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            collection.bottomAnchor.constraint(equalTo: footer.topAnchor, constant: -4),
            footer.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            footer.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            footer.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -8),
            emptyLabel.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 24),
            emptyLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -24),
            hint.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hint.bottomAnchor.constraint(equalTo: footer.topAnchor, constant: -16)
        ])

        NotificationCenter.default.addObserver(self, selector: #selector(BoardViewController.tilesChanged), name: Notification.Name("tilesChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioChanged), name: .audioStateChanged, object: nil)
        refresh()
    }

    /// Stops listening for notifications when this screen is removed from memory.
    deinit { NotificationCenter.default.removeObserver(self) }

    /// Runs each time the screen is about to appear. Makes sure the navigation bar is visible.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    /// Runs when leaving the screen. If we are going back (not just opening the editor), stop any
    /// sound.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent { audio.stopAll() }
    }

    /// Runs when the device rotates. Recalculates the grid so tiles fit the new width.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in self.layout.invalidateLayout() }
    }

    /// Updates everything that depends on the mode: subtitle text, empty message, grid contents and
    /// the top-right button.
    private func refresh() {
        subtitle.text = editMode ? "Tap a picture to record or change it." : "Tap a picture to hear a familiar voice."
        emptyLabel.isHidden = !(items.isEmpty)
        collection.reloadData()
        updateNavItem()
    }

    /// Sets the top-right button: "Done editing" in edit mode, or a "Hold to edit" button (press
    /// for 1 second) in play mode.
    private func updateNavItem() {
        if editMode {
            let done = UIBarButtonItem(title: "Done editing", style: .prominent, target: self, action: #selector(doneEditing))
            done.tintColor = Palette.primary
            navigationItem.rightBarButtonItem = done
        } else {
            var c = UIButton.Configuration.plain()
            c.title = "Hold to edit"
            c.baseForegroundColor = Palette.text
            c.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14)
            c.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { a in
                var a = a
                a.font = Fonts.make(15, .medium)
                return a
            }
            let b = UIButton(configuration: c)
            b.layer.cornerRadius = 18
            b.layer.borderWidth = 1
            b.layer.borderColor = Palette.outline.resolvedColor(with: traitCollection).cgColor
            b.addTarget(self, action: #selector(showHint), for: .touchUpInside)
            let press = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
            press.minimumPressDuration = 1
            b.addGestureRecognizer(press)
            b.accessibilityHint = "Press and hold to edit sounds"
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: b)
        }
    }

    /// Called when tiles are saved or deleted. Reloads the screen.
    @objc private func tilesChanged() { refresh() }

    /// Called when a sound starts or stops. The playing tile grows and the others return to normal
    /// size.
    @objc private func audioChanged() {
        for case let cell as TileCell in collection.visibleCells {
            cell.setPlaying(audio.playingID == cell.tileID, animated: true)
        }
    }

    /// Leaves edit mode.
    @objc private func doneEditing() {
        editMode = false
        refresh()
    }

    /// Called once "Hold to edit" has been pressed for 1 second. Gives a small vibration and
    /// switches to edit mode. (The hold stops a baby from changing tiles by accident.)
    @objc private func longPressed(_ g: UILongPressGestureRecognizer) {
        guard g.state == .began else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        editMode = true
        refresh()
    }

    /// Called on a quick tap of "Hold to edit". Briefly shows a message saying you need to press
    /// and hold.
    @objc private func showHint() {
        UIView.animate(withDuration: 0.2) { self.hint.alpha = 1 }
        UIView.animate(withDuration: 0.3, delay: 2) { self.hint.alpha = 0 }
    }

    /// Opens the New/Edit tile screen full-screen for the given tile.
    private func openEditor(_ tile: Tile, isNew: Bool) {
        let vc = TileEditorViewController(tile: tile, isNew: isNew)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

/// These methods feed the grid with data and respond to taps.
extension BoardViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    /// How many cells the grid has.
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int { items.count }

    /// Creates (or reuses) the cell for a position: a tile cell, or the Add cell.
    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch items[indexPath.item] {
        case .tile(let tile):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: TileCell.id, for: indexPath) as! TileCell
            cell.configure(id: tile.id,
                           name: tile.name,
                           color: Palette.tile[tile.colorIndex % Palette.tile.count],
                           words: tile.words,
                           photo: store.image(tile.photoFile),
                           badge: editMode ? (tile.hasAudio ? "Edit" : "Record") : nil,
                           dimmed: editMode && !tile.hasAudio,
                           playing: audio.playingID == tile.id)
            return cell
        case .add:
            return cv.dequeueReusableCell(withReuseIdentifier: AddCell.id, for: indexPath)
        }
    }

    /// Called when a cell is tapped. Tile in edit mode: open the editor. Tile in play mode: play
    /// its voice. Add cell: open the editor for a brand-new tile.
    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch items[indexPath.item] {
        case .tile(let tile):
            if editMode {
                openEditor(tile, isNew: false)
            } else {
                audio.play(url: store.audioURL(tile.id), id: tile.id)
            }
        case .add:
            openEditor(store.newTile(), isNew: true)
        }
    }

    /// Decides each cell size: square, at least 150 wide, with as many columns as fit on the
    /// screen.
    func collectionView(_ cv: UICollectionView, layout l: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = cv.bounds.width - 32
        let columns = max(2, Int((width + 14) / (150 + 14)))
        let side = floor((width - CGFloat(columns - 1) * 14) / CGFloat(columns))
        return CGSize(width: side, height: side)
    }
}
