//
//  MainCell.swift
//  InnoTechHomework
//
//  Created by Derek_Lin on 2021/3/8.
//  Copyright © 2021 Derek_Lin. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class MainCell: UITableViewCell {
    private let imgView = UIImageView()
    private let titleLabel = UILabel()
    private var task: RetrieveImageTask? = nil
    private var reloadDo: (() -> Void)? = nil
    class func reuseIdentifier() -> String {
        return "MainCell"
    }
    override var reuseIdentifier: String? {
        return MainCell.reuseIdentifier()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        reloadDo = nil
        task?.cancel()
        task = nil
        imgView.image = nil
    }

    private func setupUI() {
        imgView.contentMode = .scaleAspectFit
        contentView.addSubview(imgView)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)

        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0).isActive
         = true
        imgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive
         = true
        imgView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -8.0).isActive = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: imgView.bottomAnchor, constant: 8).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0).isActive = true

    }
    func config(_ data: DataModel, reload: @escaping (() -> Void)) {
        reloadDo = reload
        if let urlString = data.thumbnailUrl, let url = URL(string: urlString) {
            task = imgView.kf.setImage(with: url, completionHandler: { [weak self] _,_,_,_ in self?.reloadDo?() })
        }
        titleLabel.text = data.title
    }
}
