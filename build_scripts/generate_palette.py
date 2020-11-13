from PIL import Image, ImageColor
import numpy as np
import glob
import os

raw_assets_dir = 'raw_assets'
output_dir = 'assets'
palette_filepath = os.path.join(output_dir, 'base_palette.png')

def rgba2hex(r, g, b, a):
    return('#{:02x}{:02x}{:02x}{:02x}'.format(r, g, b, a))

raw_png_filepaths = glob.glob(raw_assets_dir + '/**/*.png', recursive=True)

palette = set([])

for filepath in raw_png_filepaths:
    original_im = Image.open(filepath)
    assert(original_im.mode == 'RGBA')
    original_im_array = np.array(original_im)

    for x_idx in range(original_im_array.shape[0]):
        for y_idx in range(original_im_array.shape[1]):
            palette.add(rgba2hex(*original_im_array[x_idx, y_idx]))

palette = sorted(list(palette))
assert(len(palette) <= 256)
while len(palette) < 256:
    palette.append('#ffffffff')
palette_array = np.zeros((len(palette), 1, 4), dtype='uint8')
for idx, hex_str in enumerate(palette):
    palette_array[idx, :, : ] = ImageColor.getrgb(hex_str)

palette_im = Image.fromarray(palette_array, 'RGBA')
palette_im.save(palette_filepath)

for filepath in raw_png_filepaths:
    original_im = Image.open(filepath)
    assert(original_im.mode == 'RGBA')
    original_im_array = np.array(original_im)

    out_image = np.zeros(original_im_array.shape[0:2], dtype='uint8')

    for x_idx in range(original_im_array.shape[0]):
        for y_idx in range(original_im_array.shape[1]):
            out_image[x_idx, y_idx] = palette.index(
                rgba2hex(*original_im_array[x_idx, y_idx]))

    out_im_array = np.concatenate(
        [np.expand_dims(out_image, 2) for i in range(3)], 2
    )
    out_im = Image.fromarray(out_im_array, 'RGB')

    out_im_filepath = filepath.split(os.sep)
    out_im_filepath[0] = output_dir
    print('Saving: ' + os.path.join(*out_im_filepath))
    out_im.save(os.path.join(*out_im_filepath))
