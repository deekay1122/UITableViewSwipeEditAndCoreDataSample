//
//  CustomTableViewCell.swift
//  CoreDataRelationshipPractice
//
//  Created by Daisaku Ejiri on 2022/11/15.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

  public static let identifier: String = "CustomTableViewCell"
  
  lazy var label: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = label.font.withSize(100)
    label.adjustsFontSizeToFitWidth = true
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.contentView.addSubview(label)
    layout()
  }
  
  private func layout() {
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
      label.topAnchor.constraint(equalTo: self.contentView.topAnchor),
      label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 10),
      label.bottomAnchor.constraint(equalTo: self.bottomAnchor),
    ])
  }
  
  public func configure(title: String) {
    label.text = title
  }
  
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
