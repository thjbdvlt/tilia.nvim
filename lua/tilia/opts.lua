return {
  user_cmd = "Tilia", -- ":Tilia list", ":Tilia add", etc.
  cmd_find_todo_files = "ls -a ~/todo/*.todo", -- Command to find todo files
  -- cmd_find_todo_files = "fd -t f "\.todo$" ~", -- Files anywher in home directory
  file_add_task = "~/todo/todo.todo", -- File where ":Tilia add" append tasks
  map = {
    -- Keymaps in ":Tilia list" window
    quit = "q", -- Quit window
    open = "<cr>", -- Go to task 
    -- Keymaps in Tilia files (e.g. mytask.todo)
    new_after = "o", -- New task (subtask of current one)
    new_before = "O", -- New task (same level as current one)
    toggle = "zd", -- Toggle from todo ("-") to done ("x")
    do_recursive = "zD", -- Mark current task and recursive subtasks as done
  },
  after_open = 'silent! normal zO', -- Executed when you open a task
  show_tree = true, -- Show whole tree representation in list window
  tree_truncate = nil, -- Truncate tree representation (nil or number)
  float_wrap = false, -- Wrap text in list window
  float_win_config = function() -- List window config (see :help nvim_open_win)
    local width = 100
    return {
      relative = "win",
      row = 1,
      col = (vim.o.columns - width) / 2,
      width = width,
      height = 20,
      style = nil,
      border = 'single',
    }
  end,
  shiftwidth = 2,
  iconv_from = "utf-8",
  iconv_search = true,
}
