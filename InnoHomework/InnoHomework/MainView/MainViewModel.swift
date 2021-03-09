//
//  MainViewModel.swift
//  InnoHomework
//
//  Created by Derek_Lin on 2021/3/8.
//  Copyright © 2021 Derek_Lin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MainViewModel {
    private let apiManager: Service = APIManager()
    private var dataSource = [DataModel]()
}

extension MainViewModel: ViewModelType {
    struct Input {
        let trigger: ControlEvent<Void>
        let filter: ControlProperty<String?>
        let selectEvent: ControlEvent<IndexPath>
    }

    struct Output {
        let data: Driver<[DataModel]>
        let isFetching: Signal<Bool>
        let error: Signal<NetworkError>
        let selectedItem: Signal<(IndexPath, DataModel)>
    }

    func transform(_ input: Input) -> Output {
        let errorTracker = PublishRelay<NetworkError>()
        let isFetching = PublishRelay<Bool>()

        let model = input.trigger.flatMap { [weak self] (_) -> Observable<[DataModel]> in
            guard let self = self else { return Observable.just([DataModel]())}
            return self.apiManager.retriveData(from: PlaceholderEndpoint())
                .do { (_) in
                } onError: { (error) in
                    if let error = error as? NetworkError {
                        errorTracker.accept(error)
                    }
                } onSubscribed: {
                    isFetching.accept(true)
                } onDispose: {
                    isFetching.accept(false)
                }

        }

        let outputData = Observable.combineLatest(model, input.filter).map { [weak self] (list, filterString) -> [DataModel] in
            if let filterString = filterString, filterString.isEmpty == false {
                let filterList = list.filter({ ($0.title ?? "").contains(filterString) })
                self?.dataSource = filterList
                return filterList
            } else {
                self?.dataSource = list
                return list
            }
        }.asDriver(onErrorJustReturn: [DataModel]())

        let selectedItem = input.selectEvent.map { [weak self] (indexPath) -> (IndexPath, DataModel) in
            let model = self?.dataSource[safe: indexPath.row] ?? DataModel()
            return (indexPath, model)
        }.asSignal(onErrorJustReturn: (IndexPath.init(row: 0, section: 0), DataModel()))

        return Output(data: outputData, isFetching: isFetching.asSignal(), error: errorTracker.asSignal(), selectedItem: selectedItem)
    }
}
