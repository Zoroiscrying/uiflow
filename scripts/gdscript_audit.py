## GDScript static analysis and auto-fix tool
## Usage: run `python scripts/gdscript_audit.py` from the project root
## Checks:
##   1. UIFlow.push_instance(X.new()) misuse pattern
##   2. Undeclared identifiers on the left side of assignments (excluding Godot built-in properties)
##   3. Class member variables assigned inside functions but not declared at the top of the class

import re
import os
import sys
from pathlib import Path

# Godot built-in properties (no var declaration needed when assigning)
GODOT_PROPERTIES = {
    # Node
    'name', 'owner', 'process_mode', 'process_priority', 'process_physics_priority',
    'physics_interpolation_mode', 'auto_translate', 'editor_description',
    'scene_file_path', 'unique_name_in_owner', 'multiplayer', 'custom_multiplayer',
    'process_callback',
    # CanvasItem
    'visible', 'modulate', 'self_modulate', 'show_behind_parent', 'top_level',
    'clip_children', 'light_mask', 'visibility_layer', 'z_index', 'z_as_relative',
    'y_sort_enabled', 'texture_filter', 'texture_repeat', 'material',
    'use_parent_material', 'canvas_item',
    # Control
    'anchor_left', 'anchor_top', 'anchor_right', 'anchor_bottom',
    'offset_left', 'offset_top', 'offset_right', 'offset_bottom',
    'grow_horizontal', 'grow_vertical', 'size_flags_horizontal', 'size_flags_vertical',
    'size_flags_stretch_ratio', 'localize_numeral_system', 'tooltip_text',
    'focus_neighbor_left', 'focus_neighbor_top', 'focus_neighbor_right',
    'focus_neighbor_bottom', 'focus_next', 'focus_previous', 'focus_mode',
    'mouse_filter', 'mouse_default_cursor_shape', 'shortcut_context', 'theme',
    'theme_type_variation', 'layout_direction', 'size', 'position', 'global_position',
    'rotation', 'rotation_degrees', 'scale', 'pivot_offset', 'custom_minimum_size',
    'min_size', 'max_size', 'size_2d_override', 'size_2d_override_stretch',
    # Range / ProgressBar / Slider / SpinBox
    'value', 'min_value', 'max_value', 'step', 'rounded', 'allow_greater',
    'allow_lesser', 'ratio', 'exp_edit', 'editable',
    # ScrollContainer
    'scroll_horizontal', 'scroll_vertical', 'horizontal_scroll_mode',
    'vertical_scroll_mode', 'scroll_deadzone',
    # GridContainer
    'columns',
    # TabContainer
    'current_tab', 'tabs_visible', 'all_tabs_in_front', 'tab_alignment',
    'clip_tabs', 'use_hidden_tabs_for_min_size', 'drag_to_rearrange_enabled',
    'tab_focus_mode',
    # ItemList
    'select_mode', 'allow_reselect', 'allow_rmb_select', 'auto_height',
    'same_column_width', 'fixed_column_width', 'icon_mode', 'icon_scale',
    'max_columns', 'max_text_lines', 'fixed_icon_size',
    # RichTextLabel
    'bbcode_enabled', 'text', 'fit_content', 'scroll_active', 'scroll_following',
    'autowrap_mode', 'tab_size', 'shortcut_keys_enabled', 'custom_effects',
    'threaded', 'progress_bar_delay',
    # Tree
    'columns', 'column_titles_visible', 'allow_reselect', 'allow_rmb_select',
    'hide_folding', 'hide_root', 'select_mode', 'scroll_horizontal',
}

