local tmp = {} for i, v in pairs(table) do
    tmp[i] = v
end table = tmp
global=getgenv(); function table.object(self, super) if super then setmetatable(self, super) end; self.__index=self; return self end; function table.super(self, super, ...) return setmetatable(super.new(...), self) end
function table.new(meta, self) return setmetatable(self or {}, meta) end
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
                  getgenv()[k] = resins[k]
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
                getgenv()[v.Name] = resins[v.Name]
              end
            else
              local resins = game
              for i, v in pairs(root:gsub("@game/", ""):split("/")) do
                resins = resins:FindFirstChild(v)
              end
              getgenv()[name] = resins[name]
            end
          end
        elseif root == "@game" then
          if type(name) == "table" then
            for i, v in pairs(game:GetChildren()) do
              for j, k in pairs(name) do
                if v.Name == k then
                  getgenv()[k] = game[k]
                end
              end
            end
          elseif type(name) == "string" then
            if name == "*" then
              for i, v in pairs(game:GetChildren()) do
                local i = v.Name:gsub(" ", "")
                getgenv()[i] = v
              end
            else
              getgenv()[name] = game:GetService(name)
            end
          end
        elseif root ~= "@game" then
          return
        end
      elseif root:find("$", 1, true) then
        if root == "$libs" then
          if type(name) == "table" then
            for i, v in pairs(name) do
              loadstring (game:HttpGet("https://raw.githubusercontent.com/Breakfast-Dev/LuaAdv/main/Libs/" .. v .. ".adv.lua"), "Lib" .. v) ()
            end
          elseif type(name) == "string" then
            loadstring (game:HttpGet("https://raw.githubusercontent.com/Breakfast-Dev/LuaAdv/main/Libs/" .. name .. ".adv.lua"), "Lib" .. name) ()
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
                getgenv()[k] = restab[k]
              end
            end
          end
          getgenv()[name] = restab[name]
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
              getgenv()[i] = restab[i]
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
            getgenv()[name] = restab[name]
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
  service = function(name: string): Service 
    getgenv()[name] = game:GetService(name)
  end;
  http = function(addr: string): Service 
    loadstring(game:HttpGet("http://" .. addr))()
  end;
  https = function(addr: string): Service 
    loadstring(game:HttpGet("https://" .. addr))()
  end;
  static = function(tab: string): Service 
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
      self.Ok = t.ok or t.Ok
      self.Err = t.err or t.Err
      self.Result = t.result or t.Result
      return self
    end;
    exec = function(self)
      local res, err = pcall(self.Try)
      if (not res) then
        pcall(self.Err, err)
        pcall(self.Result, res)
        return err
      elseif (res) then
        pcall(self.Ok)
        pcall(self.Result, res)
        return res
      end
    end
  });
  Name = "Error";
  Description = "Default error";
  Context = nil;
  new = function(name, desc, context) T.C(name, "string", desc, "string", context, "table")
    local self = table.new(Error)
    self.Name = name
    self.Description = desc
    self.Context = context
    return self
  end;
  print = function(self)
    IO.println(
      self.Name .. ": " .. self.Description .. "\n"  ..
      "\t" .. tostring((self.Context or { Name = "Unknown" }).Name)
    )
  end;
})
global. Program = table.object({
  Name = "";
  Version = "";
  new = function(name, version) T.C(name, "string", version, "string")
    local self = table.new(Program)
    self.Name = name;
    self.Version = version;
    return self;
  end;
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