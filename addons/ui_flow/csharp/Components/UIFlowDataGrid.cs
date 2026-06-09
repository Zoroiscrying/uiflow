using Godot;
using System;
using System.Collections.Generic;

namespace UIFlow.Components;

/// <summary>
/// Sortable, scrollable data grid component.
/// </summary>
[GlobalClass]
public partial class UIFlowDataGrid : PanelContainer
{
    public record Column(string Title, float Width = 120f, bool Sortable = true);

    [Signal] public delegate void RowSelectedEventHandler(int index, Godot.Collections.Array data);
    [Signal] public delegate void ColumnSortedEventHandler(int columnIndex, bool ascending);

    private readonly List<Column> _columns = new();
    private Godot.Collections.Array _data = new();
    private int _sortColumn = -1;
    private bool _sortAscending = true;
    private int _selectedIndex = -1;

    private HBoxContainer _header;
    private VBoxContainer _rows;

    public override void _Ready()
    {
        SetupLayout();
    }

    private void SetupLayout()
    {
        var margin = new MarginContainer();
        margin.SetAnchorsPreset(LayoutPreset.FullRect);
        margin.AddThemeConstantOverride("margin_left", 4);
        margin.AddThemeConstantOverride("margin_right", 4);
        margin.AddThemeConstantOverride("margin_top", 4);
        margin.AddThemeConstantOverride("margin_bottom", 4);
        AddChild(margin);

        var vbox = new VBoxContainer();
        vbox.AddThemeConstantOverride("separation", 0);
        margin.AddChild(vbox);

        _header = new HBoxContainer();
        _header.AddThemeConstantOverride("separation", 1);
        vbox.AddChild(_header);

        var scroll = new ScrollContainer();
        scroll.SizeFlagsVertical = SizeFlags.ExpandFill;
        scroll.FollowFocus = true;
        vbox.AddChild(scroll);

        _rows = new VBoxContainer();
        _rows.AddThemeConstantOverride("separation", 1);
        scroll.AddChild(_rows);
    }

    public void AddColumn(string title, float width = 120f, bool sortable = true)
    {
        _columns.Add(new Column(title, width, sortable));
    }

    public void SetData(Godot.Collections.Array data)
    {
        _data = data;
        Rebuild();
    }

    public void SortBy(int columnIndex, bool ascending = true)
    {
        if (columnIndex < 0 || columnIndex >= _columns.Count) return;
        _sortColumn = columnIndex;
        _sortAscending = ascending;

        var list = new List<Godot.Collections.Array>();
        foreach (var item in _data)
            list.Add((Godot.Collections.Array)item);

        list.Sort((a, b) =>
        {
            var va = columnIndex < a.Count ? a[columnIndex] : null;
            var vb = columnIndex < b.Count ? b[columnIndex] : null;
            if (va == null) return 1;
            if (vb == null) return -1;
            int cmp = Comparer<object>.Default.Compare(va, vb);
            return ascending ? cmp : -cmp;
        });

        _data = new Godot.Collections.Array();
        foreach (var item in list) _data.Add(item);

        EmitSignal(SignalName.ColumnSorted, columnIndex, ascending);
        Rebuild();
    }

    private void Rebuild()
    {
        foreach (var child in _header.GetChildren()) child.QueueFree();
        foreach (var child in _rows.GetChildren()) child.QueueFree();

        for (int i = 0; i < _columns.Count; i++)
        {
            var col = _columns[i];
            var btn = new Button();
            btn.Text = col.Title;
            btn.CustomMinimumSize = new Vector2(col.Width, 32);
            btn.SizeFlagsHorizontal = SizeFlags.ExpandFill;
            btn.Alignment = HorizontalAlignment.Left;
            btn.Flat = true;
            int idx = i;
            if (col.Sortable) btn.Pressed += () => OnHeaderClicked(idx);
            _header.AddChild(btn);
        }

        for (int rowIdx = 0; rowIdx < _data.Count; rowIdx++)
        {
            var rowData = (Godot.Collections.Array)_data[rowIdx];
            var row = new HBoxContainer();
            row.AddThemeConstantOverride("separation", 1);

            for (int colIdx = 0; colIdx < _columns.Count; colIdx++)
            {
                var col = _columns[colIdx];
                var cell = new Label();
                cell.Text = colIdx < rowData.Count ? rowData[colIdx]?.ToString() ?? "" : "";
                cell.CustomMinimumSize = new Vector2(col.Width, 28);
                cell.SizeFlagsHorizontal = SizeFlags.ExpandFill;
                cell.ClipText = true;
                row.AddChild(cell);
            }

            _rows.AddChild(row);
        }
    }

    private void OnHeaderClicked(int columnIndex)
    {
        if (_sortColumn == columnIndex)
            _sortAscending = !_sortAscending;
        else
        { _sortColumn = columnIndex; _sortAscending = true; }
        SortBy(_sortColumn, _sortAscending);
    }
}
