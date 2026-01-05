' source/Audio.brs
function CreateAudioManager() as Object
    audio = {}

    audio.music = CreateObject("roAudioPlayer")
    audio.music.SetLoop(true)

    audio.PlayMusic = function(path as String)
        m.music.Stop()
        m.music.ClearContent()
        m.music.AddContent({ url: path })
        m.music.Play()
    end function

    audio.PlaySFX = function(path as String)
        sfx = CreateObject("roAudioPlayer")
        sfx.AddContent({ url: path })
        sfx.Play()
    end function

    return audio
end function
