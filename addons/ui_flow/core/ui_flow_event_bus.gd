class_name UIFlowEventBus extends RefCounted

## A lightweight pub/sub event bus for cross-page communication.
##
## Supports sticky events (new subscribers immediately receive the latest value)
## and automatic cleanup when a subscriber is freed.
##
## Usage:
## [codeblock]
## UIFlow.publish("gold_changed", 100)
## var token = UIFlow.subscribe("gold_changed", func(data): print(data))
## UIFlow.unsubscribe(token)
## [/codeblock]

class Subscription:
	var token: int
	var topic: String
	var callback: Callable
	var once: bool
	var subscriber: Object  ## Used for auto-cleanup

var _next_token: int = 1
var _subscriptions: Dictionary = {}   # token -> Subscription
var _topic_subs: Dictionary = {}      # topic -> Array[token]
var _sticky: Dictionary = {}          # topic -> data


## Publish an event to all subscribers of a topic.
func publish(topic: String, data: Variant = null) -> void:
	var tokens: Array = _topic_subs.get(topic, [])
	# Copy to avoid modification during iteration (unsubscribe from callback)
	var tokens_copy: Array = tokens.duplicate()
	for token in tokens_copy:
		var sub: Subscription = _subscriptions.get(token)
		if sub and sub.callback.is_valid():
			sub.callback.call(data)
			if sub.once:
				unsubscribe(token)


## Publish a sticky event. New subscribers will immediately receive this value.
## Existing subscribers are not notified; use [code]publish[/code] for live delivery.
func publish_sticky(topic: String, data: Variant = null) -> void:
	_sticky[topic] = data


## Subscribe to a topic. Returns a token for unsubscribing.
## [param subscriber] is optional; used for auto-cleanup when the subscriber is freed.
## [param once] if true, the subscription is removed after the first event.
func subscribe(topic: String, callback: Callable, subscriber: Object = null, once: bool = false) -> int:
	var token := _next_token
	_next_token += 1

	var sub := Subscription.new()
	sub.token = token
	sub.topic = topic
	sub.callback = callback
	sub.once = once
	sub.subscriber = subscriber

	_subscriptions[token] = sub
	if not _topic_subs.has(topic):
		_topic_subs[topic] = []
	_topic_subs[topic].append(token)

	# If sticky, immediately deliver the latest value
	if _sticky.has(topic):
		callback.call(_sticky[topic])

	return token


## Subscribe to a topic, auto-removing after the first event.
func subscribe_once(topic: String, callback: Callable, subscriber: Object = null) -> int:
	return subscribe(topic, callback, subscriber, true)


## Unsubscribe by token.
func unsubscribe(token: int) -> void:
	var sub: Subscription = _subscriptions.get(token)
	if sub == null:
		return
	_subscriptions.erase(token)
	var tokens: Array = _topic_subs.get(sub.topic, [])
	tokens.erase(token)
	if tokens.is_empty():
		_topic_subs.erase(sub.topic)


## Remove all subscriptions owned by a given subscriber.
func clear_subscriber(subscriber: Object) -> void:
	if subscriber == null:
		return
	var to_remove: Array[int] = []
	for token in _subscriptions.keys():
		var sub: Subscription = _subscriptions[token]
		if sub.subscriber == subscriber:
			to_remove.append(token)
	for token in to_remove:
		unsubscribe(token)


## Get the latest sticky value for a topic, or null if none.
func get_sticky(topic: String) -> Variant:
	return _sticky.get(topic, null)


## Clear all subscriptions and sticky values.
func clear() -> void:
	_subscriptions.clear()
	_topic_subs.clear()
	_sticky.clear()
