//
//  ObservableExtension.swift
//  Promise
//
//  Created by Amine Bensalah on 25/07/2018.
//

import Foundation
import Reactive
import Result

extension Observable {
    public func map<U, Error>(_ transform: @escaping (T) throws -> U) -> Observable<Result<U, Error>> {
        let observable = Observable<Result<U, Error>>(options: options)
        subscribe { value in
            observable.update(Result(block: { return try transform(value) }))
        }
        return observable
    }
}

extension Observable where T: ResultProtocol {

    /// Observables containing a Result<Value,Error> can be chained to only continue in the success case.
    public func then<U, Error>(_ transform: @escaping (T.Value) -> Result<U, Error>) -> Observable<Result<U, Error>> {
        return map { $0.result.flatMap(transform) }
    }

    /// Observables containing a Result<Value,Error> can be chained to only continue in the success case.
    public func then<U, Error>(_ transform: @escaping (T.Value) -> U) -> Observable<Result<U, Error>> {
        return map { $0.result.map(transform) }
    }

    /// Observables containing a Result<Value,Error> can be chained to only continue in the success case.
    public func then<U, Error>(_ transform: @escaping (T.Value) throws -> U) -> Observable<Result<U, Error>> {
        return map { $0.result.flatMap(transform) }
    }

    /// Observables containing a Result<Value,Error> can be chained to only continue in the success case.
    public func then<U, Error>(_ transform: @escaping (T.Value) -> Observable<U>) -> Observable<Result<U, Error>> {
        return flatMap { [options] in
            let observer = Observable<Result<U, Error>>(options: options)
            switch $0.result {
            case let .success(value): transform(value).subscribe { observer.update(.success($0))}
            case let .failure(error): observer.update(.failure(error as! Error))
            }
            return observer
        }
    }

    /// Observables containing a Result<Value,Error> can be chained to only continue in the success case.
    public func then<U, Error>(_ transform: @escaping (T.Value) -> Observable<Result<U, Error>>) -> Observable<Result<U, Error>> {
        return flatMap { [options] in
            switch $0.result {
            case let .success(value): return transform(value)
            case let .failure(error): return Observable<Result<U, Error>>(Result.failure(error as! Error), options: options)
            }
        }
    }

    /// Only subscribe to successful events.
    @discardableResult
    public func next(_ block: @escaping (T.Value) -> Void) -> Observable<T> {
        subscribe { result in
            if let value = result.value {
                block(value)
            }
        }
        return self
    }

    /// Only subscribe to errors.
    @discardableResult
    public func error(_ block: @escaping (Error) -> Void) -> Observable<T> {
        subscribe { result in
            if let error = result.error {
                block(error)
            }
        }
        return self
    }

    /// Peek at the value of the observable.
    public func peek() -> T.Value? {
        return self.value?.value
    }
}
