//
//  HUD.swift
//  InnoTechHomework
//
//  Created by Derek_Lin on 2021/3/8.
//  Copyright © 2021 Derek_Lin. All rights reserved.
//

import Foundation
import UIKit

public protocol ChrysanthemumSpinnerCompatible {
    var chrysanthemumSpinner: ChrysanthemumContainer { get }
}
extension UIView: ChrysanthemumSpinnerCompatible {
    public var chrysanthemumSpinner: ChrysanthemumContainer {
        return ChrysanthemumContainer(self)
    }
}
extension UIViewController: ChrysanthemumSpinnerCompatible {
    public var chrysanthemumSpinner: ChrysanthemumContainer {
        return ChrysanthemumContainer(view)
    }
}
public struct ChrysanthemumContainer {
    let base: UIView
    init(_ base: UIView) {
        self.base = base
    }
    func start() {
        guard base.subviews.filter({ ($0 as? ChrysanthemumSpinnerView) != nil }).isEmpty else { return }
        let spinner = ChrysanthemumSpinnerView()
        base.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: base.centerYAnchor).isActive = true
        spinner.widthAnchor.constraint(equalToConstant: 100).isActive = true
        spinner.heightAnchor.constraint(equalToConstant: 100).isActive = true
        spinner.setup()
        base.isUserInteractionEnabled = false
        CATransaction.flush()
    }
    func stop() {
        let spinners = base.subviews.map({ $0 as? ChrysanthemumSpinnerView }).compactMap({ $0 })
        spinners.forEach({ $0.removeFromSuperview() })
        base.isUserInteractionEnabled = true
    }
    private class ChrysanthemumSpinnerView: UIView {
        let chrysanthemum = UIActivityIndicatorView()
        func setup() {
            backgroundColor = UIColor.black.withAlphaComponent(0.8)
            layer.cornerRadius = 20
            layer.masksToBounds = true
            addSubview(chrysanthemum)
            chrysanthemum.style = .whiteLarge
            chrysanthemum.translatesAutoresizingMaskIntoConstraints = false
            chrysanthemum.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
            chrysanthemum.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
            chrysanthemum.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30).isActive = true
            chrysanthemum.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30).isActive = true
            chrysanthemum.startAnimating()
        }
    }
}
