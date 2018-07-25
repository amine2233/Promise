//
//  ObservableExtension.swift
//  Promise
//
//  Created by Amine Bensalah on 25/07/2018.
//

import Foundation
import Reactive
import Result

extension ResultProtocol {
    public var result: Result<Value,Error> {
        return Result(value, failWith: error!)
    }
}

extension Result {
    public init(block: () throws -> Value) {
        do {
            self = try .success(block())
        } catch let e {
            self = .failure(e)
        }
    }
    
    public var result: Result<Value, Error> {
        return self
    }
}
public extension Observable {
    public func map<U,Error>(_ transform: @escaping (T) throws -> U) -> Observable<Result<U,Error>> {
        let observable = Observable<Result<U,Error>>(options: options)
        subscribe { value in
            observable.update(Result(block: { return try transform(value) }))
        }
        return observable
    }
}

public extension Observable where T: ResultProtocol {
    
    public func then<U,Error>(_ transform: @escaping (T.Value) -> Result<U,Error>) -> Observable<Result<U,Error>> {
        return map { $0.result.flatMap(transform)}
    }
    
    public func then<U,Error>(_ transform: @escaping (T.Value) -> U) -> Observable<Result<U,Error>> {
        return map { $0.result.map(transform)}
    }
    
    public func then<U,Error>(_ transform: @escaping (T.Value) throws -> U) -> Observable<Result<U,Error>> {
        return map { $0.result.flatMap(transform) }
    }
    
    public func then<U,Error>(_ transform: @escaping (T.Value) -> Observable<U>) -> Observable<Result<U,Error>> {
        return flatMap { [options] in
            let observer = Observable<Result<U,Error>>(options: options)
            switch $0.result {
            case let .success(v): transform(v).subscribe { observer.update(.success($0))}
            case let .error(error): observer.update(.error(error))
            }
            return observer
        }
    }
    
    public func then<U,Error>(_ transform: @escaping (T.Value) -> Observable<Result<U,Error>>) -> Observable<Result<U,Error>> {
        return flatMap{ [options] in
            switch $0.result {
            case let .success(v): return transform(v)
            case let .error(error): return Observable<Result<U,Error>>(Result.error(error), options: options)
            }
        }
    }
    
    @discardableResult
    public func next(_ block: @escaping (T.Value) -> Void) -> Observable<T> {
        subscribe { result in
            if let value = result.value {
                block(value)
            }
        }
        return self
    }
    
    @discardableResult
    public func error(_ block: @escaping (Error) -> Void) -> Observable<T> {
        subscribe { result in
            if let error = result.error {
                block(error)
            }
        }
        return self
    }
    
    public func peek() -> T.Value? {
        return self.value?.value
    }
}
