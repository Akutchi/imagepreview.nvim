M = {}

-- from https://stackoverflow.com/a/7615129
function M.Split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

function M.Length(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function M.Has_Value(tab, val)
  for _, value in pairs(tab) do
    if value == val then
      return true
    end
  end

  return false
end

--  from https://stackoverflow.com/a/24823383
function M.Slice(tbl, first, last)
  local sliced = {}

  for i = first or 1, last or #tbl do
    sliced[#sliced + 1] = tbl[i]
  end

  return sliced
end

return M
