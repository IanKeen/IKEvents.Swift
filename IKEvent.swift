//
//  IKEvent.swift
//
//  Created by Ian Keen on 9/08/2015.
//  Copyright (c) 2015 Mustard. All rights reserved.
//

import Foundation

private class IKEventListener<Parameters> {
    typealias EventClosure = (Parameters) -> Void
    
    weak var listener: AnyObject?
    let closure: AnyObject -> EventClosure
    let once: Bool
    
    init(listener: AnyObject, once: Bool, closure: AnyObject -> EventClosure) {
        self.listener = listener
        self.closure = closure
        self.once = once
    }
}

public class IKEvent<Parameters> {
    //MARK: - Internals
    public typealias EventClosure = (Parameters) -> Void
    private var listeners = [IKEventListener<Parameters>]()
    private var forwarding = [IKEvent<Parameters>]()
    
    //MARK: - Public
    public init() { }
    
    //MARK: - Public - Adding
    public func add<T: AnyObject>(listener: T, _ closure: T -> EventClosure) {
        self.addListener(listener, once: false, closure)
    }
    public func add<T: AnyObject>(listener: T, _ closure: EventClosure) {
        self.addListener(listener, once: false, { _ in closure })
    }
    public func once<T: AnyObject>(listener: T, _ closure: T -> EventClosure) {
        self.addListener(listener, once: true, closure)
    }
    public func once<T: AnyObject>(listener: T, _ closure: EventClosure) {
        self.addListener(listener, once: true, { _ in closure })
    }
    public func forward(event: IKEvent<Parameters>) {
        self.forwarding.append(event);
    }
    
    //MARK: - Public - Removing
    public func remove<T: AnyObject>(listener: T) {
        self.listeners = self.listeners.filter { $0 !== listener }
    }
    public func remove(event: IKEvent<Parameters>) {
        self.forwarding = self.forwarding.filter { $0 !== event }
    }
    
    //MARK: - Public - Notification
    public func notify(parameters: Parameters) {
        self.notifyForwarders(parameters)
        self.notifyListeners(parameters)
    }
    
    //MARK: - Private
    private func addListener<T: AnyObject>(listener: T, once: Bool, _ closure: T -> EventClosure) {
        let eventListener = IKEventListener(listener: listener, once: false, closure: { closure($0 as! T) })
        self.listeners.append(eventListener)
    }
    private func notifyListeners(parameters: Parameters) {
        for eventListener in self.listeners {
            if let listener: AnyObject = eventListener.listener {
                let closure = eventListener.closure(listener)
                closure(parameters)
            }
        }
        
        self.listeners = self.listeners.filter { $0.listener != nil && !$0.once }
    }
    private func notifyForwarders(parameters: Parameters) {
        for event in self.forwarding {
            event.notify(parameters)
        }
    }
}