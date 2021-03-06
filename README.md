# Blood Moon - GitHub Game Off 2020

Made for the GitHub Game Off 2020, which had the theme "moonshot".

In Blood Moon you're a werewolf, whose senses and strength increase at night when the moon is high! Try and survive for 5 nights to be turned back into a human. There's also an endless mode to test your abilities. Best played fullscreen.

Here we are interpreting moonshot as using the time when the moon is highest as your "shot" to kill as many enemies as possible.

Godot version v3.2.3.stable.official

## Creating sprites with different day / night colours

Put sprites into `raw_assets`, with the correct directory structure. Make sure that the corresponding directories also exist in assets.
Install the required Python packages (`build_scripts/requirements.txt`) into a virtual requirement, then run the `generate_palette.py` script while in the base directory:

```
python build_scripts/generate_palette.py

Saving: assets/sprites/building.png
Saving: assets/sprites/werewolf/body_0.png
Saving: assets/sprites/werewolf/feet_3.png
Saving: assets/sprites/werewolf/feet_4.png
Saving: assets/sprites/werewolf/feet_2.png
Saving: assets/sprites/werewolf/body_2.png
Saving: assets/sprites/werewolf/body_1.png
Saving: assets/sprites/werewolf/feet_1.png
Saving: assets/sprites/werewolf/feet_0.png
Saving: assets/sprites/map/grass_tileset.png
Saving: assets/sprites/map/dirt_tileset.png
```
The script will output the modified sprites in `assets`, as well as a file `assets/base_palette.png` and `assets/night_palette.png`

### Editing night palette
`night_palette.png` is "best effort" in code, but sometimes you might want to edit this manually:

- Run `cp assets/base_palette.png assets/night_palette.png` to match night palette to day palette.
- Modify `Palette.shader` to only use `day_colour`.
- Run the game and take a screenshot.
- Open up GIMP and paste the screenshot in.
- Copy the night palette into the image, and dick around with the hue, saturation, and colour temperature.
- Overwrite `assets/night_palette.png` with the altered palette, making sure that the resulting palette is the same size as `assets/base_palette.png`.

# Credits

## Audio

"Rooster Calling, Close, A.wav" by InspectorJ (www.jshaw.co.uk) of Freesound.org

"Tawny Owls 2.wav" by Benboncan of Freesound.org

"Dog Begging.wav" by Coral_Island_Studios of Freesound.org

"male_hurt12.ogg" by micahlg of Freesound.org

"Oh Shit.wav" by pyro13djt of Freesound.org

"crit - Shout - scream" by albertgrinyo of Freesound.org

"oh my lord!.wav" by Reitanna of Freesound.org

"Oh no Oh crap" by AmeAngelofSin of Freesound.org

"Weapon_Revolver_Shots_Stereo.wav" by Nox_Sound of Freesound.org

"howling" by PhonosUPF of Freesound.org

## Images

Moon image modified from https://commons.wikimedia.org/wiki/File:Supermoon_Nov-14-2016-minneapolis.jpg

Sound on icon by Yaroslav Samoylov of thenounproject.com

Sound off icon by Yaroslav Samoylov of thenounproject.com

Colours from the CC-29 palette by Alpha6 were used for some sprites (https://lospec.com/palette-list/cc-29)

## Fonts

Fonts used are:
Scratch by KohanTheBarbarian
http://fontstruct.com/fontstructions/show/959231

Aquifer Regular Font by JLH Fonts
http://www.publicdomainfiles.com/show_file.php?id=13949887208668
