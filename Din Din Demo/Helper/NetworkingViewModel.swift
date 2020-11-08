//
//  NetworkingViewModel.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 9/11/20.
//

import Foundation
import RxSwift

public protocol NetworkingViewModel {
    associatedtype EventType: MapsToNetworkEvent

    var events: PublishSubject<EventType> { get }
}

public protocol MapsToNetworkEvent {
    func toNetworkEvent() -> NetworkingUIEvent<()>?
}

public enum NetworkingUIEvent<ResponseType> {
    case waiting
    case succeeded(ResponseType)
    case failed(Error)

    public func ignoreResponse() -> NetworkingUIEvent<()> {
        switch self {
            case .succeeded:
                return .succeeded(())
            case .failed(let error):
                return .failed(error)
            case .waiting:
                return .waiting
        }
    }
}

extension NetworkingUIEvent: Equatable {

    public static func == (lhs: NetworkingUIEvent, rhs: NetworkingUIEvent) -> Bool {
        switch (lhs, rhs) {
            case (.waiting, .waiting):
                return true
            case (.succeeded, .succeeded):
                return true
            case (.failed(let errorA), .failed(let errorB)):
                return errorA.localizedDescription == errorB.localizedDescription
            default:
                return false
        }
    }
}
