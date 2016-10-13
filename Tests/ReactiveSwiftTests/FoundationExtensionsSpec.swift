//
//  FoundationExtensionsSpec.swift
//  ReactiveSwift
//
//  Created by Neil Pankey on 5/22/15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

import Result
import Nimble
import Quick
import ReactiveSwift

extension Notification.Name {
	static let racFirst = Notification.Name(rawValue: "rac_notifications_test")
	static let racAnother = Notification.Name(rawValue: "rac_notifications_another")
}

class FoundationExtensionsSpec: QuickSpec {
	override func spec() {
		describe("NotificationCenter.reactive.notifications") {
			let center = NotificationCenter.default

			it("should send notifications on the producer") {
				let signal = center.reactive.notifications(forName: .racFirst)

				var notif: Notification? = nil
				let disposable = signal.observeValues { notif = $0 }

				center.post(name: .racAnother, object: nil)
				expect(notif).to(beNil())

				center.post(name: .racFirst, object: nil)
				expect(notif?.name) == .racFirst

				notif = nil
				disposable?.dispose()

				center.post(name: .racFirst, object: nil)
				expect(notif).to(beNil())
			}

			it("should be freed if it is not reachable and no observers is attached") {
				weak var signal: Signal<Notification, NoError>?

				let disposable: Disposable? = {
					let innerSignal = center.reactive.notifications(forName: nil)
					signal = innerSignal
					return innerSignal.observe { _ in }
				}()

				expect(signal).toNot(beNil())
				disposable?.dispose()

				expect(signal).to(beNil())
			}
		}
	}
}
