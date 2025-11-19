/* SPDX-FileCopyrightText: 2022 Blender Authors
 *
 * SPDX-License-Identifier: GPL-2.0-or-later */

/* Requires all common matrices declared. */

void normal_transform_object_to_world(vec3 vin, out vec3 vout)
{
  /* Expansion of NormalMatrix. */
#ifdef GPU_SHADER_EEVEE_LEGACY_DEFINES
  vout = vin * to_float3x3(ModelMatrixInverseGoo);
#else
  vout = vin * to_float3x3(drw_modelinv());
#endif
}

void normal_transform_world_to_object(vec3 vin, out vec3 vout)
{
  /* Expansion of NormalMatrixInverse. */
#ifdef GPU_SHADER_EEVEE_LEGACY_DEFINES
  vout = vin * to_float3x3(ModelMatrixGoo);
#else
  vout = vin * to_float3x3(drw_modelmat());
#endif
}

void direction_transform_object_to_world(vec3 vin, out vec3 vout)
{
#ifdef GPU_SHADER_EEVEE_LEGACY_DEFINES
  vout = to_float3x3(ModelMatrixGoo) * vin;
#else
  vout = to_float3x3(drw_modelmat()) * vin;
#endif
}

void direction_transform_object_to_view(vec3 vin, out vec3 vout)
{
#ifdef GPU_SHADER_EEVEE_LEGACY_DEFINES
  vout = to_float3x3(ModelMatrixGoo) * vin;
  vout = to_float3x3(ViewMatrixGoo) * vout;
#else
  vout = to_float3x3(drw_modelmat()) * vin;
  vout = to_float3x3(drw_view().viewmat) * vout;
#endif
}

void direction_transform_view_to_world(vec3 vin, out vec3 vout)
{
#ifdef GPU_SHADER_EEVEE_LEGACY_DEFINES
  vout = to_float3x3(ViewMatrixInverseGoo) * vin;
#else
  vout = to_float3x3(drw_view().viewinv) * vin;
#endif
}

void direction_transform_view_to_object(vec3 vin, out vec3 vout)
{
#ifdef GPU_SHADER_EEVEE_LEGACY_DEFINES
  vout = to_float3x3(ViewMatrixInverseGoo) * vin;
  vout = to_float3x3(ModelMatrixInverseGoo) * vout;
#else
  vout = to_float3x3(drw_view().viewinv) * vin;
  vout = to_float3x3(drw_modelinv()) * vout;
#endif
}

void direction_transform_world_to_view(vec3 vin, out vec3 vout)
{
#ifdef GPU_SHADER_EEVEE_LEGACY_DEFINES
  vout = to_float3x3(ViewMatrixGoo) * vin;
#else
  vout = to_float3x3(drw_view().viewmat) * vin;
#endif
}

void direction_transform_world_to_object(vec3 vin, out vec3 vout)
{
#ifdef GPU_SHADER_EEVEE_LEGACY_DEFINES
  vout = to_float3x3(ModelMatrixInverseGoo) * vin;
#else
  vout = to_float3x3(drw_modelinv()) * vin;
#endif
}

void point_transform_object_to_world(vec3 vin, out vec3 vout)
{
#ifdef GPU_SHADER_EEVEE_LEGACY_DEFINES
  vout = (ModelMatrixGoo * vec4(vin, 1.0)).xyz;
#else
  vout = (drw_modelmat() * vec4(vin, 1.0)).xyz;
#endif
}

void point_transform_object_to_view(vec3 vin, out vec3 vout)
{
#ifdef GPU_SHADER_EEVEE_LEGACY_DEFINES
  vout = (ViewMatrixGoo * (ModelMatrixGoo * vec4(vin, 1.0))).xyz;
#else
  vout = (drw_view().viewmat * (drw_modelmat() * vec4(vin, 1.0))).xyz;
#endif
}

void point_transform_view_to_world(vec3 vin, out vec3 vout)
{
#ifdef GPU_SHADER_EEVEE_LEGACY_DEFINES
  vout = (ViewMatrixInverseGoo * vec4(vin, 1.0)).xyz;
#else
  vout = (drw_view().viewinv * vec4(vin, 1.0)).xyz;
#endif
}

void point_transform_view_to_object(vec3 vin, out vec3 vout)
{
#ifdef GPU_SHADER_EEVEE_LEGACY_DEFINES
  vout = (ModelMatrixInverseGoo * (ViewMatrixInverseGoo * vec4(vin, 1.0))).xyz;
#else
  vout = (drw_modelinv() * (drw_view().viewinv * vec4(vin, 1.0))).xyz;
#endif
}

void point_transform_world_to_view(vec3 vin, out vec3 vout)
{
#ifdef GPU_SHADER_EEVEE_LEGACY_DEFINES
  vout = (ViewMatrixGoo * vec4(vin, 1.0)).xyz;
#else
  vout = (drw_view().viewmat * vec4(vin, 1.0)).xyz;
#endif
}

void point_transform_world_to_object(vec3 vin, out vec3 vout)
{
#ifdef GPU_SHADER_EEVEE_LEGACY_DEFINES
  vout = (ModelMatrixInverseGoo * vec4(vin, 1.0)).xyz;
#else
  vout = (drw_modelinv() * vec4(vin, 1.0)).xyz;
#endif
}