# Global built-in functions/classes/constants
BUILTINS = {
    'true', 'false', 'null', 'self', 'super', 'PI', 'TAU', 'INF', 'NAN',
    'int', 'float', 'bool', 'String', 'Vector2', 'Vector3', 'Vector2i', 'Vector3i',
    'Rect2', 'Rect2i', 'Transform2D', 'Transform3D', 'Plane', 'Quaternion', 'AABB',
    'Basis', 'Projection', 'Color', 'NodePath', 'RID', 'Object', 'Callable', 'Signal',
    'Dictionary', 'Array', 'PackedByteArray', 'PackedInt32Array', 'PackedInt64Array',
    'PackedFloat32Array', 'PackedFloat64Array', 'PackedStringArray', 'PackedVector2Array',
    'PackedVector3Array', 'PackedColorArray', 'PackedVector4Array',
    'Input', 'OS', 'Engine', 'Time', 'ProjectSettings', 'ResourceLoader', 'ResourceSaver',
    'FileAccess', 'DirAccess', 'JSON', 'Marshalls', 'Crypto', 'HashingContext',
    'IP', 'Performance', 'PhysicsServer2D', 'PhysicsServer3D', 'RenderingServer',
    'TextServer', 'Thread', 'Semaphore', 'Mutex', 'WorkerThreadPool',
    'UIFlow', 'UIFlowBindUtils', 'UIFlowPage', 'UIFlowNavigator', 'UIFlowSceneResolver',
    'UIFlowEventBus', 'UIFlowInputActionNode', 'UIFlowThemeDictionary',
    'UIFlowVirtualList', 'UIFlowDataGrid', 'UIFlowInventoryGrid', 'UIFlowTreeView',
    'UIFlowChartView', 'UIFlowRichTextPanel', 'UIFlowWorldUI', 'UIFlowLogger',
    'get_tree', 'preload', 'load', 'print', 'printerr', 'push_error', 'push_warning',
    'assert', 'char', 'range', 'str', 'len', 'round', 'floor', 'ceil', 'abs', 'sign',
    'min', 'max', 'clamp', 'lerp', 'inverse_lerp', 'remap', 'smoothstep', 'move_toward',
    'deg_to_rad', 'rad_to_deg', 'snap', 'wrap', 'randf', 'randi', 'randf_range', 'randi_range',
    'rand_from_seed', 'seed', 'weakref', 'funcref', 'typeof', 'str_to_var', 'var_to_str',
    'str_to_bytes', 'bytes_to_str', 'var_to_bytes', 'bytes_to_var', 'var_to_bytes_with_objects',
    'bytes_to_var_with_objects', 'convert', 'dict_to_inst', 'inst_to_dict', 'hash',
    'is_instance_of', 'is_instance_valid', 'is_same', 'deep_equal', 'type_exists',
    'class_exists', 'instance_from_id', 'free', 'queue_free', 'emit', 'connect', 'disconnect',
    'set_deferred', 'call_deferred', 'create_tween', 'create_timer', 'tween', 'await',
    'get_parent', 'get_children', 'get_node', 'get_node_or_null', 'find_child', 'find_children',
    'has_node', 'add_child', 'remove_child', 'move_child', 'get_child', 'get_child_count',
    'get_index', 'get_path', 'get_path_to', 'is_ancestor_of', 'is_greater_than',
    'print_tree', 'print_tree_pretty', 'propagate_call', 'propagate_notification',
    'set_physics_process', 'set_process', 'set_process_input', 'set_process_unhandled_input',
    'set_process_unhandled_key_input', 'get_viewport', 'get_window', 'get_theme',
    'get_theme_color', 'get_theme_font', 'get_theme_icon', 'get_theme_stylebox',
    'get_theme_constant', 'get_theme_default_base_scale', 'get_theme_default_font',
    'get_theme_default_font_size', 'get_theme_item', 'has_theme_color', 'has_theme_font',
    'has_theme_icon', 'has_theme_stylebox', 'has_theme_constant', 'add_theme_color_override',
    'add_theme_font_override', 'add_theme_font_size_override', 'add_theme_icon_override',
    'add_theme_stylebox_override', 'add_theme_constant_override', 'remove_theme_color_override',
    'remove_theme_font_override', 'remove_theme_font_size_override', 'remove_theme_icon_override',
    'remove_theme_stylebox_override', 'remove_theme_constant_override', 'get_mouse_filter',
    'set_mouse_filter', 'get_focus_mode', 'set_focus_mode', 'grab_focus', 'release_focus',
    'get_focus_next', 'set_focus_next', 'get_focus_previous', 'set_focus_previous', 'find_next_valid_focus',
    'find_prev_valid_focus', 'get_focus_owner', 'get_shortcut_context', 'set_shortcut_context',
    'set_default_cursor_shape', 'get_default_cursor_shape', 'get_cursor_shape',
    'get_theme_icon', 'get_constant', 'get_font', 'get_font_size', 'get_color', 'get_stylebox',
    'has_constant', 'has_font', 'has_font_size', 'has_color', 'has_stylebox', 'has_icon',
    'get_minimum_size', 'get_combined_minimum_size', 'set_anchors_preset', 'set_offsets_preset',
    'set_size', 'set_position', 'set_global_position', 'get_size', 'get_position', 'get_global_position',
    'get_rect', 'get_global_rect', 'set_custom_minimum_size', 'get_custom_minimum_size',
    'set_layout_direction', 'get_layout_direction', 'is_layout_rtl', 'set_auto_translate',
    'is_auto_translating', 'set_localize_numeral_system', 'is_localizing_numeral_system',
    'get_theme_type_variation', 'set_theme_type_variation', 'begin_bulk_theme_override',
    'end_bulk_theme_override', 'add_theme_item_override', 'remove_theme_item_override',
    'get_theme_item', 'get_theme_item_list', 'get_theme_color_list', 'get_theme_font_list',
    'get_theme_font_size_list', 'get_theme_icon_list', 'get_theme_stylebox_list', 'get_theme_constant_list',
    'get_parent_control', 'set_anchor', 'get_anchor', 'set_offset', 'get_offset', 'set_grow_direction',
    'get_grow_direction', 'set_pivot_offset', 'get_pivot_offset', 'get_screen_position',
    'get_screen_rect', 'get_tooltip', 'set_tooltip', 'set_focus_neighbor', 'get_focus_neighbor',
    'set_h_size_flags', 'get_h_size_flags', 'set_v_size_flags', 'get_v_size_flags', 'set_stretch_ratio',
    'get_stretch_ratio', 'set_layout_mode', 'get_layout_mode', 'set_anchors_and_offsets_preset',
    'set_anchor_and_offset', 'set_begin', 'set_end', 'get_begin', 'get_end', 'get_anchors_preset',
    'get_offsets_preset', 'set_h_grow_direction', 'get_h_grow_direction', 'set_v_grow_direction',
    'get_v_grow_direction', 'get_layout_direction', 'set_layout_direction', 'is_layout_rtl',
    'get_theme_type_variation', 'set_theme_type_variation', 'get_theme_default_base_scale',
    'get_theme_default_font', 'get_theme_default_font_size',
    # UIFlow framework properties (defined in base classes, no need for var declaration)
    'starts_hidden', 'enter_effect', 'exit_effect', 'is_modal', 'is_animating', 'is_active', 'get_state',
    'data', 'drag_icon', 'long_press_duration', 'is_dragging', 'drag_started', 'drag_ended', 'dropped',
    'can_drop', 'on_drop', 'on_hover', 'on_leave', 'accept_drop', 'reject_drop',
    'effect_type', 'duration', 'ease_type', 'trans_type', 'from_current', 'to_alpha', 'from_alpha',
    'from_scale', 'to_scale', 'direction',
}

