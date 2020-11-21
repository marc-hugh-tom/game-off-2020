# game-off-2020
Our entry for the GitHub Game Off 2020 game jam

Godot version v3.2.2.stable.official

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
