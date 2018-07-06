function sq(n) return n*n end

function readFile(path)
  local ret = ""
  local file = io.open(path, "r")
  if file then
    ret = file:read()
    file:close()
    return ret
  end
  print("File at "..path.." not found!")
  return nil
end

function fileExists(path)
  local f = io.open(path, "rb")
  if f then f:close() end
  return f ~= nil
end
