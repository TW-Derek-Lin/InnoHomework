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
