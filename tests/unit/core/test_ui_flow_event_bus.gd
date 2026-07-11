## Tests for UIFlowEventBus — pub/sub with sticky support.
extends GdUnitTestSuite

var _bus: UIFlowEventBus


func before_test() -> void:
	_bus = UIFlowEventBus.new()


func after_test() -> void:
	_bus.clear()
	_bus = null


## Test: publish delivers to subscriber
func test_publish_delivers() -> void:
	var received: Array[int] = [0]
	var token: int = _bus.subscribe("test_topic", func(data):
		received[0] = data as int
	)
	_bus.publish("test_topic", 42)
	assert_that(received[0]).is_equal(42)
	_bus.unsubscribe(token)


## Test: publish does not deliver to unsubscribed topics
func test_publish_wrong_topic() -> void:
	var received: Array[int] = [0]
	var token: int = _bus.subscribe("topic_a", func(data):
		received[0] = data as int
	)
	_bus.publish("topic_b", 99)
	assert_that(received[0]).is_equal(0)
	_bus.unsubscribe(token)


## Test: sticky event delivers to new subscriber immediately
func test_sticky_immediate() -> void:
	_bus.publish_sticky("sticky_topic", "hello")
	var received: Array[String] = [""]
	var token: int = _bus.subscribe("sticky_topic", func(data):
		received[0] = data as String
	)
	assert_that(received[0]).is_equal("hello")
	_bus.unsubscribe(token)


## Test: get_sticky returns latest value
func test_get_sticky() -> void:
	_bus.publish_sticky("my_topic", 123)
	assert_that(_bus.get_sticky("my_topic")).is_equal(123)


## Test: get_sticky returns null for unknown topic
func test_get_sticky_missing() -> void:
	assert_that(_bus.get_sticky("unknown")).is_null()


## Test: unsubscribe removes callback
func test_unsubscribe() -> void:
	var received: Array[int] = [0]
	var token: int = _bus.subscribe("topic", func(data):
		received[0] = data as int
	)
	_bus.unsubscribe(token)
	_bus.publish("topic", 99)
	assert_that(received[0]).is_equal(0)


## Test: subscribe_once auto-removes after first event
func test_subscribe_once() -> void:
	var count: Array[int] = [0]
	var token: int = _bus.subscribe_once("topic", func(_data):
		count[0] += 1
	)
	_bus.publish("topic", 1)
	_bus.publish("topic", 2)
	assert_that(count[0]).is_equal(1)


## Test: clear_subscriber removes all subscriptions for an object
func test_clear_subscriber() -> void:
	var owner = Node.new()
	var received: Array[int] = [0]
	var token1: int = _bus.subscribe("topic_a", func(_data): received[0] += 1, owner)
	var token2: int = _bus.subscribe("topic_b", func(_data): received[0] += 1, owner)
	_bus.clear_subscriber(owner)
	_bus.publish("topic_a", 1)
	_bus.publish("topic_b", 2)
	assert_that(received[0]).is_equal(0)
	owner.queue_free()


## Test: multiple subscribers receive same event
func test_multiple_subscribers() -> void:
	var count: Array[int] = [0]
	var token1: int = _bus.subscribe("topic", func(_data): count[0] += 1)
	var token2: int = _bus.subscribe("topic", func(_data): count[0] += 1)
	_bus.publish("topic", 1)
	assert_that(count[0]).is_equal(2)
	_bus.unsubscribe(token1)
	_bus.unsubscribe(token2)


## Test: clear removes all subscriptions and sticky data
func test_clear() -> void:
	var received: Array[int] = [0]
	var token: int = _bus.subscribe("topic", func(data): received[0] = data as int)
	_bus.publish_sticky("topic", 42)
	_bus.clear()
	_bus.publish("topic", 99)
	assert_that(received[0]).is_equal(0)
	assert_that(_bus.get_sticky("topic")).is_null()
