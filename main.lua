-- VersãoVermelha: a translation of the game into Português.
--
-- Nothing here is translated yet.  Every table under lang/ starts with
-- empty strings; fill one in and it takes effect on the next boot, and
-- anything still empty keeps rendering in English.  That means a
-- half-finished translation is always playable, so you can ship early and
-- fill the long tail in later.
--
-- Read TRANSLATING.md before the first edit; the font is the part people
-- get wrong.
local BattleState = require("src.battle.BattleState")
local Font = require("src.render.Font")
local Strings = require("src.core.Strings")
local TypeChart = require("src.battle.TypeChart")
local ListMenu = require("src.ui.ListMenu")
local MoveLearnMenu = require("src.ui.MoveLearnMenu")
local Theme = require("src.ui.Theme")
local TrainerCard = require("src.ui.TrainerCard")
local Badges = require("src.inventory.Badges")

return function(mod)

  local compile = loadstring or load

  local source, err = mod:read("vr_options.lua")
  if not source then
    mod.log:error("cannot read vr_options.lua: %s", tostring(err))
    return
  end

  local chunk, err = compile(
    source,
    "@" .. mod.path .. "/vr_options.lua"
  )

  if not chunk then
    mod.log:error("cannot compile vr_options.lua: %s", tostring(err))
    return
  end

  local options = chunk()
  options.install(mod)
-- Carrega as opções persistentes para o restante do mod.
mod.exports.idioma_golpes =
    mod.options:get("idioma_golpes")

mod.exports.mostrar_inimigo =
    mod.options:get("mostrar_inimigo")

mod.exports.precos_linha =
    mod.options:get("precos_linha")

mod.exports.trainer_card =
    mod.options:get("trainer_card")

  -- mod:read is the supported way into your own directory; the catalogs are
  -- plain Lua tables, so read and run them rather than require()ing them.
  local function catalog(name)
    local rel = "lang/" .. name .. ".lua"
    local body = mod:read(rel)
    if not body then return {} end
    local chunk, err = loadstring(body, rel)
    if not chunk then
      mod.log:warn("%s has a syntax error: %s", rel, tostring(err))
      return {}
    end
    local ok, table_ = pcall(chunk)
    if not ok or type(table_) ~= "table" then
      mod.log:warn("%s did not return a table: %s", rel, tostring(table_))
      return {}
    end
    return table_
  end

  -- An empty value means "not translated yet", never "translate to blank".
  local function each(name, apply)
    local n = 0
    for key, value in pairs(catalog(name)) do
      if type(value) == "string" and value ~= "" then
        apply(key, value)
        n = n + 1
      end
    end
    return n
  end

  -- ---- glyphs -------------------------------------------------------
  -- Register the sheet BEFORE anything asks for a glyph on it.  base is
  -- the first code the page owns; 0x100 and up is free space above the
  -- vanilla pages, so a new alphabet never collides with them.
  for id, page in pairs(catalog("font")) do
    -- A page's `image` goes straight to love.graphics.newImage, which
    -- resolves against the game root rather than the mod, so a path that
    -- lives in this mod has to be made absolute or the page loads nothing
    -- and every accented character draws as a blank.  mod:read is the
    -- precise test for "this file is mine".
    if type(page) == "table" and type(page.image) == "string"
        and mod:read(page.image) then
      page.image = mod.assets:path(page.image)
    end
    mod.content.font:register(id, page)
	-- mod.content.font:register("ttf", {
    -- file = mod.assets:path("assets/fonts/plainpixel/Prop10.ttf"),
    -- size = 10,
    --})
  end
  -- charmap: which byte sequence draws which code
  for seq, code in pairs(catalog("charmap")) do
    mod.content.font:register("charmap:" .. seq, { seq = seq, code = code })
  end

  -- ---- text ---------------------------------------------------------
  local counts = {}
  counts.dialogue = each("pokedex_redblue", function(id, value)
  mod.content.text:override(id, value)
  end)
  counts.dialogue = each("dialogue", function(id, value)
    mod.content.text:override(id, value)
  end)
  counts.strings = each("strings", function(source, value)
    mod.content.strings:override(source, value)
  end)
  counts.species = each("species_names", function(id, value)
    mod.content.pokemon:patch(id, { name = value })
  end)
  
 --- =========================================
 --- OPTION, MOSTRAR OU NÂO INIMIGO + USED NA LINHA DEBAIXO
 --- =========================================
  local mostrarInimigo = mod.options:get("mostrar_inimigo")
