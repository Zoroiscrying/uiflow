## Loading page used by async progress tests; records set_progress calls
## in a static log so tests can inspect them after the page is removed.
class_name AsyncProgressLoadingPage extends UIFlowPage

static var progress_log: Array = []


func set_progress(p: float) -> void:
	progress_log.append(p)
