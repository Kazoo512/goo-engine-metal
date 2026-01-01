/* SPDX-FileCopyrightText: 2018-2023 Blender Authors
 *
 * SPDX-License-Identifier: GPL-2.0-or-later */

#pragma once

#ifndef DRAW_MODEL_LIB_GLSL
#define DRAW_MODEL_LIB_GLSL

#include "draw_view_info.hh"

#include "draw_view_lib.glsl"

#if !defined(DRAW_MODELMAT_CREATE_INFO) && !defined(GLSL_CPP_STUBS)
#  error Missing draw_modelmat additional create info on shader create info
#endif





#ifdef GPU_SHADER_EEVEE_LEGACY_DEFINES

/* Temporary until we fully make the switch. */
#  ifndef USE_GPU_SHADER_CREATE_INFO
uniform int drw_resourceChunk;
#  endif /* !USE_GPU_SHADER_CREATE_INFO */

#  ifdef GPU_VERTEX_SHADER

/* Temporary until we fully make the switch. */
#    ifndef USE_GPU_SHADER_CREATE_INFO

/* clang-format off */
#      if defined(IN_PLACE_INSTANCES) || defined(INSTANCED_ATTR) || defined(DRW_LEGACY_MODEL_MATRIX) || defined(GPU_DEPRECATED_AMD_DRIVER)
/* clang-format on */
/* When drawing instances of an object at the same position. */
#        define instanceId 0
#      else
#        define instanceId gl_InstanceID
#      endif

#      if defined(UNIFORM_RESOURCE_ID)
/* This is in the case we want to do a special instance drawcall for one object but still want to
 * have the right resourceId and all the correct UBO datas. */
uniform int drw_ResourceID;
#        define resource_id drw_ResourceID
#      else
#        define resource_id (gpu_BaseInstance + instanceId)
#      endif

/* Use this to declare and pass the value if
 * the fragment shader uses the resource_id. */
#      if defined(EEVEE_GENERATED_INTERFACE)
#        define RESOURCE_ID_VARYING
#        define PASS_RESOURCE_ID resourceIDFrag = resource_id;
#      elif defined(USE_GEOMETRY_SHADER)
#        define RESOURCE_ID_VARYING flat out int resourceIDGeom;
#        define PASS_RESOURCE_ID resourceIDGeom = resource_id;
#      else
#        define RESOURCE_ID_VARYING flat out int resourceIDFrag;
#        define PASS_RESOURCE_ID resourceIDFrag = resource_id;
#      endif

#    endif /* USE_GPU_SHADER_CREATE_INFO */

#  endif /* GPU_VERTEX_SHADER */

/* Temporary until we fully make the switch. */
#  ifdef USE_GPU_SHADER_CREATE_INFO
/* TODO(fclem): Rename PASS_RESOURCE_ID to DRW_RESOURCE_ID_VARYING_SET */
#    if defined(UNIFORM_RESOURCE_ID)
#      define resource_id drw_ResourceID
#      define PASS_RESOURCE_ID

#    elif defined(GPU_VERTEX_SHADER)
#      if defined(UNIFORM_RESOURCE_ID_NEW)
#        define resource_id (drw_ResourceID >> DRW_VIEW_SHIFT)
#      else
#        define resource_id gpu_InstanceIndex
#      endif
#      define PASS_RESOURCE_ID drw_ResourceID_iface.resource_index = resource_id;

#    elif defined(GPU_GEOMETRY_SHADER)
#      define resource_id drw_ResourceID_iface_in[0].resource_index
#      define PASS_RESOURCE_ID drw_ResourceID_iface_out.resource_index = resource_id;

#    elif defined(GPU_FRAGMENT_SHADER)
#      define resource_id drw_ResourceID_iface.resource_index
#    endif

/* TODO(fclem): Remove. */
#    define RESOURCE_ID_VARYING

#  else
/* If used in a fragment / geometry shader, we pass
 * resource_id as varying. */
#    ifdef GPU_GEOMETRY_SHADER
/* TODO(fclem): Remove. This is getting ridiculous. */
#      if !defined(EEVEE_GENERATED_INTERFACE)
#        define RESOURCE_ID_VARYING \
        flat out int resourceIDFrag; \
        flat in int resourceIDGeom[];
#      else
#        define RESOURCE_ID_VARYING
#      endif

#      define resource_id resourceIDGeom
#      define PASS_RESOURCE_ID resourceIDFrag = resource_id[0];
#    endif

#    if defined(GPU_FRAGMENT_SHADER)
#      if !defined(EEVEE_GENERATED_INTERFACE)
flat in int resourceIDFrag;
#      endif
#      define resource_id resourceIDFrag
#    endif
#  endif


#else

