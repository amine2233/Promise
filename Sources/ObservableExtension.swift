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
    /// Convert this result into an `Promise.Result`. This implementation is optional.
    public var result: Result<Value,Error> {
        return Result(value, failWith: error!)
    }
}

extension Result {
    
    public init(block: () throws -> Value) {
        do {
            self = try .success(block())
        } catch let error {
            self = .failure(error as! Error)
        }
    }
    
    public var result: Result<Value, Error> {
        return self
    }
    
    /**
     Transform a result into another result using a function. If the result was an error,
     the function will not be executed and the error returned instead.
     */
    public func map<U,Error>(_ f: @escaping (Value) -> U) -> Result<U,Error> {
        switch self {
        case let .success(v): return .success(f(v))
        case let .failure(error): return .failure(error as! Error)
        }
    }
    
    /**
     Transform a result into another result using a function. If the result was an error,
     the function will not be executed and the error returned instead.
     */
    public func flatMap<U,Error>(_ f: (Value) -> Result<U,Error>) -> Result<U,Error> {
        switch self {
        case let .success(v): return f(v)
        case let .failure(error): return .failure(error as! Error)
        }
    }
    
    /**
     Transform a result into another result using a function. If the result was an error,
     the function will not be executed and the error returned instead.
     */
    public func flatMap<U,Error>(_ f: (Value) throws -> U) -> Result<U,Error> {
        return flatMap { t in
            do {
                return .success(try f(t))
            } catch let error {
                return .failure(error as! Error)
            }
        }
    }
    /**
     Transform a result into another result using a function. If the result was an error,
     the function will not be executed and the error returned instead.
     */
    public func flatMap<U,Error>(_ f:@escaping (Value, (@escaping(Result<U,Error>)->Void))->Void) -> (@escaping(Result<U,Error>)->Void)->Void {
        return { g in
            switch self {
            case let .success(v): f(v, g)
            case let .failure(error): g(.failure(error as! Error))
            }
        }
    }
}

/**
 Provide a default value for failed results.
 */
public func ?? <Value,Error> (result: Result<Value,Error>, defaultValue: @autoclosure () -> Value) -> Value {
    switch result {
    case .success(let x): return x
    case .failure: return defaultValue()
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

    /// Observables containing a Result<Value,Error> can be chained to only continue in the success case.
    public func then<U,Error>(_ transform: @escaping (T.Value) -> Result<U,Error>) -> Observable<Result<U,Error>> {
        return map { $0.result.flatMap(transform) }
    }
    
    /// Observables containing a Result<Value,Error> can be chained to only continue in the success case.
    public func then<U,Error>(_ transform: @escaping (T.Value) -> U) -> Observable<Result<U,Error>> {
        return map { $0.result.map(transform) }
    }
    
    /// Observables containing a Result<Value,Error> can be chained to only continue in the success case.
    public func then<U,Error>(_ transform: @escaping (T.Value) throws -> U) -> Observable<Result<U,Error>> {
        return map { $0.result.flatMap(transform) }
    }
    
    /// Observables containing a Result<Value,Error> can be chained to only continue in the success case.
    public func then<U,Error>(_ transform: @escaping (T.Value) -> Observable<U>) -> Observable<Result<U,Error>> {
        return flatMap { [options] in
            let observer = Observable<Result<U,Error>>(options: options)
            switch $0.result {
            case let .success(v): transform(v).subscribe { observer.update(.success($0))}
            case let .failure(error): observer.update(.failure(error as! Error))
            }
            return observer
        }
    }
    
    /// Observables containing a Result<Value,Error> can be chained to only continue in the success case.
    public func then<U,Error>(_ transform: @escaping (T.Value) -> Observable<Result<U,Error>>) -> Observable<Result<U,Error>> {
        return flatMap{ [options] in
            switch $0.result {
            case let .success(v): return transform(v)
            case let .failure(error): return Observable<Result<U,Error>>(Result.failure(error as! Error), options: options)
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
