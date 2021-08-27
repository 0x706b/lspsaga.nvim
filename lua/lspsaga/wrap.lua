local config = require('lspsaga').config_values
local wrap = {}

function splittokens(s)
  local res = {}
  for w in s:gmatch("%S+") do
      res[#res+1] = w
  end
  return res
end

function wrap.wrap_text(text, linewidth, opts)
  local spaceleft = linewidth
  local res = {}
  local line = {}

  for _, word in ipairs(splittokens(text)) do
      if #word + 1 > spaceleft then
          table.insert(res, table.concat(line, ' '))
          line = {word}
          spaceleft = linewidth - #word
      else
          table.insert(line, word)
          spaceleft = spaceleft - (#word + 1)
      end
  end

  table.insert(res, table.concat(line, ' '))
  return res
end

-- If the content too long.
-- auto wrap according width
-- fill the space with wrap text
-- function wrap.wrap_text(text,width,opts)
--   opts = opts or {}
--   local ret = {}
--   local space = ' '
--   local pad_left = opts.pad_left or 0
--   -- if text width < width just return it
--   if #text <= width then
--     table.insert(ret,text)
--     return ret
--   end

--   local _truncate = function (t,w)
--     local tmp = t
--     local tbl = {}
--     while true do
--       if #tmp > w then
--         table.insert(tbl,tmp:sub(1,w))
--         if tmp:find('^%c//') then
--           tmp = '\t// ' .. tmp:sub(w+1)
--         else
--           tmp = tmp:sub(w+1)
--         end
--       else
--         table.insert(tbl,tmp)
--         break
--       end
--     end
--     return tbl
--   end
--   ret = _truncate(text,width)

--   local pad = ''
--   if pad_left ~= 0 then
--     for _=1,pad_left,1 do
--       pad = pad .. space
--     end
--   end

--   if opts.fill then
--     for i=2,#ret,1 do
--       ret[i] = pad .. ret[i]
--     end
--   end

--   return ret
-- end

function wrap.wrap_contents(contents,width,opts)
  opts = opts or {}
  if type(contents) ~= "table" then
    error("Wrong params type of function wrap_contents")
    return
  end
  local stripped = {}

  for _, text in ipairs(contents) do
    if #text < width then
      table.insert(stripped,text)
    else
      local tmp = wrap.wrap_text(text,width,opts)
      for _,j in ipairs(tmp) do
        table.insert(stripped,j)
      end
    end
  end

  return stripped
end

function wrap.add_truncate_line(contents)
  local line_widths = {}
  local width = 0
  local char = config.border_style == 4 and '-' or '─'
  local truncate_line = char

  for i,line in ipairs(contents) do
    line_widths[i] = vim.fn.strdisplaywidth(line)
    width = math.max(line_widths[i], width)
  end

  for _=1,width,1 do
    truncate_line = truncate_line .. char
  end

  return truncate_line
end

return wrap