if mostrarInimigo then
  mod.content.strings:override("Enemy %s", "%s inimigo ")
  mod.content.strings:override("%s\nused %s!", "%s\nusou %s!")
else
  mod.content.strings:override("Enemy %s", "%s")
  mod.content.strings:override("%s\nused %s!", "%s usou\n%s!")
end
 
--- =========================================
-- CHANGE MOVE LANGUAGES (PT-BR = on / EN = off
--- =========================================
local idioma = mod.options:get("idioma_golpes")

if idioma == "portuguese1" then

    counts.moves = each("move_names", function(id, value)
        mod.content.moves:patch(id, { name = value })
    end)
--------------------------------------------------------------
----------------------BATTLE UI
--------------------------------------------------------------
local oldDrawTextArea = BattleState.drawTextArea

BattleState.drawTextArea = function(self, ...)
    local oldDraw = Font.draw
    local oldDrawCode = Font.drawCode
	local oldDrawBox = Font.drawBox

    Font.draw = function(text, x, y, ...)
        if x == 48 and y >= 104 and y <= 128 then
        x = 16	
			
        end

        return oldDraw(text, x, y, ...)
    end

    Font.drawCode = function(code, x, y, ...)
		--CURSORES DE GOLPES
		if code == 0xED and x == 40 and y == 104 then
            x = 08
            y = 104
		elseif code == 0xED and x == 40 and y == 112 then
            x = 08
            y = 112
		elseif code == 0xED and x == 40 and y == 120 then
            x = 08
            y = 120
		elseif code == 0xED and x == 40 and y == 128 then
            x = 08
            y = 128
		elseif code == 0xEC and x == 40 and y == 104 then
            x = 08
            y = 104				
		elseif code == 0xEC and x == 40 and y == 112 then
            x = 08
            y = 112
		elseif code == 0xEC and x == 40 and y == 120 then
            x = 08
            y = 120
		elseif code == 0xEC and x == 40 and y == 128 then
            x = 08
            y = 128		
	--CURSORES DE MIMIC
	
			
        end
		
		
		
		
		

        return oldDrawCode(code, x, y, ...)
    end
--
	Font.drawBox = function(x, y, w, h, ...)
		
--MOVELIST BOX Font.drawBox(4, 12, 16, 6)			
			if x == 4 and y == 12 and w == 16 and h == 6 then
			x = 0
			y = 12
			w = 20
			h = 6
--MOVELIST TYPE BOX Font.drawBox(0, 8, 11, 5)			
			--elseif x == 0 and y == 8 and w == 11 and h == 5 then
			--x = 0
			--y = 8
			--w = 11
			--h = 5			
--MIMIC BOX Font.drawBox(0, 7, 16, 6)			
			elseif x == 0 and y == 7 and w == 16 and h == 6 then
			x = 0
			y = 7
			w = 20
			h = 6
--MOVE LEARN BOX Font.drawBox(0, 5, 20, 7)			
			elseif x == 4 and y == 5 and w == 16 and h == 7 then
			x = 0
			y = 5
			w = 20
			h = 7
    end

	
	

    return oldDrawBox(x, y, w, h, ...)
end


    local ok, a, b, c, d, e = pcall(oldDrawTextArea, self, ...)

	
	Font.drawBox = oldDrawBox
    Font.draw = oldDraw
    Font.drawCode = oldDrawCode

    if not ok then
        error(a)
    end

    return a, b, c, d, e
end
----------------------------------------------
----LEARN MOVE BOX
----------------------------------------------
local oldMoveLearnDraw = MoveLearnMenu.draw

MoveLearnMenu.draw = function(self, ...)
    local oldDraw = Font.draw
    local oldDrawCode = Font.drawCode
    local oldDrawBox = Font.drawBox

    Font.draw = function(text, x, y, ...)
        -- Nomes dos golpes
        if x == 48 and y >= 48 and y <= 128 then
            x = 16
        -- CANCEL
        elseif text == Strings("CANCEL") and x == 48 then
            x = 16
        end

        return oldDraw(text, x, y, ...)
    end

    Font.drawCode = function(code, x, y, ...)
        -- Cursor da lista
        if code == 0xED and x == 40 then
        x = 8
		end

        return oldDrawCode(code, x, y, ...)
    end

    Font.drawBox = function(x, y, w, h, ...)
        -- Caixa da lista de golpes
        if x == 4 and y == 7 and w == 16 and h == 6 then
            x = 0
            y = 7
            w = 20
            h = 6
        end

        return oldDrawBox(x, y, w, h, ...)
    end

    local ok, a, b, c, d, e = pcall(oldMoveLearnDraw, self, ...)

    Font.draw = oldDraw
    Font.drawCode = oldDrawCode
    Font.drawBox = oldDrawBox

    if not ok then
        error(a)
    end

    return a, b, c, d, e
end




elseif idioma == "english" then

    each("engmoves_dialogue", function(id, value)
        mod.content.text:override(id, value)
    end)

    each("engmoves_strings", function(source, value)
        mod.content.strings:override(source, value)
    end)






--elseif idioma == "portuguese2" then
--    counts.moves = each("move_names2", function(id, value)
--        mod.content.moves:patch(id, { name = value })
--    end)

end



  
  
 ------------ 
  counts.items = each("item_names", function(id, value)
    mod.content.items:patch(id, { name = value })
  end)
  counts.trainers = each("trainer_names", function(id, value)
    mod.content.trainers:patch(id, { name = value })
  end)
  counts.statuses = each("status_labels", function(id, value)
    mod.content.statuses:patch(id, { label = value })
  end)

  -- ---- name entry ---------------------------------------------------
  -- The naming screen's letter grid.  Leave lang/naming.lua returning nil
  -- to keep the English alphabet.
  -- The mod-facing hook surface is :wrap(name, callback, priority); the
  -- generated template calls :on, which does not exist and only blows up
  -- once lang/naming.lua is actually filled in.
 -- local grid = catalog("naming")
 -- if grid.upper or grid.lower then
 --  mod.hooks:wrap("ui.naming.grid", function(base, ctx)
 --     local want = ctx and ctx.lower and grid.lower or grid.upper
 --     return want or base
 --   end)
 -- end

  mod.events:on("game.ready", function()
    local total = 0
    for _, n in pairs(counts) do total = total + n end
    mod.log:info("Português: %d strings traduzidas", total)
  end)
  
 -------------------------------------------------------------------
 --TABELA DE TIPOS
 -------------------------------------------------------------------
 -- Injected: localized type display names from generated lang/type_names.lua
  -- Type names stay English in the type_chart registry so third-party
  -- mods that key colors/UI off TypeChart.displayName keep resolving,
  -- and are localized at draw time instead: every engine site renders
  -- the type name as a standalone Font.draw string, which is substituted
  -- below.
  local okType, TypeChart = pcall(require, "src.battle.TypeChart")
  local by_english = {}
  counts.type_names = each("type_names", function(typeId, localized)
    if okType and TypeChart and type(TypeChart.displayName) == "function" then
      local canonical = TypeChart.displayName(typeId)
      if type(canonical) == "string" and canonical ~= "" and canonical ~= localized then
        by_english[canonical] = localized
      end
    end
  end)
  if next(by_english) then
    local okFont, Font = pcall(require, "src.render.Font")
    if okFont and type(Font) == "table" then
      local function localize(text)
        if type(text) ~= "string" then return text end
        local localized = by_english[text]
        return type(localized) == "string" and localized or text
      end
      if type(Font.split) == "function" then
        local original_split = Font.split
        Font.split = function(text)
          return original_split(localize(text))
        end
      end
      if type(Font.draw) == "function" then
        local original_draw = Font.draw
        Font.draw = function(text, x, y, ...)
          return original_draw(localize(text), x, y, ...)
        end
      end
    end
  end

  

--- =========================================
  -- Injected: versioned catalogs for Pokémon Yellow.
--- =========================================
  local okGame, GameVersion = pcall(require, "src.core.GameVersion")
  local yellow_game_version = okGame and type(GameVersion) == "table"
      and type(GameVersion.isYellow) == "function"
      and GameVersion.isYellow()
  if yellow_game_version then
    each("dialogue_yellow", function(id, value) mod.content.text:override(id, value) end)
    each("pokedex_yellow", function(id, value) mod.content.text:override(id, value) end)
  end
  
  
 
  
  
  
--- =========================================
  -- Traduções Literais
--- ========================================= 
  local literal_body = mod:read("lang/literal_handlers.lua")
  if literal_body then
    local chunk, err = loadstring(literal_body, "lang/literal_handlers.lua")
    if not chunk then error(err) end
    local setup = chunk()
    if type(setup) ~= "function" then error("literal_handlers.lua must return a function") end
    setup(mod)
  end

--- =========================================
-- Cartão de Treinador
-- ==========================================
local oldTrainerCardDraw = TrainerCard.draw

TrainerCard.draw = function(self, ...)
    if not mod.exports.trainer_card then
        return oldTrainerCardDraw(self, ...)
    end

    local oldDraw = Font.draw
    local oldGfxDraw = love.graphics.draw
    local save = self.game.save

    Font.draw = function(text, x, y, ...)
        if x == 16 and y == 16 then
            oldDraw(
                Strings("NAME/%s", save.player.name or "RED"),
                16, 12, ...
            )

        elseif x == 16 and y == 32 then
            oldDraw(
                Strings("DINHEIRO/"),
                16, 25, ...
            )

            oldDraw(
                ("¥%d"):format(save.money or 0),
                48, 33, ...
            )

        elseif x == 16 and y == 48 then
            local t = math.floor(save.playTime or 0)

            oldDraw(
                Strings("TEMPO/"),
                16, 42, ...
            )

            oldDraw(
                ("%3d:%02d"):format(
                    math.floor(t / 3600),
                    math.floor(t / 60) % 60
                ),
                48, 50, ...
            )

        elseif x == 56 and y == 72 then
            oldDraw(
                Strings("BADGES"),
                40, 72, ...
            )

        else
            return oldDraw(text, x, y, ...)
        end
    end

    love.graphics.draw = function(image, ...)
        local args = {...}

        if image == self.circle then
            local x = args[1]
            local y = args[2]

            if x == 48 and y == 72 then
                args[1] = 32
                args[2] = 70

            elseif x == 104 and y == 72 then
                args[1] = 112
                args[2] = 70
            end

        
        end

        return oldGfxDraw(image, unpack(args))
    end

    local ok, a, b, c, d, e =
        pcall(oldTrainerCardDraw, self, ...)

    Font.draw = oldDraw
    love.graphics.draw = oldGfxDraw

    if not ok then
        error(a)
    end

    return a, b, c, d, e
end

--------------------------------------------------------------
----------------------BATTLE UI
---------------------- BATTLE UI
---------------------- BATTLE UI
--------------------------------------------------------------
local oldDrawTextArea = BattleState.drawTextArea

BattleState.drawTextArea = function(self, ...)
    local oldDraw = Font.draw
    local oldDrawCode = Font.drawCode
    local oldDrawBox = Font.drawBox

    -- Sequências reais dos textos
    local fight = Font.encode(Strings("FIGHT", "battle"))
    local item  = Font.encode(Strings("ITEM", "battle"))
    local run   = Font.encode(Strings("RUN", "battle"))

    Font.drawCode = function(code, x, y, ...)
        -- =====================================================
        -- FIGHT / ITEM / RUN
        -- Só pode funcionar no menu normal de batalha.
        -- =====================================================

        if self.phase == "menu" and not self.safari then

            -- FIGHT
            if y == 112 then
                for i, glyph in ipairs(fight) do
                    if code == glyph and x == 80 + (i - 1) * 8 then
                        x = x - 24
                        break
                    end
                end
            end

            -- ITEM
            if y == 128 then
                for i, glyph in ipairs(item) do
                    if code == glyph and x == 80 + (i - 1) * 8 then
                        x = x - 24
                        break
                    end
                end
            end

            -- RUN
            if y == 128 then
                for i, glyph in ipairs(run) do
                    if code == glyph and x == 128 + (i - 1) * 8 then
                        x = x - 16
                        break
                    end
                end
            end

            -- =================================================
            -- PKMN
            -- =================================================

            if code == 0xE1 and x == 128 and y == 112 then
                x = 112

            elseif code == 0xE2 and x == 136 and y == 112 then
                x = 120
            end

            -- =================================================
            -- CURSORES DE BATALHA
            -- =================================================

            if code == 0xED and x == 72 and y == 112 then
                x = 48

            elseif code == 0xED and x == 120 and y == 112 then
                x = 104

            elseif code == 0xED and x == 72 and y == 128 then
                x = 48

            elseif code == 0xED and x == 120 and y == 128 then
                x = 104
            end
        end

        return oldDrawCode(code, x, y, ...)
    end

    -- =========================================================
    -- FIGHT / PKMN / ITEM / RUN BOX
    -- =========================================================

    Font.drawBox = function(x, y, w, h, ...)
        if self.phase == "menu"
            and not self.safari
            and x == 8
            and y == 12
            and w == 12
            and h == 6 then

            x = 5
            w = 15
        end

        return oldDrawBox(x, y, w, h, ...)
    end

    local ok, a, b, c, d, e = pcall(oldDrawTextArea, self, ...)

    -- Restaura as funções originais
    Font.drawBox = oldDrawBox
    Font.draw = oldDraw
    Font.drawCode = oldDrawCode

    if not ok then
        error(a)
    end

    return a, b, c, d, e
end


----------------------------------------
--INVENTÁRIO - QUEBRA DE LINHA
----------------------------------------
local oldListMenuDraw = ListMenu.draw

ListMenu.draw = function(self, ...)
    local oldDraw = Font.draw
    local oldDrawCode = Font.drawCode
    local oldDrawBox = Font.drawBox

    local offset = mod.exports.precos_linha and 8 or 0

    Font.draw = function(text, x, y, ...)
        
        -- ITEM_NAME_X
        -- Original: 48
        -- Novo: 40
        if x == 48 then
            x = 40
        end

        return oldDraw(text, x, y, ...)
    end

Font.drawCode = function(code, x, y, ...)
    -- CURSORES DO ITEM MENU
    if code == Theme.cursor and x == 40 then
        x = 32

    elseif code == Theme.cursorHollow and x == 40 then
        x = 32
    end

    return oldDrawCode(code, x, y, ...)
end


    Font.drawBox = function(x, y, w, h, ...)
        -- ITEM_BOX
        -- Original: 4, 2, 16, 11
        -- Novo: 2, 2, 20, 11
        if x == 4
            and y == 2
            and w == 16
            and h == 11 then

            x = 3
            y = 2
            w = 17
            h = 11
        end

        return oldDrawBox(x, y, w, h, ...)
    end

    local ok, a, b, c, d, e = pcall(oldListMenuDraw, self, ...)

    Font.drawBox = oldDrawBox
    Font.draw = oldDraw
    Font.drawCode = oldDrawCode

    if not ok then
        error(a)
    end

    return a, b, c, d, e
end


-------------
mod.hooks:wrap("ui.party.submenu", function(next, game, items, mon, ctx)
    local result = next(game, items, mon, ctx)

    if type(result) == "table" then
        for _, item in ipairs(result) do
            if item.action == "switch" then
                item.label = "MOVER"
            end
        end
    end

    return result
end)

local OverworldState = require("src.world.OverworldController")
local TextBox = require("src.render.TextBox")

local oldNurseHeal = OverworldState.nurseHeal
local oldTextBoxNew = TextBox.new

OverworldState.nurseHeal = function(self, onDone, npc)
    TextBox.new = function(game, text, onDone, opts)
        if opts
            and opts.choiceLabels
            and opts.choiceBox == Theme.healCancelBox then

            for i, label in ipairs(opts.choiceLabels) do
                if label == "CANCEL" then
                    opts.choiceLabels[i] = "SAIR"
                end
            end
        end

        return oldTextBoxNew(game, text, onDone, opts)
    end

    local ok, a, b, c, d, e = pcall(oldNurseHeal, self, onDone, npc)

    TextBox.new = oldTextBoxNew

    if not ok then
        error(a)
    end

    return a, b, c, d, e
end

------------------
------------------
 -- local TitleState = require("src.ui.TitleState")

-- local oldDraw = TitleState.draw

-- TitleState.draw = function(self)
  -- oldDraw(self)

  -- if self.version
     -- and not self.yellowLayout
     -- and self.phase ~= "drop"
     -- and self.phase ~= "settle" then

    -- local iw, ih = self.version:getDimensions()
    -- local rx = self.ribbonOffset or 0

    -- love.graphics.setColor(1, 1, 1, 1)
    -- love.graphics.rectangle(
      -- "fill",
      -- 40 + rx,
      -- 64,
      -- 104,
      -- 8
    -- )

    -- if self.blue then
     -- BLUE:
     -- antigo: 0,0,64,8  -> 56,64
     -- novo:   88,0,72,8  -> 48,64
      -- love.graphics.draw(
        -- self.version,
        -- love.graphics.newQuad(88, 0, 72, 8, iw, ih),
        -- 48 + rx,
        -- 64
      -- )
    -- else
     -- RED:
     -- antigo: dois pedaços
     -- novo: um pedaço contínuo
      -- love.graphics.draw(
        -- self.version,
        -- love.graphics.newQuad(0, 0, 88, 8, iw, ih),
        -- 40 + rx,
        -- 64
      -- )
    -- end
  -- end

  -- love.graphics.setColor(1, 1, 1, 1)
-- end

--yellow
-------------
-- local TitleState = require("src.ui.TitleState")

-- local oldNew = TitleState.new

-- TitleState.new = function(game, opts)
  -- local self = oldNew(game, opts)

  -- if self.yellow then
    -- local ok, logo = pcall(
      -- love.graphics.newImage,
      -- mod.assets:path("assets/title/yellow_logo.png")
    -- )

    -- if ok and logo then
      -- logo:setFilter("nearest", "nearest")
      -- self.logo = logo
    -- end
--  end

--  if self.yellow then
--    local ok, bubble = pcall(
--      love.graphics.newImage,
--      mod.assets:path("assets/title/pika_bubble.png")
--    )

--   if ok and bubble then
--      bubble:setFilter("nearest", "nearest")
--      self.yellowBubble = bubble
--    end
--  end


--  return self
--end

 
------------------

    local Font = require("src.render.Font")
    local oldDraw = Font.draw
    local oldDrawBox = Font.drawBox

    Font.draw = function(text, x, y, ...)
        if text == Strings("MONEY") and x == 96 and y == 16 then
            x = 88
        elseif text == Strings("COIN") and x == 96 and y == 32 then
            x = 88
        end

        return oldDraw(text, x, y, ...)
    end

    Font.drawBox = function(x, y, w, h, ...)
        if x == 11 and y == 0 and w == 9 and h == 7 then
            w = 10
			x = 10
        end

        return oldDrawBox(x, y, w, h, ...)
    end

------------------
--rename ROCKET to TEAM ROCKET
------------------
local oldBattleSay = BattleState.say
local oldBattleSayNext = BattleState.sayNext

local function replaceRocketName(self, text)
  local index = self.partyIndex or 1

  if self.oppClass == "OPP_ROCKET"
     and index >= 42 -- JESSIE & JAMES
     and index <= 45 -- JESSIE & JAMES
     and type(text) == "string" then

    local newName = "EQUIPE ROCKET" --or JESSIE&JAMES

    if not text:find(newName, 1, true) then
      text = text:gsub("ROCKET", newName)
    end
  end

  return text
end

BattleState.say = function(self, text, ...)
  text = replaceRocketName(self, text)
  return oldBattleSay(self, text, ...)
end

BattleState.sayNext = function(self, text, ...)
  text = replaceRocketName(self, text)
  return oldBattleSayNext(self, text, ...)
end
------------------
local DexExtra = catalog("dex_extra")

local DexEntryMenu = require("src.ui.DexEntryMenu")
local oldDexEntryNew = DexEntryMenu.new

DexEntryMenu.new = function(game, speciesOrOpts, onDone)
    for species, extra in pairs(DexExtra) do
        local pokemon = game.data.pokemon[species]

        if pokemon and pokemon.dexEntry then
            pokemon.dexEntry.heightM = extra.heightM
            pokemon.dexEntry.weightKg = extra.weightKg
        end
    end

    return oldDexEntryNew(game, speciesOrOpts, onDone)
end

------------------
end
