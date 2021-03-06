local tmp = {} for i, v in pairs(table) do
    tmp[i] = v
end table = tmp
global=getgenv(); function table.object(self, super) if super then setmetatable(self, super) end; self.__index=self; return self end; function table.super(self, super, ...) return setmetatable(super.new(...), self) end; function table.new(meta, self) return setmetatable(self or {}, meta) end; function table.delete(self, super) if super and super.delete then super.delete(self) else for i, v in pairs(self) do self[i] = nil end end; return nil end; function table.searchParents(key, parents) for i, v in pairs(parents) do if parents[i][key] then return parents[i][key] end end end; function table.registerParents(parents) return { __index = function(self, key) return table.searchParents(key, parents) end } end
global. import = function(name)
  return {
    from = function(root)
      if root:find("@") then
        if root:find("/", 1, true) then 
          if type(name) == "table" then
            local resins = game
            for i, v in pairs(root:gsub("@game/", ""):split("/")) do
              resins = resins:FindFirstChild(v)
            end
            for i, v in pairs(resins:GetChildren()) do
              for j, k in pairs(name) do
                if v.Name == k then
                  getgenv()[k:gsub(" ", "")] = resins[k]
                end
              end
            end
          elseif type(name) == "string" then
            if name == "*" then
              local resins = game
              for i, v in pairs(root:gsub("@game/", ""):split("/")) do
                resins = resins:FindFirstChild(v)
              end
              for i, v in pairs(resins:GetChildren()) do
                getgenv()[v.Name:gsub(" ", "")] = resins[v.Name]
              end
            else
              local resins = game
              for i, v in pairs(root:gsub("@game/", ""):split("/")) do
                resins = resins:FindFirstChild(v)
              end
              getgenv()[name:gsub(" ", "")] = resins[name]
            end
          end
        elseif root == "@game" then
          if type(name) == "table" then
            for i, v in pairs(game:GetChildren()) do
              for j, k in pairs(name) do
                if v.Name == k then
                  getgenv()[k:gsub(" ", "")] = game[k]
                end
              end
            end
          elseif type(name) == "string" then
            if name == "*" then
              for i, v in pairs(game:GetChildren()) do
                local i = v.Name:gsub(" ", "")
                getgenv()[i:gsub(" ", "")] = v
              end
            else
              getgenv()[name:gsub(" ", "")] = game:GetService(name)
            end
          end
        elseif root ~= "@game" then
          return
        end
      elseif root:find("$", 1, true) then
        if root == "$libs" then
          if type(name) == "table" then
            for i, v in pairs(name) do
              local res, err = loadstring (game:HttpGet("https://raw.githubusercontent.com/Breakfast-Dev/LuaAdv/main/Libs/" .. v .. ".adv.lua"), "Lib" .. v)
              if type(res) == "function" then
                res()
              else
                Error.toError(err):print()
              end
            end
          elseif type(name) == "string" then
            local res, err = loadstring (game:HttpGet("https://raw.githubusercontent.com/Breakfast-Dev/LuaAdv/main/Libs/" .. name .. ".adv.lua"), "Lib" .. name)
            if type(res) == "function" then
              res()
            else
              Error.toError(err):print()
            end
          end
        end
      else
        if type(name) == "table" then
          local restab = getgenv()
          if root:find('.', 1, true) then
            for i, v in pairs(root:split(".")) do
              restab = restab[v]
            end
          else
            restab = restab[root]
          end
          for i, v in pairs(restab) do
            for j, k in pairs(name) do
              if i == k then
                getgenv()[k:gsub(" ", "")] = restab[k]
              end
            end
          end
          getgenv()[name:gsub(" ", "")] = restab[name]
        elseif type(name) == "string" then
          if name == "*" then
            local restab = getgenv()
            if root:find('.', 1, true) then
              for i, v in pairs(root:split(".")) do
                restab = restab[v]
              end
            else
              restab = restab[root]
            end
            for i, v in pairs(restab) do
              getgenv()[i:gsub(" ", "")] = restab[i]
            end
          else
            local restab = getgenv()
            if root:find('.', 1, true) then
              for i, v in pairs(root:split(".")) do
                restab = restab[v]
              end
            else
              restab = restab[root]
            end
            getgenv()[name:gsub(" ", "")] = restab[name]
          end
        end
      end
    end
  }
