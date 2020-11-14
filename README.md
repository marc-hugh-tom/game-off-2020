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
The script will output the modified sprites in `assets`, as well as a file `assets/base_palette.png`.
Then, take a screenshot of the game and open up GIMP.
Copy the base palette into the image, and dick around with the hue, saturation, and colour temperature.
Copy the resulting palette as `assets/night_palette.png`.
