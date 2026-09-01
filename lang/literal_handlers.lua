-- Generated qid-driven literal dialogue handlers.
return function(mod)
  local TextBox = mod.ui.TextBox
  local ChoiceBox = mod.ui.ChoiceBox
  mod.content.map_scripts:register("VIRIDIAN_CITY", {talk = {
    ["TEXT_VIRIDIANCITY_YOUNGSTER2"] = function(game, ow, npc, done)
      game.stack:push(TextBox.new(game, "Quer saber sobre\nos 2 tipos de\011lagartas POKéMON?", function()
        game.stack:push(ChoiceBox.new(game, function(yes)
          game.stack:push(TextBox.new(game, yes and "CATERPIE não tem\nveneno, mas o\011WEEDLE tem.\012Cuidado com o seu\nFERRÃO VENENOSO!" or "Ah, tudo bem\nentão!", done))
        end))
      end))
    end,
  },
  })
  mod.content.map_scripts:register("MUSEUM_1F", {talk = {
    ["TEXT_MUSEUM1F_SCIENTIST1"] = function(game, ow, npc, done)
      if game.save.flags["EVENT_BOUGHT_MUSEUM_TICKET"] then
        game.stack:push(TextBox.new(game, "Fique à vontade\npara olhar o\011tempo que quiser!", done))
      else
        game.stack:push(TextBox.new(game, "Custa ¥50 por um\nbilhete infantil.\012Gostaria de\nentrar?", function()
          game.stack:push(ChoiceBox.new(game, function(yes)
            if yes then
              if (game.save.money or 0) >= 50 then
                game.save.money = (game.save.money or 0) + (-50)
                game.save.flags["EVENT_BOUGHT_MUSEUM_TICKET"] = true
                game.stack:push(TextBox.new(game, "50¥! Perfeito!\nObrigado!", done))
              else
                game.stack:push(TextBox.new(game, "Você não tem di\nheiro suficiente.", done))
              end
            else
              game.stack:push(TextBox.new(game, "Volte sempre!", done))
            end
          end))
        end))
      end
    end,
  },
    onStep = function(game, ow, x, y)
      if ((x == 9 and y == 4) or (x == 10 and y == 4)) and not game.save.flags["EVENT_BOUGHT_MUSEUM_TICKET"] then
        local function on_done() end
        game.stack:push(TextBox.new(game, "Custa ¥50 por um\nbilhete infantil.\012Gostaria de\nentrar?", function()
          game.stack:push(ChoiceBox.new(game, function(yes)
            if yes then
              if (game.save.money or 0) >= 50 then
                game.save.money = (game.save.money or 0) + (-50)
                game.save.flags["EVENT_BOUGHT_MUSEUM_TICKET"] = true
                game.stack:push(TextBox.new(game, "Certo, ¥50!\nObrigado!", on_done))
              else
                game.stack:push(TextBox.new(game, "Você não tem di\nheiro suficiente.", function()
                  ow:scriptMove(ow.player, "down", 1, on_done)
                end))
              end
            else
              game.stack:push(TextBox.new(game, "Volte sempre!", function()
                ow:scriptMove(ow.player, "down", 1, on_done)
              end))
            end
          end))
        end))
        return true
      end
      return false
    end,
  })
  

---
mod.content.map_scripts:register("ROUTE_24", {
  talk = {
    ["TEXT_ROUTE24_COOLTRAINER_M1"] = function(game, ow, npc, done)
      if game.save.flags["EVENT_BEAT_ROUTE24_ROCKET"] then
        game.stack:push(TextBox.new(game, "Com essa aptidão,\nvocê poderia ser\vum grande líder\vna EQUIPE ROCKET!", done))
        return
      end

      local function start_battle()
        mod.log:info("--- DEBUG: Avvio battaglia con ow:engageTrainer ---")
        if ow and type(ow.engageTrainer) == "function" then
          -- Segna come sconfitto per evitare futuri combattimenti futuri
          game.save.flags["EVENT_BEAT_ROUTE24_ROCKET"] = true
          ow:engageTrainer(npc, done)
        else
          done()
        end
      end

      local function ask_join()
        game.stack:push(TextBox.new(game, "Aproveitando, que\ntal se juntar a\vEQUIPE ROCKET?\fSomos um grupo que\nse dedica ao mal\vusando POKéMON!\fQuer entrar?", function()
          game.stack:push(ChoiceBox.new(game, function(yes)
            game.stack:push(TextBox.new(game, "Tem certeza?\nNão?\fQual é, se\njunte a nós!\fEstou mandando\nvocê participar!\fTá, você precisa\nser convencido!", function()
              start_battle()
            end))
          end))
        end))
      end

      if not game.save.flags["EVENT_GOT_NUGGET"] then
        game.stack:push(TextBox.new(game, "Parabéns!\nVocê derrotou os\v5 competidores!\fE ganhou um prêmio\nfabuloso!", function()
          game.save.inventory["NUGGET"] = (game.save.inventory["NUGGET"] or 0) + 1
          game.save.flags["EVENT_GOT_NUGGET"] = true
          game.stack:push(TextBox.new(game, "{PLAYER} ganhou\numa PEPITA!", function()
            ask_join()
          end))
        end))
      else
        ask_join()
      end
    end,
  },
})
end