end
global. object = table.object({
  global = function(name)
    return setmetatable({
      inherit = function(super)
        return function(obj)
          local superobj = getgenv()
          for i, v in pairs(string.split(super, ".")) do
            superobj = superobj[v]
          end
          global [name] = table.object(obj, superobj)
        end
      end
    }, {
      __call = function(tab, obj)
        global [name] = table.object(obj)
      end
    })
  end,
  inherit = function(super)
    return function(obj)
      local superobj = getgenv()
      for i, v in pairs(string.split(super, ".")) do
        superobj = superobj[v]
      end
      return table.object(obj, superobj)
    end
  end
})
setmetatable(global. object, {
  __call = function(tab, name)
    if type(name) == "table" then
      return table.object(name)
    else
      return setmetatable({
        inherit = function(super)
          return function(obj)
            local superobj = getgenv()
            for i, v in pairs(string.split(super, ".")) do
              superobj = superobj[v]
            end
            if string.find(name, ".", 1, true) then 
              local parobj, nameslen, objname = getgenv(), 0, ""
              for i, v in pairs(string.split(name, ".")) do
                nameslen = nameslen + 1
              end
              for i, v in pairs(string.split(name, ".")) do
                if i < nameslen then
                  parobj = parobj[v]
                else
                  objname = v
                end
              end
              parobj[objname] = table.object(obj, superobj)
            else
              return table.object(obj, superobj)
            end
          end
        end
      }, {
        __call = function(tab, obj)
          if string.find(name, ".", 1, true) then 
            local parobj, nameslen, objname = getgenv(), 0, ""
            for i, v in pairs(string.split(name, ".")) do
              nameslen = nameslen + 1
            end
            for i, v in pairs(string.split(name, ".")) do
              if i < nameslen then
                parobj = parobj[v]
              else
                objname = v
              end
            end
            parobj[objname] = table.object(obj)
          else
            return table.object(obj)
          end
        end
      })
    end
  end
})
global. T = table.object({
  C = function(...)
    local params = {...}
    for i, v in pairs(params) do
      if (i % 2) ~= 0 and type(v) ~= params[i + 1] then
        error("expected '" .. params[i + 1] .. "', got '" .. type(v) .. "'")
      end
    end
  end
})
global. Import = table.object({
  service = function(name)
    getgenv()[name] = game:GetService(name)
  end;
  http = function(addr)
    loadstring(game:HttpGet("http://" .. addr))()
  end;
  https = function(addr) 
    loadstring(game:HttpGet("https://" .. addr))()
  end;
  static = function(tab)
    for i, v in pairs(tab) do
      getgenv()[i] = v
    end
  end
})
global. Error = table.object({
  Handle = table.object({
    Try = function() end;
    Ok = function() end;
    Err = function(err) end;
    Result = function() end;
    new = function(fn, t) T.C(fn, "function", t, "table")
      local self = table.new(Error.Handle)
      self.Try = fn
      self.Ok = ((t or {}).ok or (t or {}).Ok) or function(res) end
      self.Err = ((t or {}).err or (t or {}).Err) or function(err) end
      self.Res = ((t or {}).res or (t or {}).Res) or function() end
      return self
    end;
    set = function(self, t) T.C(t, "table")
      self.Ok = (t.ok or t.Ok) or function(res) end
      self.Err = (t.err or t.Err) or function(err) end
      self.Res = (t.res or t.Res) or function() end
      return self
    end;
    exec = function(self)
      local res, err = pcall(self.Try)
      if (not res) then
        pcall(self.Err, Error.toError(err))
        pcall(self.Res)
        return err
      elseif (res) then
        pcall(self.Ok, err)
        pcall(self.Res)
        return err
      end
    end; 
    match = function(self, t) T.C(t, "table")
      self:set(t)
      return self:exec()
    end;
  });
  Name = "Error";
  Description = "Default error";
  Line = 0;
  Context = nil;
  new = function(name, desc, line, context) T.C(name, "string", desc, "string", context, "table")
    local self = table.new(Error)
    self.Name = name
    self.Description = desc
    self.Line = line
    self.Context = context
    return self
  end;
  print = function(self)
    (warn or print)(
      "\n ! LuaAdv[Error] | " .. string.rep(" ", math.max(4 - #self.Name, 0)) .. self.Name .. " : " .. self.Description .. "\n" ..
      string.rep(" ", 16) .. " | \n" .. 
      string.rep(" ", 16) .. " | " .. string.rep(" ", math.max(#self.Name - 4, 0)) .. "at   > " .. tostring((self.Context or { Name = "Unknown" }).Name .. "\n" .. 
      string.rep(" ", 16) .. " | " .. string.rep(" ", math.max(#self.Name - 4, 0)) .. "line > " .. self.Line) .. "\n\n" .. 
      " * This error caught by LuaAdv\n\n"
    )
  end;
  toError = function(err)
    local errinfo = string.split(err, ":")
    local errdesc = string.sub(errinfo[3], 2, #errinfo[3])
    local errline = errinfo[2]
    return Error.new("Error", errdesc, errline, nil)
  end;
})
global. Script = table.object({
  _connections = {};
  Name = "";
  new = function(name) T.C(name, "string")
    local self = table.new(Script)
    self.Name = name;
    return self;
  end;
  delete = function(self)
    if type(self.update) == "function" then
      self._connections[1] = false
    end
    if type(self.fixedUpdate) == "function" then 
      self._connections[2]:Disconnect()
    end
    table.delete(self)
    return nil
  end;
  entry = function(self)
    if type(self.start) == "function" then self:start() end
    if type(self.update) == "function" then 
      self._connections[1] = true; coroutine.resume(coroutine.create(function() while self._connections[1] do game:GetService("RunService").RenderStepped:Wait() self:update() end end))
    end
    if type(self.fixedUpdate) == "function" then 
      self._connections[2] = game:GetService("RunService").Heartbeat:Connect(function(fps) self:fixedUpdate(fps) end) 
    end
    return self
  end;
  log = function(self, content)
    print("\n ! LuaAdv[Info] | " .. tostring(self.Name) .. " : " .. tostring(content))
  end;
  warn = function(self, content)
    (warn or print)("\n ! LuaAdv[Warn] | " .. tostring(self.Name) .. " : " .. tostring(content))
  end;
  error = function(self, content)
    pcall(function() (error or print)("\n ! LuaAdv[Error] | " .. tostring(self.Name) .. " : " .. tostring(content)) end)
  end;
  -- virtual start();
  -- virtual update();
  -- virtual fixedUpdate();
})
global. IO = table.object({
  print = function(string, ...) T.C(string, "string")
    local tmp = "\t" for i, v in pairs({...}) do
      tmp = tmp .. "\t" .. tostring(v)
    end
    return io.write(string .. tmp)
  end;
  println = function(string, ...) T.C(string, "string")
    local tmp = "\t" for i, v in pairs({...}) do
      tmp = tmp .. "\t" .. tostring(v)
    end
    return print(string .. tmp)
  end;
  ln = function()
    print()
  end;
  readInt = function()
    return tonumber(io.read())
  end;
  readChar = function() 
    return string.sub(tostring(io.read()), 1, 1)
  end;
  readString = function()
    return tostring(io.read())
  end;
})