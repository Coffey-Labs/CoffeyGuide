local file, ids = arg[1], arg[2] or ""
local allowed = {}
for id in ids:gmatch("[^,]+") do allowed[id] = true end
local ACTS = { accept=1, turnin=1, kill=1, collect=1, use=1, go=1, fp=1, hs=1, note=1 }
local NEEDQ = { accept=1, turnin=1, kill=1, collect=1, use=1 }
local RACES = { Orc=1, Troll=1, Tauren=1, Scourge=1, Skyborne=1, Human=1, Dwarf=1, Gnome=1, NightElf=1 }
local errs, counts, quests = {}, {}, {}
local function err(p, i, m) errs[#errs+1] = ("%s[%d]: %s"):format(p, i, m) end
local ns = {}
function ns.AddQuestPlan(p, steps)
  if not allowed[p] then errs[#errs+1] = "unknown parent id: " .. tostring(p) end
  counts[p] = (counts[p] or 0) + #steps
  quests[p] = quests[p] or {}
  for i, s in ipairs(steps) do
    if not ACTS[s.act] then err(p, i, "bad act " .. tostring(s.act)) end
    if NEEDQ[s.act] then
      if type(s.quest) ~= "table" or type(s.quest[1]) ~= "string" or type(s.quest[2]) ~= "number" or s.quest[2] <= 0 then
        err(p, i, "quest = { name, id } required for " .. tostring(s.act))
      else quests[p][s.quest[2]] = true end
    end
    if s.text and #s.text > 120 then err(p, i, "text > 120 chars") end
    if not s.text and not s.quest then err(p, i, "needs text or quest") end
    if s.wp then
      local w = s.wp
      if type(w[1]) ~= "number" or type(w[2]) ~= "number" or type(w[3]) ~= "number" then err(p, i, "wp needs {map,x,y,label}")
      elseif w[2] < 0 or w[2] > 100 or w[3] < 0 or w[3] > 100 then err(p, i, "wp coords out of 0-100") end
    end
    if s.races then for _, r in ipairs(s.races) do if not RACES[r] then err(p, i, "bad race " .. tostring(r)) end end end
  end
end
local chunk, e = loadfile(file)
if not chunk then print("LOAD ERROR: " .. e); os.exit(1) end
local ok, e2 = pcall(chunk, "CoffeyGuide", ns)
if not ok then print("RUN ERROR: " .. e2); os.exit(1) end
for p, n in pairs(counts) do local q = 0; for _ in pairs(quests[p]) do q = q + 1 end; print(("%-28s %3d steps %3d quests"):format(p, n, q)) end
for id in pairs(allowed) do if not counts[id] then print("MISSING plan for " .. id) end end
for _, m in ipairs(errs) do print("ERROR " .. m) end
print(#errs == 0 and "VALID" or ("INVALID: " .. #errs .. " errors")); os.exit(#errs == 0 and 0 or 1)
