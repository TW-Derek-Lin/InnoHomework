//
//  ViewController.swift
//  InnoHomework
//
//  Created by Derek_Lin on 2021/3/7.
//  Copyright © 2021 Derek_Lin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class MainViewController: UIViewController {
    let viewModel = MainViewModel()

    private let searchBar = UISearchBar()
    private let tableView = UITableView()

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        KingfisherManager.shared.cache.maxMemoryCost = 100 * 1024 * 1024
        KingfisherManager.shared.cache.maxDiskCacheSize = 300 * 1024 * 1024
        setupUI()
        bindingViewModel()
    }

    private func setupUI() {
        navigationItem.titleView = searchBar
        tableView.register(MainCell.self, forCellReuseIdentifier: MainCell.reuseIdentifier())
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        tableView.estimatedRowHeight = 100;
        tableView.rowHeight = UITableView.automaticDimension;
    }

    private func bindingViewModel() {
        searchBar.rx.searchButtonClicked.bind { [weak self] (_) in
            self?.searchBar.searchTextField.resignFirstResponder()
        }.disposed(by: disposeBag)

        searchBar.rx.value.map({ $0?.isEmpty == true }).bind { [weak self] (value) in
            if value {
                DispatchQueue.main.async {
                    self?.searchBar.searchTextField.resignFirstResponder()
                }
            }
        }.disposed(by: disposeBag)

        tableView.rx.itemSelected.bind { [weak self] (indexPath) in
            self?.tableView.deselectRow(at: indexPath, animated: true)
            if let model = self?.viewModel.dataSource[safe: indexPath.row] {
                print("\(model)")
            }
        }.disposed(by: disposeBag)

        let input = MainViewModel.Input(trigger: rx.viewDidAppear, filter: searchBar.rx.text)
        let output = viewModel.transform(input)

        output.data.drive(onNext: { [weak self] (_) in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)

        output.data.drive(tableView.rx.items(cellIdentifier: MainCell.reuseIdentifier(), cellType: MainCell.self)) { [weak self] (row, data, cell) in
            cell.config(data, reload: { [weak self] in
                let indexPath = IndexPath(row: row, section: 0)
                if self?.tableView.indexPathsForVisibleRows?.contains(indexPath) == true {
                    self?.tableView.beginUpdates()
                    self?.tableView.endUpdates()
                }
            })
        }.disposed(by: disposeBag)

        output.isFetching.emit { [weak self] (isFetching) in
            if isFetching {
                self?.chrysanthemumSpinner.start()
            } else {
                self?.chrysanthemumSpinner.stop()
            }
        }.disposed(by: disposeBag)

        output.error.emit { [weak self] (error) in
            let alert = UIAlertController(title: "Error", message: error.description, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }.disposed(by: disposeBag)
    }
}

public extension Reactive where Base: UIViewController {
    var viewDidAppear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidAppear)).map { _ in }
        return ControlEvent(events: source)
    }
}

