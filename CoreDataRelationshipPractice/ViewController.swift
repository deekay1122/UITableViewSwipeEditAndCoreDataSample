//
//  ViewController.swift
//  CoreDataRelationshipPractice
//
//  Created by Daisaku Ejiri on 2022/11/15.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

  let dataService = DataService.shared
  let bag = DisposeBag()
  var songs: [Song] = []
  
  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identifier)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.dragDelegate = self
    tableView.dropDelegate = self
    
    return tableView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Manage Songs"
    navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped)), animated: true)
    view.backgroundColor = .white
    view.addSubview(tableView)
    
    dataService.projectRelay.subscribe(onNext: { [weak self] project in
      if let project = project {
        self?.songs = project.songs?.array as! [Song]
      }
    })
    .disposed(by: bag)
  }
  
  @objc private func addTapped() {
    var alertTextField: UITextField?
    let alert = UIAlertController(title: "Enter New Song Title", message: nil, preferredStyle: UIAlertController.Style.alert)
    alert.addTextField(configurationHandler: { (textField: UITextField!) in
      alertTextField = textField
    })
    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel))
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { _ in
      if let text = alertTextField?.text {
        if self.dataService.checkUnique(title: text) {
          self.dataService.addNewSong(title: text)
          self.tableView.reloadData()
        } else {
          let existsAlert = UIAlertController(title: "That song name already exists", message: nil, preferredStyle: UIAlertController.Style.alert)
          existsAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default))
          self.present(existsAlert, animated: true)
        }
      }
    })
    self.present(alert, animated: true)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    layout()
  }

  private func layout() {
    tableView.frame = view.bounds
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    songs.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifier, for: indexPath) as! CustomTableViewCell
    cell.configure(title: songs[indexPath.row].title!)
    return cell
  }
}

extension ViewController: UITableViewDragDelegate {
  func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
    tableView.cellForRow(at: indexPath)
    session.localContext = tableView
    let itemProvider = NSItemProvider(object: "\(indexPath.row)" as NSString)
    let dragItem = UIDragItem(itemProvider: itemProvider)
    dragItem.localObject = indexPath.row
    return [dragItem]
  }
}

extension ViewController: UITableViewDropDelegate {
  
  func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
    let isSelf = (session.localDragSession?.localContext as? UITableView) == tableView
    return UITableViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
  }
  
  func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
    for item in coordinator.items {
      if let sourceIndexPath = item.sourceIndexPath {
        tableView.performBatchUpdates {
          let song = songs.remove(at: sourceIndexPath.row)
          songs.insert(song, at: destinationIndexPath.row)
          tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
          tableView.insertRows(at: [destinationIndexPath], with: .automatic)
        }
      }
    }
    dataService.updateReorderedSongs(songs: songs)
  }
}

extension ViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    var song: Song?
    let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
      tableView.performBatchUpdates {
        song = self.songs.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
      }
      self.dataService.deleteSongAndUpdate(song: song!, songs: self.songs)
      self.tableView.reloadData()
    }
    return UISwipeActionsConfiguration(actions: [deleteAction])
  }
  
  func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let cell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
    guard let title = cell.label.text else { fatalError("error when getting text from cell label in swipe delete action")}
    var alertTextField: UITextField?
    let editAction = UIContextualAction(style: .normal, title: "edit") { (action, view, handler) in
      let alert = UIAlertController(title: "Edit song title", message: nil, preferredStyle: UIAlertController.Style.alert)
      alert.addTextField(configurationHandler: { (textField: UITextField!) in
        alertTextField = textField
        alertTextField?.text = title
      })
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { _ in
        if let text = alertTextField?.text {
          if title != text {
            if self.dataService.checkUnique(title: text) {
              self.songs[indexPath.row].title = text
              self.tableView.reloadData()
            } else {
              let existsAlert = UIAlertController(title: "That song name already exists", message: nil, preferredStyle: UIAlertController.Style.alert)
              existsAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default))
              self.present(existsAlert, animated: true)
            }
          }
        }
      })
      self.present(alert, animated: true)
    }
    editAction.backgroundColor = .systemGreen
    return UISwipeActionsConfiguration(actions: [editAction])
  }
}



