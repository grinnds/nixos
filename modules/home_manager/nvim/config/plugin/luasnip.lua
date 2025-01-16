-- Requires {{{
local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt
local ts_utils = require("nvim-treesitter.ts_utils")
local ts_locals = require("nvim-treesitter.locals")
local rep = require("luasnip.extras").rep
local ai = require("luasnip.nodes.absolute_indexer")
--}}}

local M = {}

---Returns a choice node for errors.
-- @param choice_index integer
-- @param err_name string
M.go_err_snippet = function(args, _, _, spec)
	local err_name = args[1][1]
	local index = spec and spec.index or nil
	local msg = spec and spec[1] or ""
	if spec and spec[2] then
		err_name = err_name .. spec[2]
	end
	return ls.sn(index, {
		ls.c(1, {
			ls.sn(nil, fmt('fmt.Errorf("{}: %w", {})', { ls.i(1, msg), ls.t(err_name) })),
			-- ls.sn(nil, fmt('fmt.Errorf("{}", {}, {})', { ls.t(err_name), ls.i(1, msg), ls.i(2) })),
			ls.sn(
				nil,
				fmt('internal.GrpcError({},\n\t\tcodes.{}, "{}", "{}", {})', {
					ls.t(err_name),
					ls.i(1, "Internal"),
					ls.i(2, "Description"),
					ls.i(3, "Field"),
					ls.i(4, "fields"),
				})
			),
			ls.t(err_name),
		}),
	})
end

