#ifdef GPU_VERTEX_SHADER
    #define FRAG_DEPTH float _frag_depth
#else
    #define FRAG_DEPTH gl_FragDepth
#endif

void view_z_get(out float z)
{
#ifndef EEVEE_ENGINE
    return;
#else
    z = abs(viewPosition.z);
#endif
}

void node_set_depth(in Closure _in, in float z_in, out Closure _out)
{
#ifndef EEVEE_ENGINE
    return;
#else
    _out = _in;
    float viewNear = drw_depth_screen_to_view(0.0f);
    float viewFar = drw_depth_screen_to_view(1.0f);
    float z_clipped = max(min(-z_in, viewNear), viewFar);
    FRAG_DEPTH = drw_depth_view_to_screen(z_clipped);
#endif
}

#undef FRAG_DEPTH