WHITELIST = BUILTINS | GODOT_PROPERTIES

def scan_project(project_dir):
    project_dir = Path(project_dir)
    issues = []
    
    for gd_path in project_dir.rglob('*.gd'):
        # Skip .worktrees, .git, .godot, etc.
        rel = gd_path.relative_to(project_dir)
        if any(part.startswith('.') for part in rel.parts):
            continue
        if 'gdUnit4' in rel.parts:
            continue  # Skip test framework
        
        text = gd_path.read_text(encoding='utf-8')
        
        # 1. Detect push_instance + new()
        push_instance_pattern = re.compile(r'UIFlow\.push_instance\s*\(\s*(\w+)\.new\s*\(\s*\)')
        for m in push_instance_pattern.finditer(text):
            issues.append({
                'file': str(rel),
                'line': text[:m.start()].count('\n') + 1,
                'type': 'push_instance+new',
                'message': f"UIFlow.push_instance({m.group(1)}.new()) — should be UIFlow.push({m.group(1)}, ...)"
            })
        
        # 2. Detect undeclared variables in assignments
        issues.extend(check_undeclared_vars(gd_path, rel, text))
    
    return issues


def check_undeclared_vars(filepath, rel_path, text):
    """Check for variables used in assignments that are not declared."""
    issues = []
    lines = text.split('\n')
    
    # Parse class-level declarations
    class_vars = set()
    class_consts = set()
    class_enum_values = set()
    class_name_alias = None
    base_class = None
    
    for line in lines:
        stripped = line.strip()
        # class_name
        m = re.match(r'^class_name\s+(\w+)', stripped)
        if m:
            class_name_alias = m.group(1)
        # extends
        m = re.match(r'^extends\s+(.+)', stripped)
        if m:
            base_class = m.group(1).strip()
        # class vars: var x, @onready var x, @export var x, static var x
        m = re.match(r'^(?:@\w+\s+)*(?:static\s+)?var\s+(\w+)', stripped)
        if m:
            class_vars.add(m.group(1))
        # const
        m = re.match(r'^const\s+(\w+)', stripped)
        if m:
            class_consts.add(m.group(1))
        # enum with values
        m = re.match(r'^enum\s+\w+\s*\{([^}]*)\}', stripped)
        if m:
            for item in m.group(1).split(','):
                item = item.strip()
                if item:
                    enum_name = item.split('=')[0].strip().split()[0]
                    class_enum_values.add(enum_name)
        # inline enum without name
        m = re.match(r'^enum\s*\{([^}]*)\}', stripped)
        if m:
            for item in m.group(1).split(','):
                item = item.strip()
                if item:
                    enum_name = item.split('=')[0].strip().split()[0]
                    class_enum_values.add(enum_name)
    
    # Add class_name and base_class to known identifiers
    if class_name_alias:
        WHITELIST.add(class_name_alias)
    if base_class:
        WHITELIST.add(base_class.split('.')[0].strip())
    
    # Now scan each function
    in_func = False
    func_indent = 0
    local_vars = set()
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        
        # Detect function definition
        func_match = re.match(r'^(func\s+\w+\s*\()', line)
        if func_match:
            in_func = True
            func_indent = len(line) - len(line.lstrip())
            local_vars = set()
            
            # Parse parameters
            params_match = re.search(r'func\s+\w+\s*\((.*)\)', line)
            if params_match:
                params_str = params_match.group(1)
                # Handle multi-line parameters
                while ')' not in line and i + 1 < len(lines):
                    i += 1
                    line = lines[i]
                    params_str += ' ' + line.strip()
                    stripped = line.strip()
                # Extract param names (before : or = or ,)
                for param in re.split(r'[,;]', params_str):
                    param = param.strip()
                    if param and not param.startswith('//'):
                        # param might be "x: Type = default" or "x: Type"
                        m = re.match(r'(\w+)', param)
                        if m:
                            local_vars.add(m.group(1))
            i += 1
            continue
        
        if in_func:
            curr_indent = len(line) - len(line.lstrip())
            if curr_indent <= func_indent and stripped:
                # Exited function
                in_func = False
                local_vars = set()
            else:
                # Check for local variable declarations
                # var x, var x = ..., var x: Type = ..., for x in ..., match x:
                if re.match(r'^var\s+(\w+)', stripped):
                    m = re.match(r'^var\s+(\w+)', stripped)
                    local_vars.add(m.group(1))
                elif re.match(r'^for\s+(\w+)', stripped):
                    m = re.match(r'^for\s+(\w+)', stripped)
                    local_vars.add(m.group(1))
                elif re.match(r'^for\s+\w+\s+(\w+)\s+in', stripped):
                    pass
                elif re.match(r'^match\s+', stripped):
                    pass
                
                # Check for assignment left-hand side (not property assignment)
                # Pattern: identifier = ... (but not inside string, not after ., not after [)
                # Simple approach: look for lines starting with identifier = or identifier += etc.
                assign_match = re.match(r'^(\w+)\s*([+\-*/%&|^]?|<<|>>)?=', stripped)
                if assign_match:
                    var_name = assign_match.group(1)
                    if var_name not in WHITELIST and \
                       var_name not in class_vars and \
                       var_name not in class_consts and \
                       var_name not in class_enum_values and \
                       var_name not in local_vars:
                        issues.append({
                            'file': str(rel_path),
                            'line': i + 1,
                            'type': 'undeclared_var',
                            'message': f"Identifier '{var_name}' not declared in the current scope"
                        })
        
        i += 1
    
    return issues


def main():
    project_dir = Path(__file__).parent.parent
    print(f"Scanning project: {project_dir}")
    
    issues = scan_project(project_dir)
    
    # Write report
    report_path = project_dir / 'gdscript_audit_report.md'
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write("# GDScript Audit Report\n\n")
        if not issues:
            f.write("No issues found.\n")
        else:
            f.write(f"Found {len(issues)} issue(s):\n\n")
            for issue in issues:
                f.write(f"- **{issue['type']}** in `{issue['file']}` line {issue['line']}: {issue['message']}\n")
    
    print(f"\nReport saved to: {report_path}")
    
    if not issues:
        print("OK: No issues found!")
    else:
        print(f"\nFound {len(issues)} issue(s):\n")
        for issue in issues:
            print(f"[{issue['type']}] {issue['file']}:{issue['line']} -- {issue['message']}")
    
    return 0 if not issues else 1


if __name__ == '__main__':
    sys.exit(main())
