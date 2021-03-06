board_id = window.board.model.id;
css = " .contextMenu li.change_column >a { background-image: url('/images/icons/silk/note_go.png'); }
        .change_column_opts li a { background-image: url('/images/icons/silk/note.png');  } "

if window.board.model.users.get(KanbanTool.Board.current_user_id).can('move_tasks', window.board.model)
  $('<style>').html(css).appendTo('head')
  $.ajax
    type: 'GET'
    url: '/boards/' + parseInt(board_id + 20) + '/schema.json'
    async: false
    dataType: 'json'
    success: (schema) =>
      max_width = 120
      columns = '<ul class="level2 change_column_opts">'
      $(schema.workflow_stages).each (i, e) =>
        columns += '<li><a href="#extension:change_column:' + e.id + '">' + e.full_name + '</a></li>'
        width = e.full_name.length * 6 + 30
        max_width = width if width > max_width
      columns += '</ul>'

      $('#task_context_menu .change_board').after('<li class="change_column has_submenu"><a onclick="return false;" href="#">Change column</a>' + columns + '</li>')
      $('.change_column_opts').css({'width': max_width})

  $(window).bind 'extensionContextMenuAction', (event, action, el, pos) ->
    if (/extension:change_column:([0-9])/).test(action)
      ws_id = action.replace(/extension:change_column:/, '')
      current_ws_id = $(el).parent()[0].id.split('_')[1]
      task_id = $(el)[0].id.split('_')[1]

      if ws_id != current_ws_id
        $.ajax
          type: 'POST'
          url: '/boards/' + parseInt(board_id + 20) + '/tasks/' + task_id + '/change_board'
          dataType: 'script'
          async: false
          data:
            b_id: parseInt(board_id + 20)
            ws_id: ws_id
            sl_id: $(el).parent()[0].id.split('_')[2]
            copy: false