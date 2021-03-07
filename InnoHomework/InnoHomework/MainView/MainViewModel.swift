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
    public var dataSource = [DataModel]()
}

extension MainViewModel: ViewModelType {
    struct Input {
        let trigger: ControlEvent<Void>
        let filter: ControlProperty<String?>
    }

    struct Output {
        let data: Driver<[DataModel]>
        let isFetching: Signal<Bool>
        let error: Signal<NetworkError>
    }

    func transform(_ input: Input) -> Output {
        let errorTracker = PublishRelay<NetworkError>()
        let isFetching = PublishRelay<Bool>()
        let model = input.trigger.flatMap { _ -> Observable<[DataModel]> in
            return Observable<[DataModel]>.create { [weak self] (observer) -> Disposable in
                isFetching.accept(true)
                self?.apiManager.retriveData(from: PlaceholderEndpoint(), completion: { (result) in
                    switch result {
                    case .success(let response):
                        observer.onNext(response)
                        observer.onCompleted()
                    case .failure(let error):
                        if let error = error as? NetworkError {
                            errorTracker.accept(error)
                        }
                        observer.onError(error)
                    }
                    isFetching.accept(false)
                })
                return Disposables.create()
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
        }
        return Output(data: outputData.asDriver(onErrorJustReturn: [DataModel]()), isFetching: isFetching.asSignal(), error: errorTracker.asSignal())
    }
}