#  if defined(UNIFORM_RESOURCE_ID)
/* TODO(fclem): Legacy API. To remove. */
#    define resource_id drw_ResourceID
#    define DRW_RESOURCE_ID_VARYING_SET

#  elif defined(GPU_VERTEX_SHADER)
VERTEX_SHADER_CREATE_INFO(draw_resource_id_varying)
#    if defined(UNIFORM_RESOURCE_ID_NEW)
#      define resource_id (drw_ResourceID >> DRW_VIEW_SHIFT)
#    else
#      define resource_id gpu_InstanceIndex
#    endif
#    define DRW_RESOURCE_ID_VARYING_SET drw_ResourceID_iface.resource_index = resource_id;

#  elif defined(GPU_GEOMETRY_SHADER)
#    define resource_id drw_ResourceID_iface_in[0].resource_index

#  elif defined(GPU_FRAGMENT_SHADER)
FRAGMENT_SHADER_CREATE_INFO(draw_resource_id_varying)
#    define resource_id drw_ResourceID_iface.resource_index
#  elif defined(GPU_LIBRARY_SHADER)
SHADER_LIBRARY_CREATE_INFO(draw_resource_id_varying)
#    define resource_id drw_ResourceID_iface.resource_index
#  endif

#endif


/* Due to some shader compiler bug, we somewhat need to access gl_VertexID
 * to make vertex shaders work. even if it's actually dead code. */
#if defined(GPU_INTEL) && defined(GPU_OPENGL)
#  define GPU_INTEL_VERTEX_SHADER_WORKAROUND gl_Position.x = float(gl_VertexID);
#else
#  define GPU_INTEL_VERTEX_SHADER_WORKAROUND
#endif

#define DRW_BASE_SELECTED (1 << 1)
#define DRW_BASE_FROM_DUPLI (1 << 2)
#define DRW_BASE_FROM_SET (1 << 3)
#define DRW_BASE_ACTIVE (1 << 4)
#define DRW_BASE_HOLDOUT (1 << 5)

mat4x4 drw_modelmat()
{
  return drw_matrix_buf[resource_id].model;
}
mat4x4 drw_modelinv()
{
  return drw_matrix_buf[resource_id].model_inverse;
}

/**
 * Usually Normal matrix is `transpose(inverse(ViewMatrix * ModelMatrix))`.
 *
 * But since it is slow to multiply matrices we decompose it. Decomposing
 * inversion and transposition both invert the product order leaving us with
 * the same original order:
 * transpose(ViewMatrixInverse) * transpose(ModelMatrixInverse)
 *
 * Knowing that the view matrix is orthogonal, the transpose is also the inverse.
 * NOTE: This is only valid because we are only using the mat3 of the ViewMatrixInverse.
 * ViewMatrix * transpose(ModelMatrixInverse)
 */
mat3x3 drw_normat()
{
  return transpose(to_float3x3(drw_modelinv()));
}
mat3x3 drw_norinv()
{
  return transpose(to_float3x3(drw_modelmat()));
}

/* -------------------------------------------------------------------- */
/** \name Transform Normal
 *
 * Space conversion helpers for normal vectors.
 * \{ */

vec3 drw_normal_object_to_world(vec3 lN)
{
  return (drw_normat() * lN);
}
vec3 drw_normal_world_to_object(vec3 N)
{
  return (drw_norinv() * N);
}

vec3 drw_normal_object_to_view(vec3 lN)
{
  return (to_float3x3(drw_view.viewmat) * (drw_normat() * lN));
}
vec3 drw_normal_view_to_object(vec3 vN)
{
  return (drw_norinv() * (to_float3x3(drw_view.viewinv) * vN));
}

/** \} */

/* -------------------------------------------------------------------- */
/** \name Transform Normal
 *
 * Space conversion helpers for points (coordinates).
 * \{ */

vec3 drw_point_object_to_world(vec3 lP)
{
  return (drw_modelmat() * vec4(lP, 1.0)).xyz;
}
vec3 drw_point_world_to_object(vec3 P)
{
  return (drw_modelinv() * vec4(P, 1.0)).xyz;
}

vec3 drw_point_object_to_view(vec3 lP)
{
  return (drw_view.viewmat * (drw_modelmat() * vec4(lP, 1.0))).xyz;
}
vec3 drw_point_view_to_object(vec3 vP)
{
  return (drw_modelinv() * (drw_view.viewinv * vec4(vP, 1.0))).xyz;
}

vec4 drw_point_object_to_homogenous(vec3 lP)
{
  return (drw_view.winmat * (drw_view.viewmat * (drw_modelmat() * vec4(lP, 1.0))));
}
vec3 drw_point_object_to_ndc(vec3 lP)
{
  return drw_perspective_divide(drw_point_object_to_homogenous(lP));
}

#endif /* DRAW_MODEL_LIB_GLSL */