---Transform makes a node from the given text.
local function transform(text, info) --{{{
	local string_sn = function(template, default)
		info.index = info.index + 1
		return ls.sn(info.index, fmt(template, ls.i(1, default)))
	end
	local new_sn = function(default)
		return string_sn("{}", default)
	end

	-- cutting the name if exists.
	if text:find([[^[^\[]*string$]]) then
		text = "string"
	elseif text:find("^[^%[]*map%[[^%]]+") then
		text = "map"
	elseif text:find("%[%]") then
		text = "slice"
	elseif text:find([[ ?chan +[%a%d]+]]) then
		return ls.t("nil")
	end

	-- separating the type from the name if exists.
	local type = text:match([[^[%a%d]+ ([%a%d]+)$]])
	if type then
		text = type
	end

	if text == "int" or text == "int64" or text == "int32" then
		return new_sn("0")
	elseif text == "float32" or text == "float64" then
		return new_sn("0")
	elseif text == "error" then
		if not info then
			return ls.t("err")
		end

		info.index = info.index + 1
		return M.go_err_snippet({ { info.err_name } }, nil, nil, { index = info.index })
	elseif text == "bool" then
		info.index = info.index + 1
		return ls.c(info.index, { ls.i(1, "false"), ls.i(2, "true") })
	elseif text == "string" then
		return string_sn('"{}"', "")
	elseif text == "map" or text == "slice" then
		return ls.t("nil")
	elseif string.find(text, "*", 1, true) then
		return new_sn("nil")
	end

	text = text:match("[^ ]+$")
	if text == "context.Context" then
		text = "context.Background()"
	else
		-- when the type is concrete
		text = text .. "{}"
	end

	return ls.t(text)
end --}}}

local get_node_text = vim.treesitter.get_node_text
local handlers = { --{{{
	parameter_list = function(node, info)
		local result = {}

		local count = node:named_child_count()
		for idx = 0, count - 1 do
			table.insert(result, transform(get_node_text(node:named_child(idx), 0), info))
			if idx ~= count - 1 then
				table.insert(result, ls.t({ ", " }))
			end
		end

		return result
	end,

	type_identifier = function(node, info)
		local text = get_node_text(node, 0)
		return { transform(text, info) }
	end,
} --}}}

local function return_value_nodes(info) --{{{
	local cursor_node = ts_utils.get_node_at_cursor()
	local scope_tree = ts_locals.get_scope_tree(cursor_node, 0)

	local function_node
	for _, scope in ipairs(scope_tree) do
		if
			scope:type() == "function_declaration"
			or scope:type() == "method_declaration"
			or scope:type() == "func_literal"
		then
			function_node = scope
			break
		end
	end

	if not function_node then
		return
	end

	local query = vim.treesitter.query.get("go", "luasnip")
	for _, node in query:iter_captures(function_node, 0) do
		if handlers[node:type()] then
			return handlers[node:type()](node, info)
		end
	end
	return ls.t({ "" })
end --}}}

---Transforms the given arguments into nodes wrapped in a snippet node.
M.make_return_nodes = function(args) --{{{
	local info = { index = 0, err_name = args[1][1] }
	return ls.sn(nil, return_value_nodes(info))
end --}}}

---Runs the command in shell.
-- @param command string
-- @return table
M.shell = function(command) --{{{
	local file = io.popen(command, "r")
	local res = {}
	for line in file:lines() do
		table.insert(res, line)
	end
	return res
end --}}}

M.last_lua_module_section = function(args) --{{{
	local text = args[1][1] or ""
	local split = vim.split(text, ".", { plain = true })

	local options = {}
	for len = 0, #split - 1 do
		local node = ls.t(table.concat(vim.list_slice(split, #split - len, #split), "_"))
		table.insert(options, node)
	end

	return ls.sn(nil, {
		ls.c(1, options),
	})
end --}}}

---Returns true if the cursor in a function body.
-- @return boolean
function M.is_in_function() --{{{
	local current_node = ts_utils.get_node_at_cursor()
	if not current_node then
		return false
	end
	local expr = current_node

	while expr do
		if expr:type() == "function_declaration" or expr:type() == "method_declaration" then
			return true
		end
		expr = expr:parent()
	end
	return false
end --}}}

---Returns true if the cursor in a test file.
-- @return boolean
function M.is_in_test_file() --{{{
	local filename = vim.fn.expand("%:p")
	return vim.endswith(filename, "_test.go")
end --}}}

---Returns true if the cursor in a function body in a test file.
-- @return boolean
function M.is_in_test_function() --{{{
	return M.is_in_test_file() and M.is_in_function()
end --}}}

math.randomseed(os.time())
M.uuid = function() --{{{
	local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
	local out
	local function subs(c)
		local v = (((c == "x") and math.random(0, 15)) or math.random(8, 11))
		return string.format("%x", v)
	end
	out = template:gsub("[xy]", subs)
	return out
end --}}}

local charset = {} -- Random String {{{
for i = 48, 57 do
	table.insert(charset, string.char(i))
end
for i = 65, 90 do
	table.insert(charset, string.char(i))
end
for i = 97, 122 do
	table.insert(charset, string.char(i))
end
M.random_string = function(length)
	if length == 0 then
		return ""
	end
	return M.random_string(length - 1) .. charset[math.random(1, #charset)]
end --}}}

M.snake_case = function(titlecase) --{{{
	-- lowercase the first letter otherwise it causes the result to start with an
	-- underscore.
	titlecase = string.lower(string.sub(titlecase, 1, 1)) .. string.sub(titlecase, 2)
	return titlecase:gsub("%u", function(c)
		return "_" .. c:lower()
	end)
end --}}}

M.create_t_run = function(args) --{{{
	return ls.sn(1, {
		ls.c(1, {
			ls.t({ "" }),
			ls.sn(
				nil,
				fmt('\tt.Run("{}", {}{})\n{}', {
					ls.i(1, "Case"),
					ls.t(args[1]),
					rep(1),
					ls.d(2, M.create_t_run, ai[1]),
				})
			),
		}),
	})
end --}}}

M.mirror_t_run_funcs = function(args) --{{{
	local strs = {}
	for _, v in ipairs(args[1]) do
		local name = v:match('^%s*t%.Run%s*%(%s*".*", (.*)%)')
		if name then
			local node = string.format("func %s(t *testing.T) {{\n\tt.Parallel()\n}}\n\n", name)
			table.insert(strs, node)
		end
	end
	local str = table.concat(strs, "")
	if #str == 0 then
		return ls.sn(1, ls.t(""))
	end
	return ls.sn(1, fmt(str, {}))
end --}}}

-- vim: fdm=marker fdl=0

ls.add_snippets("all", {
	ls.s("hlc", ls.t("http://localhost")),
	ls.s("hl1", ls.t("http://127.0.0.1")),
	ls.s("lh", ls.t("localhost")),
	ls.s("lh1", ls.t("127.0.0.1")),
})

-- Requires {{{
-- local ls = require("luasnip")
-- local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
-- local rep = require("luasnip.extras").rep
-- local ai = require("luasnip.nodes.absolute_indexer")
local partial = require("luasnip.extras").partial
--}}}

-- Conditions {{{
local function not_in_function()
	return not M.is_in_function()
end

local in_test_func = {
	show_condition = M.is_in_test_function,
	condition = M.is_in_test_function,
}

local in_test_file = {
	show_condition = M.is_in_test_file,
	condition = M.is_in_test_file,
}

local in_func = {
	show_condition = M.is_in_function,
	condition = M.is_in_function,
}

local not_in_func = {
	show_condition = not_in_function,
	condition = not_in_function,
}
--}}}

-- stylua: ignore start
local snippets = {
  -- Main {{{
  ls.s(
    { trig = "main", name = "Main", dscr = "Create a main function" },
    fmta("func main() {\n\t<>\n}", ls.i(0)),
    not_in_func
  ), --}}}

  -- If call error {{{
  ls.s(
    { trig = "ifc", name = "If call", dscr = "Call a function and check the error" },
    fmt(
      [[
        {val}, {err1} := {func}({args})
        if {err2} != nil {{
          return {err3}
        }}
        {finally}
      ]], {
        val     = ls.i(1, { "val" }),
        err1    = ls.i(2, { "err" }),
        func    = ls.i(3, { "Func" }),
        args    = ls.i(4),
        err2    = rep(2),
        err3    = ls.d(5, M.make_return_nodes, { 2 }),
        finally = ls.i(0),
    }),
    in_func
  ), --}}}

  -- if err:=call(); err != nil { return err } {{{
  ls.s(
    { trig = "ifce", name = "If call err inline", dscr = "Call a function and check the error" },
    fmt(
	  [[
        if {err1} := {func}({args}); {err2} != nil {{
          return {err3}
        }}
        {finally}
      ]], {
        err1    = ls.i(1, { "err" }),
        func    = ls.i(2, { "func" }),
        args    = ls.i(3, { "args" }),
        err2    = rep(1),
        err3    = ls.d(4, M.make_return_nodes, { 1 }),
        finally = ls.i(0),
    }),
    in_func
  ), --}}}

  -- Function {{{
  ls.s(
    { trig = "fn", name = "Function", dscr = "Create a function or a method" },
    fmt(
      [[
        // {name1} {desc}
        func {rec}{name2}({args}) {ret} {{
          {finally}
        }}
      ]], {
        name1 = rep(2),
        desc  = ls.i(5, "description"),
        rec   = ls.c(1, {
          ls.t(""),
          ls.sn(nil, fmt("({} {}) ", {
            ls.i(1, "r"),
            ls.i(2, "receiver"),
          })),
        }),
        name2 = ls.i(2, "Name"),
        args  = ls.i(3),
        ret   = ls.c(4, {
          ls.i(1, "error"),
          ls.sn(nil, fmt("({}, {}) ", {
            ls.i(1, "ret"),
            ls.i(2, "error"),
          })),
        }),
        finally = ls.i(0),
    }),
    not_in_func
  ), --}}}

  -- If error {{{
  ls.s(
    { trig = "ife", name = "If error", dscr = "If error, return wrapped" },
    fmt("if {} != nil {{\n\treturn {}\n}}\n{}", {
      ls.i(1, "err"),
      ls.d(2, M.make_return_nodes, { 1 }, { user_args = { { "a1", "a2" } } }),
      ls.i(0),
    }),
    in_func
  ), --}}}

  -- Defer Recover {{{
  ls.s(
    { trig = "refrec", name = "Defer Recover", dscr = "Defer Recover" },
    fmta(
      [[
        defer func() {{
          if e := recover(); e != nil {{
            fmt.Printf("Panic: %v\n%v\n", e, string(debug.Stack()))
          }}
        }}()
      ]]
    , {}),
    in_func
  ), --}}}

  -- gRPC Error{{{
  ls.s(
    { trig = "gerr", dscr = "Return an instrumented gRPC error" },
    fmt('internal.GrpcError({},\n\tcodes.{}, "{}", "{}", {})', {
      ls.i(1, "err"),
      ls.i(2, "Internal"),
      ls.i(3, "Description"),
      ls.i(4, "Field"),
      ls.i(5, "fields"),
    }),
    in_func
  ), --}}}

  -- Mockery {{{
  ls.s(
    { trig = "mockery", name = "Mockery", dscr = "Create an interface for making mocks" },
    fmt(
      [[
        // {} mocks {} interface for testing purposes.
        //go:generate mockery --name {} --filename {}_mock.go
        type {} interface {{
          {}
        }}
      ]], {
        rep(1),
        rep(2),
        rep(1),
        ls.f(function(args) return M.snake_case(args[1][1]) end, { 1 }),
        ls.i(1, "Client"),
        ls.i(2, "pkg.Interface"),
    })
  ), --}}}

  -- Nolint {{{
  ls.s(
    { trig = "nolint", dscr = "ignore linter" },
    fmt([[// nolint:{} // {}]], {
      ls.i(1, "names"),
      ls.i(2, "explaination"),
    })
  ), --}}}

  -- Allocate Slices and Maps {{{
  ls.s(
    { trig = "make", name = "Make", dscr = "Allocate map or slice" },
    fmt("{} {}= make({})\n{}", {
      ls.i(1, "name"),
      ls.i(2),
      ls.c(3, {
        fmt("[]{}, {}", { ls.r(1, "type"), ls.i(2, "len") }),
        fmt("[]{}, 0, {}", { ls.r(1, "type"), ls.i(2, "len") }),
        fmt("map[{}]{}, {}", { ls.r(1, "type"), ls.i(2, "values"), ls.i(3, "len") }),
      }, {
        stored = { -- FIXME: the default value is not set.
          type = ls.i(1, "type"),
        },
      }),
      ls.i(0),
    }),
    in_func
  ), --}}}

  -- Test Cases {{{
  ls.s(
    { trig = "tcs", dscr = "create test cases for testing" },
    fmta(
      [[
        tcs := map[string]struct {
        	<>
        } {
        	// Test cases here
        }
        for name, tc := range tcs {
        	tc := tc
        	t.Run(name, func(t *testing.T) {
        		<>
        	})
        }
      ]],
      { ls.i(1), ls.i(2) }
    ),
    in_test_func
  ), --}}}

  -- Go CMP {{{
  ls.s(
    { trig = "gocmp", dscr = "Create an if block comparing with cmp.Diff" },
    fmt(
      [[
        if diff := cmp.Diff({}, {}); diff != "" {{
        	t.Errorf("(-want +got):\\n%s", diff)
        }}
      ]], {
        ls.i(1, "want"),
        ls.i(2, "got"),
    }),
    in_test_func
  ), --}}}

  -- Create Mocks {{{
  ls.s(
    { trig = "mock", name = "Mocks", dscr = "Create a mock with defering assertion" },
    fmt("{} := &mocks.{}{{}}\ndefer {}.AssertExpectations(t)\n{}", {
      ls.i(1, "m"),
      ls.i(2, "Mocked"),
      rep(1),
      ls.i(0),
    }),
    in_test_func
  ), --}}}

  -- Require NoError {{{
  ls.s(
    { trig = "noerr", name = "Require No Error", dscr = "Add a require.NoError call" },
    ls.c(1, {
      ls.sn(nil, fmt("require.NoError(t, {})", { ls.i(1, "err") })),
      ls.sn(nil, fmt('require.NoError(t, {}, "{}")', { ls.i(1, "err"), ls.i(2) })),
      ls.sn(nil, fmt('require.NoErrorf(t, {}, "{}", {})', { ls.i(1, "err"), ls.i(2), ls.i(3) })),
    }),
    in_test_func
  ), --}}}

  -- Subtests {{{
  ls.s(
    { trig = "Test", name = "Test/Subtest", dscr = "Create subtests and their function stubs" },
    fmta("func <>(t *testing.T) {\n<>\n}\n\n <>", {
      ls.i(1),
      ls.d(2, M.create_t_run, ai({ 1 })),
      ls.d(3, M.mirror_t_run_funcs, ai({ 2 })),
    }),
    in_test_file
  ), --}}}

  -- Stringer {{{
  ls.s(
    { trig = "strigner", name = "Stringer", dscr = "Create a stringer go:generate" },
    fmt("//go:generate stringer -type={} -output={}_string.go", {
      ls.i(1, "Type"),
      partial(vim.fn.expand, "%:t:r"),
    })
  ), --}}}

  -- Query Database {{{
  ls.s(
    { trig = "queryrows", name = "Query Rows", dscr = "Query rows from database" },
    fmta(
      [[
      const <query1> = `<query2>`
      <ret1> := make([]<type1>, 0, <cap>)

      <err1> := <retrier>.Do(func() error {
      	<rows1>, <err2> := <db>.Query(<ctx>, <query3>, <args>)
      	if errors.Is(<err3>, pgx.ErrNoRows) {
      		return &retry.StopError{Err: <err4>}
      	}
      	if <err5> != nil {
      		return <err6>
      	}
      	defer <rows2>.Close()

      	<ret2> = <ret3>[:0]
      	for <rows3>.Next() {
      		var <doc1> <type2>
      		<err7> := <rows4>.Scan(&<vals>)
      		if <err8> != nil {
      			return <err9>
      		}

      		<last>
      		<ret4> = append(<ret5>, <doc2>)
      	}

        if <err10> != nil {
          return <err11>
        }
        return nil
      })

      if <err12> != nil {
        return nil, <err13>
      }
      return <ret6>, nil
      ]], {
        query1  = ls.i(1, "query"),
        query2  = ls.i(2, "SELECT 1"),
        ret1    = ls.i(3, "ret"),
        type1   = ls.i(4, "Type"),
        cap     = ls.i(5, "cap"),
        err1    = ls.i(6, "err"),
        retrier = ls.i(7, "retrier"),
        rows1   = ls.i(8, "rows"),
        err2    = ls.i(9, "err"),
        db      = ls.i(10, "db"),
        ctx     = ls.i(11, "ctx"),
        query3  = rep(1),
        args    = ls.i(12, "args"),
        err3    = rep(9),
        err4    = rep(9),
        err5    = rep(9),
        err6    = ls.d(13, M.go_err_snippet, { 9 }, { user_args = { { "making query" } } }),
        rows2   = rep(8),
        ret2    = rep(3),
        ret3    = rep(3),
        rows3   = rep(8),
        doc1    = ls.i(14, "doc"),
        type2   = rep(4),
        err7    = ls.i(15, "err"),
        rows4   = rep(8),
        vals    = ls.d(16, function(args) return ls.sn(nil, ls.i(1, args[1][1])) end, { 14 }),
        err8    = rep(15),
        err9    = ls.d(17, M.go_err_snippet, { 15 }, { user_args = { { "scanning row" } } }),
        last    = ls.i(0),
        ret4    = rep(3),
        ret5    = rep(3),
        doc2    = rep(14),
        err10   = rep(15),
        err11   = ls.d(18, M.go_err_snippet, { 8 }, { user_args = { { "iterating rows", ".Err()" } } }),
        err12   = rep(15),
        ret6    = rep(3),
        err13   = ls.d(19, M.go_err_snippet, { 6 }, { user_args = { { "error in row iteration" } } }),
      }
    )
  ),
  -- }}}
}

ls.add_snippets("go", snippets)

-- stylua: ignore end

-- vim: fdm=marker fdl=0
