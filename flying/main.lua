package.path = "../verktyg/?.lua;..\\verktyg\\?.lua;" .. package.path
require "bas"
require "sprite"
require "background"

spelarkostymer = {
    "resources/player/frame-1.png",
    "resources/player/frame-2.png",
    "resources/player/frame-3.png",
    "resources/player/frame-4.png",
}

spelaranimationer = {
    ["skjut"] = {
    "resources/skjut/frame-1.png",
    "resources/skjut/frame-2.png",
    "resources/skjut/frame-3.png"
    }
}

skottkostymer = {
    "resources/skott/skott.png"
}

fiendeanimationer = {
    ["explode"] = {
    "resources/explode/a1.png",
    "resources/explode/a2.png",
    "resources/explode/a3.png",
    "resources/explode/a4.png",
    "resources/explode/a5.png"
    }
}

orangekostymer = {
    "resources/enemies/orange/frame-1.png",
    "resources/enemies/orange/frame-2.png",
    "resources/enemies/orange/frame-3.png",
    "resources/enemies/orange/frame-4.png",
}

rodkostymer = {
    "resources/enemies/red/frame-1.png",
    "resources/enemies/red/frame-2.png",
    "resources/enemies/red/frame-3.png",
    "resources/enemies/red/frame-4.png",
}

lilakostymer = {
    "resources/enemies/purple/frame-1.png",
    "resources/enemies/purple/frame-2.png",
}

sprites = {}
fiender = {}
fiendemallar = {}
eldklot = {}

function love.load()
    bas.starta(bas.hanteraSignaler)
    bas.starta(bas.uppdateraGrafik)
    bas.starta(bas.repeteraAlla)
    himmel = Background(0, 0, 2, 0, 0.40, "resources/background/sky.png")
    berg1 = Background(0, 100, 3, 0, 0.40, "resources/background/berg1.png")
    berg2 = Background(0, 100, 2, 0, 0.40, "resources/background/berg2.png")
    berg3 = Background(0, 100, 1, 0, 0.40, "resources/background/berg3.png")
    spelare = Sprite(75, 250, 0, 0, 0.14, spelarkostymer, spelaranimationer)
    rodfiende = Sprite(800, 0, -5, 0, 0.14, rodkostymer, fiendeanimationer)
    lilafiende = Sprite(800, 0, -5, 0, 0.14, lilakostymer, fiendeanimationer)
    orangefiende = Sprite(800, 0, -5, 0, 0.14, orangekostymer, fiendeanimationer)
    table.insert(fiendemallar, rodfiende)
    table.insert(fiendemallar, lilafiende)
    table.insert(fiendemallar, orangefiende)
    table.insert(sprites, himmel)
    table.insert(sprites, berg3)
    table.insert(sprites, berg2)
    table.insert(sprites, berg1)
    table.insert(sprites, spelare)
    bas.repetera(animera, 0.15, true, spelare)
    bas.repetera(skapafiende, 0.8, true)
    bas.startaGrafik(spelare, uppdateraSpelare)
    bas.startaGrafik(himmel, scrollabakgrund)
    bas.startaGrafik(berg3, scrollabakgrund)
    bas.startaGrafik(berg2, scrollabakgrund)
    bas.startaGrafik(berg1, scrollabakgrund)
    skott = Sprite(0, 0, 10, 0, 0.14, skottkostymer)
end

function love.update()
    bas.tick()
end

function love.draw()
    for _, sprite in pairs(sprites) do
        sprite:rita()
    end
    -- love.graphics.print(string.format("Poäng %s", points), 5, 5)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    if key == "up" then
        bas.skickaSignal(upp, spelare)
    end
    if key == "down" then
        bas.skickaSignal(ner, spelare)
    end
    if key == " " then
        bas.skickaSignal(skjut, spelare)
    end
end

function uppdateraSpelare(spelare)
    -- Should simplify this
    if (spelare.x + spelare.bredd < 800 and spelare.xfart > 0) and (spelare.x > 0 and spelare.xfart > 0) then
        spelare.x = spelare.x + spelare.xfart
    end
    if (spelare.y + spelare.hojd < 600 or spelare.yfart < 0) and (spelare.y > 0 or spelare.yfart > 0) then
        spelare.y = spelare.y + spelare.yfart
    end
end

function uppdateraSkott(skott)
    skott.x = skott.x + skott.xfart
    if skott.x > 850 then
        bas.raderaGrafik(skott)
        eldklot[tostring(skott)] = nil
        sprites[tostring(skott)] = nil
    end
    for i, fiende in pairs(fiender) do
        if fiende ~= nil and fiende:krock(skott) == true then
            fiende:stopAnimation("explode", raderaFiende)
            bas.raderaGrafik(skott)
            eldklot[tostring(skott)] = nil
            sprites[tostring(skott)] = nil
        end
    end
end

function raderaFiende(fiende)
    sprites[tostring(fiende)] = nil
    fiender[tostring(fiende)] = nil
    bas.raderaGrafik(fiende)
end

function uppdateraFiende(fiende)
    fiende.x = fiende.x + fiende.xfart
    if fiende.x < -100 then
        raderaFiende(fiende)
    end
end

function animera(sprite)
    sprite:bytKostym()
end

function skjut(sprite)
    sprite:spelaAnimation("skjut")
    skottkopia = skott:kopiera()
    skottkopia.x, skottkopia.y = sprite.x + sprite.bredd, sprite.y + sprite.hojd / 2
    sprites[tostring(skottkopia)] = skottkopia
    eldklot[tostring(skottkopia)] = skottkopia
    bas.startaGrafik(skottkopia, uppdateraSkott)
end

function upp(sprite)
    sprite.yfart = -2
end

function ner(sprite)
    sprite.yfart = 2
end

function scrollabakgrund(background)
    background.x = background.x - background.xfart
    if background.x < background.bredd * -1 then
        background.x = background.x + background.bredd
    end
end

function skapafiende()
    slump = math.random(0, 550)
    fiendeslump = math.random(1, 3)
    fiende = fiendemallar[fiendeslump]:kopiera()
    fiende.y = slump
    sprites[tostring(fiende)] = fiende
    fiender[tostring(fiende)] = fiende
    bas.startaGrafik(fiende, uppdateraFiende)
    bas.repetera(animera, 0.15, true, fiende)
end
