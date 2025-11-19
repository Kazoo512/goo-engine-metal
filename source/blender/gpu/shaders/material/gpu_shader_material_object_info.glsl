/* SPDX-FileCopyrightText: 2019-2022 Blender Authors
 *
 * SPDX-License-Identifier: GPL-2.0-or-later */

void node_object_info(float mat_index,
                      out vec3 location,
                      out vec4 color,
                      out float alpha,
                      out float object_index,
                      out float material_index,
                      out float random)
{
#ifdef GPU_SHADER_EEVEE_LEGACY_DEFINES
  location = ModelMatrixGoo[3].xyz;
  color = ObjectColor;
  alpha = ObjectColor.a;
  object_index = ObjectInfo.x;
#else
  location = drw_modelmat()[3].xyz;
  ObjectInfos info = drw_object_infos();
  color = info.ob_color;
  alpha = info.ob_color.a;
  object_index = info.index;
#endif
  /* TODO(fclem): Put that inside the Material UBO. */
  material_index = mat_index;

#ifdef GPU_SHADER_EEVEE_LEGACY_DEFINES
  random = ObjectInfo.z;
#else
  random = info.random;
#endif
}
