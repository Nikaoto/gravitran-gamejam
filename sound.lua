sound = {
  ["jump"] = love.audio.newSource("res/jump.wav", "static"),
  ["trans"] = love.audio.newSource("res/trans.wav", "static"),
  ["reset"] = love.audio.newSource("res/reset.wav", "static"),
  ["death"] = love.audio.newSource("res/death.wav", "static"),
  ["collide"] = love.audio.newSource("res/collide.wav", "static"),
  ["apple"] = love.audio.newSource("res/apple.wav", "static"),
  ["finish"] = love.audio.newSource("res/finish.wav", "static"),
  ["win"] = love.audio.newSource("res/win.wav", "static")
  --["music"] = love.audio.newSource("res/music.ogg", "stream")
}

function sound.play(str)
  local pitch = lume.random(0.8, 1.2)
  if sound[str]:isPlaying() then
    local temp = sound[str]:clone()
    temp:setPitch(pitch)
    temp:play()
  else
    sound[str]:setPitch(pitch)
    sound[str]:play()
  end
end

-- Checks if sound not already playing before playing it
function sound.playOne(str)
  if not sound[str]:isPlaying() then
    sound.play(str)
  end
end