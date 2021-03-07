//
//  BaseViewModelType.swift
//  InnoTechHomework
//
//  Created by Derek_Lin on 2021/3/5.
//  Copyright © 2021 Derek_Lin. All rights reserved.
//

protocol ViewModelType: AnyObject {

    associatedtype InputType

    associatedtype OutputType

    func transform(_ input: InputType) -> OutputType
}

public class BaseViewModel<Input, Output>: ViewModelType {

    private let _transform: (Input) -> Output

    init<V: ViewModelType>(_ viewModel: V) where
        V.InputType == Input,
        V.OutputType == Output {
        self._transform = viewModel.transform
    }

    func transform(_ input: Input) -> Output {
        return _transform(input)
    }
}
